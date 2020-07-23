using Simplex
using CuArrays
using Dates

"""
To get these mps files, you need to check ../netlib directory.
"""

fp = open("results.md", "w")
println(fp, "# Numerical Performance ($(now()))\n")

# for instance = ["afiro", "adlittle", "sc50a", "sc50b", "sc105", "sc205"]
for instance = ["sc50a", "sc50b", "sc105", "sc205"]
    println(fp, "## Instance: $instance\n")
    netlib = "../netlib/$instance.mps"
    c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)
    m, n = size(A); nnz = length(A.nzval);
    println(fp, "- nrows   : $m")
    println(fp, "- ncols   : $n")
    println(fp, "- nnz     : $nnz")
    println(fp, "- sparsity: $(nnz / (m*n))")
    for use_gpu in [false, true]
        if use_gpu 
            println(fp, "\n### GPU\n")
        else
            println(fp, "\n### CPU\n")
        end
        println(fp, "```")
        lp = Simplex.StandardLpData(c, xl, xu, A, bl, bu)
        Simplex.run(lp, gpu = use_gpu, performance_io = fp)
        println(fp, "```")

        println("")
        lp = nothing
    end
end

close(fp)
