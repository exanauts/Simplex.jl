module Artificial

using CuArrays
using SparseArrays

import ..PhaseOne
import Simplex

"""
    This creates a reformulation to begin with all artificial basis.
    This is the simplest way to constrcut the initial basis.

    The canonical form

    minimize c x
    subject to 
        A x == b
        xl <= x <= xu

    is reformulated to

    minimize a1
    subject to
        A1 x - a1 == b - A1 xN
        A1 x + a2 == b - A1 xN
        xl <= x <= xu
        0 <= a1 <= Inf
        0 <= a2 <= Inf,

    where 
        if xl[j] > -Inf
            xN[j] = xl[j]
        elseif xu[j] < Inf
            xN[j] = xu[j]
        else
            xN[j] = 0.0
        end
"""
function reformulate(lp::Simplex.LpData)
    @assert lp.is_canonical == true

    nrows = lp.nrows
    ncols = lp.ncols + nrows

    # objective coefficient
    c = append!(zeros(lp.ncols), ones(nrows))

    # column bounds
    xl = append!(deepcopy(Array(lp.xl)), zeros(nrows))
    xu = append!(deepcopy(Array(lp.xu)), ones(nrows)*Inf)

    # cpu memory
    if lp.TArray == Array
        x = lp.x
    elseif lp.TArray == CuArray
        x = Array{Float64}(undef, lp.ncols)
    end

    for j = 1:lp.ncols
        if xl[j] > -Inf
            x[j] = xl[j]
        elseif xu[j] < Inf
            x[j] = xu[j]
        else
            x[j] = 0.0
        end
    end

    # copy
    if lp.TArray == Array
        lp.x = x
    elseif lp.TArray == CuArray
        copyto!(lp.x, x)
    end

    # rhs
    b = Array{Float64}(undef, lp.nrows)
    copyto!(b, lp.bl .- lp.A * lp.x)

    # create the submatrix for slack
    I = collect(1:nrows)
    V = Array{Float64}(undef, nrows)
    for i = 1:nrows
        if b[i] < 0
            V[i] = -1
        else
            V[i] = 1
        end
    end
    S = sparse(I, I, V)

    # create the matrix in canonical form
    A = [sparse(Matrix(lp.A)) S]

    return Simplex.LpData(c, xl, xu, A, Array(lp.bl), Array(lp.bu), Array(lp.x), lp.TArray)
end

function run(prob::Simplex.LpData; kwargs...)::Vector{Int}

    if !haskey(kwargs, :pivot_rule)
        @error "Argument :pivot_rule is not provided."
    end
    pivot_rule = kwargs[:pivot_rule]

    # convert to phase-one form
    p1lp = reformulate(prob)

    # load the problem
    spx = Simplex.SpxData(p1lp)
    spx.pivot_rule = deepcopy(pivot_rule)

    # set basis
    basic = collect((p1lp.ncols-p1lp.nrows+1):p1lp.ncols)
    Simplex.set_basis(spx, basic)

    # Run simplex method
    Simplex.run_core(spx)

    # Basis should not contain artificial variables.
    # if in(BASIS_BASIC, spx.basis_status[(prob.ncols+1):end])
    #     spx.start_artvars = prob.ncols+1
    #     spx.pivot_rule = Artificial
    #     spx.status = Solve
    # end
    # # while in(BASIS_BASIC, spx.basis_status[(prob.ncols+1):end]) && spx.iter <= prob.nrows
    # while spx.status == Solve && spx.iter < prob.nrows
    #     iterate(spx)
    #     println("Iteration $(spx.iter): removed artificial variable $(spx.nonbasic[spx.enter_pos]) from basis (entering variable $(spx.enter))")
    # end
    # spx.pivot_rule = pivot_rule

    if Simplex.objective(spx) > 1e-6
        prob.status = Simplex.Infeasible
        @warn("Infeasible.")
    else
        if in(Simplex.BASIS_BASIC, spx.basis_status[(prob.ncols+1):end])
            @warn("Could not remove artificial variables from basis... :(")
            prob.status = Simplex.Infeasible
        else
            prob.status = Simplex.Feasible
            prob.x .= spx.x[1:prob.ncols]
        end
    end
    # @show prob.status
    # @show prob.x
    return spx.basis_status[1:prob.ncols]
end

end # module