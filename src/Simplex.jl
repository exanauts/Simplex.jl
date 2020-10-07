module Simplex

using SparseArrays
using LinearAlgebra
using Statistics
using MatrixOptInterface
using TimerOutputs
using CUDA

const MatOI = MatrixOptInterface
const MOI = MatOI.MOI

const TO = TimerOutput()

nrows(lp::MatOI.AbstractLPForm{T}) where T = size(lp.A, 1)
ncols(lp::MatOI.AbstractLPForm{T}) where T = size(lp.A, 2)

include("Constant.jl")
include("GLPK.jl")
include("LP.jl")
include("PhaseOne/PhaseOne.jl")

mutable struct SpxData{T<:AbstractArray}
    lpdata::MatOI.AbstractLPForm

    basis_status::Vector{Int}
    basic::Vector{Int}
    nonbasic::Vector{Int}

    # Operation \ may not work with view.
    # view_basic_A     # view of basis matrix
    # view_nonbasic_A  # view of non-basis matrix
    # view_basic_x     # view of basic solution
    # view_nonbasic_x  # view of non-basic solution
    # view_basic_xl    # view of basic column lower bounds
    # view_nonbasic_xl # view of non-basic column lower bounds
    # view_basic_xu    # view of basic column upper bounds
    # view_nonbasic_xu # view of non-basic column upper bounds
    # view_basic_c     # view of basic cost
    # view_nonbasic_c  # view of non-basic cost

    matI::T # identity matrix
    matQ::T # basis updating matrix
    invB::T # inverse basis matrix (dense)
    x::T    # current iterate (solution)
    pB::T   # simplex multiplier
    r::T    # reduced cost
    d::T    # direction

    tl::T # vector for ratio test
    tu::T # vector for ratio test

    enter::Int
    enter_pos::Int
    leave::Int

    update::Bool # whether to update basis or not
    status::Status

    iter::Int
    history::Vector{Vector{Int}}

    pivot_rule::PivotRule

    # steepest-edge pivot only
    gamma::T # steepest-edge weights
    v::T     # B^{-T} d
    s::T     # = r.^2 ./ gamma
    g::T     # invB * A_j

    # start index of the artificial variables
    start_artvars::Int

    function SpxData(lpdata::MatOI.AbstractLPForm{S}, T::Type) where S
        spx = new{T}()
        spx.lpdata = lpdata

        # Check the array type
        if !in(T,[CuArray,Array])
            error("Unkown array type $(T).")
        end

        # spx.view_basic_A = TArray{T,2}(undef, nrows(lpdata), nrows(lpdata))
        # spx.view_nonbasic_A = T{Float64,2}(undef, nrows(lpdata), ncols(lpdata) - nrows(lpdata))
        # spx.view_basic_x = T{Float64}(undef, nrows(lpdata))
        # spx.view_nonbasic_x = T{Float64}(undef, ncols(lpdata) - nrows(lpdata))
        # spx.view_basic_xl = T{Float64}(undef, nrows(lpdata))
        # spx.view_nonbasic_xl = T{Float64}(undef, ncols(lpdata) - nrows(lpdata))
        # spx.view_basic_xu = T{Float64}(undef, nrows(lpdata))
        # spx.view_nonbasic_xu = T{Float64}(undef, ncols(lpdata) - nrows(lpdata))
        # spx.view_basic_c = T{Float64}(undef, nrows(lpdata))
        # spx.view_nonbasic_c = T{Float64}(undef, ncols(lpdata) - nrows(lpdata))

        # DENSE MATRICES
        spx.matI = T{Float64,2}(Matrix(I,nrows(lpdata),nrows(lpdata)))
        spx.matQ = T{Float64,2}(undef, nrows(lpdata), nrows(lpdata))
        spx.invB = T{Float64,2}(undef, nrows(lpdata), nrows(lpdata))

        spx.x = T{Float64}(undef, ncols(lpdata))
        spx.pB = T{Float64}(undef, nrows(lpdata))
        spx.r = T{Float64}(undef, ncols(lpdata) - nrows(lpdata))
        spx.d = T{Float64}(undef, nrows(lpdata))
        spx.tl = T{Float64}(undef, nrows(lpdata))
        spx.tu = T{Float64}(undef, nrows(lpdata))

        # Steepest-edge pivot only
        spx.gamma = T{Float64}(undef, ncols(lpdata) - nrows(lpdata))
        spx.v = T{Float64}(undef, nrows(lpdata))
        spx.s = T{Float64}(undef, ncols(lpdata) - nrows(lpdata))
        spx.g = T{Float64}(undef, nrows(lpdata))

        fill!(spx.matQ, 0)
        fill!(spx.x, 0)

        spx.update = true
        spx.status = Solve
        spx.iter = 1
        spx.history = Vector{Vector{Int}}()

        spx.pivot_rule = Dantzig

        return spx
    end
end

objective(spx::SpxData) = (spx.lpdata.c' * spx.x)
rhs(spx::SpxData) = spx.lpdata.b

function inverse(spx::SpxData)
    @timeit TO "inverse" begin
        # spx.invB .= spx.view_basic_A \ spx.matI
        # @show size(spx.invB), size(spx.lpdata.A), size(spx.matI)
        spx.invB .= spx.lpdata.A[:,spx.basic] \ spx.matI
        # droptol!(spx.invB, 1e-10)
    end
end

function update_inverse_basis(spx::SpxData)
    if spx.iter % 100 > 0
        @timeit TO "PF" begin
            # view_invB_leave = @view spx.invB[spx.leave,:]
            # view_matQ_leave = @view spx.matQ[spx.leave,:]

            # compute Q
            # spx.matQ .= spx.d * view_invB_leave' ./ spx.d[spx.leave]
            # view_matQ_leave .= view_invB_leave .* (1.0 - 1.0 / spx.d[spx.leave])
            spx.matQ .= spx.d * spx.invB[spx.leave,:]' ./ spx.d[spx.leave]
            spx.matQ[spx.leave,:] .= spx.invB[spx.leave,:] .* (1.0 - 1.0 / spx.d[spx.leave])

            # update inverse B
            spx.invB .-= spx.matQ
        end
    else
        inverse(spx)
    end
    # @show mean(spx.invB), var(spx.invB), minimum(spx.invB), maximum(spx.invB)
end

function compute_xB(spx::SpxData)
    @timeit TO "compute xB" begin
        if USE_INVB
            # spx.view_basic_x .= spx.invB * (rhs(spx) .- spx.view_nonbasic_A * spx.view_nonbasic_x)
            spx.x[spx.basic] .= spx.invB * (rhs(spx) .- spx.lpdata.A[:,spx.nonbasic] * spx.x[spx.nonbasic])
        else
            # spx.view_basic_x .= spx.lpdata.A[:,spx.basic] \ (rhs(spx) .- spx.view_nonbasic_A * spx.view_nonbasic_x)
            spx.x[spx.basic] .= spx.lpdata.A[:,spx.basic] \ (rhs(spx) .- spx.lpdata.A[:,spx.nonbasic] * spx.x[spx.nonbasic])
        end
        # @show spx.basic
        # @show spx.x[spx.basic] .- spx.lpdata.v_lb[spx.basic]
        @assert spx.x[spx.basic] >= spx.lpdata.v_lb[spx.basic]
        @assert spx.x[spx.basic] <= spx.lpdata.v_ub[spx.basic]
    end
end

function compute_pB(spx::SpxData)
    @timeit TO "compute pB" begin
        if USE_INVB
            # spx.pB .= transpose(spx.invB) * spx.view_basic_c
            spx.pB .= transpose(spx.invB) * spx.lpdata.c[spx.basic]
        else
            spx.pB .= transpose(spx.lpdata.A[:,spx.basic]) \ spx.lpdata.c[spx.basic]
        end
    end
end

function compute_reduced_cost(spx::SpxData)
    @timeit TO "compute reduced cost" begin
        # spx.r .= spx.view_nonbasic_c .- spx.view_nonbasic_A' * spx.pB
        spx.r .= spx.lpdata.c[spx.nonbasic] .- spx.lpdata.A[:,spx.nonbasic]' * spx.pB
    end
end

function compute_direction(spx::SpxData)
    @timeit TO "compute direction" begin
        if USE_INVB
            spx.d .= spx.invB * spx.lpdata.A[:,spx.enter]
        else
            view_A_enter = @view spx.lpdata.A[:,spx.enter]
            # @show cond(Matrix(spx.lpdata.A[:,spx.basic]))
            spx.d .= spx.lpdata.A[:,spx.basic] \ view_A_enter
        end
    end
end

function compute_entering_variable(spx::SpxData)
    @timeit TO "compute entering variable" begin
        if spx.pivot_rule == Bland
            pivot_Bland(spx)
        elseif spx.pivot_rule == Steepest
            pivot_steepest_edge(spx)
        elseif spx.pivot_rule == Dantzig
            pivot_Dantzig(spx)
        elseif spx.pivot_rule == Artificial
            pivot_to_remove_artificials(spx)
        else
            @error("Invalid pivot rule.")
        end
    end
end

function pivot(spx::SpxData)
    spx.leave = -1
    spx.update = true
    best_t = 0.0

    # compute the direction
    compute_direction(spx)
    # @show norm(spx.d)

    # Terminate with unboundedness
    if norm(spx.d) < EPS
        return
    end

    # ratio test
    @timeit TO "ratio test" begin
        spx.tl .= (spx.x[spx.basic] .- spx.lpdata.v_lb[spx.basic]) ./ spx.d
        spx.tu .= (spx.x[spx.basic] .- spx.lpdata.v_ub[spx.basic]) ./ spx.d
        if spx.r[spx.enter_pos] < 0
            best_t = Inf
            for i = 1:nrows(spx.lpdata)
                if spx.d[i] < -EPS && best_t > spx.tu[i]
                    best_t = spx.tu[i]
                    spx.leave = i
                end
                if spx.d[i] > +EPS && best_t > spx.tl[i]
                    best_t = spx.tl[i]
                    spx.leave = i
                end
            end
            if best_t > spx.lpdata.v_ub[spx.enter] - spx.x[spx.enter] && best_t < Inf
                best_t = spx.lpdata.v_ub[spx.enter] - spx.lpdata.v_lb[spx.enter]
                spx.x[spx.enter] = spx.lpdata.v_ub[spx.enter]
                spx.basis_status[spx.enter] = BASIS_AT_UPPER
                spx.update = false
            end
        elseif spx.r[spx.enter_pos] > 0
            best_t = -Inf
            for i = 1:nrows(spx.lpdata)
                if spx.d[i] < -EPS && best_t < spx.tl[i]
                    best_t = spx.tl[i]
                    spx.leave = i
                end
                if spx.d[i] > +EPS && best_t < spx.tu[i]
                    best_t = spx.tu[i]
                    spx.leave = i
                end
                # if spx.pivot_rule == Artificial && spx.basic[i] < spx.start_artvars
                #     spx.tu[i] = -Inf
                # end
            end
            if best_t < spx.lpdata.v_lb[spx.enter] - spx.x[spx.enter] && best_t > -Inf
                best_t = spx.lpdata.v_lb[spx.enter] - spx.lpdata.v_ub[spx.enter]
                spx.x[spx.enter] = spx.lpdata.v_lb[spx.enter]
                spx.basis_status[spx.enter] = BASIS_AT_LOWER
                spx.update = false
            end
        else
            @error("The reduced cost is zero.")
        end
        @assert spx.leave > 0

        best_t = abs(best_t*spx.d[spx.leave]) < EPS ? 0.0 : best_t
        # @show abs(best_t*spx.d[spx.leave])
        # if abs(best_t) < Inf
        #     best_t = abs(best_t*spx.d[spx.leave]) < EPS ? 0.0 : best_t
        # else
        #     spx.leave = -1
        #     return
        # end
        # @assert abs(spx.d[spx.leave]) >= 1e-8
    end

    # update solution
    # @show spx.x[spx.basic[spx.leave]], spx.lpdata.v_lb[spx.basic[spx.leave]], spx.lpdata.v_ub[spx.basic[spx.leave]]
    spx.x[spx.basic] .-= best_t * spx.d
    # spx.view_basic_x .-= best_t * spx.d
    # @show spx.x[spx.basic[spx.leave]], spx.lpdata.v_lb[spx.basic[spx.leave]], spx.lpdata.v_ub[spx.basic[spx.leave]]
    @assert spx.x[spx.basic[spx.leave]] >= spx.lpdata.v_lb[spx.basic[spx.leave]] - 1e-8
    @assert spx.x[spx.basic[spx.leave]] <= spx.lpdata.v_ub[spx.basic[spx.leave]] + 1e-8
    if spx.update
        spx.x[spx.enter] += best_t
        # @show spx.x[spx.enter], spx.lpdata.v_lb[spx.enter], spx.lpdata.v_ub[spx.enter]
        @assert spx.x[spx.enter] >= spx.lpdata.v_lb[spx.enter] - 1e-8
        @assert spx.x[spx.enter] <= spx.lpdata.v_ub[spx.enter] + 1e-8
    end
end

function detect_cycle(spx::SpxData)
    @timeit TO "detect cycly" begin
        if in(spx.basic, spx.history)
            @info "Cycle is detected."
            spx.status = Cycle
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
    @timeit TO "update basis" begin
        if isapprox(spx.x[spx.basic[spx.leave]], spx.lpdata.v_lb[spx.basic[spx.leave]], atol=1e-6)
            spx.basis_status[spx.basic[spx.leave]] = BASIS_AT_LOWER
            spx.x[spx.basic[spx.leave]] = spx.lpdata.v_lb[spx.basic[spx.leave]]
        elseif isapprox(spx.x[spx.basic[spx.leave]], spx.lpdata.v_ub[spx.basic[spx.leave]], atol=1e-6)
            spx.basis_status[spx.basic[spx.leave]] = BASIS_AT_UPPER
            spx.x[spx.basic[spx.leave]] = spx.lpdata.v_ub[spx.basic[spx.leave]]
        else
            spx.basis_status[spx.basic[spx.leave]] = BASIS_FREE
        end
        spx.basis_status[spx.enter] = BASIS_BASIC

        # update basic/nonbasic indices
        spx.nonbasic[spx.enter_pos] = deepcopy(spx.basic[spx.leave])
        spx.basic[spx.leave] = deepcopy(spx.enter)
        # @show spx.basic
    end

    detect_cycle(spx)

    if USE_INVB
        update_inverse_basis(spx)
    end
end

function iterate(spx::SpxData)
    @timeit TO "One iteration" begin
        if spx.iter % PRINT_ITER_FREQ == 0 && spx.pivot_rule != Artificial
            println("Iteration $(spx.iter): objective $(objective(spx))")
        end

        if spx.update
            compute_pB(spx)
            # @show spx.pB
        end

        compute_entering_variable(spx)

        if spx.enter < 0
            spx.status = Optimal
            return
        end

        pivot(spx)

        if spx.leave < 0
            # spx.status = spx.pivot_rule == Artificial ? Feasible : Unbounded
            spx.status = Unbounded
            return
        end

        # println("Update basis? ", spx.update)

        if spx.update
            if spx.pivot_rule == Steepest
                @timeit TO "compute v" begin
                    # compute v before changing basis
                    spx.v .= transpose(spx.invB) * spx.d
                end
            end

            # println("  Entering/Leaving variables: $(spx.enter), $(spx.basic[spx.leave])")
            update_basis(spx)
        end

        spx.iter += 1
    end
end

function run(prob::MatOI.LPForm{T, AT, VT};
    basis::Vector{Int} = Int[],
    pivot_rule::PivotRule = Dantzig,
    phase_one_method::PhaseOne.Method = PhaseOne.CPLEX,
    gpu = false,
    performance_io::IO = stdout) where {T, AT, VT}

    reset_timer!(TO)
    status = NotSolved

    @timeit TO "run" begin

        @timeit TO "presolve" begin
            presolve_prob = presolve(prob)
        end

        @timeit TO "scaling" begin
            scaling!(presolve_prob)
        end

        # convert the problem into a canonical form
        canonical = Simplex.canonical_form(presolve_prob)

        # Use GPU?
        processed_prob = gpu ? Simplex.cpu2gpu(canonical) : canonical
        TT = gpu ? CuArray : Array

        @timeit TO "run core" begin

            if length(basis) == 0
                println("Phase 1:")

                # Mark the original objective function 
                original_objective = deepcopy(processed_prob.c)
                # @show original_objective

                @timeit TO "Phase 1" begin
                    spx = PhaseOne.run(processed_prob, TT,
                        method = phase_one_method,
                        original_lp = presolve_prob,
                        pivot_rule = pivot_rule)
                end

                status = objective(spx) > 1.e-6 ? Infeasible : Feasible
                println("Phase 1 is done: status $(Symbol(status))")
                if status == Infeasible
                    show(TO)
                    return status
                end

                # Replace back to the original objective function
                spx.lpdata.c .= [original_objective; zeros(length(spx.lpdata.c)-length(original_objective))]
                # @show spx.lpdata.c

                # reset the status
                spx.status = Solve
            else
                println("Basis information is provided.")
                spx = SpxData(processed_prob, TT)
                spx.pivot_rule = pivot_rule
                set_basis(spx, basis)
            end

            @timeit TO "Phase 2" begin
                run_core(spx)
            end

            status = spx.status
            println("Phase 2 is done: status $(Symbol(spx.status))")
            println(performance_io, "Final objective value: $(objective(spx))")
        end # run core

    end # run

    show(performance_io, TO)
    println(performance_io, "")
    return status
end

function run_core(spx::SpxData)
    if USE_INVB
        inverse(spx)
    end
    # @show spx.invB

    compute_xB(spx)
    # @show spx.x

    # main iterations
    my_pivot_rule = spx.pivot_rule
    while spx.status in [Solve, Cycle] && spx.iter < MAX_ITER
        # Use Bland's rule if cycle is detected
        if spx.status == Cycle
            spx.pivot_rule = Bland
        end
        iterate(spx)
        spx.pivot_rule = my_pivot_rule
    end
end

include("Presolve.jl")
include("PivotRules.jl")
include("WarmStart.jl")
# include("utils.jl")

end # module
