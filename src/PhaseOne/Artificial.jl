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
function reformulate(lp::Simplex.LpData; basis::Array{Int,1} = Int[])
    @assert lp.is_canonical == true

    artif_idx = Int[]
    if length(basis) > 0
        for j in 1:length(basis)
            if basis[j] > lp.ncols
                push!(artif_idx, basis[j])
                basis[j] = lp.ncols + length(artif_idx)
            end
        end
    else
        artif_idx = collect(1:lp.nrows) .+ lp.ncols
    end

    nartif = length(artif_idx)
    nrows = lp.nrows
    ncols = lp.ncols + nartif
    
    # objective coefficient
    c = append!(zeros(lp.ncols), ones(nartif))

    # column bounds
    xl = append!(deepcopy(Array(lp.xl)), zeros(nartif))
    xu = append!(deepcopy(Array(lp.xu)), fill(Inf, nartif))

    # solution x
    x = Array{Float64}(undef, ncols)
    for j = 1:lp.ncols
        if xl[j] > -Inf && abs(xl[j]) <= abs(xu[j])
            x[j] = xl[j]
        elseif xu[j] < Inf && abs(xl[j]) > abs(xu[j])
            x[j] = xu[j]
        else
            x[j] = 0.0
        end
    end
    # for j in basis
    #     x[j] = 0.0
    # end

    # rhs
    b = Array{Float64}(undef, lp.nrows)
    copyto!(b, lp.bl .- lp.A * x[1:lp.ncols])

    # create the submatrix for slack
    I = Array{Int64}(undef, nartif)
    J = collect(1:nartif)
    V = Array{Float64}(undef, nartif)
    for i = 1:nartif
        I[i] = artif_idx[i] - lp.ncols
        if b[I[i]] < 0
            V[i] = -1
            x[lp.ncols+i] = -b[I[i]]
        else
            V[i] = 1
            x[lp.ncols+i] = b[I[i]]
        end
    end
    S = sparse(I, J, V, nrows, nartif)

    # create the matrix in canonical form
    A = [sparse(Matrix(lp.A)) S]

    p1lp = Simplex.LpData(c, xl, xu, A, Array(lp.bl), Array(lp.bu), x, lp.TArray)
    p1lp.is_canonical = true

    return p1lp
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
    elseif in(Simplex.BASIS_BASIC, spx.basis_status[(prob.ncols+1):end])
        prob.status = Simplex.Infeasible
        @warn("Could not remove artificial variables from basis... :(")
    else
        prob.status = Simplex.Feasible
        prob.x .= spx.x[1:prob.ncols]
    end
    # @show prob.status
    # @show prob.x
    return spx.basis_status[1:prob.ncols]
end

end # module