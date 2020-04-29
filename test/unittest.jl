"""
The following example is taken from 
    Example 3.5 in "Introduction to Linear Optimization" Bertsimas and Tsitsiklis.

min  -10 x1 - 12 x2 - 12 x3
s.t.   x1 + 2 x2 + 2 x3 <= 20
     2 x1 +   x2 + 2 x3 <= 20
     2 x1 + 2 x2 +   x3 <= 20
     x1, x2, x3 >= 0
"""
# A = sparse([1; 2; 3; 1; 2; 3; 1; 2; 3], [1; 1; 1; 2; 2; 2; 3; 3; 3], [1.; 2.; 2.; 2; 1.; 2.; 2.; 2.; 1.])
# bl = [-Inf; -Inf; -Inf]
# bu = [20.; 20.; 20.;]
# c = [-10.; -12.; -12.;]
# xl = [0.; 0.; 0.;]; xu = [Inf; Inf; Inf]

"""
This is a slight modification to test various row/column bounds.

min  -10 x1 - 12 x2 - 12 x3
s.t. -20 <= - x1 - 2 x2 - 2 x3
            2 x1 +   x2 + 2 x3 <= 20
      10 <= 2 x1 + 2 x2 +   x3 <= 20
     -10 <= - x1 -   x2
     x1, x2 >= 0
     -1 <= x3 <= 10
"""
A = sparse([1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3], [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3], [-1.; 2.; 2.; -1; -2; 1.; 2.; -1.; -2.; 2.; 1.])
bl = [-20; -Inf; 10; -10]
bu = [Inf; 20.; 20.; Inf]
c = [-10.; -12.; -12.]
xl = [0.; 0.; -1.]; xu = [Inf; Inf; 10.]
lp = Simplex.LpData(c, xl, xu, A, bl, bu)
# Simplex.print(lp)

"""
min  -10 x1 - 12 x2 - 12 x3
s.t. - x1 - 2 x2 - 2 x3 - x4                == -20
     2 x1 +   x2 + 2 x3      + x5           ==  20
     2 x1 + 2 x2 +   x3           - x6      ==  10
     - x1 -   x2                       - x7 == -10
     x1, x2, x4, x5, x7 >= 0
     -1 <= x3 <= 10
      0 <= x6 <= 10
"""

canonical = Simplex.canonical_form(lp)
@test canonical.nrows == 4
@test canonical.ncols == 7
I = [1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3; 1; 2; 3; 4]
J = [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3; 4; 5; 6; 7]
V = Float64[-1; 2; 2; -1; -2; 1; 2; -1; -2; 2; 1; -1; 1; -1; -1]
A = sparse(I, J, V)
@test canonical.A == A
@test canonical.bl == [-20; 20; 10; -10]
@test canonical.bu == [-20; 20; 10; -10]
@test canonical.c == [-10; -12; -12; 0; 0; 0; 0]
@test canonical.xl == [0; 0; -1; 0; 0; 0; 0]
@test canonical.xu == [Inf; Inf; 10; Inf; Inf; 10; Inf]
@test canonical.is_canonical == true

"""
min                                           x8 + x9 + x10 + x11
s.t.   x1 + 2 x2 + 2 x3 + x4                + x8                  ==  20
     2 x1 +   x2 + 2 x3      + x5                + x9             ==  20
     2 x1 + 2 x2 +   x3           - x6                + x10       ==  10
       x1 +   x2                       + x7                 + x11 ==  10
     x1, x2, x4, x5, x7, x8, x9, x10, x11 >= 0
     -1 <= x3 <= 10
      0 <= x6 <= 10
"""
p1 = Simplex.PhaseOne.Artificial.reformulate(canonical)
@test p1.nrows == 4
@test p1.ncols == 11
I = [1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3; 1; 2; 3; 4; 1; 2; 3; 4]
J = [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3; 4; 5; 6; 7; 8; 9; 10; 11]
V = Float64[1; 2; 2; 1; 2; 1; 2; 1; 2; 2; 1; 1; 1; -1; 1; 1; 1; 1; 1]
A = sparse(I, J, V)
@test p1.A == A
@test p1.bl == [20; 20; 10; 10]
@test p1.bu == [20; 20; 10; 10]
@test p1.c == [0; 0; 0; 0; 0; 0; 0; 1; 1; 1; 1]
@test p1.xl == [0; 0; -1; 0; 0; 0; 0; 0; 0; 0; 0]
@test p1.xu == [Inf; Inf; 10; Inf; Inf; 10; Inf; Inf; Inf; Inf; Inf]

# The original problems should not be modified.
@test lp.nrows == 4
@test lp.ncols == 3
A = sparse([1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3], [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3], [-1.; 2.; 2.; -1; -2; 1.; 2.; -1.; -2.; 2.; 1.])
@test lp.A == A
@test lp.bl == [-20; -Inf; 10; -10]
@test lp.bu == [Inf; 20.; 20.; Inf]
@test lp.c == [-10.; -12.; -12.;]
@test lp.xl == [0; 0; -1]
@test lp.xu == [Inf; Inf; 10]
@test lp.is_canonical == false

@test canonical.nrows == 4
@test canonical.ncols == 7
I = [1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3; 1; 2; 3; 4]
J = [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3; 4; 5; 6; 7]
V = Float64[-1; 2; 2; -1; -2; 1; 2; -1; -2; 2; 1; -1; 1; -1; -1]
A = sparse(I, J, V)
@test canonical.A == A
@test canonical.bl == [-20; 20; 10; -10]
@test canonical.bu == [-20; 20; 10; -10]
@test canonical.c == [-10; -12; -12; 0; 0; 0; 0]
@test canonical.xl == [0; 0; -1; 0; 0; 0; 0]
@test canonical.xu == [Inf; Inf; 10; Inf; Inf; 10; Inf]
@test canonical.is_canonical == true

Simplex.phase_one(canonical)
@test canonical.status == Simplex.STAT_FEASIBLE
@test canonical.A * canonical.x == canonical.bl
@test (canonical.x .>= canonical.xl) == trues(canonical.ncols)
@test (canonical.x .<= canonical.xu) == trues(canonical.ncols)

spx = Simplex.SpxData(canonical)
Simplex.set_basis(spx, canonical.x)
# @show spx.basic
# @show spx.nonbasic
# @show spx.basis_status

Simplex.inverse(spx)
Simplex.compute_xB(spx)

while spx.status == Simplex.STAT_SOLVE
    Simplex.iterate(spx)
end
@test spx.x == [4.; 4.; 4.; 0.; 0.; 10.; 2.;]
