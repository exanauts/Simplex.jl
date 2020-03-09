"""
Presolve is a key to accelerate the linear programming solution.

TODO: Need to check and implement the algorithms in
  Andersen and Andersen. Presolving in linear programming. 1995
"""
function presolve(lp::LpData)
    remove_dependent_rows(lp)
end

"""
Eliminate linearly dependent rows

The implementation is based on
  Chvatal. Linear programming. 1981

The computational efficiency can be improved by
  Andersen. Finding all linearly dependent rows in large-scale linear programming. 1995
"""
function remove_dependent_rows(lp::LpData)
    m = lp.nrows; n = lp.ncols;
    I = sparse(collect(1:m), collect(1:m), ones(m))
    A2 = [lp.A I]
    V = collect((1+n):(m+n))
    basis = collect((1+n):(m+n))
    BV = unique([basis; V])
    
    depind = Int[]
    for i in 1:m
        e_i = zeros(m); e_i[i] = 1.0;
        pi = A2[:,basis]' \ e_i
        is_dependent = true
        for j = 1:n
            # @show A2[:,j]
            if !in(j, basis) && abs(A2[:,j]' * pi) > 1e-7
                basis[i] = j
                # println("Pivot: row $i column $j")
                is_dependent = false
                break
            end
        end
        if is_dependent
            # println("Row $i is dependent.")
            push!(depind, i)
        end
    end
    # @show basis[basis .> n]
    # @show basis[basis .> n] .- n

    println("Presolve reduced $(length(depind)) rows.")
    
    deprows = [i for i=1:m if !in(i,depind)]
    lp.A = lp.A[deprows,:]
    lp.bl = lp.bl[deprows]
    lp.bu = lp.bu[deprows]
    lp.nrows -= length(depind)
end
