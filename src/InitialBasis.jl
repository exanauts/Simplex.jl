"""
Phase 1 procedues to construct the initial basis.
"""

"""
    This creates a reformulation to begin with all artificial basis.
    This is the simplest way to constrcut the initial basis.
"""
function all_artificial_basis(lp::LpData)
    @assert lp.is_canonical == true

    nrows = lp.nrows
    ncols = lp.ncols + nrows

    # objective coefficient
    c = append!(zeros(lp.ncols), ones(nrows))

    # column bounds
    xl = append!(deepcopy(Array(lp.xl)), zeros(nrows))
    xu = append!(deepcopy(Array(lp.xu)), ones(nrows)*Inf)

    for j = 1:lp.ncols
        if lp.xl[j] > -Inf
            lp.x[j] = lp.xl[j]
        elseif lp.xu[j] < Inf
            lp.x[j] = lp.xu[j]
        else
            @error("Invalid column bounds")
        end
    end

    # rhs
    b = lp.bl .- lp.A * lp.x

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

    return LpData(c, xl, xu, A, Array(lp.bl), Array(lp.bu), Array(lp.x), lp.TArray)
end

function cplex_basis(lp::LpData)
    @assert lp.is_canonical == true
end

function phase_one(prob::LpData; 
    pivot_rule::Int = PIVOT_DANTZIG)::Vector{Int}

    # convert to phase-one form
    p1lp = all_artificial_basis(prob)

    # load the problem
    spx = SpxData(p1lp)
    spx.pivot_rule = deepcopy(pivot_rule)

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

    # Basis should not contain artificial variables.
    # if in(BASIS_BASIC, spx.basis_status[(prob.ncols+1):end])
    #     spx.start_artvars = prob.ncols+1
    #     spx.pivot_rule = PIVOT_ARTIFICIAL
    #     spx.status = STAT_SOLVE
    # end
    # # while in(BASIS_BASIC, spx.basis_status[(prob.ncols+1):end]) && spx.iter <= prob.nrows
    # while spx.status == STAT_SOLVE && spx.iter < prob.nrows
    #     iterate(spx)
    #     println("Iteration $(spx.iter): removed artificial variable $(spx.nonbasic[spx.enter_pos]) from basis (entering variable $(spx.enter))")
    # end
    # spx.pivot_rule = pivot_rule

    if objective(spx) > 1e-6
        prob.status = STAT_INFEASIBLE
        @warn("Infeasible.")
    else
        if in(BASIS_BASIC, spx.basis_status[(prob.ncols+1):end])
            @warn("Could not remove artificial variables from basis... :(")
            prob.status = STAT_INFEASIBLE
        else
            prob.status = STAT_FEASIBLE
            prob.x .= spx.x[1:prob.ncols]
        end
    end
    # @show prob.status
    # @show prob.x
    return spx.basis_status[1:prob.ncols]
end