# Bland's rule
function pivot_Bland(spx::SpxData)
    spx.enter = -1

    # compute reduced cost
    compute_reduced_cost(spx)
    # @show spx.r
    # @show spx.nonbasic

    min_enter = spx.lpdata.ncols + 1
    for j = 1:length(spx.r)
        if spx.nonbasic[j] < min_enter
            if spx.basis_status[spx.nonbasic[j]] == BASIS_AT_UPPER
                if spx.r[j] > 1e-10
                    spx.enter = spx.nonbasic[j]
                    spx.enter_pos = j
                    min_enter = spx.enter
                end
            else
                if spx.r[j] < -1e-10
                    spx.enter = spx.nonbasic[j]
                    spx.enter_pos = j
                    min_enter = spx.enter
                end
            end
        end
    end
    @show spx.enter, spx.r[spx.enter_pos]
end

# Steepest-edge rule
"""
Steepest-edge rule:

This is based on the following references.
1. Bieling et al. An efficient GPU implementation of the revised simplex method. 2010
2. Forest and Goldfarb. Steepest-edge simplex algorithms for linear programming. 1992
3. Goldfarb and Reid. A practicable steepest-edge simplex algorithm. 1977
"""
function pivot_steepest_edge(spx::SpxData)

    compute_reduced_cost(spx)
    # @show spx.r
    # @show spx.nonbasic

    compute_steepest_edge_weights(spx)

    # compute the local slope
    # @show length(spx.r), length(spx.gamma)
    s = (spx.r).^2 ./ spx.gamma

    spx.enter = -1
    max_s = -Inf
    for j = 1:length(spx.r)
        if s[j] > max_s
            if spx.basis_status[spx.nonbasic[j]] == BASIS_AT_UPPER && sign(spx.r[j]) > 0
                spx.enter = spx.nonbasic[j]
                spx.enter_pos = j
                max_s = s[j]
            elseif spx.basis_status[spx.nonbasic[j]] == BASIS_AT_LOWER && sign(spx.r[j]) < 0
                spx.enter = spx.nonbasic[j]
                spx.enter_pos = j
                max_s = s[j]
            end
        end
    end
    # @show spx.enter, s[spx.enter_pos]
end

function compute_steepest_edge_weights(spx::SpxData)
    @timeit TO "compute steepest edge weights" begin
        if spx.iter == 1
            spx.gamma = zeros(length(spx.nonbasic))
            Threads.@threads for j = 1:length(spx.nonbasic)
                g = spx.invB * spx.lpdata.A[:,spx.nonbasic[j]]
                @inbounds spx.gamma[j] = g' * g
            end
        else
            # Here, spx.enter and spx.leave were obtained from the previous iteration.
            gamma_e = 1 + spx.d' * spx.d
            @timeit TO "gamma_j" begin
                Threads.@threads for j = 1:length(spx.nonbasic)
                    aj = Vector(spx.lpdata.A[:,spx.nonbasic[j]])
                    alpha = transpose(spx.invB[:,spx.leave]) * aj
                    @inbounds spx.gamma[j] = spx.gamma[j] + 2 * alpha * aj' * spx.v + alpha^2 * gamma_e
                end
            end

            @timeit TO "gamm_e" begin
                # spx.gamma[spx.enter_pos] = gamma_e / spx.d[spx.leave]^2
                g = spx.invB * spx.lpdata.A[:,spx.nonbasic[spx.enter_pos]]
                spx.gamma[spx.enter_pos] = g' * g
            end
        end
    end
end

# Dantzig's rule
function pivot_Dantzig(spx::SpxData)
    spx.enter = -1

    # compute reduced cost
    compute_reduced_cost(spx)

    max_r = -Inf
    for j = 1:length(spx.r)
        if abs(spx.r[j]) > max_r
            if spx.basis_status[spx.nonbasic[j]] == BASIS_AT_UPPER
                if spx.r[j] > 1e-6
                    spx.enter = spx.nonbasic[j]
                    spx.enter_pos = j
                    max_r = spx.r[j]
                end
            else
                if spx.r[j] < -1e-6
                    spx.enter = spx.nonbasic[j]
                    spx.enter_pos = j
                    max_r = -spx.r[j]
                end
            end
        end
    end
    # @show spx.enter, spx.r[spx.enter_pos]
end
