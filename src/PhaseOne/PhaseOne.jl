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

function run(lp::MatOI.LPSolverForm,
    x::AbstractArray;
    method::Method = CPLEX,
    kwargs...)

    if method == ARTIFICIAL
        return Artificial.run(lp, x; kwargs...)
    elseif method == CPLEX
        return Cplex.run(lp, x; kwargs...)
    end
end

end
