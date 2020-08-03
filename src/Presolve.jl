"""
Presolve is a key to accelerate the linear programming solution.

TODO: Need to check and implement the algorithms in
Andersen and Andersen. Presolving in linear programming. 1995
"""
function presolve(lp::MatOI.LPForm{T, AT}) where {T, AT}
    @timeit TO "row reduction" begin
        tmp_A = lp.A
        to_keep = collect(1:nrows(lp))
        non_empty = get_empty_rows(tmp_A)
        if length(non_empty) < nrows(lp)
            println("Presolve removed $(nrows(lp)-length(non_empty)) empty rows.")
            tmp_A = tmp_A[non_empty, :]
            to_keep = non_empty
        end
        dep_rows = get_dependent_rows(tmp_A)
        if length(dep_rows) > 0
            indeprows = [i for i=1:size(tmp_A, 1) if !in(i,dep_rows)]
            println("Presolve reduced $(length(dep_rows)) rows.")
            to_keep = to_keep[indeprows]
            tmp_A = tmp_A[indeprows, :]
        end

        # @show size(lp.A)
    end
    return MatOI.LPForm{T, AT}(
        lp.direction,
        lp.c,
        sparse(tmp_A),
        lp.c_lb[to_keep],
        lp.c_ub[to_keep],
        lp.v_lb,
        lp.v_ub,
    )
end

function get_empty_rows(A::AbstractArray{T, 2}) where T
    nonempty = Int[]
    m = size(A, 1)
    sizehint!(nonempty, m)

    for i = 1:m
        if norm(A[i,:]) > 1e-10
            push!(nonempty, i)
        end
    end

    return nonempty
end

"""
Eliminate linearly dependent rows

The implementation is based on
Chvatal. Linear programming. 1981

The computational efficiency can be improved by
Andersen. Finding all linearly dependent rows in large-scale linear programming. 1995
"""
function get_dependent_rows(A::AbstractArray{T, 2}) where T
    m, n = size(A)

    # Append identity matrix to the last
    # I = sparse(collect(1:m), collect(1:m), ones(m))
    A2 = [A I]

    basis = collect((1+n):(m+n))
    # e_i = sparsevec([1],[1.0],m)
    e_i = Array{Float64}(undef, m)
    pi = Array{Float64}(undef, m)

    depind = Int[]
    sizehint!(depind, m)

    for i in 1:m
        # initialize compute components
        # e_i.nzind[1] = i
        fill!(e_i, 0)
        e_i[i] = 1

        # compute pi
        pi .= A2'[basis,:] \ e_i

        is_dependent = true
        for j = 1:n
            # @show A2[:,j]
            if !in(j, basis)
                view_A2_j = @view A2[:,j]
                if abs(view_A2_j' * pi) > 1e-7
                    basis[i] = j
                    # println("Pivot: row $i column $j")
                    is_dependent = false
                    break
                end
            end
        end
        if is_dependent
            # println("Row $i is dependent.")
            push!(depind, i)
        end
    end
    # @show basis[basis .> n]
    # @show basis[basis .> n] .- n

    return depind
end

# function remove_dependent_rows!(lp::StandardLpData{CuArray})
#     m, n = size(lp.A)

#     # Append identity matrix to the last
#     A2 = [lp.A CuMatrix(Matrix(I,m,m))]

#     basis = collect((1+n):(m+n))
#     e_i = CuArray{Float64}(undef, m)
#     pi = CuArray{Float64}(undef, m)

#     depind = Int[]
#     sizehint!(depind, m)

#     for i in 1:m
#         # initialize compute components
#         fill!(e_i, 0)
#         e_i[i] = 1

#         # compute pi
#         pi .= A2'[basis,:] \ e_i

#         is_dependent = true
#         for j = 1:n
#             # @show A2[:,j]
#             if !in(j, basis)
#                 view_A2_j = @view A2[:,j]
#                 if abs(view_A2_j' * pi) > 1e-7
#                     basis[i] = j
#                     # println("Pivot: row $i column $j")
#                     is_dependent = false
#                     break
#                 end
#             end
#         end
#         if is_dependent
#             # println("Row $i is dependent.")
#             push!(depind, i)
#         end
#     end
#     # @show basis[basis .> n]
#     # @show basis[basis .> n] .- n

#     if length(depind) > 0
#         deprows = [i for i=1:m if !in(i,depind)]
#         lp.A = lp.A[deprows,:]
#         lp.bl = lp.bl[deprows]
#         lp.bu = lp.bu[deprows]
#         lp.rd = lp.rd[deprows]
#         nrows(lp) -= length(depind)
#         println("Presolve reduced $(length(depind)) rows.")
#     end
# end

"""
Scaling algorithm from Implementation of the Simplex Method, Ping-Qi Pan (2014)
"""
function scaling!(lp::MatOI.AbstractLPForm)
    maxrounds = 50
    round = 1
    while round <= maxrounds
        aratio = matrix_coefficient_ratio(lp.A)
        # @show aratio
        scaling_rows!(lp)
        # println("Sacling rows: max|aij| $(maximum(lp.rd)) min|aij| $(minimum(lp.rd))")

        scaling_columns!(lp)
        sratio = matrix_coefficient_ratio(lp.A)
        # println("Sacling columns: max|aij| $(maximum(lp.cd)) min|aij| $(minimum(lp.cd))")
        # @show sratio, aratio
        if sratio >= 0.9 * aratio
            break
        end
        round += 1
    end
    normalizing_rows!(lp)
    normalizing_columns!(lp)
end

function normalizing_rows!(lp::MatOI.AbstractLPForm{T}) where T
    m, n = size(lp.A)
    rd = zeros(T, m)
    for i = 1:m
        rd[i] = -Inf
        for j = 1:n
            v = abs(lp.A[i,j])
            if v > 0
                rd[i] = rd[i] < v ? v : rd[i]
            end
        end
    end
    lp.A ./= rd
    lp.c_lb ./= rd
    lp.c_ub ./= rd
end

function scaling_rows!(lp::MatOI.AbstractLPForm{T}) where T
    m, n = size(lp.A)
    rd = zeros(T, m)
    for i = 1:m
        mina = Inf; maxa = -Inf
        for j = 1:n
            v = abs(lp.A[i,j])
            if v > 0
                mina = mina > v ? v : mina
                maxa = maxa < v ? v : maxa
            end
        end
        rd[i] = sqrt(mina*maxa)
    end
    lp.A ./= rd
    lp.c_lb ./= rd
    lp.c_ub ./= rd
end

function normalizing_columns!(lp::MatOI.AbstractLPForm{T}) where T
    m, n = size(lp.A)
    cd = zeros(T, n)
    vals = nonzeros(lp.A)
    for j = 1:n
        cd[j] = -Inf
        for i in nzrange(lp.A, j)
            v = abs(vals[i])
            if v > 0
                cd[j] = cd[j] < v ? v : cd[j]
            end
        end
    end
    lp.A ./= cd'
    lp.c ./= cd
    lp.v_lb .*= cd
    lp.v_ub .*= cd
end

# function normalizing_columns!(lp::StandardLpData{CuArray})
#     m, n = size(lp.A)
#     for j = 1:n
#         lp.cd[j] = -Inf
#         for i in 1:m
#             v = abs(lp.A[i,j])
#             if v > 0
#                 lp.cd[j] = lp.cd[j] < v ? v : lp.cd[j]
#             end
#         end
#     end
#     lp.A ./= lp.cd'
#     lp.c ./= lp.cd
#     lp.xl .*= lp.cd
#     lp.xu .*= lp.cd
# end

function scaling_columns!(lp::MatOI.AbstractLPForm{T}) where T
    m, n = size(lp.A)
    cd = zeros(T, n)
    vals = nonzeros(lp.A)
    for j = 1:n
        mina = Inf; maxa = -Inf
        for i in nzrange(lp.A, j)
            v = abs(vals[i])
            if v > 0
                mina = mina > v ? v : mina
                maxa = maxa < v ? v : maxa
            end
        end
        cd[j] = sqrt(mina*maxa)
    end
    lp.A ./= cd'
    lp.c ./= cd
    lp.v_lb .*= cd
    lp.v_ub .*= cd
end

# function scaling_columns!(lp::StandardLpData{CuArray})
#     m, n = size(lp.A)
#     for j = 1:n
#         mina = Inf; maxa = -Inf
#         for i in 1:m
#             v = abs(lp.A[i,j])
#             if v > 0
#                 mina = mina > v ? v : mina
#                 maxa = maxa < v ? v : maxa
#             end
#         end
#         lp.cd[j] = sqrt(mina*maxa)
#     end
#     lp.A ./= lp.cd'
#     lp.c ./= lp.cd
#     lp.xl .*= lp.cd
#     lp.xu .*= lp.cd
# end


"""
Compute the ratio of the constraint matrix values
"""

function matrix_coefficient_ratio(A::Union{Matrix,CuMatrix})::Float64
    ratio = -Inf
    m, n = size(A)
    for j = 1:n
        mina = Inf; maxa = -Inf
        for i in 1:m
            v = abs(A[i,j])
            if v > 0
                mina = mina > v ? v : mina
                maxa = maxa < v ? v : maxa
            end
        end
        ratio = ratio > maxa / mina ? ratio : maxa / mina
    end
    return ratio
end

function matrix_coefficient_ratio(A::SparseMatrixCSC)::Float64
    ratio = -Inf
    m, n = size(A)
    vals = nonzeros(A)
    for j = 1:n
        mina = Inf; maxa = -Inf
        for i in nzrange(A, j)
            v = abs(vals[i])
            if v > 0
                mina = mina > v ? v : mina
                maxa = maxa < v ? v : maxa
            end
        end
        ratio = ratio > maxa / mina ? ratio : maxa / mina
    end
    return ratio
end

