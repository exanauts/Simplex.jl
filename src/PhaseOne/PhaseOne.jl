module PhaseOne

import Simplex

include("Artificial.jl")
include("Cplex.jl")

@enum(
    Method,
    ARTIFICIAL,
    CPLEX,
)

function run(lp::Simplex.LpData; 
    method::Method = CPLEX, 
    kwargs...)::Vector{Int}
    
    if method == ARTIFICIAL
        return Artificial.run(lp; kwargs...)
    elseif method == CPLEX
        return Cplex.run(lp; kwargs...)
    end
end

end
