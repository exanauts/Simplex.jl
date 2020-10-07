using Simplex
using CUDA
using SparseArrays
using LinearAlgebra
using MatrixOptInterface
using Test

const MatOI = MatrixOptInterface
const MOI = MatOI.MOI
# CUDA.allowscalar(false)

include("PhaseOne/Artificial.jl")
include("PhaseOne/Cplex.jl")
include("netlib.jl")
