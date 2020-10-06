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
    lp = GLPK.glp_create_prob()
    ret = GLPK.glp_read_mps(lp, GLPK.GLP_MPS_FILE, C_NULL, mpsfile)
    @assert ret == 0

    # Numbers of rows and columns
    nrow::Int = GLPK.glp_get_num_rows(lp)
    ncol::Int = GLPK.glp_get_num_cols(lp)
    nnz::Int = GLPK.glp_get_num_nz(lp);
    @show nrow
    @show ncol
    @show nnz
    
    index1 = Array{Int32,1}(undef, nrow)
    coef1 = Array{Float64,1}(undef, nrow)

    c = Vector{Float64}(undef, ncol)
    xlb = Vector{Float64}(undef, ncol)
    xub = Vector{Float64}(undef, ncol)
    l = Vector{Float64}(undef, nrow)
    u = Vector{Float64}(undef, nrow)

    for i in 1:ncol
        c[i] = GLPK.glp_get_obj_coef(lp,i)
        @show i, c[i]
        t = GLPK.glp_get_col_type(lp,i)
        @show t
        if t == GLPK.GLP_FR
            xlb[i] = typemin(Float64)
            xub[i] = typemax(Float64)
        elseif t == GLPK.GLP_UP
            xlb[i] = typemin(Float64)
            xub[i] = GLPK.glp_get_col_ub(lp,i)
        elseif t == GLPK.GLP_LO
            xlb[i] = GLPK.glp_get_col_lb(lp,i)
            xub[i] = typemax(Float64)
        elseif t == GLPK.GLP_DB || t == GLPK.GLP_FX
            xlb[i] = GLPK.glp_get_col_lb(lp,i)
            xub[i] = GLPK.glp_get_col_ub(lp,i)
        else
            @error "Unexpected column type $t"
        end
    end

    objname = GLPK.glp_get_obj_name(lp)
    GLPK.glp_create_index(lp)
    objrow = GLPK.glp_find_row(lp,objname)

    for i in 1:nrow
        reali = i
        # if (i >= objrow)
        #     reali += 1
        # end
        t = GLPK.glp_get_row_type(lp,reali)
        if t == GLPK.GLP_UP
            l[i] = typemin(Float64)
            u[i] = GLPK.glp_get_row_ub(lp,reali)
        elseif t == GLPK.GLP_LO
            l[i] = GLPK.glp_get_row_lb(lp,reali)
            u[i] = typemax(Float64)
        elseif t == GLPK.GLP_DB || t == GLPK.GLP_FX
            l[i] = GLPK.glp_get_row_lb(lp,reali)
            u[i] = GLPK.glp_get_row_ub(lp,reali)
        end
    end

    Arows = Int[]
    Acols = Int[]
    Avals = Float64[]
    sizehint!(Arows, nnz)
    sizehint!(Acols, nnz)
    sizehint!(Avals, nnz)
    for j in 1:ncol
        nnz1 = GLPK.glp_get_mat_col(lp, j, index1, coef1)
        for k = 1:nnz1
            if index1[k+1] == objrow
                continue
            end
            if objrow > 0 && index1[k+1] > objrow
                push!(Arows, index1[k+1]-1)
            else
                push!(Arows, index1[k+1])
            end
            push!(Acols, j)
            push!(Avals, coef1[k+1])
        end
    end

    A = sparse(Arows, Acols, Avals, nrow, ncol)

    return c, xlb, xub, l, u, A
end