
instances=[
    "afiro", 
    "adlittle",
    "sc50a",
    "sc50b",
    "sc105",
    "sc205"
]
truefalse = [
    # true,
    false,
]
phaseone_methods = [
    Simplex.PhaseOne.ARTIFICIAL, 
    Simplex.PhaseOne.CPLEX,
]
pivot_rules = [
    Simplex.Bland,
    Simplex.Steepest,
    Simplex.Dantzig,
]

function run_netlib_instance(netlib, use_gpu, method, pivot)::Simplex.Status
    c, xl, xu, bl, bu, A = Simplex.GLPK_read_mps(netlib)
    lp =  MatOI.LPForm{Float64, typeof(A), typeof(c)}(
        MOI.MIN_SENSE, c, A, bl, bu, xl, xu
    )
    Simplex.summary(lp)
    status = Simplex.run(lp, 
        gpu = use_gpu,
        phase_one_method = method,
        pivot_rule = pivot)
    return status
end

@testset "netlib instances" begin
    for use_gpu in truefalse
        arch = use_gpu ? "GPU" : "CPU"
        @testset "$arch" begin
            for i in instances
                @testset "$(i)" begin
                    for method in phaseone_methods
                        @testset "$(Symbol(method))" begin
                            for pivot in pivot_rules
                                @testset "$(Symbol(pivot))" begin
                                    netlib = "../netlib/$i.mps"
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