"""
Linear programming problem
"""

mutable struct LpData{T<:Number}
    nrows::Int
    ncols::Int
    A::SparseMatrixCSC{T,Int}
    bl::Vector{T}
    bu::Vector{T}
    c::Vector{T}
    xl::Vector{T}
    xu::Vector{T}

    x::Vector{T}
    status::Int

    is_canonical::Bool

    function LpData(c::Vector{T}, xl::Vector{T}, xu::Vector{T}, 
            A::SparseMatrixCSC{T,Int}, bl::Vector{T}, bu::Vector{T},
            x0::Vector{T} = T[]) where T
        lp = new{T}()
        lp.nrows, lp.ncols = size(A)

        @assert lp.nrows == length(bl)
        @assert lp.nrows == length(bu)
        @assert lp.ncols == length(c)
        @assert lp.ncols == length(xl)
        @assert lp.ncols == length(xu)

        lp.A = A; lp.bl = bl; lp.bu = bu;
        lp.c = c; lp.xl = xl; lp.xu = xu;
        if length(x0) == lp.ncols
            lp.x = x0
        end

        lp.status = STAT_NOT_SOLVED
        lp.is_canonical = false

        return lp
    end
end

function canonical_form(standard::LpData)
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
    c = append!(deepcopy(standard.c), zeros(nineq))
    @assert length(c) == ncols

    # column bounds
    xl = append!(deepcopy(standard.xl), zeros(nineq))
    xu = append!(deepcopy(standard.xu), ones(nineq)*Inf)
    @assert length(xl) == ncols
    @assert length(xu) == ncols
    for i in ineq
        if standard.bl[i] > -INF
            xu[standard.ncols + i] = standard.bu[i] - standard.bl[i]
        end
    end

    # row bounds
    b = deepcopy(standard.bl)

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
    S = sparse(I, J, V)

    # create the matrix in canonical form
    A = [standard.A S]

    # create a canonical form data
    canonical = LpData(c, xl, xu, A, b, b)
    canonical.is_canonical = true

    return canonical
end

function phase_one_form(lp::LpData)
    @assert lp.is_canonical == true

    nrows = lp.nrows
    ncols = lp.ncols + nrows

    # objective coefficient
    c = append!(zeros(lp.ncols), ones(nrows))

    # column bounds
    xl = append!(deepcopy(lp.xl), zeros(nrows))
    xu = append!(deepcopy(lp.xu), ones(nrows)*Inf)

    # rhs
    b = deepcopy(lp.bl)

    # create the submatrix for slack
    I = Int64[]; V = Float64[];
    VV = Float64[];
    for i = 1:nrows
        if b[i] < 0
            b[i] *= -1
            push!(VV, -1.0);
        else
            push!(VV, 1.0);
        end
        push!(I, i); push!(V, 1.0);
    end
    S = sparse(I, I, V)
    P = sparse(I, I, VV)

    # create the matrix in canonical form
    A = [P*lp.A S]

    return LpData(c, xl, xu, A, b, b)
end

"""
Scaling algorithm from Implementation of the Simplex Method, Ping-Qi Pan (2014)
"""
function scaling(lp::LpData)
    @assert lp.is_canonical == true
    
    maxrounds = 50
    round = 1
    while round <= maxrounds
        aratio = matrix_coefficient_ratio(lp.A)
        # @show aratio
        rd = zeros(lp.nrows)
        for i = 1:lp.nrows
            mina = Inf; maxa = -Inf
            for j = 1:lp.ncols
                v = abs(lp.A[i,j])
                if v > 0
                    mina = mina > v ? v : mina
                    maxa = maxa < v ? v : maxa
                end
            end
            rd[i] = sqrt(mina*maxa)
        end
        # @show maximum(rd), minimum(rd)
        lp.A = lp.A ./ rd
        lp.bl = lp.bl ./ rd[:,1]
        println("Sacling rows: max|aij| $(maximum(rd)) min|aij| $(minimum(rd))")

        cd = zeros(lp.ncols)
        vals = nonzeros(lp.A)
        for j = 1:lp.ncols
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
        # @show maximum(cd), minimum(cd)
        lp.A = lp.A ./ cd'
        lp.c = lp.c ./ cd
        lp.xl = lp.xl .* cd
        lp.xu = lp.xu .* cd
        sratio = matrix_coefficient_ratio(lp.A)
        println("Sacling columns: max|aij| $(maximum(cd)) min|aij| $(minimum(cd))")
        # @show sratio, aratio
        if sratio >= 0.9 * aratio
            break
        end
        round += 1
    end
    lp.bu = deepcopy(lp.bl)
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
