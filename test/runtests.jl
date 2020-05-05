using Simplex
using CuArrays
using SparseArrays
using LinearAlgebra
using Test

# CuArrays.allowscalar(false)

# include("LP.jl")
# include("PhaseOne/Artificial.jl")
include("PhaseOne/Cplex.jl")
include("netlib.jl")
