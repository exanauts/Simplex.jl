module PhaseOne

using MatrixOptInterface
import Simplex

const MatOI = MatrixOptInterface

include("Artificial.jl")
include("Cplex.jl")

@enum(
    Method,
    ARTIFICIAL,
    CPLEX,
)

function run(lp::MatOI.LPSolverForm, Tv::Type; 
    method::Method = CPLEX, kwargs...)::Simplex.SpxData
    if method == ARTIFICIAL
        return Artificial.run(lp, Tv; kwargs...)
    elseif method == CPLEX
        return Cplex.run(lp, Tv; kwargs...)
    end
end

end
