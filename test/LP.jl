
@testset "LP.jl" begin

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
     # Simplex.print(lp)

     @testset "canonical form" begin
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
          orglp = Simplex.LpData(c, xl, xu, A, bl, bu)
          canonical = Simplex.canonical_form(orglp)
          @test canonical.nrows == 4
          @test canonical.ncols == 7
          @test canonical.A == sparse(
               [1; 2; 3; 4; 1; 2; 3; 4; 1; 2; 3; 1; 2; 3; 4], 
               [1; 1; 1; 1; 2; 2; 2; 2; 3; 3; 3; 4; 5; 6; 7], 
               Float64[-1; 2; 2; -1; -2; 1; 2; -1; -2; 2; 1; -1; 1; -1; -1])
          @test canonical.bl == [-20; 20; 10; -10]
          @test canonical.bu == [-20; 20; 10; -10]
          @test canonical.c == [-10; -12; -12; 0; 0; 0; 0]
          @test canonical.xl == [0; 0; -1; 0; 0; 0; 0]
          @test canonical.xu == [Inf; Inf; 10; Inf; Inf; 10; Inf]
          @test canonical.is_canonical == true

          # The original problems should not be modified.
          @test orglp.nrows == 4
          @test orglp.ncols == 3
          @test orglp.A == A
          @test orglp.bl == bl
          @test orglp.bu == bu
          @test orglp.c == c
          @test orglp.xl == xl
          @test orglp.xu == xu
          @test orglp.is_canonical == false

          orglp = nothing
     end

     @testset "cpu2gpu" begin
          cpu = Simplex.LpData(c, xl, xu, A, bl, bu)
          gpu = Simplex.cpu2gpu(cpu)
          @test gpu.TArray == CuArray
          @test typeof(gpu.bl) == CuArray{Float64,1,Nothing}
          @test typeof(gpu.bu) == CuArray{Float64,1,Nothing}
          @test typeof(gpu.c) == CuArray{Float64,1,Nothing}
          @test typeof(gpu.xl) == CuArray{Float64,1,Nothing}
          @test typeof(gpu.xu) == CuArray{Float64,1,Nothing}
          @test typeof(gpu.rd) == CuArray{Float64,1,Nothing}
          @test typeof(gpu.cd) == CuArray{Float64,1,Nothing}
          @test typeof(gpu.A) == CuArray{Float64,2,Nothing}

          cpu = nothing
          gpu = nothing
     end

     @testset "permute rows" begin
          """
          Permuted LP:

          min  -10 x1 - 12 x2 - 12 x3
          s.t.        2 x1 +   x2 + 2 x3 <= 20
               -20 <= - x1 - 2 x2 - 2 x3
                10 <= 2 x1 + 2 x2 +   x3 <= 20
               -10 <= - x1 -   x2
               x1, x2 >= 0
               -1 <= x3 <= 10
          """
          permlp = Simplex.LpData(c, xl, xu, A, bl, bu)
          Simplex.permute_rows(permlp)
          @test permlp.nrows == 4
          @test permlp.ncols == 3
          @test permlp.A == A[permlp.row_perm,:]
          @test permlp.bl == bl[permlp.row_perm]
          @test permlp.bu == bu[permlp.row_perm]
          @test permlp.c == c
          @test permlp.xl == xl
          @test permlp.xu == xu
          @test permlp.row_perm == [2, 1, 3, 4]

          permlp = nothing
     end
end