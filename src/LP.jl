"""
Linear programming problem
"""

# abstract type AbstractLpData{T<:AbstractArray} end

# function initialize!(lp::AbstractLpData, c::Array, xl::Array, xu::Array,
#         A::SparseMatrixCSC{Float64,Int}, x0::Array, TArray)
#     lp.nrows, lp.ncols = size(A)

#     @assert lp.ncols == length(c)
#     @assert lp.ncols == length(xl)
#     @assert lp.ncols == length(xu)

#     lp.c = TArray{Float64}(undef, lp.ncols)
#     lp.xl = TArray{Float64}(undef, lp.ncols)
#     lp.xu = TArray{Float64}(undef, lp.ncols)
#     lp.x = TArray{Float64}(undef, lp.ncols)

#     lp.rd = TArray{Float64}(undef, lp.nrows)
#     lp.cd = TArray{Float64}(undef, lp.ncols)

#     copyto!(lp.c, c)
#     copyto!(lp.xl, xl)
#     copyto!(lp.xu, xu)

#     # copy initial solution; or zeros
#     if length(x0) == lp.ncols
#         copyto!(lp.x, x0)
#     else
#         fill!(lp.x, 0)
#     end

#     # DENSE A matrix
#     lp.A = TArray == CuArray ? TArray{Float64,2}(Matrix(A)) : A
#     # lp.A = TArray == CuVector ? CuArrays.CUSPARSE.CuSparseMatrixCSC(A) : A

#     lp.status = NotSolved
#     lp.TArray = TArray
# end

# mutable struct StandardLpData{T} <: AbstractLpData{T}
#     nrows::Int
#     ncols::Int

#     A  # constraint matrix
#     bl::T # row lower bound vector
#     bu::T # row upper bound vector
#     c::T  # linear objective coefficient vector
#     xl::T # column lower bound vector
#     xu::T # column upper bound vector
#     x::T  # column solution vector

#     rd::T # temp for scaling
#     cd::T # temp for scaling

#     status::Status
#     TArray

#     function StandardLpData(c::Array, xl::Array, xu::Array,
#             A::SparseMatrixCSC{Float64,Int}, bl::Array, bu::Array,
#             x0::Array = Float64[],
#             TArray = Array)

#         # Check the array type
#         if !in(TArray,[CuArray,Array])
#             error("Unkown array type $TArray.")
#         end

#         lp = new{TArray}()

#         initialize!(lp, c, xl, xu, A, x0, TArray)

#         @assert lp.nrows == length(bl)
#         @assert lp.nrows == length(bu)
#         lp.bl = TArray{Float64}(undef, lp.nrows)
#         lp.bu = TArray{Float64}(undef, lp.nrows)
#         copyto!(lp.bl, bl)
#         copyto!(lp.bu, bu)

#         return lp
#     end
# end

# mutable struct CanonicalLpData{T} <: AbstractLpData{T}
#     nrows::Int
#     ncols::Int

#     A  # constraint matrix
#     b::T # row bound vector
#     c::T  # linear objective coefficient vector
#     xl::T # column lower bound vector
#     xu::T # column upper bound vector
#     x::T  # column solution vector

#     rd::T # temp for scaling
#     cd::T # temp for scaling

#     status::Status
#     TArray

#     function CanonicalLpData(c::Array, xl::Array, xu::Array,
#             A::SparseMatrixCSC{Float64,Int}, b::Array,
#             x0::Array = Float64[],
#             TArray = Array)

#         # Check the array type
#         if !in(TArray,[CuArray,Array])
#             error("Unkown array type $TArray.")
#         end

#         lp = new{TArray}()

#         initialize!(lp, c, xl, xu, A, x0, TArray)

#         @assert lp.nrows == length(b)
#         lp.b = TArray{Float64}(undef, lp.nrows)
#         copyto!(lp.b, b)

#         return lp
#     end
# end

# cpu2gpu(lp::StandardLpData{Array}) = StandardLpData(lp.c, lp.xl, lp.xu, lp.A, lp.bl, lp.bu, lp.x, CuArray)
# cpu2gpu(lp::StandardLpData{CuArray}) = lp
# cpu2gpu(lp::CanonicalLpData{Array}) = CanonicalLpData(lp.c, lp.xl, lp.xu, lp.A, lp.b, lp.x, CuArray)
# cpu2gpu(lp::CanonicalLpData{CuArray}) = lp

# function rhs(lp::StandardLpData)
#     @error "This is available for canonical form only."
# end
# rhs(lp::CanonicalLpData) = lp.b

# function assign_rhs!(lp::StandardLpData, bl, bu)
#     lp.bl = bl
#     lp.bu = bu
# end

# function assign_rhs!(lp::CanonicalLpData, b)
#     lp.b = b
# end

# function divide_rhs!(lp::StandardLpData, bl, bu)
#     lp.bl ./= bl
#     lp.bu ./= bu
# end

# function divide_rhs!(lp::CanonicalLpData, b)
#     lp.b ./= b
# end

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
function canonical_form(standard::MatOI.LPForm{T, AT}) where {T, AT}
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
        if standard.v_lb[ineq[i]] > -INF
            xu[ncols(standard) + i] = standard.c_ub[ineq[i]] - standard.c_lb[ineq[i]]
        end
    end

    # row bounds
    b = deepcopy(Array(standard.c_lb))

    # create the submatrix for slack
    I = Int64[]; J = Int64[]; V = Float64[]; j = 1;
    for i in ineq
        if standard.c_lb[i] > -INF
            push!(I, i); push!(J, j); push!(V, -1.0);
            j += 1
        elseif standard.c_ub[i] < INF
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
    # canonical = CanonicalLpData(c, xl, xu, A, b, [], standard.TArray)
    senses = fill(MatOI.EQUAL_TO, lp_nrows)
    canonical = MatOI.LPSolverForm{T, typeof(A)}(
        MOI.MIN_SENSE, c, A, b, senses, xl, xu
    )

    return canonical
end
canonical_form(standard::MatOI.LPSolverForm) = standard
