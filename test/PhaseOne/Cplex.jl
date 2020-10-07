import Simplex: nrows, ncols

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
        lp = MatOI.LPForm(MOI.MIN_SENSE, c, A, bl, bu, xl, xu)
        Simplex.presolve(lp)
        Simplex.scaling!(lp)
        B = Simplex.PhaseOne.Cplex.cplex_basis(lp)
        @test B == [4,5,6,7]

        """
        canonical:
            minimize -10 x1 - 12 x2 - 12 x3
            subject to
                -0.5 x1     - x2     - x3 - x4 == -10
                     x1 + 0.5 x2     + x3 + x5 == 10
                     x1     + x2 + 0.5 x3 - x6 == 5
                    -x1     - x2          - x7 == -10
                     x1, x2, x4, x5, x7 >= 0
                     -1 <= x3 <= 10
                     0 <= x6 <= 5
        """
        canonical = Simplex.canonical_form(lp)
        @test canonical.A == sparse([
            -0.5 -1.0 -1.0 -1.0 0.0 0.0 0.0; 
            1.0 0.5 1.0 0.0 1.0 0.0 0.0; 
            1.0 1.0 0.5 0.0 0.0 -1.0 0.0;
            -1.0 -1.0 0.0 0.0 0.0 0.0 -1.0])
        @test canonical.v_lb ≈ [0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0]
        @test canonical.v_ub ≈ [Inf, Inf, 10.0, Inf, Inf, 5.0, Inf]
        @test canonical.b ≈ [-10.0, 10.0, 5.0, -10.0]

        """
        phase-one:
            minimize 0
            subject to
                c1:-0.5 x1     - x2     - x3 - x4                == -10
                c2:     x1 + 0.5 x2     + x3      + x4           == 10
                c3:     x1     + x2 + 0.5 x3           - x6      == 5
                c4:   - x1     - x2                         - x7 == -10
                x1, x2, x4, x5, x7 >= 0
                -1 <= x3 <= 10
                0 <= x6 <= 5
                
        """
        p1lp = Simplex.PhaseOne.Artificial.reformulate(canonical, basis = B)
        @test p1lp.A == canonical.A
        @test p1lp.v_lb == canonical.v_lb
        @test p1lp.v_ub == canonical.v_ub
        @test p1lp.b == canonical.b
        @test p1lp.c == zeros(ncols(p1lp))

        x, is_feasible = Simplex.PhaseOne.Cplex.compute_x(p1lp, B)
        @test x ≈ Float64[0, 0, -1, 11, 11, -5.5, 10]
        @test is_feasible == false

        num_xvars = ncols(canonical)
        num_artif = ncols(p1lp) - num_xvars
        @test num_xvars == 7
        @test num_artif == 0

        """
        CPLEX basis LP:
            minimize x8
            subject to
                c1:-0.5 x1     - x2     - x3 - x4                == -10
                c2:     x1 + 0.5 x2     + x3      + x5           == 10
                c3:     x1     + x2 + 0.5 x3           - x6      == 5
                c4:   - x1     - x2                         - x7 == -10
                c5:                                      x6 + x8 - x9 == 0
                        x8..x9 >= 0
        """
        cpxlp, newB = Simplex.PhaseOne.Cplex.reformulate(p1lp, x, num_xvars, num_artif, B)
        @test cpxlp.A == sparse(
            [-0.5 -1.0 -1.0 -1.0 0.0  0.0  0.0 0.0  0.0; 
              1.0  0.5  1.0  0.0 1.0  0.0  0.0 0.0  0.0; 
              1.0  1.0  0.5  0.0 0.0 -1.0  0.0 0.0  0.0;
             -1.0 -1.0  0.0  0.0 0.0  0.0 -1.0 0.0  0.0;
              0.0  0.0  0.0  0.0 0.0  1.0  0.0 1.0 -1.0])
        @test cpxlp.b ≈ Float64[-10,10,5,-10,0]
        @test cpxlp.v_lb ≈ [fill(-Inf,7); zeros(2)]
        @test cpxlp.v_ub ≈ fill(Inf,9)
        @test cpxlp.c == [zeros(7); 1.; 0.]
        @test newB == [4,5,6,7,8]
    end
end
