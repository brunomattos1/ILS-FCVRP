function constructSol!(solver::Solver)
    # clarkeWright(solver)
    # bestParallelInsertion(solver)
    if rand(solver.seed) <= 1.5
        bestParallelInsertion(solver)
    else
        clarkeWright(solver)
    end
end


function bestParallelInsertion(solver::Solver)
    vertices = deepcopy(solver.data.vertices)
    nbRoutes = min(length(vertices), solver.data.maxNbRoutes)
    costMatrix = getCostMatrix(solver)
    solver.currSol = Solution()
    visits = zeros(Int, solver.data.numFamilies)
    currSol = solver.currSol
    for r = 1:nbRoutes
        selectedIdx = rand(solver.seed, 1:length(vertices))

        selected = vertices[selectedIdx]
        while visits[selected.family] >= solver.data.visits[selected.family]
            selectedIdx = rand(solver.seed, 1:length(vertices))
            selected = vertices[selectedIdx]
        end
        visits[selected.family] += 1
        push!(currSol.routes, Int[0, selected.id, 0])
        currSol.dist += costMatrix[1, selected.id+1] + costMatrix[selected.id+1, 1]

        currSol.capViolation += max(0, selected.demand - solver.data.vehicles[r].capacity)
        push!(currSol.routeCapViolation, max(0, selected.demand - solver.data.vehicles[r].capacity))
        push!(currSol.demands, selected.demand)
        push!(currSol.capacities, solver.data.vehicles[r].capacity)

        # visits = length(solver.currSol.routes[r]) - 2
        currSol.minVisitsViolation += max(0, solver.data.minVisits - 1)
        currSol.maxVisitsViolation += max(0, 1 - solver.data.maxVisits)

        push!(currSol.routeMinVisitsViolation, max(0, solver.data.minVisits - 1))
        push!(currSol.routeMaxVisitsViolation, max(0, 1 - solver.data.maxVisits))

        currSol.cost = currSol.dist + solver.params.capPenalty*currSol.capViolation + solver.params.minVisitsPenalty*currSol.minVisitsViolation + solver.params.maxVisitsPenalty*currSol.maxVisitsViolation
        # vertices[selectedIdx], vertices[r] = vertices[r], vertices[selectedIdx]
        deleteat!(vertices, selectedIdx)
    end

    while true
        allFamiliesServed = true
        for f in keys(solver.data.visits)
            if visits[f] < solver.data.visits[f]
                allFamiliesServed = false
                break
            end
        end

        if allFamiliesServed
            break
        end

        bestCost = Inf
        bestI = -1
        bestJ = -1
        bestR = -1
        bestDist = currSol.dist
        bestCapViol = 0.0
        bestMinVisitsViol = 0.0
        bestMaxVisitsViol = 0.0
        for i = 1:length(vertices)
            fam = vertices[i].family

            # Checa se ainda é necessário visitar essa família
            if visits[fam] >= solver.data.visits[fam]
                continue
            end

            for r = 1:length(currSol.routes)
                if length(currSol.routes[r]) - 2 >= solver.data.maxVisits
                    continue
                end
                for j = 2:length(currSol.routes[r])-1  # posição de inserção
                    dist = evalBestInsertion(currSol.dist, currSol.routes, solver, r, vertices[i].id, j)
                    capViol, minVisitsViol, maxVisitsViol = computeViolationInsertion(solver, r, vertices[i].id, j)

                    penalizedCost = dist + solver.params.capPenalty*(currSol.capViolation - currSol.routeCapViolation[r] + capViol)
                    penalizedCost += solver.params.minVisitsPenalty*(currSol.minVisitsViolation - currSol.routeMinVisitsViolation[r] + minVisitsViol)
                    penalizedCost += solver.params.maxVisitsPenalty*(currSol.maxVisitsViolation - currSol.routeMaxVisitsViolation[r] + maxVisitsViol)

                    if improved(penalizedCost, bestCost)
                        bestCost = penalizedCost
                        bestI = i
                        bestJ = j
                        bestR = r
                        bestDist = dist
                        bestCapViol = capViol
                        bestMinVisitsViol = minVisitsViol
                        bestMaxVisitsViol = maxVisitsViol
                    end
                end
            end
        end
        # if bestI > 0
            applyMoveInsertion(solver, bestDist, bestCost, bestCapViol, bestMinVisitsViol, bestMaxVisitsViol, bestR, vertices[bestI], bestJ)
            # vertices[bestI], vertices[k] = vertices[k], vertices[bestI]
            visits[vertices[bestI].family] += 1
            deleteat!(vertices, bestI)
        # end
    end
    vertices = solver.data.vertices  # assumindo que o depósito é o 1º
    
    # criar um dicionário: família => todos os vértices dessa família
    family_vertices = Dict{Int, Vector{Int}}()
    for v in vertices
        push!(get!(family_vertices, v.family, Int[]), v.id)
    end

    # coletar todos os vértices que aparecem nas rotas
    visited = Set(v for route in solver.currSol.routes for v in route)

    # criar vetor de vetores com os vértices ausentes em cada família
    missing_by_family = Vector{Set{Int}}()
    for f in 1:solver.data.numFamilies
        all_f = get(family_vertices, f, Int[])
        miss = Set([v for v in all_f if !(v in visited)])
        push!(missing_by_family, miss)
    end
    solver.currSol.notVisited = copy(missing_by_family)

    solver.currSol.timeStamp = 0
    R = length(solver.currSol.routes)

    solver.currSol.lastModif = zeros(Int, R)
    intraMoveId = [1, 2, 3, 4]
    solver.currSol.lastEval = Array{Int,3}(undef, 10, R, R)
    for moveId in intraMoveId
        for r in 1:R
            1==2#solver.currSol.lastEval[moveId, r, r] = solver.currSol.timeStamp
        end
    end
    interMoveId = [5, 6, 7, 8, 9, 10]
    for moveId in interMoveId
        for r1 in 1:R
            for r2 in 1:R
                1==2#solver.currSol.lastEval[moveId, r1, r2] = solver.currSol.timeStamp
            end
        end
    end
end

function clarkeWright(solver::Solver)
    vertices = copy(solver.data.vertices)
    costMatrix = getCostMatrix(solver)
    depot = 0  # assumindo 0 como depósito

    # Filtrar clientes (excluir depot se estiver na lista)
    customers = [v.id for v in vertices if v.id != depot]

    # Inicializar estruturas
    routes = Dict{Int, Vector{Int}}()  # rotas (chave = primeiro cliente da rota)
    node_to_route = Dict{Int, Int}()   # mapeamento nó -> chave da rota que pertence

    # 1. Fase de Inicialização: uma rota por cliente [depot -> cliente -> depot]
    for c in customers
        route = [depot, c, depot]
        routes[c] = route          # chave = ID do primeiro cliente
        node_to_route[c] = c       # cada nó inicialmente em sua própria rota
    end

    # 2. Fase de Cálculo de Savings
    σ = rand(solver.seed)
    savings = [(i, j, costMatrix[depot+1, i+1] + costMatrix[depot+1, j+1] - σ*costMatrix[i+1, j+1])
              for i in customers for j in customers if i < j]
    sort!(savings, by = x -> -x[3])  # ordenar por savings decrescente

    # 3. Fase de Junção de Rotas
    for (i, j, s) in savings
        route_i_key = node_to_route[i]
        route_j_key = node_to_route[j]

        # Se já estão na mesma rota, pule
        route_i_key == route_j_key && continue

        r_i = routes[route_i_key]
        r_j = routes[route_j_key]

        # Verificar posições dos nós nas rotas
        i_is_first = (r_i[2] == i)
        i_is_last = (r_i[end-1] == i)
        j_is_first = (r_j[2] == j)
        j_is_last = (r_j[end-1] == j)

        # Tentar combinações válidas de junção
        new_route = nothing
        if i_is_last && j_is_first
            new_route = vcat(r_i[1:end-1], r_j[2:end])
        elseif j_is_last && i_is_first
            new_route = vcat(r_j[1:end-1], r_i[2:end])
        elseif i_is_last && j_is_last
            new_route = vcat(r_i[1:end-1], reverse(r_j[2:end-1]), [depot])
        elseif i_is_first && j_is_first
            new_route = vcat([depot], reverse(r_j[2:end-1]), r_i[2:end])
        else
            continue  # não é possível juntar
        end

        # Verificar restrição de risco
        computeViolation(solver, new_route) > 0 && continue

        # Atualizar estruturas de dados
        new_key = min(route_i_key, route_j_key)
        old_key = new_key == route_i_key ? route_j_key : route_i_key

        # Atualizar rotas
        delete!(routes, old_key)
        routes[new_key] = new_route

        # Atualizar mapeamento de nós para rotas
        for node in new_route[2:end-1]  # excluir depots
            node_to_route[node] = new_key
        end
    end
    # 4. Transferir rotas para a Solution
    solver.currSol = Solution()
    currSol = solver.currSol

    for (_, route) in routes
        push!(currSol.routes, route)
        # Calcular custo total da rota
        route_cost = 0
        for k in 1:length(route)-1
            route_cost += costMatrix[route[k]+1, route[k+1]+1]
        end
        currSol.cost += route_cost
        # Calcular violação
        push!(currSol.routeViolation, computeViolation(solver, route))
    end

    return solver.currSol
end
