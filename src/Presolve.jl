"""
Presolve is a key to accelerate the linear programming solution.

TODO: Need to check and implement the algorithms in
  Andersen and Andersen. Presolving in linear programming. 1995
"""
function presolve(lp::LpData)
  @timeit TO "row reduction" begin
    remove_empty_rows!(lp)
    remove_dependent_rows!(lp)
    make_sparse!(lp)
    # @show size(lp.A)
  end
end

function remove_empty_rows!(lp::LpData)
  nonempty = Int[]
  sizehint!(nonempty, lp.nrows)

  for i = 1:lp.nrows
    if norm(lp.A[i,:]) > 1e-10
      push!(nonempty, i)
    end
  end

  if length(nonempty) < lp.nrows
    println("Presolve removed $(lp.nrows-length(nonempty)) empty rows.")
    lp.A = lp.A[nonempty,:]
    lp.bl = lp.bl[nonempty]
    lp.bu = lp.bu[nonempty]
    lp.nrows = length(nonempty)
  end
end

function make_sparse!(lp::LpData{Array})
  lp.A = sparse(lp.A)
end

function make_sparse!(lp::LpData{CuArray})
  println("We do not make CuArray sparse.")
end

"""
Eliminate linearly dependent rows

The implementation is based on
  Chvatal. Linear programming. 1981

The computational efficiency can be improved by
  Andersen. Finding all linearly dependent rows in large-scale linear programming. 1995
"""
function remove_dependent_rows!(lp::LpData{Array})
  m, n = size(lp.A)

  # Append identity matrix to the last
  I = sparse(collect(1:m), collect(1:m), ones(m))
  A2 = [lp.A I]

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
  
  if length(depind) > 0
    deprows = [i for i=1:m if !in(i,depind)]
    lp.A = sparse(lp.A[deprows,:])
    lp.bl = lp.bl[deprows]
    lp.bu = lp.bu[deprows]
    lp.nrows -= length(depind)
    println("Presolve reduced $(length(depind)) rows.")
  end
end

function remove_dependent_rows!(lp::LpData{CuArray})
  m, n = size(lp.A)

  # Append identity matrix to the last
  A2 = [lp.A CuMatrix(Matrix(I,m,m))]

  basis = collect((1+n):(m+n))
  e_i = CuArray{Float64}(undef, m)
  pi = CuArray{Float64}(undef, m)
  
  depind = Int[]
  sizehint!(depind, m)

  for i in 1:m
    # initialize compute components
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
  
  if length(depind) > 0
    deprows = [i for i=1:m if !in(i,depind)]
    lp.A = lp.A[deprows,:]
    lp.bl = lp.bl[deprows]
    lp.bu = lp.bu[deprows]
    lp.nrows -= length(depind)
    println("Presolve reduced $(length(depind)) rows.")
  end
end

"""
Scaling algorithm from Implementation of the Simplex Method, Ping-Qi Pan (2014)
"""
function scaling!(lp::LpData)
    @assert lp.is_canonical == true
    
    maxrounds = 50
    round = 1
    while round <= maxrounds
        aratio = matrix_coefficient_ratio(lp.A)
        # @show aratio
        scaling_rows!(lp)
        println("Sacling rows: max|aij| $(maximum(lp.rd)) min|aij| $(minimum(lp.rd))")

        scaling_columns!(lp)
        sratio = matrix_coefficient_ratio(lp.A)
        println("Sacling columns: max|aij| $(maximum(lp.cd)) min|aij| $(minimum(lp.cd))")
        # @show sratio, aratio
        if sratio >= 0.9 * aratio
            break
        end
        round += 1
    end
    lp.bu .= lp.bl
end

function scaling_rows!(lp::LpData)
  m, n = size(lp.A)
  for i = 1:m
    mina = Inf; maxa = -Inf
    for j = 1:n
      v = abs(lp.A[i,j])
      if v > 0
        mina = mina > v ? v : mina
        maxa = maxa < v ? v : maxa
      end
    end
    lp.rd[i] = sqrt(mina*maxa)
  end
  lp.A ./= lp.rd
  lp.bl ./= lp.rd
  # lp.bl ./= lp.rd[:,1]
end

function scaling_columns!(lp::LpData{Array})
  m, n = size(lp.A)
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
      lp.cd[j] = sqrt(mina*maxa)
  end
  lp.A ./= lp.cd'
  lp.c ./= lp.cd
  lp.xl .*= lp.cd
  lp.xu .*= lp.cd
end

function scaling_columns!(lp::LpData{CuArray})
  m, n = size(lp.A)
  for j = 1:n
      mina = Inf; maxa = -Inf
      for i in 1:m
          v = abs(lp.A[i,j])
          if v > 0
              mina = mina > v ? v : mina
              maxa = maxa < v ? v : maxa
          end
      end
      lp.cd[j] = sqrt(mina*maxa)
  end
  lp.A ./= lp.cd'
  lp.c ./= lp.cd
  lp.xl .*= lp.cd
  lp.xu .*= lp.cd
end


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

