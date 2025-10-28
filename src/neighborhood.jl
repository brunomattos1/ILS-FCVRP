
function intraShift10!(solver::Solver)
    flag = false
    for r = 1:length(solver.currSol.routes)
        if solver.currSol.lastEval[1, r, r] >= max(solver.currSol.lastModif[r])
            continue
        end
        bestI = 0
        bestJ = 0
        bestR = 0
        sol = solver.currSol
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViol = sol.capViolation
        bestMinVisitsViol = sol.minVisitsViolation
        bestMaxVisitsViol = sol.maxVisitsViolation
        for i = 2:length(sol.routes[r])-1
            for j = 2:length(sol.routes[r])-1
                if i == j || j == i+1 || i == j+1
                    continue
                end
                dist = evalIntraShift10(sol.dist, routes, solver, r, i, j)
                capViol, minVisitsViol, maxVisitsViol = computeViolIntraShift10(solver, r, i, j)
                penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r] + capViol)
                penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r] + minVisitsViol)
                penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r] + maxVisitsViol)
                improvement = improved(penalizedCost, bestCost)

                if improvement
                    bestI = i
                    bestJ = j
                    bestR = r
                    bestDist = dist
                    bestCost = penalizedCost
                    bestCapViol = capViol
                    bestMinVisitsViol = minVisitsViol
                    bestMaxVisitsViol = maxVisitsViol
                end
            end
        end
        if bestI > 0
            applyMoveIntraShift10!(solver, bestDist, bestCost, bestCapViol, bestMinVisitsViol, bestMaxVisitsViol, bestR, bestI, bestJ)
            flag = true
        end
    end
    return flag
end

function intraShift20!(solver::Solver)
    flag = false
    sol = solver.currSol
    for r = 1:length(sol.routes)
        if solver.currSol.lastEval[2, r, r] >= max(solver.currSol.lastModif[r])
            continue
        end
        bestI = 0
        bestJ = 0
        bestR = 0
        sol = solver.currSol
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViol = sol.capViolation
        bestMinVisitsViol = sol.minVisitsViolation
        bestMaxVisitsViol = sol.maxVisitsViolation
        for i = 2:length(sol.routes[r])-2
            for j = 2:length(sol.routes[r])
                if j <= i+2 && j >= i-2
                    continue
                end
                dist = evalIntraShift20(sol.dist, routes, solver, r, i, j)
                capViol, minVisitsViol, maxVisitsViol = computeViolIntraShift20(solver, r, i, j)

                penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r] + capViol)
                penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r] + minVisitsViol)
                penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r] + maxVisitsViol)
                improvement = improved(penalizedCost, bestCost)

                if improvement
                    bestI = i
                    bestJ = j
                    bestR = r
                    bestDist = dist
                    bestCost = penalizedCost
                    bestCapViol = capViol
                    bestMinVisitsViol = minVisitsViol
                    bestMaxVisitsViol = maxVisitsViol
                end
            end
        end
        if bestI > 0
            applyMoveIntraShift20!(solver, bestDist, bestCost, bestCapViol, bestMinVisitsViol, bestMaxVisitsViol, bestR, bestI, bestJ)
            flag = true
        end
    end
    return flag
end

function intraSwap11!(solver::Solver)
    flag = false
    sol = solver.currSol
    for r = 1:length(sol.routes)
        if solver.currSol.lastEval[3, r, r] >= max(solver.currSol.lastModif[r])
            continue
        end
        bestI = 0
        bestJ = 0
        bestR = 0
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViol = sol.capViolation
        bestMinVisitsViol = sol.minVisitsViolation
        bestMaxVisitsViol = sol.maxVisitsViolation
        for i = 2:length(sol.routes[r]) - 2
            for j = i+1:length(sol.routes[r]) - 1
                if i == j
                    continue
                end
                dist = evalIntraSwap11(sol.dist, routes, solver, r, i, j)
                capViol, minVisitsViol, maxVisitsViol = computeViolIntraSwap11(solver, r, i, j)

                penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r] + capViol)
                penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r] + minVisitsViol)
                penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r] + maxVisitsViol)
                improvement = improved(penalizedCost, bestCost)

                if improvement
                    bestI = i
                    bestJ = j
                    bestR = r
                    bestDist = dist
                    bestCost = penalizedCost
                    bestCapViol = capViol
                    bestMinVisitsViol = minVisitsViol
                    bestMaxVisitsViol = maxVisitsViol
                end
            end
        end
        if bestI > 0
            applyMoveIntraSwap11!(solver, bestDist, bestCost, bestCapViol, bestMinVisitsViol, bestMaxVisitsViol, bestR, bestI, bestJ)
            flag = true
        end
    end
    return flag
end

function twoOpt!(solver::Solver)
    flag = false
    sol = solver.currSol
    for r = 1:length(sol.routes)
        if solver.currSol.lastEval[4, r, r] >= max(solver.currSol.lastModif[r])
            continue
        end
        bestI = 0
        bestJ = 0
        bestR = 0
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViol = sol.capViolation
        bestMinVisitsViol = sol.minVisitsViolation
        bestMaxVisitsViol = sol.maxVisitsViolation
        for i = 2:length(sol.routes[r]) - 2
            for j = i+1:length(sol.routes[r]) - 1
                if i == j
                    continue
                end
                dist = eval2opt(sol.dist, routes, solver, r, i, j)
                capViol, minVisitsViol, maxVisitsViol = computeViol2opt(solver, r, i, j)

                penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r] + capViol)
                penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r] + minVisitsViol)
                penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r] + maxVisitsViol)
                improvement = improved(penalizedCost, bestCost)

                if improvement
                    bestI = i
                    bestJ = j
                    bestR = r
                    bestDist = dist
                    bestCost = penalizedCost
                    bestCapViol = capViol
                    bestMinVisitsViol = minVisitsViol
                    bestMaxVisitsViol = maxVisitsViol
                end
            end
        end
        if bestI > 0
            applyMove2opt!(solver, bestDist, bestCost, bestCapViol, bestMinVisitsViol, bestMaxVisitsViol, bestR, bestI, bestJ)
            flag = true
        end
    end
    return flag
end

function interShift10!(solver::Solver)
    flag = false
    sol = solver.currSol
    # routesIdx = shuffle!(solver.seed, Int[i for i = 1:length(solver.currSol.routes)])
    resize!(solver.buffer, length(sol.routes))

    copyto!(solver.buffer, 1:length(sol.routes))

    shuffle!(solver.buffer)

    routesIdx = solver.buffer 
    for r1 in routesIdx
        bestI = 0
        bestJ = 0
        bestR1 = 0
        bestR2 = 0
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViolR1 = 0.
        bestCapViolR2 = 0.
        bestMinVisitsViolR1 = 0
        bestMinVisitsViolR2 = 0
        bestMaxVisitsViolR1 = 0
        bestMaxVisitsViolR2 = 0
        for r2 in routesIdx
            if r2 == r1
                continue
            end
            if solver.currSol.lastEval[5, r1, r2] >= max(solver.currSol.lastModif[r1], solver.currSol.lastModif[r2])
                continue
            end
            for i = 2:length(sol.routes[r1]) - 1
                for j = 2:length(sol.routes[r2])
                    dist = evalInterShift10(sol.dist, routes, solver, r1, r2, i, j)
                    capViolR1, capViolR2, minVisitsViolR1, maxVisitsViolR1, minVisitsViolR2, maxVisitsViolR2 = computeViolInterShift10(solver, r1, r2, i, j)
                    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
                    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
                    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)
                    # @show minVisitsViolR1, maxVisitsViolR1, length(sol.routes[r1]) - 2 - 1
                    # @show minVisitsViolR2, maxVisitsViolR2, length(sol.routes[r2]) - 2 + 1
                    # println("-"^100)
                    improvement = improved(penalizedCost, bestCost)
                    if improvement
                        bestI = i
                        bestJ = j
                        bestR1 = r1
                        bestR2 = r2
                        bestDist = dist
                        bestCost = penalizedCost
                        bestCapViolR1 = capViolR1
                        bestCapViolR2 = capViolR2
                        bestMinVisitsViolR1 = minVisitsViolR1
                        bestMinVisitsViolR2 = minVisitsViolR2
                        bestMaxVisitsViolR1 = maxVisitsViolR1
                        bestMaxVisitsViolR2 = maxVisitsViolR2
                    end
                end
            end
        end
        if bestI > 0
            flag = true
            applyMoveInterShift10!(solver, bestDist, bestCost, bestCapViolR1, bestCapViolR2, bestMinVisitsViolR1, bestMinVisitsViolR2, bestMaxVisitsViolR1, bestMaxVisitsViolR2, bestR1, bestR2, bestI, bestJ)

        end
    end
    return flag
end

function interShift20!(solver::Solver)
    flag = false
    sol = solver.currSol
    # routesIdx = shuffle!(solver.seed, Int[i for i = 1:length(solver.currSol.routes)])
    resize!(solver.buffer, length(sol.routes))

    copyto!(solver.buffer, 1:length(sol.routes))

    shuffle!(solver.buffer)

    routesIdx = solver.buffer 
    for r1 in routesIdx# = 1:length(sol.routes)
        bestI = 0
        bestJ = 0
        bestR1 = 0
        bestR2 = 0
        sol = solver.currSol
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViolR1 = 0.
        bestCapViolR2 = 0.
        bestMinVisitsViolR1 = 0.
        bestMinVisitsViolR2 = 0.
        bestMaxVisitsViolR1 = 0.
        bestMaxVisitsViolR2 = 0.
        for r2 in routesIdx
            if r2 == r1
                continue
            end
            if solver.currSol.lastEval[6, r1, r2] >= max(solver.currSol.lastModif[r1], solver.currSol.lastModif[r2])
                continue
            end
            for i = 2:length(sol.routes[r1]) - 2
                for j = 2:length(sol.routes[r2])
                    dist = evalInterShift20(sol.dist, routes, solver, r1, r2, i, j)
                    capViolR1, capViolR2, minVisitsViolR1, maxVisitsViolR1, minVisitsViolR2, maxVisitsViolR2 = computeViolInterShift20(solver, r1, r2, i, j)
                    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
                    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
                    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)

                    improvement = improved(penalizedCost, bestCost)
                    if improvement
                        bestI = i
                        bestJ = j
                        bestR1 = r1
                        bestR2 = r2
                        bestDist = dist
                        bestCost = penalizedCost
                        bestCapViolR1 = capViolR1
                        bestCapViolR2 = capViolR2
                        bestMinVisitsViolR1 = minVisitsViolR1
                        bestMinVisitsViolR2 = minVisitsViolR2
                        bestMaxVisitsViolR1 = maxVisitsViolR1
                        bestMaxVisitsViolR2 = maxVisitsViolR2
                    end
                end
            end
        end
        if bestI > 0
            flag = true
            applyMoveInterShift20!(solver, bestDist, bestCost, bestCapViolR1, bestCapViolR2, bestMinVisitsViolR1, bestMinVisitsViolR2, bestMaxVisitsViolR1, bestMaxVisitsViolR2, bestR1, bestR2, bestI, bestJ)

        end
    end
    return flag
end

function interSwap11!(solver::Solver)
    flag = false
    sol = solver.currSol
    # routesIdx = shuffle!(solver.seed, Int[i for i = 1:length(solver.currSol.routes)])
    resize!(solver.buffer, length(sol.routes))

    copyto!(solver.buffer, 1:length(sol.routes))

    shuffle!(solver.buffer)

    routesIdx = solver.buffer 
    for r1 in routesIdx# = 1:length(sol.routes)
        bestI = 0
        bestJ = 0
        bestR1 = 0
        bestR2 = 0
        sol = solver.currSol
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViolR1 = 0.
        bestCapViolR2 = 0.
        bestMinVisitsViolR1 = 0.
        bestMinVisitsViolR2 = 0.
        bestMaxVisitsViolR1 = 0.
        bestMaxVisitsViolR2 = 0.
        for r2 in routesIdx
            if r2 <= r1
                continue
            end
            if solver.currSol.lastEval[7, r1, r2] >= max(solver.currSol.lastModif[r1], solver.currSol.lastModif[r2])
                continue
            end            
            for i = 2:length(sol.routes[r1]) - 1
                for j = 2:length(sol.routes[r2]) - 1
                    dist = evalInterSwap11(sol.dist, routes, solver, r1, r2, i, j)
                    capViolR1, capViolR2, minVisitsViolR1, maxVisitsViolR1, minVisitsViolR2, maxVisitsViolR2 = computeViolInterSwap11(solver, r1, r2, i, j)
                    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
                    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
                    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)

                    improvement = improved(penalizedCost, bestCost)
                    if improvement
                        bestI = i
                        bestJ = j
                        bestR1 = r1
                        bestR2 = r2
                        bestDist = dist
                        bestCost = penalizedCost
                        bestCapViolR1 = capViolR1
                        bestCapViolR2 = capViolR2
                        bestMinVisitsViolR1 = minVisitsViolR1
                        bestMinVisitsViolR2 = minVisitsViolR2
                        bestMaxVisitsViolR1 = maxVisitsViolR1
                        bestMaxVisitsViolR2 = maxVisitsViolR2
                    end
                end
            end
        end
        if bestI > 0
            flag = true
            applyMoveInterSwap11!(solver, bestDist, bestCost, bestCapViolR1, bestCapViolR2, bestMinVisitsViolR1, bestMinVisitsViolR2, bestMaxVisitsViolR1, bestMaxVisitsViolR2, bestR1, bestR2, bestI, bestJ)
        end
    end
    return flag
end

function interSwap21!(solver::Solver)
    flag = false
    sol = solver.currSol
    # routesIdx = shuffle!(solver.seed, Int[i for i = 1:length(solver.currSol.routes)])
    resize!(solver.buffer, length(sol.routes))

    copyto!(solver.buffer, 1:length(sol.routes))

    shuffle!(solver.buffer)

    routesIdx = solver.buffer 
    for r1 in routesIdx# = 1:length(sol.routes)
        bestI = 0
        bestJ = 0
        bestR1 = 0
        bestR2 = 0
        sol = solver.currSol
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViolR1 = 0.
        bestCapViolR2 = 0.
        bestMinVisitsViolR1 = 0.
        bestMinVisitsViolR2 = 0.
        bestMaxVisitsViolR1 = 0.
        bestMaxVisitsViolR2 = 0.
        for r2 in routesIdx
            if r2 <= r1
                continue
            end
            if solver.currSol.lastEval[8, r1, r2] >= max(solver.currSol.lastModif[r1], solver.currSol.lastModif[r2])
                continue
            end
            for i = 2:length(sol.routes[r1]) - 2
                for j = 2:length(sol.routes[r2]) - 1
                    dist = evalInterSwap21(sol.dist, routes, solver, r1, r2, i, j)
                    capViolR1, capViolR2, minVisitsViolR1, maxVisitsViolR1, minVisitsViolR2, maxVisitsViolR2 = computeViolInterSwap21(solver, r1, r2, i, j)
                    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
                    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
                    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)

                    improvement = improved(penalizedCost, bestCost)
                    if improvement
                        bestI = i
                        bestJ = j
                        bestR1 = r1
                        bestR2 = r2
                        bestDist = dist
                        bestCost = penalizedCost
                        bestCapViolR1 = capViolR1
                        bestCapViolR2 = capViolR2
                        bestMinVisitsViolR1 = minVisitsViolR1
                        bestMinVisitsViolR2 = minVisitsViolR2
                        bestMaxVisitsViolR1 = maxVisitsViolR1
                        bestMaxVisitsViolR2 = maxVisitsViolR2
                    end
                end
            end
        end
        if bestI > 0
            flag = true
            applyMoveInterSwap21!(solver, bestDist, bestCost, bestCapViolR1, bestCapViolR2, bestMinVisitsViolR1, bestMinVisitsViolR2, bestMaxVisitsViolR1, bestMaxVisitsViolR2, bestR1, bestR2, bestI, bestJ)

        end
    end
    return flag
end

function interSwap22!(solver::Solver)
    flag = false
    sol = solver.currSol
    # routesIdx = shuffle!(solver.seed, Int[i for i = 1:length(solver.currSol.routes)])
    resize!(solver.buffer, length(sol.routes))

    copyto!(solver.buffer, 1:length(sol.routes))

    shuffle!(solver.buffer)

    routesIdx = solver.buffer 
    for r1 in routesIdx# = 1:length(sol.routes)
        bestI = 0
        bestJ = 0
        bestR1 = 0
        bestR2 = 0
        sol = solver.currSol
        routes = getRoutes(sol)
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViolR1 = 0.
        bestCapViolR2 = 0.
        bestMinVisitsViolR1 = 0.
        bestMinVisitsViolR2 = 0.
        bestMaxVisitsViolR1 = 0.
        bestMaxVisitsViolR2 = 0.
        for r2 in routesIdx
            if r2 <= r1
                continue
            end
            if solver.currSol.lastEval[8, r1, r2] >= max(solver.currSol.lastModif[r1], solver.currSol.lastModif[r2])
                continue
            end
            for i = 2:length(sol.routes[r1]) - 2
                for j = 2:length(sol.routes[r2]) - 2
                    dist = evalInterSwap22(sol.dist, routes, solver, r1, r2, i, j)
                    capViolR1, capViolR2, minVisitsViolR1, maxVisitsViolR1, minVisitsViolR2, maxVisitsViolR2 = computeViolInterSwap22(solver, r1, r2, i, j)
                    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
                    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
                    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)

                    improvement = improved(penalizedCost, bestCost)
                    if improvement
                        bestI = i
                        bestJ = j
                        bestR1 = r1
                        bestR2 = r2
                        bestDist = dist
                        bestCost = penalizedCost
                        bestCapViolR1 = capViolR1
                        bestCapViolR2 = capViolR2
                        bestMinVisitsViolR1 = minVisitsViolR1
                        bestMinVisitsViolR2 = minVisitsViolR2
                        bestMaxVisitsViolR1 = maxVisitsViolR1
                        bestMaxVisitsViolR2 = maxVisitsViolR2
                    end
                end
            end
        end
        if bestI > 0
            flag = true
            applyMoveInterSwap22!(solver, bestDist, bestCost, bestCapViolR1, bestCapViolR2, bestMinVisitsViolR1, bestMinVisitsViolR2, bestMaxVisitsViolR1, bestMaxVisitsViolR2, bestR1, bestR2, bestI, bestJ)
        end
    end
    return flag
end

function familiarSwap!(solver::Solver)
    sol = solver.currSol
    flag = false
    shuffle!(solver.seed, solver.data.families)
    for family in solver.data.families
        bestI = 0
        bestR = 0
        bestOuter = 0
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViol = sol.capViolation
        bestMinVisitsViol = sol.minVisitsViolation
        bestMaxVisitsViol = sol.maxVisitsViolation
        for outer in sol.notVisited[family]
            for r = 1:length(sol.routes)
                if solver.currSol.lastEval[9, r, r] >= max(solver.currSol.lastModif[r], solver.currSol.lastModif[r])
                    continue
                end
                for i = 2:length(sol.routes[r])-1
                    if solver.data.vertices[sol.routes[r][i]].family != family
                        continue
                    end
                    dist = evalFamiliarSwap(sol.dist, sol.routes, solver, r, i, outer)
                    capViol, minVisitsViol, maxVisitsViol = computeViolFamiliarSwap(solver, r, i, outer)
                    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r] + capViol)
                    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r] + minVisitsViol)
                    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r] + maxVisitsViol)
                    if improved(penalizedCost, bestCost)
                        bestI = i
                        bestR = r
                        bestOuter = outer
                        bestDist = dist
                        bestCost = penalizedCost
                        bestCapViol = capViol
                        bestMinVisitsViol = minVisitsViol
                        bestMaxVisitsViol = maxVisitsViol
                    end
                end
            end
        end
        if bestI > 0 
            applyMoveFamiliarSwap(solver, bestDist, bestCost, bestCapViol, bestMinVisitsViol, bestMaxVisitsViol, bestR, bestI, bestOuter)
            flag = true
        end
    end
    return flag
end

function familiarRelocateSwap!(solver::Solver)
    sol = solver.currSol
    flag = false
    shuffle!(solver.seed, solver.data.families)

    for family in solver.data.families
        bestI = 0
        bestRin = 0
        bestRout = 0
        bestPos = 0
        bestOuter = 0
        bestDist = sol.dist
        bestCost = sol.cost
        bestCapViolRout = 0
        bestCapViolRin = 0
        bestMinVisitsViolOut = 0
        bestMinVisitsViolIn = 0
        bestMaxVisitsViolOut = 0
        bestMaxVisitsViolIn = 0
        # Para cada vértice de fora (não visitado) da família
        for outer in sol.notVisited[family]
            # Para cada rota onde há um vértice dessa família (para sair)
            for rout = 1:length(sol.routes)

                for i = 2:length(sol.routes[rout]) - 1
                    if solver.data.vertices[sol.routes[rout][i]].family != family
                        continue
                    end
                    # Tenta inserir o outer em qualquer posição de qualquer rota
                    for rin = 1:length(sol.routes)
                        # if rout == rin
                        #     continue
                        # end
                        # if solver.currSol.lastEval[10, rout, rin] >= max(solver.currSol.lastModif[rout], solver.currSol.lastModif[rin])
                        #     continue
                        # end    
                        for pos = 2:length(sol.routes[rin])
                            dist = evalFamiliarRelocateSwap(sol.dist, sol.routes, solver, rout, i, rin, pos, outer)
                            capOut, minOut, maxOut, capIn, minIn, maxIn =
                                computeViolFamiliarRelocateSwap(solver, rout, i, rin, pos, outer)

                            penalizedCost = dist
                            # Atualiza custo penalizado levando em conta as duas rotas afetadas
                            if rout != rin
                                penalizedCost += solver.params.capPenalty * (
                                    sol.capViolation - sol.routeCapViolation[rout] - sol.routeCapViolation[rin] + capOut + capIn)

                                penalizedCost += solver.params.minVisitsPenalty * (
                                    sol.minVisitsViolation - sol.routeMinVisitsViolation[rout] - sol.routeMinVisitsViolation[rin] + minOut + minIn)

                                penalizedCost += solver.params.maxVisitsPenalty * (
                                    sol.maxVisitsViolation - sol.routeMaxVisitsViolation[rout] - sol.routeMaxVisitsViolation[rin] + maxOut + maxIn)
                            else
                                penalizedCost += solver.params.capPenalty * (
                                    sol.capViolation - sol.routeCapViolation[rout] + capOut)

                                penalizedCost += solver.params.minVisitsPenalty * (
                                    sol.minVisitsViolation - sol.routeMinVisitsViolation[rout] + minOut)

                                penalizedCost += solver.params.maxVisitsPenalty * (
                                    sol.maxVisitsViolation - sol.routeMaxVisitsViolation[rout] + maxOut)
                            end
                            # @show dist, cost
                            if improved(penalizedCost, bestCost)
                                bestI = i
                                bestRin = rin
                                bestRout = rout
                                bestPos = pos
                                bestOuter = outer
                                bestDist = dist
                                bestCost = penalizedCost
                                bestCapViolRout = capOut
                                bestCapViolRin = capIn
                                bestMinVisitsViolOut = minOut
                                bestMinVisitsViolIn = minIn
                                bestMaxVisitsViolOut = maxOut
                                bestMaxVisitsViolIn = maxIn

                            end
                        end
                    end
                end
            end
        end

        if bestI > 0
            applyMoveFamiliarRelocateSwap(
                solver, bestDist, bestCost, bestCapViolRout, bestCapViolRin, bestMinVisitsViolOut, bestMinVisitsViolIn, bestMaxVisitsViolOut, bestMaxVisitsViolIn,
                bestRin, bestPos, bestRout, bestI, bestOuter
            )
            flag = true
        end
    end
    return flag
end
