using Simplex
using CuArrays
using SparseArrays
using LinearAlgebra
using Test

# CuArrays.allowscalar(false)

pivot_rules = [
    Simplex.Bland,
    Simplex.Steepest,
    Simplex.Dantzig,
]

@testset "netlib instances" begin
    instances=[
        "afiro", 
        "adlittle",
        "sc50a",
        "sc50b",
        "sc105",
        "sc205"
    ]
    for use_gpu in [false, true]
        arch = use_gpu ? "GPU" : "CPU"

        @testset "$arch" begin
            for i in instances
                netlib = "../netlib/$i.mps"

                @testset "$(i)" begin
                    for method in [Simplex.PhaseOne.ARTIFICIAL, Simplex.PhaseOne.CPLEX]
                
                        @testset "$(Symbol(method))" begin

                            for pivot in pivot_rules

                                @testset "$(Symbol(pivot))" begin
                                    c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)
                                    lp = Simplex.LpData(c, xl, xu, A, bl, bu)
                                    Simplex.run(lp, 
                                        gpu = false,
                                        phase_one_method = method,
                                        pivot_rule = pivot)
                                    @test lp.status == Simplex.Optimal
                                    lp = nothing
                                end
                                
                            end
                        end
                    end
                end

            end
        end

    end
end
