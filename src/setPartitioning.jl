# function hash(route::Vector{Int})
#     edges = Vector{Tuple{Int, Int}}()
#     for i = 1:length(route) - 1
#         push!(edges, (route[i], route[i+1]))
#     end
#     return hash(edges)
# end

# function solHash(sol::Solution)
#     edges = Vector{Tuple{Int, Int}}()
#     for r = 1:length(sol.routes)
#         for i = 1:length(sol.routes[r]) - 1
#             push!(edges, (sol.routes[r][i], sol.routes[r][i+1]))
#         end
#     end
#     return hash(edges)
# end


function push!(solver::Solver)
    for r = 1:length(solver.currSol.routes)
        if solver.currSol.routeCapViolation[r] <= 1e-6 && solver.currSol.routeMinVisitsViolation[r] <= 1e-6 && solver.currSol.routeMaxVisitsViolation[r] <= 1e-6
            if haskey(solver.pool, solver.currSol.routes[r])
                solver.pool[copy(solver.currSol.routes[r])][1] = min(solver.pool[solver.currSol.routes[r]][1], solver.currSol.cost)
            else
                solver.pool[copy(solver.currSol.routes[r])] = Float64[solver.currSol.cost, r]
            end
        end
    end
end

function α(i::Int, route::Vector{Int})
    return i in route
end

function β(solver::Solver, route::Vector{Int}, family::Int)
    visits = 0
    for i in route
        if i == 0
            continue
        end
        if solver.data.vertices[i].family == family
            visits += 1
        end
    end
    return visits
end

function c(solver::Solver, pool::Vector{Vector{Int}}, r::Int)
    cost = 0.
    for i = 1:length(pool[r])-1
        cost += solver.data.costMatrix[pool[r][i]+1, pool[r][i+1]+1]
    end
    return cost
end

function setPartitioning(solver::Solver)
    sp = Model(CPLEX.Optimizer)
    set_optimizer_attribute(sp, "CPXPARAM_MIP_Tolerances_UpperCutoff", solver.bestFeasSol.cost + 0.1)
    pool = collect(keys(solver.pool))
    # for (r, c) in solver.pool
    #     push!(pool, r)
    # end
    @variable(sp, λ[r = 1:length(pool)], Bin)
    @objective(sp, Min, sum(c(solver, pool, r)λ[r] for r = 1:length(pool)))

    for f = 1:solver.data.numFamilies
        @constraint(sp, sum(β(solver, pool[r], f)λ[r] for r = 1:length(pool)) >= solver.data.visits[f])
    end
    @constraint(sp, [i = 1:length(solver.data.vertices)], sum(α(i, pool[r])λ[r] for r = 1:length(pool)) <= 1)
    for vehicle = 1:solver.data.maxNbRoutes
        @constraint(sp, sum(λ[r] for r = 1:length(pool) if solver.pool[pool[r]][2] == vehicle) <= 1)
    end
    optimize!(sp)
    cost = 0.
    @show termination_status(sp)
    @show objective_value(sp)
    if termination_status(sp) == OPTIMAL
        for r = 1:length(pool)
            if value(λ[r]) >= 0.9
                for i = 1:length(pool[r])-1
                    cost += solver.data.costMatrix[pool[r][i]+1, pool[r][i+1]+1]
                end
            end
        end
        sol = Solution()
        sol.routes = [pool[r] for r = 1:length(pool) if value(λ[r]) >= 0.9]
        sol.cost, sol.dist = cost, cost
        return sol
    elseif termination_status(sp) == TIME_LIMIT
        if primal_status(sp) == FEASIBLE_POINT
            for r = 1:length(pool)
                if value(λ[r]) >= 0.9
                    for i = 1:length(pool[r])-1
                        cost += solver.data.costMatrix[pool[r][i]+1, pool[r][i+1]+1]
                    end
                end
            end
            if cost < solver.bestSol.cost - 0.001
                return Solution([pool[r] for r = 1:length(pool) if value(λ[r]) >= 0.9], 
                cost, 
                [computeViolation(solver, pool[r]) for r = 1:length(pool) if value(λ[r]) >= 0.9], 
                sum([computeViolation(solver, pool[r]) for r = 1:length(pool) if value(λ[r]) >= 0.9]))
            end
        else
            return solver.bestSol
        end
    else
        return solver.bestSol
    end
end