
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
        for _ = 1:2
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
    capViolR1, capViolR2, minVisitsViolR1, maxVisitsViolR1, minVisitsViolR2, maxVisitsViolR2 = computeViolInterShift10(solver, r1, r2, i, j)
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
    capViolR1, capViolR2, minVisitsViolR1, maxVisitsViolR1, minVisitsViolR2, maxVisitsViolR2 = computeViolInterSwap11(solver, r1, r2, i, j)
    penalizedCost = dist + solver.params.capPenalty*(sol.capViolation - sol.routeCapViolation[r1] + capViolR1 - sol.routeCapViolation[r2] + capViolR2)
    penalizedCost += solver.params.minVisitsPenalty*(sol.minVisitsViolation - sol.routeMinVisitsViolation[r1] + minVisitsViolR1 - sol.routeMinVisitsViolation[r2] + minVisitsViolR2)
    penalizedCost += solver.params.maxVisitsPenalty*(sol.maxVisitsViolation - sol.routeMaxVisitsViolation[r1] + maxVisitsViolR1 - sol.routeMaxVisitsViolation[r2] + maxVisitsViolR2)
    applyMoveInterSwap11!(solver, dist, penalizedCost, capViolR1, capViolR2, minVisitsViolR1, minVisitsViolR2, maxVisitsViolR1, maxVisitsViolR2, r1, r2, i, j)

    return true
end

function randomFamiliarSwap!(solver::Solver)
    sol = solver.currSol
    rout, rin, i, pos, outer = 0, 0, 0, 0, 0
    loop = true
    counter = 0
    while loop
        loop = false
        rout = rand(solver.seed, 1:length(sol.routes))
        rin = rand(solver.seed, 1:length(sol.routes))
        if length(sol.routes[rout]) <= 2 || rin != rout
            loop = true
        else
            i = rand(solver.seed, 2:length(sol.routes[rout])-1)
            family = solver.data.vertices[sol.routes[rout][i]].family
            if length(sol.notVisited[family]) == 0
                loop = true
            else
                pos = rand(solver.seed, 2:length(sol.routes[rin]))
                outer = rand(solver.seed, sol.notVisited[family])
            end
        end
        counter += 1
        if counter > 15
            return false
        end
    end
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
    applyMoveFamiliarRelocateSwap(
        solver, dist, penalizedCost, capOut, capIn, minOut, minIn, maxOut, maxIn,
        rin, pos, rout, i, outer
    )
    return true
end