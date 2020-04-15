using Simplex
using CuArrays
using SparseArrays
using LinearAlgebra
using Test

# netlib = "afiro.mps"
# Simplex.GLPK_solve(netlib)
c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)
# @show c, xlb, xub, l, u, A

lp = Simplex.LpData(c, xl, xu, A, bl, bu, Array)
# Simplex.summary(lp)
# Simplex.run(lp)
Simplex.run(lp, pivot_rule = Simplex.PIVOT_DANTZIG)