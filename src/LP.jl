"""
Given the original LP of the form
    min cx
    subject to
    -Inf <= A1 x <= b1
      b2 <= A2 x <= Inf
      bl <= A3 x <= bu
      b4 <= A4 x <= b4
      xl <= xu <= xu,
the canonical form is given by
    min cx + 0 s1 + 0 s2 + 0 s3
    subject to
    A1 x + s1 = b1
    A2 x - s2 = b2
    A3 x - s3 = bl
    A4 x      = b4
    xl <= x <= xu
    0 <= s1 <= Inf
    0 <= s2 <= Inf
    0 <= s3 <= bu - bl
"""

function canonical_form(standard::MatOI.LPForm{T, AT, VT}) where {T, AT, VT}
    # count the number of inequality constraints
    ineq = Int[]
    for i = 1:nrows(standard)
        if standard.c_lb[i] < standard.c_ub[i]
            push!(ineq, i)
        end
    end
    nineq = length(ineq)

    lp_nrows = nrows(standard)
    lp_ncols = ncols(standard) + nineq

    # objective coefficient
    c = append!(deepcopy(Array(standard.c)), zeros(nineq))
    @assert length(c) == lp_ncols

    # column bounds
    xl = append!(deepcopy(Array(standard.v_lb)), zeros(nineq))
    xu = append!(deepcopy(Array(standard.v_ub)), fill(Inf, nineq))
    @assert length(xl) == lp_ncols
    @assert length(xu) == lp_ncols
    for i = 1:nineq
        if isFinite(standard.c_lb[ineq[i]])
            xu[ncols(standard) + i] = standard.c_ub[ineq[i]] - standard.c_lb[ineq[i]]
        end
    end

    # row bounds
    b = deepcopy(Array(standard.c_lb))

    # create the submatrix for slack
    I = Int64[]; J = Int64[]; V = Float64[]; j = 1;
    for i in ineq
        if isFinite(standard.c_lb[i])
            push!(I, i); push!(J, j); push!(V, -1.0);
            j += 1
        elseif isFinite(standard.c_ub[i])
            b[i] = standard.c_ub[i]
            push!(I, i); push!(J, j); push!(V, 1.0);
            j += 1
        end
    end
    S = sparse(I, J, V, nrows(standard), nineq)

    # create the matrix in canonical form
    @assert size(standard.A,1) == size(S,1)
    A = [sparse(Matrix(standard.A)) S]

    # create a canonical form data
    # @show standard.TArray
    senses = fill(MatOI.EQUAL_TO, lp_nrows)
    canonical = MatOI.LPSolverForm{T, typeof(A), typeof(c)}(
        MOI.MIN_SENSE, c, A, b, senses, xl, xu
    )

    return canonical
end
canonical_form(standard::MatOI.LPSolverForm) = standard

function cpu2gpu(lp::MatOI.LPForm{T, AT, VT}) where {T, AT, VT}
    if VT <: CuArray
        return lp
    end
    c = convert(CuArray{T, 1}, lp.c)
    A = convert(CuArray{T, 2}, lp.A)
    c_lb = convert(CuArray{T, 1}, lp.c_lb)
    c_ub = convert(CuArray{T, 1}, lp.c_ub)
    v_lb = convert(CuArray{T, 1}, lp.v_lb)
    v_ub = convert(CuArray{T, 1}, lp.v_ub)

    return MatOI.LPForm{T, typeof(A), typeof(b)}(
        lp.direction, c, A, c_lb, c_ub, v_lb, v_ub
    )
end

function cpu2gpu(lp::MatOI.LPSolverForm{T, AT, VT}) where {T, AT, VT}
    if VT <: CuArray
        return lp
    end
    c = convert(CuArray{T, 1}, lp.c)
    A = convert(CuArray{T, 2}, lp.A)
    b = convert(CuArray{T, 1}, lp.b)
    v_lb = convert(CuArray{T, 1}, lp.v_lb)
    v_ub = convert(CuArray{T, 1}, lp.v_ub)

    return MatOI.LPSolverForm{T, typeof(A), typeof(b)}(
        lp.direction, c, A, b, lp.senses, v_lb, v_ub
    )
end
