"""
CPLEX basis, proposed by Bixby in DOI: 10.1287/ijoc.4.3.267.

Original form:

minimize c x
subject to
-Inf <= A1 x <= b1
  b2 <= A2 x <= Inf
  bl <= A3 x <= bu
  b4 <= A4 x <= b4
  xl <= x <= xu

Canonical form:

minimize c x + 0 s1 + 0 s2 + 0 s3
subjec to
  A1 x + s1 == b1
  A2 x - s2 == b2
  A3 x - s3 == bl
  Ab x      == b4
  xl <= x <= xu
  0 <= s1 <= Inf
  0 <= s2 <= Inf
  0 <= s3 <= bu - bl,

where we treat the constraint bl <= A3 x <= bu as the form A x >= b.
"""

module Cplex

using SparseArrays
import ..PhaseOne
import Simplex

function run(lp::Simplex.LpData; kwargs...)::Vector{Int}

    if !haskey(kwargs, :original_lp)
        @error "Argument :original_lp is not provided."
    end
    if !haskey(kwargs, :pivot_rule)
        @error "Argument :pivot_rule is not provided."
    end
    original_lp = kwargs[:original_lp]
    pivot_rule = kwargs[:pivot_rule]

    # get cplex basis
    B = cplex_basis(original_lp)

    # convert to phase-one form
    p1lp, newB, nartif = reformulate(lp, B)
    @assert size(p1lp.A,1) == length(newB)

    # load the problem
    spx = Simplex.SpxData(p1lp)
    spx.pivot_rule = deepcopy(pivot_rule)

    # set basis
    Simplex.set_basis(spx, newB)
    # spx.x .= p1lp.x

    # Run simplex method
    Simplex.inverse(spx)
    
    Simplex.compute_xB(spx)
    # @show spx.x

    # main iterations
    while spx.status == Simplex.Solve && spx.iter < Simplex.MAX_ITER
        Simplex.iterate(spx)
    end

    if Simplex.objective(spx) > 1e-6
        lp.status = Simplex.Infeasible
        @warn("Infeasible.")
    else
        if in(Simplex.BASIS_BASIC, spx.basis_status[collect(1:nartif).+lp.ncols])
            @warn("Could not remove artificial variables from basis... :(")
            lp.status = Simplex.Infeasible
        else
            lp.status = Simplex.Feasible
            lp.x .= spx.x[1:lp.ncols]
            # set the correct basis information
            @show spx.basis_status[1:lp.ncols]
            for (j,s) in enumerate(spx.basis_status[1:lp.ncols])
                if s != Simplex.BASIS_FREE
                    continue
                elseif lp.x[j] == lp.xl[j]
                    spx.basis_status[j] = Simplex.BASIS_AT_LOWER
                elseif lp.x[j] == lp.xu[j]
                    spx.basis_status[j] = Simplex.BASIS_AT_UPPER
                end
            end
            @show spx.basis_status[1:lp.ncols]
        end
    end
    
    return spx.basis_status[1:lp.ncols]
end

function cplex_basis(lp::Simplex.LpData)::Array{Int64}

    m1_idx = Int[]
    m2_idx = Int[]
    m3_idx = Int[]

    for i = 1:lp.nrows
        if lp.bl[i] == lp.bu[i]
            push!(m3_idx, i)
        elseif lp.bl[i] > -Inf
            push!(m2_idx, i)
        elseif lp.bu[i] < Inf
            push!(m1_idx, i)
        end
    end
    m1 = length(m1_idx) # number of <= constraints
    m2 = length(m2_idx) # number of >= constraints
    m3 = length(m3_idx) # number of == constraints
    # It is important to have the constraints in the following order: <=, >=, and ==.
    # So we use a permuatation vector.
    perm_A = [m1_idx; m2_idx; m3_idx]
    @assert perm_A == collect(1:lp.nrows)
    
    C2 = Int[] # free
    C3 = Int[] # single bounded
    C4 = Int[] # bounded

    # penalty
    q = Array{Float64}(undef, lp.ncols)

    for j = 1:lp.ncols
        if lp.xl[j] > -Inf
            if lp.xu[j] < Inf
                push!(C4, j)
                q[j] = lp.xl[j] - lp.xu[j]
            else
                push!(C3, j)
                q[j] = lp.xl[j]
            end
        elseif lp.xu[j] < Inf
            push!(C3, j)
            q[j] = -lp.xu[j]
        else
            push!(C2, j)
            q[j] = 0.0
        end
    end

    # @show lp.c
    gamma = maximum(abs.(lp.c))
    cmax = gamma > 0 ? 1000 * gamma : 1.0
    q .+= lp.c / cmax

    # sort C2, C3, C4 by q
    sort!(C2, by = x -> q[x])
    sort!(C3, by = x -> q[x])
    sort!(C4, by = x -> q[x])

    # ordered column indices
    C = [C2; C3; C4]

    # Step 1
    I = [ones(Int64, m1 + m2); zeros(Int64, lp.nrows - m1 - m2)]
    r = [ones(Int64, m1 + m2); zeros(Int64, lp.nrows - m1 - m2)]
    v = fill(Inf, lp.nrows)
    B = collect(1:(m1+m2)) .+ lp.ncols
    # @show B

    # Step 2
    for k = 1:lp.ncols
        # Step 2a
        alpha = 0.
        max_l = -1
        for i = 1:lp.nrows
            if r[i] == 0
                absA = abs(lp.A[i,C[k]])
                if alpha < absA
                    alpha = absA
                    max_l = i
                end
            end
        end
        if alpha >= 0.99
            push!(B, C[k])
            # println("Step 2a: Adding $(C[k]) to basis")
            I[max_l] = 1
            v[max_l] = alpha
            for i = 1:lp.nrows
                if abs(lp.A[i,C[k]]) > 0
                    r[i] += 1
                end
            end
            continue
        end
        # Step 2b
        alpha = 0.
        max_l = -1
        next_k = false
        for i = 1:lp.nrows
            if abs(lp.A[i,C[k]]) > 0.01 * v[i]
                next_k = true
                break
            end
            if I[i] == 0
                absA = abs(lp.A[i,C[k]])
                if alpha < absA
                    alpha = absA
                    max_l = i
                end
            end
        end
        if next_k
            continue
        end
        if alpha > 0.0
            push!(B, C[k])
            # println("Step 2b: Adding $(C[k]) to basis")
            I[max_l] = 1
            v[max_l] = alpha
            for i = 1:lp.nrows
                if abs(lp.A[i,C[k]]) > 0
                    r[i] += 1
                end
            end
        end
    end

    # Step 3
    for i = (m1+m2+1):lp.nrows
        if I[i] == 0
            push!(B, lp.ncols + m1 + m2 + i)
            # println("Step 3: Adding $(lp.ncols + m1 + m2 + i) to basis")
        end
    end
    @assert length(B) == lp.nrows

    return sort(B)
end

"""
    Input: 
    minimize c x
    subject to
        A x == b
        xl <= x <= xu

    Output:
    minimize a + sl + su
    subject to
        A x + d a == b
        x + sl - sl2 == xl (nxl)
        x - su + su2 == xu (nxu)
        a, sl, sl2, su, su2 >= 0,

    where 
        d_i = +1 if b_i - A_i xN > 0,
        d_i = -1 otherwise.
"""
function reformulate(lp::Simplex.LpData, basis::Array{Int,1})
    @assert lp.is_canonical == true
    @assert length(basis) == lp.nrows

    # count artifical variables
    artif_idx = Int[]
    for j in 1:length(basis)
        if basis[j] > lp.ncols
            push!(artif_idx, basis[j])
            basis[j] = lp.ncols + length(artif_idx)
        end
    end
    nartif = length(artif_idx)

    # count slacks for column bounds
    xl_idx = Int[]
    xu_idx = Int[]
    for j in 1:lp.ncols
        if lp.xl[j] > -Inf
            push!(xl_idx, j)
        end
        if lp.xu[j] < Inf
            push!(xu_idx, j)
        end
    end
    nxl = length(xl_idx)
    nxu = length(xu_idx)
    nslacks = 2 * (nxl + nxu)

    # nonbasic indices
    nb_idx = Int[]
    for j in 1:lp.ncols
        if !in(j, basis)
            push!(nb_idx, j)
        end
    end
    
    naux = nartif + nslacks # number of auxiliary variables
    nrows = lp.nrows + nxl + nxu # number of rows
    ncols = lp.ncols + naux # number of columns
    
    # objective coefficient
    c = [zeros(lp.ncols); ones(nartif + nxl + nxu); zeros(nxl + nxu)]

    # column bounds
    xl = [fill(-Inf, lp.ncols); zeros(naux)]
    xu = fill(Inf, ncols)

    # solution x
    x = zeros(ncols)
    for j = 1:lp.ncols
        if lp.xl[j] > -Inf && abs(lp.xl[j]) <= abs(lp.xu[j])
            x[j] = lp.xl[j]
        elseif lp.xu[j] < Inf && abs(lp.xl[j]) > abs(lp.xu[j])
            x[j] = lp.xu[j]
        end
    end
    for j in basis
        x[j] = 0.0
    end

    # rhs
    bN = Array{Float64}(undef, lp.nrows)
    copyto!(bN, lp.bl .- lp.A[:,nb_idx] * x[nb_idx])
    b = [lp.bl; Array(lp.xl[xl_idx]); Array(lp.xu[xu_idx])]

    # create the submatrix for artificial and slack variables
    I = Array{Int64}(undef, naux)
    J = collect(1:naux)
    V = Array{Float64}(undef, naux)
    pos = 1
    for i = 1:nartif
        I[pos] = artif_idx[i] - lp.ncols
        if bN[I[i]] < 0
            V[pos] = -1
            x[lp.ncols+i] = -bN[I[i]]
        else
            V[pos] = 1
            x[lp.ncols+i] = bN[I[i]]
        end
        pos += 1
    end
    # sl
    for i = 1:nxl
        I[pos] = lp.nrows + i
        V[pos] = 1
        pos += 1
    end
    # su
    for i = 1:nxu
        I[pos] = lp.nrows + nxl + i
        V[pos] = -1
        pos += 1
    end
    # sl2
    for i = 1:nxl
        I[pos] = lp.nrows + i
        V[pos] = -1
        pos += 1
    end
    # su2
    for i = 1:nxu
        I[pos] = lp.nrows + nxl + i
        V[pos] = 1
        pos += 1
    end
    S = sparse(I, J, V, nrows, naux)

    # create the matrix in canonical form
    A = [[sparse(Matrix(lp.A)); 
        sparse(collect(1:nxl), xl_idx, ones(nxl), nxl, lp.ncols); 
        sparse(collect(1:nxu), xu_idx, ones(nxu), nxu, lp.ncols)] S]

    p1lp = Simplex.LpData(c, xl, xu, A, b, b, x, lp.TArray)
    p1lp.is_canonical = true

    ## Basis should be carefully chosen.

    # additional basis
    # additional_basis = collect(1:(nxl+nxu)) .+ (lp.ncols + nartif + nxl + nxu)
    additional_basis = collect(1:(nxl+nxu)) .+ (lp.ncols + nartif)
    @show additional_basis

    return p1lp, [basis; additional_basis], nartif
end

end
