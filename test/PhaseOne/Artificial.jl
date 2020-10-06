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
    bl = Float64[-20; 20; 10; -10]
    bu = Float64[-20; 20; 10; -10]
    c = Float64[-10; -12; -12; 0; 0; 0; 0]
    xl = Float64[0; 0; -1; 0; 0; 0; 0]
    xu = Float64[Inf; Inf; 10; Inf; Inf; 10; Inf]
    lp = Simplex.LpData(c, xl, xu, A, bl, bu)
    lp.is_canonical = true

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
        p1 = Simplex.PhaseOne.Artificial.reformulate(lp)
        @test p1.nrows == 4
        @test p1.ncols == 11
        @test p1.A == sparse(
            [1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3; 1; 2; 3; 4; 1; 2; 3; 4], 
            [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3; 4; 5; 6; 7; 8; 9; 10; 11], 
            Float64[-1; 2; 2; -1; -2; 1; 2; -1; -2; 2; 1; -1; 1; -1; -1; -1; 1; 1; -1])
        @test p1.bl == [-20; 20; 10; -10]
        @test p1.bu == [-20; 20; 10; -10]
        @test p1.c == [0; 0; 0; 0; 0; 0; 0; 1; 1; 1; 1]
        @test p1.xl == [0; 0; -1; 0; 0; 0; 0; 0; 0; 0; 0]
        @test p1.xu == [Inf; Inf; 10; Inf; Inf; 10; Inf; Inf; Inf; Inf; Inf]

        # The original problems should not be modified.
        @test lp.nrows == 4
        @test lp.ncols == 7
        @test lp.A == A
        @test lp.bl == bl
        @test lp.bu == bu
        @test lp.c == c
        @test lp.xl == xl
        @test lp.xu == xu
        @test lp.is_canonical == true
    end

    lp = nothing
end