import Simplex: nrows, ncols

@testset "Artificial.jl" begin
    """
    Canonical form:

    min  -10 x1 - 12 x2 - 12 x3
    s.t. - x1 - 2 x2 - 2 x3 - x4                == -20
        2 x1 +   x2 + 2 x3      + x5           ==  20
        2 x1 + 2 x2 +   x3           - x6      ==  10
        - x1 -   x2                       - x7 == -10
        x1, x2, x4, x5, x7 >= 0
        -1 <= x3 <= 10
        0 <= x6 <= 10
    """
    A = sparse(
        [1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3; 1; 2; 3; 4], 
        [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3; 4; 5; 6; 7], 
        Float64[-1; 2; 2; -1; -2; 1; 2; -1; -2; 2; 1; -1; 1; -1; -1])
    b = Float64[-20; 20; 10; -10]
    c = Float64[-10; -12; -12; 0; 0; 0; 0]
    xl = Float64[0; 0; -1; 0; 0; 0; 0]
    xu = Float64[Inf; Inf; 10; Inf; Inf; 10; Inf]
    senses = fill(MatOI.EQUAL_TO, 4)
    lp = MatOI.LPSolverForm(MOI.MIN_SENSE, c, A, b, senses, xl, xu)

    @testset "reformulate" begin
        """
        Phase-one form:
        min                                           x8 + x9 + x10 + x11
        s.t. - x1 - 2 x2 - 2 x3 - x4                - x8                  ==  -20
            2 x1 +   x2 + 2 x3      + x5                + x9             ==  20
            2 x1 + 2 x2 +   x3           - x6                + x10       ==  10
            - x1 -   x2                       - x7                 - x11 ==  -10
            x1, x2, x4, x5, x7, x8, x9, x10, x11 >= 0
            -1 <= x3 <= 10
            0 <= x6 <= 10
        """
        p1, artif_col_idx = Simplex.PhaseOne.Artificial.reformulate(lp)
        @test nrows(p1) == 4
        @test ncols(p1) == 11
        @test p1.A == sparse(
            [1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3; 1; 2; 3; 4; 1; 2; 3; 4], 
            [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3; 4; 5; 6; 7; 8; 9; 10; 11], 
            Float64[-1; 2; 2; -1; -2; 1; 2; -1; -2; 2; 1; -1; 1; -1; -1; -1; 1; 1; -1])
        @test p1.b == [-20; 20; 10; -10]
        @test p1.c == [0; 0; 0; 0; 0; 0; 0; 1; 1; 1; 1]
        @test p1.v_lb == [0; 0; -1; 0; 0; 0; 0; 0; 0; 0; 0]
        @test p1.v_ub == [Inf; Inf; 10; Inf; Inf; 10; Inf; Inf; Inf; Inf; Inf]

        # The original problems should not be modified.
        @test nrows(lp) == 4
        @test ncols(lp) == 7
        @test lp.A == A
        @test lp.b == b
        @test lp.c == c
        @test lp.v_lb == xl
        @test lp.v_ub == xu
    end

    lp = nothing
end