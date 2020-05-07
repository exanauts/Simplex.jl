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
        Presolved LP:

        min  -10 x1 - 12 x2 - 12 x3
        s.t.          x1 + 0.5 x2 +     x3 <= 10
                 -0.5 x1 -     x2 -     x3 >= -10
             5 <=     x1 +     x2 + 0.5 x3 <= 10
            x1, x2 >= 0
            -1 <= x3 <= 10
        """
        lp = Simplex.LpData(c, xl, xu, A, bl, bu)
        Simplex.presolve(lp)
        Simplex.scaling!(lp)
        @test lp.A == sparse([1 0.5 1; -0.5 -1 -1; 1 1 0.5])
        @test lp.bl == [-Inf, -10., 5.]
        @test lp.bu == [10., Inf, 10.]
        @test lp.xl == xl
        @test lp.xu == xu
        @test lp.c == c

        B = Simplex.PhaseOne.Cplex.cplex_basis(lp)
        @test B == [4,5,6]

        """
        canonical:
            minimize -10 x1 - 12 x2 - 12 x3
            subject to
                     x1 + 0.5 x2     + x3 + x4 == 10
                -0.5 x1     - x2     - x3 - x5 == -10
                     x1     + x2 + 0.5 x3 - x6 == 5
                     x1, x2, x4, x5 >= 0
                     -1 <= x3 <= 10
                     0 <= x6 <= 5
        """
        canonical = Simplex.canonical_form(lp)
        @test canonical.A == sparse([1.0 0.5 1.0 1.0 0.0 0.0; -0.5 -1.0 -1.0 0.0 -1.0 0.0; 1.0 1.0 0.5 0.0 0.0 -1.0])
        @test canonical.xl == [0.0, 0.0, -1.0, 0.0, 0.0, 0.0]
        @test canonical.xu == [Inf, Inf, 10.0, Inf, Inf, 5.0]
        @test canonical.bl == [10.0, -10.0, 5.0]

        """
        phase-one:
            minimize 0
            subject to
                c1:     x1 + 0.5 x2     + x3 + x4           == 10
                c2:-0.5 x1     - x2     - x3      - x5      == -10
                c3:     x1     + x2 + 0.5 x3           - x6 == 5
                x1, x2, x4, x5 >= 0
                -1 <= x3 <= 10
                0 <= x6 <= 5
                
        """
        p1lp = Simplex.PhaseOne.Artificial.reformulate(canonical, basis = B)
        @test p1lp.A == canonical.A
        @test p1lp.xl == canonical.xl
        @test p1lp.xu == canonical.xu
        @test p1lp.bl == canonical.bl
        @test p1lp.c == zeros(p1lp.ncols)

        is_feasible = Simplex.PhaseOne.Cplex.compute_x(p1lp, B)
        @test p1lp.x == Float64[0, 0, -1, 11, 11, -5.5]
        @test is_feasible == false

        """
        CPLEX basis LP:
            minimize x7
            subject to
                c1:     x1 + 0.5 x2     + x3 + x4           == 10
                c2:-0.5 x1     - x2     - x3      - x5      == -10
                c3:     x1     + x2 + 0.5 x3           - x6 == 5
                c4:                                      x6 + x7 - x8 == 0
                        x7..x8 >= 0
        """
        cpxlp, newB = Simplex.PhaseOne.Cplex.reformulate(p1lp, 6, 0, B)
        @test cpxlp.A == sparse(
            [1,2,3,1,2,3,1,2,3,1,2,3,4,4,4],
            [1,1,1,2,2,2,3,3,3,4,5,6,6,7,8],
            Float64[1,-0.5,1,0.5,-1,1,1,-1,0.5,1,-1,-1,1,1,-1])
        @test cpxlp.bl == Float64[10,-10,5,0]
        @test cpxlp.xl == [fill(-Inf,6); zeros(2)]
        @test cpxlp.xu == fill(Inf,8)
        @test cpxlp.c == [zeros(6); 1.; 0.]
        @test cpxlp.x == Float64[0,0,-1,11,11,-5.5,5.5,0]
        @test newB == [4,5,6,7]
    end
end
