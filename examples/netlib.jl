using Simplex
using CuArrays

"""
To get these mps files, you need to check ../netlib directory.
"""
# netlib = "../netlib/afiro.mps"
# netlib = "../netlib/adlittle.mps"
# netlib = "../netlib/sc50a.mps"
# netlib = "../netlib/sc50b.mps"
# netlib = "../netlib/sc105.mps"
netlib = "../netlib/sc205.mps"

# Simplex.GLPK_solve(netlib)
c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)
# @show c, xlb, xub, l, u, A

if length(ARGS) < 2
    @error("Insufficient arguments")
end
arg1 = parse(Int,ARGS[1])
arg2 = parse(Int,ARGS[2])

MyArrays = [false,true]
MyPivots = [Simplex.PIVOT_BLAND, Simplex.PIVOT_STEEPEST, Simplex.PIVOT_DANTZIG]

Simplex.run(lp, pivot_rule = MyPivots[arg2], gpu = MyArrays[arg1])
