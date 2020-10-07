"""
PivotRule

This indicates the type of simplex pivot rule.
"""
@enum(PivotRule,
    Bland,
    Steepest,
    Dantzig,
    Artificial,
)

"""
    Parameters
"""
Base.@kwdef mutable struct Parameters
    use_invB::Bool = true
    max_iter::Int = 1000000000
    max_history::Int = 100
    print_iter_freq::Int = 10
end
