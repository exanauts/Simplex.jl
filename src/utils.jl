function print(lp::LpData)
    println("Number of rows   : $(lp.nrows)")
    println("Number of columns: $(lp.ncols)")
    println("Constraint matrix: $(Matrix(lp.A))")
    println("Row lower bounds: $(lp.bl)")
    println("Row upper bounds: $(lp.bu)")
    println("Objective coefficients: $(lp.c)")
    println("Column lower bound: $(lp.xl)")
    println("Column upper bound: $(lp.xu)")
end

function summary(lp::LpData)
    println("Number of rows   : $(lp.nrows)")
    println("Number of columns: $(lp.ncols)")
    println("A: Min $(minimum(nonzeros(lp.A))), Max $(maximum(nonzeros(lp.A)))")
    println("bl: Min $(minimum(lp.bl)), Max $(maximum(lp.bl))")
    println("bu: Min $(minimum(lp.bu)), Max $(maximum(lp.bu))")
    println("xl: Min $(minimum(lp.xl)), Max $(maximum(lp.xl))")
    println("xu: Min $(minimum(lp.xu)), Max $(maximum(lp.xu))")
    println("c: Min $(minimum(lp.c)), Max $(maximum(lp.c))")

    cons = Dict("EQ"=>0, "GT"=>0, "LT"=>0, "RNG"=>0, "FR"=>0)
    vars = Dict("EQ"=>0, "GT"=>0, "LT"=>0, "RNG"=>0, "FR"=>0)
    for i = 1:lp.nrows
        if lp.bl[i] == lp.bu[i]
            cons["EQ"] += 1
        elseif lp.bl[i] > -Inf
            if lp.bu[i] < Inf
                cons["RNG"] += 1
            else
                cons["GT"] += 1
            end
        elseif lp.bu[i] <= Inf
            cons["LT"] += 1
        else
            cons["FR"] += 1
        end
    end

    for j = 1:lp.ncols
        if lp.xl[j] == lp.xu[j]
            vars["EQ"] += 1
        elseif lp.xl[j] > -Inf
            if lp.xu[j] < Inf
                vars["RNG"] += 1
            else
                vars["GT"] += 1
            end
        elseif lp.xu[j] <= Inf
            vars["LT"] += 1
        else
            vars["FR"] += 1
        end
    end

    println("Constraints:")
    for (k,v) = cons
        println(" $k = $v")
    end
    println("Variables:")
    for (k,v) = vars
        println(" $k = $v")
    end

    # for j = 1:lp.ncols
    #     if lp.xl[j] 
    # end
    # println("Free: ")
end