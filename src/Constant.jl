"""
Define constant variables
"""

const USE_INVB = true

const INF = 1.0e+20
const EPS = 1e-6

const MAX_ITER = 30000000000
const MAX_HISTORY = 100

@enum(
    Status,
    NotSolved,
    Solve,
    Optimal,
    Unbounded,
    Infeasible,
    Feasible,
    Cycle,
)

const BASIS_BASIC = 1
const BASIS_AT_LOWER = 2
const BASIS_AT_UPPER = 3
const BASIS_FREE = 4

@enum(
    PivotRule,
    Bland,
    Steepest,
    Dantzig,
    Artificial,
)
