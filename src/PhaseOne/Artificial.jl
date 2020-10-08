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
    This is the simplest way to construct the initial basis.

    The canonical form

    minimize c x
    subject to
        A x == b
        xl <= x <= xu

    is reformulated to

    minimize a1 + a2
    subject to
        A1 x - a1 == b - A1 xN
        A2 x + a2 == b - A2 xN
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
function reformulate(lp::MatOI.LPSolverForm{T, AT, VT}; basis::Array{Int,1} = Int[]) where {T, AT, VT}

    artif_idx = Int[]
    if length(basis) > 0
        # Add the artifical variables that are identified as basis
        for j in 1:length(basis)
            # if basis indicates an artificial variable,
            if basis[j] > ncols(lp)
                if basis[j] - ncols(lp) > nrows(lp)
                    @error "Invalid basis provided for phase one"
                end
                push!(artif_idx, basis[j])
                basis[j] = ncols(lp) + length(artif_idx)
            end
        end
    else
        # if no basis is provided, return (m+1,...,m+n)
        artif_idx = collect(1:nrows(lp)) .+ ncols(lp)
    end

    nartif = length(artif_idx)
    lp_nrows = nrows(lp)
    lp_ncols = ncols(lp) + nartif
    
    # objective coefficient
    c = append!(zeros(ncols(lp)), ones(nartif))
    c = VT(c)

    # column bounds
    # TODO: build thing directly on GPU
    xl = append!(deepcopy(Array(lp.v_lb)), zeros(nartif))
    xu = append!(deepcopy(Array(lp.v_ub)), fill(Inf, nartif))
    xl = VT(xl)
    xu = VT(xu)

    x = VT(undef, lp_ncols)

    for j = 1:lp_ncols
        if xl[j] > -Inf && abs(xl[j]) <= abs(xu[j])
            x[j] = xl[j]
        elseif xu[j] < Inf && abs(xl[j]) > abs(xu[j])
            x[j] = xu[j]
        else
            x[j] = 0.0
        end
    end

    # rhs
    b = VT(undef, nrows(lp))
    copyto!(b, lp.b .- lp.A * x[1:ncols(lp)])

    # create the submatrix for slack
    I = Array{Int64}(undef, nartif)
    J = collect(1:nartif)
    V = VT(undef, nartif)
    for i = 1:nartif
        I[i] = artif_idx[i] - ncols(lp)
        if b[I[i]] < 0
            V[i] = -1
            x[ncols(lp)+i] = -b[I[i]]
        else
            V[i] = 1
            x[ncols(lp)+i] = b[I[i]]
        end
    end
    S = sparse(I, J, V, lp_nrows, nartif)

    if VT <: Array
        # create the matrix in canonical form
        A = [sparse(Matrix(lp.A)) S]
    elseif VT <: CuArray
        # on GPU
        A = [lp.A Matrix(S)]
    else
        error("Not supported vector type $(VT)")
    end

    artif_col_idx = Int[]
    for j = 1:nartif
        push!(artif_col_idx, ncols(lp)+j)
    end

    senses = fill(MatOI.EQUAL_TO, nrows(lp))
    return MatOI.LPSolverForm{T, typeof(A), typeof(c)}(
        MOI.MIN_SENSE,
        c, A, lp.b, senses, xl, xu
    ), artif_col_idx
end

function run(prob::MatOI.LPSolverForm, Tv::Type; kwargs...)::Simplex.SpxData

    if !haskey(kwargs, :pivot_rule)
        @error "Argument :pivot_rule is not provided."
    end
    pivot_rule = kwargs[:pivot_rule]

    # convert to phase-one form
    p1lp, artif = reformulate(prob)

    # load the problem
    spx = Simplex.SpxData(p1lp, Tv)
    spx.params.pivot_rule = pivot_rule

    # set basis
    basic = collect((ncols(p1lp)-nrows(p1lp)+1):ncols(p1lp))
    Simplex.set_basis(spx, basic)

    # Run simplex method
    Simplex.run_core(spx)

    for j in artif
        spx.lpdata.v_lb[j] = 0.0
        spx.lpdata.v_ub[j] = 0.0
    end
    
    return spx
end

end # module
