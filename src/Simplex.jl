module Simplex

using SparseArrays
using LinearAlgebra
using Statistics
using Memento
using TimerOutputs

TO = TimerOutput()

LOGGER = Memento.config!("debug"; fmt="[{level} | {name}]: {msg}")

const USE_INVB = true

const INF = 1.0e+20
const EPS = 1e-6

const MAX_ITER = 30000000
const MAX_HISTORY = 100

const STAT_NOT_SOLVED = 0
const STAT_SOLVE = 1
const STAT_OPTIMAL = 2
const STAT_UNBOUNDED = 3
const STAT_INFEASIBLE = 4
const STAT_FEASIBLE = 5
const STAT_CYCLE = 6

include("GLPK.jl")
include("LP.jl")

const BASIS_BASIC = 1
const BASIS_AT_LOWER = 2
const BASIS_AT_UPPER = 3
const BASIS_FREE = 4

const PIVOT_BLAND = 0
const PIVOT_STEEPEST = 1
const PIVOT_DANTZIG = 2

mutable struct SpxData{T<:Number}
    lpdata::LpData

    basis_status::Vector{Int}
    basic::Vector{Int}
    nonbasic::Vector{Int}

    # invB::Matrix{T}
    invB::SparseMatrixCSC{T,Int}
    x::Vector{T}
    pB::Vector{T}
    r::Vector{T} # reduced cost

    d::Vector{T}
    enter::Int
    enter_pos::Int
    leave::Int

    update::Bool # whether to update basis or not
    status::Int

    iter::Int
    history::Vector{Vector{Int}}

    pivot_rule::Int

    gamma::Vector{T} # steepest-edge weights
    v::Vector{T} # B^{-T} d

    function SpxData(lpdata::LpData{T}) where T
        spx = new{T}()
        spx.lpdata = lpdata
        spx.update = true
        spx.status = STAT_SOLVE
        spx.iter = 1
        spx.x = zeros(spx.lpdata.ncols)
        spx.history = Vector{Vector{Int}}()
        spx.r = Vector{T}(undef, spx.lpdata.ncols - spx.lpdata.nrows)

        spx.pivot_rule = PIVOT_STEEPEST

        return spx
    end
end

objective(spx::SpxData) = (spx.lpdata.c' * spx.x)

function inverse(spx::SpxData)
    @timeit TO "inverse" begin
        # @show cond(Matrix(spx.lpdata.A[:,spx.basic]))
        spx.invB = sparse(inv(Matrix(spx.lpdata.A[:,spx.basic])))
        droptol!(spx.invB, 1e-10)
    end
end

function update_inverse_basis(spx::SpxData)
    if spx.iter % 100 > 0
        @timeit TO "PF" begin
            # compute Q
            I = repeat(collect(1:spx.lpdata.nrows), 2)
            J = [ones(Int,spx.lpdata.nrows)*spx.leave; collect(1:spx.lpdata.nrows)]
            V = Vector{Float64}(undef, spx.lpdata.nrows)
            Threads.@threads for i = 1:spx.lpdata.nrows
                @inbounds V[i] = -spx.d[i]/spx.d[spx.leave];
                # @inbounds Q[i,spx.leave] = -spx.d[i]/spx.d[spx.leave]
            end
            append!(V, ones(spx.lpdata.nrows))
            Q = sparse(I, J, V)
            Q[spx.leave,spx.leave] = 1.0/spx.d[spx.leave]

            # update inverse B
            spx.invB = Q * spx.invB
        end
    else
        inverse(spx)
    end
    # @show mean(spx.invB), var(spx.invB), minimum(spx.invB), maximum(spx.invB)
end

function compute_xB(spx::SpxData)
    ANxN = spx.lpdata.A[:,spx.nonbasic] * spx.x[spx.nonbasic]
    if USE_INVB
        spx.x[spx.basic] = spx.invB * (spx.lpdata.bl - ANxN)
    else
        spx.x[spx.basic] = spx.lpdata.A[:,spx.basic] \ (spx.lpdata.bl - ANxN)
    end
end

function compute_pB(spx::SpxData)
    @timeit TO "compute pB" begin
        if USE_INVB
            spx.pB = transpose(spx.invB) * spx.lpdata.c[spx.basic]
        else
            AT = transpose(spx.lpdata.A[:,spx.basic])
            spx.pB = AT \ spx.lpdata.c[spx.basic]
        end
    end
end

function compute_reduced_cost(spx::SpxData)
    @timeit TO "compute reduced cost" begin
        Threads.@threads for j in 1:length(spx.nonbasic)
            @inbounds spx.r[j] = spx.lpdata.c[spx.nonbasic[j]] - spx.lpdata.A[:,spx.nonbasic[j]]' * spx.pB
        end
    end
end

function compute_direction(spx::SpxData)
    @timeit TO "compute direction" begin
        if USE_INVB
            spx.d = spx.invB * spx.lpdata.A[:,spx.enter]
        else
            B = spx.lpdata.A[:,spx.basic]
            # @show cond(Matrix(B))
            Ae = Vector(spx.lpdata.A[:,spx.enter])
            spx.d = B \ Ae
        end
    end
end

function compute_entering_variable(spx::SpxData)
    @timeit TO "compute entering variable" begin
        if spx.pivot_rule == PIVOT_BLAND
            pivot_Bland(spx)
        elseif spx.pivot_rule == PIVOT_STEEPEST
            pivot_steepest_edge(spx)
        elseif spx.pivot_rule == PIVOT_DANTZIG
            pivot_Dantzig(spx)
        end
    end
end

function pivot(spx::SpxData)
    spx.leave = -1
    spx.update = true
    
    # compute the direction
    compute_direction(spx)
    # @show spx.d
    # @show norm(spx.d)

    # Terminate with unboundedness
    if norm(spx.d) < EPS
        return
    end

    # ratio test
    @timeit TO "ratio test" begin
        tl = (spx.x[spx.basic] - spx.lpdata.xl[spx.basic]) ./ spx.d
        tu = (spx.x[spx.basic] - spx.lpdata.xu[spx.basic]) ./ spx.d
        # @show spx.basis_status[spx.enter], spx.x[spx.enter], spx.lpdata.xl[spx.enter], spx.lpdata.xu[spx.enter]
        # @show minimum(spx.d), maximum(spx.d)
        if spx.basis_status[spx.enter] == BASIS_AT_LOWER
            t = tu
            for i = 1:spx.lpdata.nrows
                if abs(spx.d[i]) < EPS
                    t[i] = Inf
                elseif spx.d[i] > 0
                    t[i] = tl[i]
                end
            end
            spx.leave = argmin(t)
            if t[spx.leave] > spx.lpdata.xu[spx.enter] - spx.x[spx.enter]
                t[spx.leave] = spx.lpdata.xu[spx.enter] - spx.lpdata.xl[spx.enter]
                spx.x[spx.enter] = spx.lpdata.xu[spx.enter]
                spx.basis_status[spx.enter] = BASIS_AT_UPPER
                spx.update = false
            end
        else
            t = tu
            for i = 1:spx.lpdata.nrows
                if abs(spx.d[i]) < EPS
                    t[i] = -Inf
                elseif spx.d[i] < 0
                    t[i] = tl[i]
                end
            end
            spx.leave = argmax(t)
            if t[spx.leave] < spx.lpdata.xl[spx.enter] - spx.x[spx.enter]
                t[spx.leave] = spx.lpdata.xl[spx.enter] - spx.lpdata.xu[spx.enter]
                spx.x[spx.enter] = spx.lpdata.xl[spx.enter]
                spx.basis_status[spx.enter] = BASIS_AT_LOWER
                spx.update = false
            end
        end

        # @show abs(t[spx.leave]*spx.d[spx.leave])
        t[spx.leave] = abs(t[spx.leave]*spx.d[spx.leave]) < EPS ? 0.0 : t[spx.leave]
        @assert abs(spx.d[spx.leave]) >= 1e-8
        # @show t[spx.leave], spx.d[spx.leave]
    end

    # update solution
    # @show t[spx.leave], spx.d[spx.leave]
    # @show spx.x[spx.basic[spx.leave]], spx.lpdata.xl[spx.basic[spx.leave]], spx.lpdata.xu[spx.basic[spx.leave]]
    spx.x[spx.basic] = spx.x[spx.basic] - t[spx.leave] * spx.d
    # @show spx.x[spx.basic[spx.leave]], spx.lpdata.xl[spx.basic[spx.leave]], spx.lpdata.xu[spx.basic[spx.leave]]
    @assert spx.x[spx.basic[spx.leave]] >= spx.lpdata.xl[spx.basic[spx.leave]] - 1e-8
    @assert spx.x[spx.basic[spx.leave]] <= spx.lpdata.xu[spx.basic[spx.leave]] + 1e-8
    if spx.update
        spx.x[spx.enter] = spx.x[spx.enter] + t[spx.leave]
        # @show spx.x[spx.enter], spx.lpdata.xl[spx.enter], spx.lpdata.xu[spx.enter]
        @assert spx.x[spx.enter] >= spx.lpdata.xl[spx.enter] - 1e-8
        @assert spx.x[spx.enter] <= spx.lpdata.xu[spx.enter] + 1e-8
    end
end

function detect_cycle(spx::SpxData)
    @timeit TO "detect cycly" begin
        if in(spx.basic, spx.history)
            @warn("Cycle is detected.\n")
            spx.status = STAT_CYCLE
        end
        if length(spx.history) == MAX_HISTORY
            pop!(spx.history)
        end
        push!(spx.history, deepcopy(spx.basic))
    end
end

function update_basis(spx::SpxData)
    @assert spx.d[spx.leave] != 0

    # update basis status
    if isapprox(spx.x[spx.basic[spx.leave]], spx.lpdata.xl[spx.basic[spx.leave]], atol=1e-6)
        spx.basis_status[spx.basic[spx.leave]] = BASIS_AT_LOWER
        spx.x[spx.basic[spx.leave]] = spx.lpdata.xl[spx.basic[spx.leave]]
    elseif isapprox(spx.x[spx.basic[spx.leave]], spx.lpdata.xu[spx.basic[spx.leave]], atol=1e-6)
        spx.basis_status[spx.basic[spx.leave]] = BASIS_AT_UPPER
        spx.x[spx.basic[spx.leave]] = spx.lpdata.xu[spx.basic[spx.leave]]
    else
        spx.basis_status[spx.basic[spx.leave]] = BASIS_FREE
    end
    spx.basis_status[spx.enter] = BASIS_BASIC

    # update basic/nonbasic indices
    spx.nonbasic[spx.enter_pos] = deepcopy(spx.basic[spx.leave])
    spx.basic[spx.leave] = deepcopy(spx.enter)
    # @show spx.basic

    detect_cycle(spx)

    if USE_INVB
        update_inverse_basis(spx)
    end
end

function iterate(spx::SpxData)
    println("Iteration $(spx.iter): objective $(objective(spx))")

    if spx.update
        compute_pB(spx)
        # @show spx.pB
    end

    compute_entering_variable(spx)

    if spx.enter < 0
        spx.status = STAT_OPTIMAL
        return
    end

    pivot(spx)

    if spx.leave < 0
        spx.status = STAT_UNBOUNDED
        return
    end

    # println("Update basis? ", spx.update)

    if spx.update
        if spx.pivot_rule == PIVOT_STEEPEST
            @timeit TO "compute v" begin
                # compute v before changing basis
                spx.v = transpose(spx.invB) * spx.d
            end
        end

        # println("  Entering/Leaving variables: $(spx.enter), $(spx.basic[spx.leave])")
        update_basis(spx)
    end

    spx.iter += 1
end

function phase_one(prob::LpData; 
    pivot_rule::Int = PIVOT_STEEPEST)::Vector{Int}

    # convert to phase-one form
    p1lp = phase_one_form(prob)
    summary(p1lp)

    # load the problem
    spx = SpxData(p1lp)
    spx.pivot_rule = pivot_rule

    # set basis
    basic = collect((p1lp.ncols-p1lp.nrows+1):p1lp.ncols)
    set_basis(spx, basic)

    # The inverse basis matrix is an identity matrix.
    inverse(spx)
        
    # compute basic solution
    compute_xB(spx)

    # main iterations
    while spx.status == STAT_SOLVE && spx.iter < MAX_ITER
        iterate(spx)
    end

    if objective(spx) > 1e-6
        prob.status = STAT_INFEASIBLE
        @warn("Infeasible.")
    else
        prob.status = STAT_FEASIBLE
        prob.x = spx.x[1:prob.ncols]
        @assert !in(BASIS_BASIC, spx.basis_status[(prob.ncols+1):end])
    end
    # @show prob.status
    # @show prob.x
    return spx.basis_status[1:prob.ncols]
end

function run(prob::LpData; 
    basis::Vector{Int} = Int[],
    pivot_rule::Int = PIVOT_STEEPEST)

    @timeit TO "presolve" begin
        presolve(prob)
    end

    # convert the problem into a canonical form
    canonical = Simplex.canonical_form(prob)

    @timeit TO "scaling" begin
        scaling(canonical)
    end

    # load the problem
    spx = SpxData(canonical)
    spx.pivot_rule = pivot_rule
    # summary(canonical)

    if length(basis) == 0
        println("Phase 1:")
        basis_status = phase_one(canonical, pivot_rule = pivot_rule)

        if canonical.status == STAT_FEASIBLE
            set_basis_status(spx, basis_status)
            # @show length(spx.basic), length(spx.nonbasic)
            # @show spx.basis_status
        else
            show(TO)
            return
        end
    else
        println("Basis information is provided.")
        set_basis(spx, basis)
    end

    if USE_INVB
        inverse(spx)
    end
    # @show spx.invB
    
    compute_xB(spx)
    # @show spx.x

    # main iterations
    while spx.status == STAT_SOLVE && spx.iter < MAX_ITER
        iterate(spx)
    end

    show(TO)
end

include("Presolve.jl")
include("PivotRules.jl")
include("WarmStart.jl")
include("utils.jl")

end # module
