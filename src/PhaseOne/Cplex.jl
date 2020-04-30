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

    m1_idx = Int[]
    m2_idx = Int[]
    m3_idx = Int[]

    for i = 1:original_lp.nrows
        if original_lp.bl[i] == original_lp.bu[i]
            push!(m3_idx, i)
        elseif original_lp.bl[i] > -Inf
            push!(m2_idx, i)
        elseif original_lp.bu[i] < Inf
            push!(m1_idx, i)
        end
    end
    m1 = length(m1_idx) # number of <= constraints
    m2 = length(m2_idx) # number of >= constraints
    m3 = length(m3_idx) # number of == constraints
    # It is important to have the constraints in the following order: <=, >=, and ==.
    # So we use a permuatation vector.
    perm_A = [m1_idx; m2_idx; m3_idx]
    # @show m1, m2, m3
    
    # penalty
    q = Array{Float64}(undef, original_lp.ncols)

    for j = 1:original_lp.ncols
        if original_lp.xl[j] > -Inf
            if original_lp.xu[j] < Inf
                q[j] = original_lp.xl[j] - original_lp.xu[j]
            else
                q[j] = original_lp.xl[j]
            end
        elseif original_lp.xu[j] < Inf
            q[j] = -original_lp.xu[j]
        else
            q[j] = 0.0
        end
    end

    # @show original_lp.c
    gamma = maximum(abs.(original_lp.c))
    cmax = gamma > 0 ? 1000 * gamma : 1.0
    q .+= original_lp.c / cmax

    # ordered column indices
    C = sortperm(q)
    # @show C, q[C]

    # Step 1
    I = [ones(Int64, m1 + m2); zeros(Int64, original_lp.nrows - m1 - m2)]
    r = [ones(Int64, m1 + m2); zeros(Int64, original_lp.nrows - m1 - m2)]
    v = fill(Inf, original_lp.nrows)
    B = collect(1:(m1+m2)) .+ original_lp.ncols

    # Step 2
    for k = 1:original_lp.ncols
        # Step 2a
        alpha = 0.
        max_l = -1
        for i = 1:original_lp.nrows
            if r[i] == 0
                absA = abs(original_lp.A[perm_A[i],C[k]])
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
            for i = 1:original_lp.nrows
                if abs(original_lp.A[perm_A[i],C[k]]) > 0
                    r[i] += 1
                end
            end
            continue
        end
        # Step 2b
        alpha = 0.
        max_l = -1
        for i = 1:original_lp.nrows
            if abs(original_lp.A[perm_A[i],C[k]]) > 0.01 * v[i]
                continue
            end
            if I[i] == 0
                absA = abs(original_lp.A[perm_A[i],C[k]])
                if alpha < absA
                    alpha = absA
                    max_l = i
                end
            end
        end
        if alpha > 0.0
            push!(B, C[k])
            # println("Step 2b: Adding $(C[k]) to basis")
            I[max_l] = 1
            v[max_l] = alpha
            for i = 1:original_lp.nrows
                if abs(original_lp.A[perm_A[i],C[k]]) > 0
                    r[i] += 1
                end
            end
        end
    end

    # Step 3
    for i = (m1+m2+1):original_lp.nrows
        if I[i] == 0
            push!(B, original_lp.ncols + m1 + m2 + perm_A[i])
            # println("Step 3: Adding $(original_lp.ncols + m1 + m2 + perm_A[i]) to basis")
        end
    end
    # @show length(B), original_lp.nrows, B
    @assert length(B) == original_lp.nrows

    # convert to phase-one form
    p1lp = Artificial.reformulate(lp)

    # load the problem
    spx = Simplex.SpxData(p1lp)
    spx.pivot_rule = deepcopy(pivot_rule)

    # set basis
    Simplex.set_basis(spx, sort(B))

    # Run simplex method
    Simplex.run_core(spx)

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

end
