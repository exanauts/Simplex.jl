"""
Define constant variables
"""

const USE_INVB = true

const INF = 1.0e+20
const EPS = 1e-6

const MAX_ITER = 30000000000
const MAX_HISTORY = 100

const STAT_NOT_SOLVED = 0
const STAT_SOLVE = 1
const STAT_OPTIMAL = 2
const STAT_UNBOUNDED = 3
const STAT_INFEASIBLE = 4
const STAT_FEASIBLE = 5
const STAT_CYCLE = 6

const BASIS_BASIC = 1
const BASIS_AT_LOWER = 2
const BASIS_AT_UPPER = 3
const BASIS_FREE = 4

const PIVOT_BLAND = 0
const PIVOT_STEEPEST = 1
const PIVOT_DANTZIG = 2
const PIVOT_ARTIFICIAL = 999