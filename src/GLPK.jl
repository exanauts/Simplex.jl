#=
These functions are taken 
  from https://github.com/mlubin/jlSimplex/blob/master/jlSimplex.jl 
  and modified as needed.
=#

using GLPK

function GLPK_solve(mpsfile::String)
    lp = GLPK.Prob()
    ret = GLPK.read_mps(lp, GLPK.MPS_FILE, mpsfile)
    @assert ret == 0

    lps_opts = GLPK.SimplexParam()
    # lps_opts.presolve = GLPK.ON
    lps_opts.msg_lev = GLPK.MSG_ALL
    lps_opts.meth = GLPK.PRIMAL

    GLPK.simplex(lp, lps_opts)
end

function GLPK_read_mps(mpsfile::String) 

    # Read MPS file from GLPK
    lp = GLPK.Prob()
    ret = GLPK.read_mps(lp, GLPK.MPS_FILE, mpsfile)
    @assert ret == 0

    # Numbers of rows and columns
    nrow::Int = GLPK.get_num_rows(lp)
    ncol::Int = GLPK.get_num_cols(lp)
    nnz::Int = GLPK.get_num_nz(lp);
    
    index1 = Array{Int32,1}(undef, nrow)
    coef1 = Array{Float64,1}(undef, nrow)

    c = Vector{Float64}(undef, ncol)
    xlb = Vector{Float64}(undef, ncol)
    xub = Vector{Float64}(undef, ncol)
    l = Vector{Float64}(undef, nrow)
    u = Vector{Float64}(undef, nrow)

    for i in 1:ncol
        c[i] = GLPK.get_obj_coef(lp,i)
        t = GLPK.get_col_type(lp,i)
        if t == GLPK.FR
            xlb[i] = typemin(Float64)
            xub[i] = typemax(Float64)
        elseif t == GLPK.UP
            xlb[i] = typemin(Float64)
            xub[i] = GLPK.get_col_ub(lp,i)
        elseif t == GLPK.LO
            xlb[i] = GLPK.get_col_lb(lp,i)
            xub[i] = typemax(Float64)
        elseif t == GLPK.DB || t == GLPK.FX
            xlb[i] = GLPK.get_col_lb(lp,i)
            xub[i] = GLPK.get_col_ub(lp,i)
        end
    end

    objname = GLPK.get_obj_name(lp)
    GLPK.create_index(lp)
    objrow = GLPK.find_row(lp,objname)

    for i in 1:nrow
        reali = i
        # if (i >= objrow)
        #     reali += 1
        # end
        t = GLPK.get_row_type(lp,reali)
        if t == GLPK.UP
            l[i] = typemin(Float64)
            u[i] = GLPK.get_row_ub(lp,reali)
        elseif t == GLPK.LO
            l[i] = GLPK.get_row_lb(lp,reali)
            u[i] = typemax(Float64)
        elseif t == GLPK.DB || t == GLPK.FX
            l[i] = GLPK.get_row_lb(lp,reali)
            u[i] = GLPK.get_row_ub(lp,reali)
        end
    end

    Arows = Int[]
    Acols = Int[]
    Avals = Float64[]
    sizehint!(Arows, nnz)
    sizehint!(Acols, nnz)
    sizehint!(Avals, nnz)
    for j in 1:ncol
        nnz1 = GLPK.get_mat_col(lp, j, index1, coef1)
        for k = 1:nnz1
            if index1[k] == objrow
                continue
            end
            if objrow > 0 && index1[k] > objrow
                push!(Arows, index1[k]-1)
            else
                push!(Arows, index1[k])
            end
            push!(Acols, j)
            push!(Avals, coef1[k])
        end
    end

    A = sparse(Arows, Acols, Avals, nrow, ncol)

    return c, xlb, xub, l, u, A
end