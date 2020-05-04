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

import ..PhaseOne
import ..Artificial
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

    # No artificial variable is needed.
    if maximum(B) <= lp.ncols
        basis_status = Array{Int}(undef, lp.ncols)
        for j = 1:lp.ncols
            axl = abs(lp.xl[j])
            axu = abs(lp.xu[j])
            if in(j, B)
                basis_status[j] = Simplex.BASIS_BASIC
                lp.x[j] = 0.0
            elseif lp.xl[j] > -Inf && axl <= axu
                basis_status[j] = Simplex.BASIS_AT_LOWER
                lp.x[j] = lp.xl[j]
            elseif lp.xu[j] < Inf && axl > axu
                basis_status[j] = Simplex.BASIS_AT_UPPER
                lp.x[j] = lp.xu[j]
            else
                basis_status[j] = Simplex.BASIS_FREE
                lp.x[j] = 0.0
            end
        end
        lp.status = Simplex.Feasible
        return basis_status
    end

    # convert to phase-one form
    p1lp = Artificial.reformulate(lp, basis = B)
    @assert length(p1lp.c) >= maximum(B)

    # load the problem
    spx = Simplex.SpxData(p1lp)
    spx.pivot_rule = deepcopy(pivot_rule)

    # set basis
    Simplex.set_basis(spx, B)
    # spx.x .= p1lp.x

    # Run simplex method
    Simplex.inverse(spx)
    
    Simplex.compute_xB(spx)
    # @show spx.x

    # main iterations
    while spx.status == Simplex.Solve && spx.iter < Simplex.MAX_ITER
        Simplex.iterate(spx)
        # if Simplex.objective(spx) <= 1e-6
        #     break
        # end
    end

    if Simplex.objective(spx) > 1e-6
        lp.status = Simplex.Infeasible
        @warn("Infeasible.")
    else
        if in(Simplex.BASIS_BASIC, spx.basis_status[(lp.ncols+1):end])
            @warn("Could not remove artificial variables from basis... :(")
            lp.status = Simplex.Infeasible
        else
            lp.status = Simplex.Feasible
            lp.x .= spx.x[1:lp.ncols]
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
    # @show C, q[C]

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

end
