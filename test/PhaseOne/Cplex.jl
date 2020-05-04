@testset "Cplex.jl" begin
    """
    Original LP:

    min  -10 x1 - 12 x2 - 12 x3
    s.t. -20 <= - x1 - 2 x2 - 2 x3
            2 x1 +   x2 + 2 x3 <= 20
        10 <= 2 x1 + 2 x2 +   x3 <= 20
        -10 <= - x1 -   x2
        x1, x2 >= 0
        -1 <= x3 <= 10
    """
    A = sparse([1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3], [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3], [-1.; 2.; 2.; -1; -2; 1.; 2.; -1.; -2.; 2.; 1.])
    bl = [-20.; -Inf; 10.; -10.]
    bu = [Inf; 20.; 20.; Inf]
    c = [-10.; -12.; -12.]
    xl = [0.; 0.; -1.]; xu = [Inf; Inf; 10.]
    @testset "cplex_basis" begin
        """
        Permuted LP:

        min  -10 x1 - 12 x2 - 12 x3
        s.t.       2 x1 +   x2 + 2 x3 <= 20
            -20 <= - x1 - 2 x2 - 2 x3
             10 <= 2 x1 + 2 x2 +   x3 <= 20
            -10 <= - x1 -   x2
            x1, x2 >= 0
            -1 <= x3 <= 10
        """
        lp = Simplex.LpData(c, xl, xu, A, bl, bu)
        Simplex.presolve(lp)
        B = Simplex.PhaseOne.Cplex.cplex_basis(lp)
        @test B = [4,5,6,7]
    end
end
