

function set_basis(spx::SpxData, basis::Vector{Int})
    # Set basic and nonbasic indices
    spx.basis_status = Vector{Int}(undef, ncols(spx.lpdata))
    spx.basic = basis
    spx.nonbasic = Int[]
    sizehint!(spx.nonbasic, ncols(spx.lpdata) - nrows(spx.lpdata))
    for j = 1:ncols(spx.lpdata)
        if !in(j, spx.basic)
            push!(spx.nonbasic, j)
            axl = abs(spx.lpdata.v_lb[j])
            axu = abs(spx.lpdata.v_ub[j])
            if spx.lpdata.v_lb[j] > -Inf && axl <= axu
                spx.basis_status[j] = BASIS_AT_LOWER
            elseif spx.lpdata.v_ub[j] < Inf && axl > axu
                spx.basis_status[j] = BASIS_AT_UPPER
            else
                spx.basis_status[j] = BASIS_FREE
            end
        else
            spx.basis_status[j] = BASIS_BASIC
        end
    end
    set_nonbasic(spx)
end

function set_basis_status(spx::SpxData, basis_status::Vector{Int})
    # Set basic and nonbasic indices
    spx.basis_status = basis_status
    spx.basic = Int[]
    spx.nonbasic = Int[]
    sizehint!(spx.basic, nrows(spx.lpdata))
    sizehint!(spx.nonbasic, ncols(spx.lpdata) - nrows(spx.lpdata))
    for j = 1:ncols(spx.lpdata)
        if basis_status[j] == BASIS_BASIC
            push!(spx.basic, j)
        else
            push!(spx.nonbasic, j)
        end
    end
    set_nonbasic(spx)
end

function set_basis(spx::SpxData, basis::Vector{Int}, basis_status::Vector{Int})
    # Set basic and nonbasic indices
    spx.basis_status = basis_status
    spx.basic = basis
    spx.nonbasic = Int[]
    sizehint!(spx.nonbasic, ncols(spx.lpdata) - nrows(spx.lpdata))
    for j = 1:ncols(spx.lpdata)
        if !in(j, spx.basic)
            push!(spx.nonbasic, j)
        end
    end
    set_nonbasic(spx)
end

function set_basis(spx::SpxData{T}, x::T) where T
    spx.basis_status = Vector{Int}(undef, ncols(spx.lpdata))
    spx.basic = Int[]
    spx.nonbasic = Int[]
    sizehint!(spx.basic, nrows(spx.lpdata))
    sizehint!(spx.nonbasic, ncols(spx.lpdata) - nrows(spx.lpdata))
    for j = 1:ncols(spx.lpdata)
        if x[j] == spx.lpdata.v_lb[j]
            spx.basis_status[j] = BASIS_AT_LOWER
            push!(spx.nonbasic, j)
        elseif x[j] == spx.lpdata.v_ub[j]
            spx.basis_status[j] = BASIS_AT_UPPER
            push!(spx.nonbasic, j)
        elseif length(spx.basic) < nrows(spx.lpdata)
            spx.basis_status[j] = BASIS_BASIC
            push!(spx.basic, j)
        else
            spx.basis_status[j] = BASIS_FREE
            push!(spx.nonbasic, j)
        end
    end
    spx.x .= x
end

function set_nonbasic(spx::SpxData)
    for j in spx.nonbasic
        if spx.basis_status[j] == BASIS_AT_LOWER
            spx.x[j] = spx.lpdata.v_lb[j]
        elseif spx.basis_status[j] == BASIS_AT_UPPER
            spx.x[j] = spx.lpdata.v_ub[j]
        elseif spx.basis_status[j] == BASIS_FREE
            # @warn("Free nonbasic variable (x$j) is set to zero.")
            spx.x[j] = 0.0
        end
    end
end
