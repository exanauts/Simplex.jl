"""
    AlgorithmStatus

This indicates the status of algorithm.
"""
@enum(AlgorithmStatus,
    NotSolved,
    Solve,
    Optimal,
    Unbounded,
    Infeasible,
    Feasible,
    Cycle,
)

"""
    BasisStatus

- `Basis_Basic`: basic variable
- `Basis_At_Lower`: nonbasic variable at lower bound
- `Basis_At_Upper`: nonbasic variable at upper bound
- `Basis_Fixed`: nonbasic variable at the fixed bound
- `Basis_Free`: nonbasic free variable
"""
@enum(BasisStatus,
    Basis_Basic,
    Basis_At_Lower,
    Basis_At_Upper,
    Basis_Fixed,
    Basis_Free
)
