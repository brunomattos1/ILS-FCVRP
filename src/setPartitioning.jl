function hash(route::Vector{Int})
    edges = Vector{Tuple{Int, Int}}()
    for i = 1:length(route) - 1
        push!(edges, (route[i], route[i+1]))
    end
    return hash(edges)
end

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
        if solver.currSol.routeCapViolation[r] <= 1e-4 && solver.currSol.routeMinVisitsViolation[r] <= 1e-4 && solver.currSol.routeMaxVisitsViolation[r] <= 1e-4
            route = copy(solver.currSol.routes[r])
            if haskey(solver.pool, solver.currSol.routes[r])
                solver.poolCosts[route] = min(solver.poolCosts[route], solver.currSol.cost)
                solver.pool[route] = r
            else
                solver.pool[route] = r
                solver.poolCosts[route] = solver.currSol.cost
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

# Função de custo — recalculando via matriz de custos
function c(solver::Solver, route::Vector{Int})
    total = 0.0
    for i in 1:length(route)-1
        total += solver.data.costMatrix[route[i]+1, route[i+1]+1]
    end
    return total
end

function setPartitioning(solver::Solver)
    sp = Model(CPLEX.Optimizer)

    set_optimizer_attribute(sp, "CPXPARAM_MIP_Tolerances_UpperCutoff",
                            solver.bestFeasSol.cost + 0.5)

    # Extrai rotas diretamente do pool
    routes = collect(keys(solver.pool))
    veh(solver::Solver, route::Vector{Int}) = solver.pool[route]

    @variable(sp, λ[r = 1:length(routes)], Bin)
    @objective(sp, Min, sum(c(solver, routes[r]) * λ[r] for r in 1:length(routes)))

    # Restrição por família
    for f in 1:solver.data.numFamilies
        @constraint(sp,
            sum(β(solver, routes[r], f) * λ[r] for r in 1:length(routes)) ==
            solver.data.visits[f]
        )
    end

    # Restrição de cobertura por cliente
    @constraint(sp, [i = 1:length(solver.data.vertices)],
        sum(α(i, routes[r]) * λ[r] for r in 1:length(routes)) <= 1
    )

    # Número máximo de rotas
    # @constraint(sp, sum(λ[r] for r in 1:length(routes)) == solver.data.maxNbRoutes)

    # Cada veículo pode usar no máximo uma rota
    for v in 1:solver.data.maxNbRoutes
        @constraint(sp,
            sum(λ[r] for r in 1:length(routes) if veh(solver, routes[r]) == v) <= 1
        )
    end

    optimize!(sp)

    cost = 0.
    @show termination_status(sp)
    @show objective_value(sp)
    if termination_status(sp) == OPTIMAL
        for r = 1:length(routes)
            if value(λ[r]) >= 0.9
                for i = 1:length(routes[r])-1
                    cost += solver.data.costMatrix[routes[r][i]+1, routes[r][i+1]+1]
                end
            end
        end
        sol = Solution()
        sol.routes = [routes[r] for r = 1:length(routes) if value(λ[r]) >= 0.9]
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