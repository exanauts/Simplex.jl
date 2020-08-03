using Revise
using Simplex
using CUDA
using SparseArrays
using LinearAlgebra
using MatrixOptInterface
using Test

const MatOI = MatrixOptInterface
const MOI = MatOI.MOI
# CUDA.allowscalar(false)

instances=[
    "afiro",
    # "adlittle",
    # "sc50a",
    # "sc50b",
    # "sc105",
    # "sc205"
]
phaseone_methods = [
    Simplex.PhaseOne.ARTIFICIAL,
    # Simplex.PhaseOne.CPLEX,
]
pivot_rules = [
    Simplex.Bland,
    # Simplex.Steepest,
    # Simplex.Dantzig,
]
arch_list = [
    # "GPU",
    "CPU",
]

function run_netlib_instance(netlib, use_gpu, method, pivot)::Simplex.Status
    c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)
    # lp = Simplex.StandardLpData(c, xl, xu, A, bl, bu)
    lp =  MatOI.LPForm{Float64, typeof(A)}(
        MOI.MIN_SENSE, c, A, bl, bu, xl, xu
    )
    status = Simplex.run(lp,
        gpu = use_gpu,
        phase_one_method = method,
        pivot_rule = pivot)
    return status
end

@testset "netlib instances" begin
    # for use_gpu in [false, true]
    for arch in arch_list
        use_gpu = arch == "GPU" ? true : false
        @testset "$arch" begin
            for i in instances
                @testset "$(i)" begin
                    for method in phaseone_methods
                        @testset "$(Symbol(method))" begin
                            for pivot in pivot_rules
                                @testset "$(Symbol(pivot))" begin
                                    netlib = "netlib/$i.mps"
                                    @test Simplex.Optimal == run_netlib_instance(netlib, use_gpu, method, pivot)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
