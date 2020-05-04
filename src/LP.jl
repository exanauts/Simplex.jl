"""
Linear programming problem
"""

mutable struct LpData{T<:AbstractArray}
    nrows::Int
    ncols::Int

    A  # constraint matrix
    bl::T # row lower bound vector
    bu::T # row upper bound vector
    c::T  # linear objective coefficient vector
    xl::T # column lower bound vector
    xu::T # column upper bound vector
    x::T  # column solution vector

    rd::T # temp for scaling
    cd::T # temp for scaling

    status::Status
    is_canonical::Bool
    TArray

    row_perm::Array{Int}

    function LpData(c::Vector{Float64}, xl::Vector{Float64}, xu::Vector{Float64}, 
            A::SparseMatrixCSC{Float64,Int}, bl::Vector{Float64}, bu::Vector{Float64},
            x0::Vector{Float64} = Float64[],
            TArray = Array)

        # Check the array type
        if !in(TArray,[CuArray,Array])
            error("Unkown array type $TArray.")
        end

        lp = new{TArray}()
        lp.nrows, lp.ncols = size(A)

        @assert lp.nrows == length(bl)
        @assert lp.nrows == length(bu)
        @assert lp.ncols == length(c)
        @assert lp.ncols == length(xl)
        @assert lp.ncols == length(xu)

        lp.bl = TArray{Float64}(undef, lp.nrows)
        lp.bu = TArray{Float64}(undef, lp.nrows)
        lp.c = TArray{Float64}(undef, lp.ncols)
        lp.xl = TArray{Float64}(undef, lp.ncols)
        lp.xu = TArray{Float64}(undef, lp.ncols)
        lp.x = TArray{Float64}(undef, lp.ncols)

        lp.rd = TArray{Float64}(undef, lp.nrows)
        lp.cd = TArray{Float64}(undef, lp.ncols)

        copyto!(lp.bl, bl)
        copyto!(lp.bu, bu)
        copyto!(lp.c, c)
        copyto!(lp.xl, xl)
        copyto!(lp.xu, xu)
        
        # copy initial solution; or zeros
        if length(x0) == lp.ncols
            copyto!(lp.x, x0)
        else
            fill!(lp.x, 0)
        end

        # DENSE A matrix
        lp.A = TArray == CuArray ? TArray{Float64,2}(Matrix(A)) : A
        # lp.A = TArray == CuVector ? CuArrays.CUSPARSE.CuSparseMatrixCSC(A) : A

        lp.status = NotSolved
        lp.is_canonical = false
        lp.TArray = TArray
        lp.row_perm = collect(1:lp.nrows)

        return lp
    end
end

LpData(c::Vector{Float64}, xl::Vector{Float64}, xu::Vector{Float64}, 
    A::SparseMatrixCSC{Float64,Int}, bl::Vector{Float64}, bu::Vector{Float64},
    TArray) = LpData(c, xl, xu, A, bl, bu, Float64[], TArray)

cpu2gpu(lp::LpData{Array}) = LpData(lp.c, lp.xl, lp.xu, lp.A, lp.bl, lp.bu, lp.x, CuArray)

"""
    This function permutes the rows of the linear constraints in the order of <=, >=, and ==.
    The range constraints are considered as >=.
"""
function permute_rows(lp::LpData)
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
    perm_A = [m1_idx; m2_idx; m3_idx]
    # @show perm_A

    lp.A = lp.A[perm_A,:]
    lp.bl .= lp.bl[perm_A]
    lp.bu .= lp.bu[perm_A]
    lp.row_perm .= perm_A
end

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
function canonical_form(standard::LpData)::LpData
    # count the number of inequality constraints
    ineq = Int[]
    for i = 1:standard.nrows
        if standard.bl[i] < standard.bu[i]
            push!(ineq, i)
        end
    end
    nineq = length(ineq)

    nrows = standard.nrows
    ncols = standard.ncols + nineq

    # objective coefficient
    c = append!(deepcopy(Array(standard.c)), zeros(nineq))
    @assert length(c) == ncols

    # column bounds
    xl = append!(deepcopy(Array(standard.xl)), zeros(nineq))
    xu = append!(deepcopy(Array(standard.xu)), ones(nineq)*Inf)
    @assert length(xl) == ncols
    @assert length(xu) == ncols
    for i = 1:nineq
        if standard.bl[ineq[i]] > -INF
            xu[standard.ncols + i] = standard.bu[ineq[i]] - standard.bl[ineq[i]]
        end
    end

    # row bounds
    b = deepcopy(Array(standard.bl))

    # create the submatrix for slack
    I = Int64[]; J = Int64[]; V = Float64[]; j = 1;
    for i in ineq
        if standard.bl[i] > -INF
            push!(I, i); push!(J, j); push!(V, -1.0);
            j += 1
        elseif standard.bu[i] < INF
            b[i] = standard.bu[i]
            push!(I, i); push!(J, j); push!(V, 1.0);
            j += 1
        end
    end
    S = sparse(I, J, V, standard.nrows, nineq)

    # create the matrix in canonical form
    @assert size(standard.A,1) == size(S,1)
    A = [sparse(Matrix(standard.A)) S]

    # create a canonical form data
    # @show standard.TArray
    canonical = LpData(c, xl, xu, A, b, b, standard.TArray)
    canonical.is_canonical = true

    return canonical
end
