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
    # nrow = nrow - 1 # glpk puts the objective row in the constraint matrix, dunno why... 
    ncol::Int = GLPK.get_num_cols(lp)
    
    index1 = Array{Int32,1}(undef, nrow)
    coef1 = Array{Float64,1}(undef, nrow)
    
    starts = Vector{Int64}(undef, ncol+1)
    idx = Array{Int64,1}(undef, 0)
    elt = Vector{Float64}(undef, 0)
    nnz = 0

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

    # @show objrow, nrow, ncol
    sel = Vector{Bool}(undef, nrow)
    for i in 1:ncol
        starts[i] = nnz+1
        nnz1 = GLPK.get_mat_col(lp, i, index1, coef1)
        fill!(sel, false)
        for k in 1:nnz1
            if (index1[k] != objrow)
                sel[k] = true
            end
            if (objrow > 0 && index1[k] > objrow)
                index1[k] -= 1
            end
        end
        # @show index1[sel]
        nnz1 = sum(sel)
        idx = [idx; index1[sel]]
        elt = [elt; coef1[sel]]
        nnz += nnz1
    end
    starts[ncol+1] = nnz+1

    A = SparseMatrixCSC(nrow, ncol, starts, idx, elt)

    return c, xlb, xub, l, u, A
end