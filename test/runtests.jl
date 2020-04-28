using Simplex
using CuArrays
using SparseArrays
using LinearAlgebra
using Test

netlib = "afiro.mps"
c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)

lp = Simplex.LpData(c, xl, xu, A, bl, bu)
Simplex.run(lp, pivot_rule = Simplex.PIVOT_DANTZIG, gpu = false)