
function perturb!(solver::Solver)
    rnd = rand(solver.seed)
    # if rnd <= 0.1
    #     randomTwoOpt!(solver)
    if rnd <= 0.2
        for _ = 1:solver.diversification.swap
            perturbed = randomInterSwap11!(solver)
        end
    elseif rnd <= 0.5
        for _ = 1:solver.diversification.shift
            perturbed = randomInterShit10!(solver)
        end
    else
        for _ = 1:1
            perturbed = randomFamiliarSwap!(solver)
        end
    end
end

function randomInterShit10!(solver::Solver)
    sol = solver.currSol
    routes = getRoutes(sol)
    r1 = rand(solver.seed, 1:length(routes))
    r2 = rand(solver.seed, 1:length(routes))
    counter = 0
    while r1 == r2 || length(routes[r1]) <= 2
        r1 = rand(solver.seed, 1:length(routes))
        r2 = rand(solver.seed, 1:length(routes))
        if counter > 20
           return false
        end
        counter += 1
    end
    i = rand(solver.seed, 2:length(routes[r1])-1)
    j = rand(solver.seed, 2:length(routes[r2]))
    dist = evalInterShift10(sol.dist, routes, solver, r1, r2, i, j)
    capViolR1, capViolR2, minVisitsViolR1, minVisitsViolR2, maxVisitsViolR1, maxVisitsViolR2 = computeViolInterShift10(solver, r1, r2, i, j)
    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)
    applyMoveInterShift10!(solver, dist, penalizedCost, capViolR1, capViolR2, minVisitsViolR1, minVisitsViolR2, maxVisitsViolR1, maxVisitsViolR2, r1, r2, i, j)

    return true
end

function randomInterSwap11!(solver::Solver)
    sol = solver.currSol
    routes = getRoutes(getCurrSol(solver))
    r1 = rand(solver.seed, 1:length(routes))
    r2 = rand(solver.seed, 1:length(routes))
    counter = 0
    while r1 == r2 || length(routes[r1]) <= 2 || length(routes[r2]) <= 2
        r1 = rand(solver.seed, 1:length(routes))
        r2 = rand(solver.seed, 1:length(routes))
        if counter > 20
            return false
        end
        counter += 1
    end
    i = rand(solver.seed, 2:length(routes[r1]) - 1)
    j = rand(solver.seed, 2:length(routes[r2]) - 1)
    
    dist = evalInterSwap11(sol.dist, routes, solver, r1, r2, i, j)
    capViolR1, capViolR2, minVisitsViolR1, minVisitsViolR2, maxVisitsViolR1, maxVisitsViolR2 = computeViolInterSwap11(solver, r1, r2, i, j)
    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)
    applyMoveInterSwap11!(solver, dist, penalizedCost, capViolR1, capViolR2, minVisitsViolR1, minVisitsViolR2, maxVisitsViolR1, maxVisitsViolR2, r1, r2, i, j)

    return true
end

function randomFamiliarSwap!(solver::Solver)
    sol = solver.currSol
    r, i, outer = 0, 0, 0
    loop = true
    counter = 0
    while loop
        loop = false
        r = rand(solver.seed, 1:length(sol.routes))
        if length(sol.routes[r]) <= 2
            loop = true
        else
            i = rand(solver.seed, 2:length(sol.routes[r])-1)
            family = solver.data.vertices[sol.routes[r][i]].family
            if length(sol.notVisited[family]) == 0
                loop = true
            else
                outer = rand(solver.seed, sol.notVisited[family])
            end
        end
        counter += 1
        if counter > 7
            return false
        end
    end
    dist = evalFamiliarSwap(sol.dist, sol.routes, solver, r, i, outer)
    capViol, minVisitsViol, maxVisitsViol = computeViolFamiliarSwap(solver, r, i, outer)
    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r] + capViol)
    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r] + minVisitsViol)
    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r] + maxVisitsViol)
    applyMoveFamiliarSwap(solver, dist, penalizedCost, capViol, minVisitsViol, maxVisitsViol, r, i, outer)
    return true
end