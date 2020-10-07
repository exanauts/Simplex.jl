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

using MatrixOptInterface
using SparseArrays
import ..PhaseOne
import ..Artificial
import Simplex
import Simplex: nrows, ncols

const MatOI = MatrixOptInterface
const MOI = MatOI.MOI

function run(lp::MatOI.LPSolverForm, Tv::Type; kwargs...)::Simplex.SpxData

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

    # add artificial variables that are identified in basis
    cpxlp, cpxartif = Artificial.reformulate(lp, basis = B)

    # compute solution x (maybe infeasible)
    x, is_feasible = compute_x(cpxlp, B)

    # number of canonical variables and artificial variables
    num_orgvars = ncols(lp)
    num_artif = ncols(cpxlp) - num_orgvars
    # @show num_orgvars, num_artif

    # If x is infeasible, we need to solve a piecewise LP.
    p1artif = Int[]
    if !is_feasible
        # @warn("CPLEX initial basis solution is infeasible.")
        # convert to phase-one form
        cpxlp, B, p1artif = reformulate(cpxlp, x, num_orgvars, num_artif, B)
        @assert size(cpxlp.A,1) == length(B)
    end

    # load the problem
    spx = Simplex.SpxData(cpxlp, Tv)
    spx.pivot_rule = deepcopy(pivot_rule)

    # set basis
    Simplex.set_basis(spx, B)

    # Run simplex method
    Simplex.run_core(spx)

    # restore the original column bounds
    # for j in 1:ncols(cpxlp)
    #     spx.lpdata.v_lb[j] = cpxlp.v_lb[j]
    #     spx.lpdata.v_ub[j] = cpxlp.v_ub[j]
    # end

    for j in [cpxartif; p1artif]
        spx.lpdata.v_lb[j] = 0.0
        spx.lpdata.v_ub[j] = 0.0
    end
    
    return spx
end

function cplex_basis(lp::MatOI.LPForm)::Array{Int64}

    m1_idx = Int[]
    m2_idx = Int[]
    m3_idx = Int[]

    for i = 1:nrows(lp)
        if lp.c_lb[i] == lp.c_ub[i]
            push!(m3_idx, i)
        elseif lp.c_lb[i] > -Inf
            push!(m2_idx, i)
        elseif lp.c_ub[i] < Inf
            push!(m1_idx, i)
        else
            @error "Constraint type is not supported"
        end
    end
    m1 = length(m1_idx) # number of <= constraints
    m2 = length(m2_idx) # number of >= constraints
    m3 = length(m3_idx) # number of == constraints
    # It is important to have the constraints in the following order: <=, >=, and ==.
    # So we use a permuatation vector.
    perm_A = [m1_idx; m2_idx; m3_idx]
    # @show m1, m2, m3
    
    C2 = Int[] # free
    C3 = Int[] # single bounded
    C4 = Int[] # bounded

    # penalty
    q = Array{Float64}(undef, ncols(lp))

    for j = 1:ncols(lp)
        if lp.v_lb[j] > -Inf
            if lp.v_ub[j] < Inf
                push!(C4, j)
                q[j] = lp.v_lb[j] - lp.v_ub[j]
            else
                push!(C3, j)
                q[j] = lp.v_lb[j]
            end
        elseif lp.v_ub[j] < Inf
            push!(C3, j)
            q[j] = -lp.v_ub[j]
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
    I = [ones(Int64, m1 + m2); zeros(Int64, nrows(lp) - m1 - m2)]
    r = [ones(Int64, m1 + m2); zeros(Int64, nrows(lp) - m1 - m2)]
    v = fill(Inf, nrows(lp))
    B = collect(1:(m1+m2)) .+ ncols(lp) # {n+1, ..., n+m1+m2}

    # Step 2
    for k = 1:ncols(lp)
        # Step 2a
        alpha = 0.
        max_l = -1
        for i = 1:nrows(lp)
            if r[i] == 0
                absA = abs(lp.A[perm_A[i],C[k]])
                if alpha < absA
                    alpha = absA
                    max_l = i
                end
            end
        end
        if alpha >= 0.99
            push!(B, C[k])
            # println("Step 2a: Adding $(C[k]) to basis with alpha ($alpha) >= 0.99")
            I[max_l] = 1
            v[max_l] = alpha
            for i = 1:nrows(lp)
                if abs(lp.A[perm_A[i],C[k]]) > 0
                    r[i] += 1
                end
            end
            continue
        end
        # Step 2b
        alpha = 0.
        max_l = -1
        next_k = false
        for i = 1:nrows(lp)
            if abs(lp.A[perm_A[i],C[k]]) > 0.01 * v[i]
                next_k = true
                break
            end
            if I[i] == 0
                absA = abs(lp.A[perm_A[i],C[k]])
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
            # println("Step 2b: Adding $(C[k]) to basis with alpha ($alpha) > 0.0")
            I[max_l] = 1
            v[max_l] = alpha
            for i = 1:nrows(lp)
                if abs(lp.A[perm_A[i],C[k]]) > 0
                    r[i] += 1
                end
            end
        end
    end

    # Step 3
    for i = (m1+m2+1):nrows(lp)
        if I[i] == 0
            # Add an artificial variable to cover each remaining uncovered row
            push!(B, ncols(lp) + m1 + m2 + perm_A[i]) # B \cup {n+m1+m2+i}
            # println("Step 3: Adding $(lp.ncols + m1 + m2 + perm_A[i]) to basis")
        end
    end
    # @show length(B), nrows(lp), B
    @assert length(B) == nrows(lp)

    return sort(B)
end

"""
    Input: 
    minimize a
    subject to
        A x + d a == b
        xl <= x <= xu,
    where 
        d_i = +1 if b_i - A_i xN > 0,
        d_i = -1 otherwise.

    Output:
    minimize a + sl + su
    subject to
        A x + d a == b
        x + sl - sl2 == xl (nxl)
        x - su + su2 == xu (nxu)
        a, sl, sl2, su, su2 >= 0,

...
# Arguments
- `lp::MatOI.LPSolverForm{T,AT,VT}`: LP problem object in the canonical form
- `x::VT`: the solution vector in the dimension of the number of columns in lp
- `num_orgvars::Int`: the number of variables in the original problem (not in lp)
- `num_artif::Int`: the number of artificial variables introduced to lp
- `basis::Vector{Int}`: basis vector identified for lp
...
"""
function reformulate(lp::MatOI.LPSolverForm{T,AT,VT}, x::VT, num_orgvars::Int, num_artif::Int, basis::Vector{Int}) where {T, AT, VT}
    @assert length(basis) == nrows(lp)
    @assert length(x) == ncols(lp)

    # compute on cpu
    c = Array(lp.c); xl = Array(lp.v_lb); xu = Array(lp.v_ub); b = Array(lp.b);
    # x = Array(lp.x)

    # count slacks for column bounds
    xl_idx = Int[]
    xu_idx = Int[]
    sizehint!(xl_idx, num_orgvars)
    sizehint!(xu_idx, num_orgvars)
    for j in 1:num_orgvars
        if x[j] < xl[j]
            push!(xl_idx, j)
        end
        if x[j] > xu[j]
            push!(xu_idx, j)
        end
    end
    nxl = length(xl_idx)
    nxu = length(xu_idx)

    # Piecewise function is replaced by a set of linear inequalities.
    num_auxvars = nxl + nxu # number of variables to replace the piecewise functions
    num_slacks = nxl + nxu # slacks for the linear inequalities
    lp_nrows = nrows(lp) + num_auxvars # number of rows
    lp_ncols = ncols(lp) + num_auxvars + num_slacks # number of columns

    # row bounds
    b = VT([b; xl[xl_idx]; xu[xu_idx]])

    # TODO: Do we need to compute x?

    # solution x
    x = Array([x; zeros(num_auxvars + num_slacks)])

    # basis construction
    for (i,j) in enumerate(xl_idx)
        if x[j] < xl[j]
            push!(basis, ncols(lp) + i)
            x[ncols(lp) + i] = xl[j] - x[j]
        else
            push!(basis, ncols(lp) + num_auxvars + i)
            x[ncols(lp) + num_auxvars + i] = x[j] - xl[j]
        end
    end
    for (i,j) in enumerate(xu_idx)
        if x[j] > xu[j]
            push!(basis, ncols(lp) + nxl + i)
            x[ncols(lp) + nxl + i] = x[j] - xu[j]
        else
            push!(basis, ncols(lp) + num_auxvars + nxl + i)
            x[ncols(lp) + num_auxvars + nxl + i] = xu[j] - x[j]
        end
    end

    # objective coefficient
    c = VT([c; ones(num_auxvars); zeros(num_slacks)])

    # column bounds
    xl = VT([xl; zeros(num_auxvars + num_slacks)])
    xu = VT([xu; fill(Inf, num_auxvars + num_slacks)])
    xl[xl_idx] = fill(-Inf,nxl)
    xu[xu_idx] = fill(+Inf,nxu)

    artif_col_idx = Int[]

    # create the submatrix for auxiliary and slack variables
    I = Array{Int64}(undef, num_auxvars + num_slacks)
    J = collect(1:(num_auxvars + num_slacks))
    V = Array{Float64}(undef, num_auxvars + num_slacks)
    pos = 1
    # sl
    for i = 1:nxl
        I[pos] = nrows(lp) + i
        V[pos] = 1
        push!(artif_col_idx, ncols(lp) + J[pos])
        pos += 1
    end
    # su
    for i = 1:nxu
        I[pos] = nrows(lp) + nxl + i
        V[pos] = -1
        push!(artif_col_idx, ncols(lp) + J[pos])
        pos += 1
    end
    # sl2
    for i = 1:nxl
        I[pos] = nrows(lp) + i
        V[pos] = -1
        pos += 1
    end
    # su2
    for i = 1:nxu
        I[pos] = nrows(lp) + nxl + i
        V[pos] = 1
        pos += 1
    end
    S = sparse(I, J, V, lp_nrows, num_auxvars + num_slacks)

    # create the matrix in canonical form
    A = AT([[sparse(Matrix(lp.A)); 
        sparse(collect(1:nxl), xl_idx, ones(nxl), nxl, ncols(lp)); 
        sparse(collect(1:nxu), xu_idx, ones(nxu), nxu, ncols(lp))] S])

    senses = fill(MatOI.EQUAL_TO, lp_nrows)
    p1lp = MatOI.LPSolverForm{T,typeof(A),typeof(c)}(lp.direction, c, A, b, senses, xl, xu)

    return p1lp, sort(basis), artif_col_idx
end

"""
    compute solution x based on basis information
    and return whether x is feasible or not
"""
function compute_x(lp::MatOI.LPSolverForm{T,AT,VT}, basis::Vector{Int}) where {T, AT, VT}
    @assert nrows(lp) == length(basis)

    nonbasis = Int[]
    sizehint!(nonbasis, ncols(lp) - length(basis))
    x = VT(undef, ncols(lp))

    # construct nonbasic indices
    for j in 1:ncols(lp)
        if !in(j, basis)
            push!(nonbasis, j)

            # set x values
            axl = abs(lp.v_lb[j])
            axu = abs(lp.v_ub[j])
            if lp.v_lb[j] > -Inf && axl <= axu
                x[j] = lp.v_lb[j]
            elseif lp.v_ub[j] < Inf && axl > axu
                x[j] = lp.v_ub[j]
            else
                x[j] = 0.0
            end
        end
    end

    x[basis] .= lp.A[:,basis] \ (lp.b .- lp.A[:,nonbasis] * x[nonbasis])

    is_feasible = true
    for j = 1:ncols(lp)
        if x[j] < lp.v_lb[j] || x[j] > lp.v_ub[j]
            is_feasible = false
            # @show j, x[j], lp.v_lb[j], lp.v_ub[j]
            break
        end
    end

    return x, is_feasible
end

end
