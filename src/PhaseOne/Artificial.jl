module Artificial

using CUDA
using LinearAlgebra
using MatrixOptInterface
using SparseArrays

import ..PhaseOne
import Simplex
import Simplex: nrows, ncols

const MatOI = MatrixOptInterface
const MOI = MatOI.MOI

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
function reformulate(lp::MatOI.LPSolverForm{T, AT, VT}) where {T, AT, VT}
    lp_nrows = nrows(lp)
    lp_ncols = ncols(lp) + lp_nrows

    # objective coefficient
    c = append!(zeros(ncols(lp)), ones(lp_nrows))
    c = VT(c)

    # column bounds
    xl = append!(deepcopy(Array(lp.v_lb)), zeros(lp_nrows))
    xu = append!(deepcopy(Array(lp.v_ub)), ones(lp_nrows)*Inf)
    xl = VT(xl)
    xu = VT(xu)

    x = VT(undef, ncols(lp))

    for j = 1:ncols(lp)
        if xl[j] > -Inf
            x[j] = xl[j]
        elseif xu[j] < Inf
            x[j] = xu[j]
        else
            x[j] = 0.0
        end
    end

    # rhs
    b = VT(undef, nrows(lp))
    copyto!(b, lp.b .- lp.A * x)

    # create the submatrix for slack
    I = collect(1:lp_nrows)
    V = VT(undef, lp_nrows)
    for i = 1:lp_nrows
        if b[i] < 0
            V[i] = -1
        else
            V[i] = 1
        end
    end

    if VT <: Array
        S = sparse(I, I, V)
        # create the matrix in canonical form
        A = [sparse(Matrix(lp.A)) S]
    elseif VT <: CuArray
        # on GPU
        A = [lp.A diagm(V)]
    else
        error("Not supported vector type $(VT)")
    end

    senses = fill(MatOI.EQUAL_TO, nrows(lp))
    return MatOI.LPSolverForm{T, typeof(A), typeof(c)}(
        MOI.MIN_SENSE,
        c, A, lp.b, senses, xl, xu)
end

function run(prob::MatOI.LPSolverForm, x::AbstractArray; kwargs...)

    if !haskey(kwargs, :pivot_rule)
        @error "Argument :pivot_rule is not provided."
    end
    pivot_rule = kwargs[:pivot_rule]

    # convert to phase-one form
    p1lp = reformulate(prob)

    # load the problem
    # TODO: quick hack before curating type in SpxData
    T = (typeof(x) <: CuArray) ? CuArray : Array
    spx = Simplex.SpxData(p1lp, T)
    spx.pivot_rule = deepcopy(pivot_rule)

    # set basis
    basic = collect((ncols(p1lp)-nrows(p1lp)+1):ncols(p1lp))
    Simplex.set_basis(spx, basic)

    # Run simplex method
    Simplex.run_core(spx)

    # Basis should not contain artificial variables.
    # if in(BASIS_BASIC, spx.basis_status[(ncols(prob)+1):end])
    #     spx.start_artvars = ncols(prob)+1
    #     spx.pivot_rule = Artificial
    #     spx.status = Solve
    # end
    # # while in(BASIS_BASIC, spx.basis_status[(ncols(prob)+1):end]) && spx.iter <= prob.nrows
    # while spx.status == Solve && spx.iter < prob.nrows
    #     iterate(spx)
    #     println("Iteration $(spx.iter): removed artificial variable $(spx.nonbasic[spx.enter_pos]) from basis (entering variable $(spx.enter))")
    # end
    # spx.pivot_rule = pivot_rule

    if Simplex.objective(spx) > 1e-6
        status = Simplex.Infeasible
        @warn("Infeasible.")
    else
        if in(Simplex.BASIS_BASIC, spx.basis_status[(ncols(prob)+1):end])
            @warn("Could not remove artificial variables from basis... :(")
            status = Simplex.Infeasible
        else
            status = Simplex.Feasible
            x .= spx.x[1:ncols(prob)]
        end
    end
    # @show prob.status
    # @show prob.x
    return status, spx.basis_status[1:ncols(prob)]
end

end # module
