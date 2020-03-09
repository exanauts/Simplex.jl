using Simplex
using SparseArrays
using Test

# netlib = "AFIRO.sif"
netlib = "25FV47.sif"
# Simplex.GLPK_solve(netlib)
c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)
# @show c, xlb, xub, l, u, A

lp = Simplex.LpData(c, xl, xu, A, bl, bu)
# Simplex.summary(lp)
# Simplex.run(lp)
Simplex.run(lp, pivot_rule = Simplex.PIVOT_DANTZIG)