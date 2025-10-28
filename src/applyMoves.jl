function applyMoveInsertion(solver::Solver, newDist::Float64, newCost::Float64, newCapViol::Float64, newMinVisitsViol::Int, newMaxVisitsViol::Int, r::Int, customer::Vertex, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.demands[r] += customer.demand
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r] + newCapViol
    solver.currSol.routeCapViolation[r] = newCapViol

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r] + newMinVisitsViol
    solver.currSol.routeMinVisitsViolation[r] = newMinVisitsViol

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r] + newMaxVisitsViol
    solver.currSol.routeMaxVisitsViolation[r] = newMaxVisitsViol
    insert!(solver.currSol.routes[r], j, customer.id)
end

function applyMoveIntraShift10!(solver::Solver, newDist::Float64, newCost::Float64, newCapViol::Float64, newMinVisitsViol::Int, newMaxVisitsViol, r::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r] + newCapViol
    solver.currSol.routeCapViolation[r] = newCapViol

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r] + newMinVisitsViol
    solver.currSol.routeMinVisitsViolation[r] = newMinVisitsViol

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r] + newMaxVisitsViol
    solver.currSol.routeMaxVisitsViolation[r] = newMaxVisitsViol

    customerI = solver.currSol.routes[r][i]
    if i < j
        deleteat!(solver.currSol.routes[r], i)
        insert!(solver.currSol.routes[r], j-1, customerI)
    else
        deleteat!(solver.currSol.routes[r], i)
        insert!(solver.currSol.routes[r], j, customerI)
    end
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[1, r, r] = solver.currSol.timeStamp
    solver.currSol.lastModif[r] = solver.currSol.timeStamp
end

function applyMoveIntraShift20!(solver::Solver, newDist::Float64, newCost::Float64, newCapViol::Float64, newMinVisitsViol::Int, newMaxVisitsViol, r::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r] + newCapViol
    solver.currSol.routeCapViolation[r] = newCapViol

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r] + newMinVisitsViol
    solver.currSol.routeMinVisitsViolation[r] = newMinVisitsViol

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r] + newMaxVisitsViol
    solver.currSol.routeMaxVisitsViolation[r] = newMaxVisitsViol
    customerI1 = solver.currSol.routes[r][i]
    customerI2 = solver.currSol.routes[r][i+1]
    if i < j
        deleteat!(solver.currSol.routes[r], [i, i+1])
        insert!(solver.currSol.routes[r], j-2, customerI2)
        insert!(solver.currSol.routes[r], j-2, customerI1)
    else
        deleteat!(solver.currSol.routes[r], [i, i+1])
        insert!(solver.currSol.routes[r], j, customerI2)
        insert!(solver.currSol.routes[r], j, customerI1)
    end
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[2, r, r] = solver.currSol.timeStamp
    solver.currSol.lastModif[r] = solver.currSol.timeStamp
end

function applyMoveIntraSwap11!(solver::Solver, newDist::Float64, newCost::Float64, newCapViol::Float64, newMinVisitsViol::Int, newMaxVisitsViol, r::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r] + newCapViol
    solver.currSol.routeCapViolation[r] = newCapViol

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r] + newMinVisitsViol
    solver.currSol.routeMinVisitsViolation[r] = newMinVisitsViol

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r] + newMaxVisitsViol
    solver.currSol.routeMaxVisitsViolation[r] = newMaxVisitsViol
    solver.currSol.routes[r][i], solver.currSol.routes[r][j] = solver.currSol.routes[r][j], solver.currSol.routes[r][i]
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[3, r, r] = solver.currSol.timeStamp
    solver.currSol.lastModif[r] = solver.currSol.timeStamp
end

function applyMove2opt!(solver::Solver, newDist::Float64, newCost::Float64, newCapViol::Float64, newMinVisitsViol::Int, newMaxVisitsViol, r::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r] + newCapViol
    solver.currSol.routeCapViolation[r] = newCapViol

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r] + newMinVisitsViol
    solver.currSol.routeMinVisitsViolation[r] = newMinVisitsViol

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r] + newMaxVisitsViol
    solver.currSol.routeMaxVisitsViolation[r] = newMaxVisitsViol
    reverse!(solver.currSol.routes[r], i, j)
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[4, r, r] = solver.currSol.timeStamp
    solver.currSol.lastModif[r] = solver.currSol.timeStamp
end

function applyMoveInterShift10!(solver::Solver, newDist::Float64, newCost::Float64, newCapViolR1::Float64, newCapViolR2::Float64, newMinVisitsViolR1::Int, newMinVisitsViolR2::Int, 
    newMaxVisitsViolR1::Int, newMaxVisitsViolR2::Int, r1::Int, r2::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r1] + newCapViolR1 - solver.currSol.routeCapViolation[r2] + newCapViolR2
    solver.currSol.routeCapViolation[r1] = newCapViolR1
    solver.currSol.routeCapViolation[r2] = newCapViolR2

    solver.currSol.demands[r1] -= demand(solver, solver.currSol.routes[r1][i])
    solver.currSol.demands[r2] += demand(solver, solver.currSol.routes[r1][i])


    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r1] + newMinVisitsViolR1 - solver.currSol.routeMinVisitsViolation[r2] + newMinVisitsViolR2
    solver.currSol.routeMinVisitsViolation[r1] = newMinVisitsViolR1
    solver.currSol.routeMinVisitsViolation[r2] = newMinVisitsViolR2

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r1] + newMaxVisitsViolR1 - solver.currSol.routeMaxVisitsViolation[r2] + newMaxVisitsViolR2
    solver.currSol.routeMaxVisitsViolation[r1] = newMaxVisitsViolR1
    solver.currSol.routeMaxVisitsViolation[r2] = newMaxVisitsViolR2

    customerI = solver.currSol.routes[r1][i]
    deleteat!(solver.currSol.routes[r1], i)
    insert!(solver.currSol.routes[r2], j, customerI)
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[4, r1, r2] = solver.currSol.timeStamp
    solver.currSol.lastModif[r1] = solver.currSol.timeStamp
    solver.currSol.lastModif[r2] = solver.currSol.timeStamp

end

function applyMoveInterShift20!(solver::Solver, newDist::Float64, newCost::Float64, newCapViolR1::Float64, newCapViolR2::Float64, newMinVisitsViolR1::Int, newMinVisitsViolR2::Int, 
    newMaxVisitsViolR1::Int, newMaxVisitsViolR2::Int, r1::Int, r2::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r1] + newCapViolR1 - solver.currSol.routeCapViolation[r2] + newCapViolR2
    solver.currSol.routeCapViolation[r1] = newCapViolR1
    solver.currSol.routeCapViolation[r2] = newCapViolR2

    solver.currSol.demands[r1] -= demand(solver, solver.currSol.routes[r1][i]) + demand(solver, solver.currSol.routes[r1][i+1])
    solver.currSol.demands[r2] += demand(solver, solver.currSol.routes[r1][i]) + demand(solver, solver.currSol.routes[r1][i+1])

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r1] + newMinVisitsViolR1 - solver.currSol.routeMinVisitsViolation[r2] + newMinVisitsViolR2
    solver.currSol.routeMinVisitsViolation[r1] = newMinVisitsViolR1
    solver.currSol.routeMinVisitsViolation[r2] = newMinVisitsViolR2

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r1] + newMaxVisitsViolR1 - solver.currSol.routeMaxVisitsViolation[r2] + newMaxVisitsViolR2
    solver.currSol.routeMaxVisitsViolation[r1] = newMaxVisitsViolR1
    solver.currSol.routeMaxVisitsViolation[r2] = newMaxVisitsViolR2

    customerI1 = solver.currSol.routes[r1][i]
    customerI2 = solver.currSol.routes[r1][i+1]
    deleteat!(solver.currSol.routes[r1], [i, i+1])
    insert!(solver.currSol.routes[r2], j, customerI2)
    insert!(solver.currSol.routes[r2], j, customerI1)
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[5, r1, r2] = solver.currSol.timeStamp
    solver.currSol.lastModif[r1] = solver.currSol.timeStamp
    solver.currSol.lastModif[r2] = solver.currSol.timeStamp
end

function applyMoveInterSwap11!(solver::Solver, newDist::Float64, newCost::Float64, newCapViolR1::Float64, newCapViolR2::Float64, newMinVisitsViolR1::Int, newMinVisitsViolR2::Int, 
    newMaxVisitsViolR1::Int, newMaxVisitsViolR2::Int, r1::Int, r2::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r1] + newCapViolR1 - solver.currSol.routeCapViolation[r2] + newCapViolR2
    solver.currSol.routeCapViolation[r1] = newCapViolR1
    solver.currSol.routeCapViolation[r2] = newCapViolR2

    solver.currSol.demands[r1] -= demand(solver, solver.currSol.routes[r1][i])
    solver.currSol.demands[r1] += demand(solver, solver.currSol.routes[r2][j])
    solver.currSol.demands[r2] -= demand(solver, solver.currSol.routes[r2][j])
    solver.currSol.demands[r2] += demand(solver, solver.currSol.routes[r1][i])

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r1] + newMinVisitsViolR1 - solver.currSol.routeMinVisitsViolation[r2] + newMinVisitsViolR2
    solver.currSol.routeMinVisitsViolation[r1] = newMinVisitsViolR1
    solver.currSol.routeMinVisitsViolation[r2] = newMinVisitsViolR2

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r1] + newMaxVisitsViolR1 - solver.currSol.routeMaxVisitsViolation[r2] + newMaxVisitsViolR2
    solver.currSol.routeMaxVisitsViolation[r1] = newMaxVisitsViolR1
    solver.currSol.routeMaxVisitsViolation[r2] = newMaxVisitsViolR2

    customerI = solver.currSol.routes[r1][i]
    customerJ = solver.currSol.routes[r2][j]
    solver.currSol.routes[r1][i] = customerJ
    solver.currSol.routes[r2][j] = customerI
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[6, r1, r2] = solver.currSol.timeStamp
    solver.currSol.lastModif[r1] = solver.currSol.timeStamp
    solver.currSol.lastModif[r2] = solver.currSol.timeStamp
end

function applyMoveInterSwap22!(solver::Solver, newDist::Float64, newCost::Float64, newCapViolR1::Float64, newCapViolR2::Float64, newMinVisitsViolR1::Int, newMinVisitsViolR2::Int, 
    newMaxVisitsViolR1::Int, newMaxVisitsViolR2::Int, r1::Int, r2::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r1] + newCapViolR1 - solver.currSol.routeCapViolation[r2] + newCapViolR2
    solver.currSol.routeCapViolation[r1] = newCapViolR1
    solver.currSol.routeCapViolation[r2] = newCapViolR2


    solver.currSol.demands[r1] -= demand(solver, solver.currSol.routes[r1][i]) + demand(solver, solver.currSol.routes[r1][i+1])
    solver.currSol.demands[r1] += demand(solver, solver.currSol.routes[r2][j]) + demand(solver, solver.currSol.routes[r2][j+1])
    solver.currSol.demands[r2] -= demand(solver, solver.currSol.routes[r2][j]) + demand(solver, solver.currSol.routes[r2][j+1])
    solver.currSol.demands[r2] += demand(solver, solver.currSol.routes[r1][i]) + demand(solver, solver.currSol.routes[r1][i+1])

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r1] + newMinVisitsViolR1 - solver.currSol.routeMinVisitsViolation[r2] + newMinVisitsViolR2
    solver.currSol.routeMinVisitsViolation[r1] = newMinVisitsViolR1
    solver.currSol.routeMinVisitsViolation[r2] = newMinVisitsViolR2

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r1] + newMaxVisitsViolR1 - solver.currSol.routeMaxVisitsViolation[r2] + newMaxVisitsViolR2
    solver.currSol.routeMaxVisitsViolation[r1] = newMaxVisitsViolR1
    solver.currSol.routeMaxVisitsViolation[r2] = newMaxVisitsViolR2

    customerI1 = solver.currSol.routes[r1][i]
    customerI2 = solver.currSol.routes[r1][i+1]
    customerJ1 = solver.currSol.routes[r2][j]
    customerJ2 = solver.currSol.routes[r2][j+1]
    solver.currSol.routes[r1][i] = customerJ1
    solver.currSol.routes[r1][i+1] = customerJ2
    solver.currSol.routes[r2][j] = customerI1
    solver.currSol.routes[r2][j+1] = customerI2
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[7, r1, r2] = solver.currSol.timeStamp
    solver.currSol.lastModif[r1] = solver.currSol.timeStamp
    solver.currSol.lastModif[r2] = solver.currSol.timeStamp
end

function applyMoveInterSwap21!(solver::Solver, newDist::Float64, newCost::Float64, newCapViolR1::Float64, newCapViolR2::Float64, newMinVisitsViolR1::Int, newMinVisitsViolR2::Int, 
    newMaxVisitsViolR1::Int, newMaxVisitsViolR2::Int, r1::Int, r2::Int, i::Int, j::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r1] + newCapViolR1 - solver.currSol.routeCapViolation[r2] + newCapViolR2
    solver.currSol.routeCapViolation[r1] = newCapViolR1
    solver.currSol.routeCapViolation[r2] = newCapViolR2

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r1] + newMinVisitsViolR1 - solver.currSol.routeMinVisitsViolation[r2] + newMinVisitsViolR2
    solver.currSol.routeMinVisitsViolation[r1] = newMinVisitsViolR1
    solver.currSol.routeMinVisitsViolation[r2] = newMinVisitsViolR2

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r1] + newMaxVisitsViolR1 - solver.currSol.routeMaxVisitsViolation[r2] + newMaxVisitsViolR2
    solver.currSol.routeMaxVisitsViolation[r1] = newMaxVisitsViolR1
    solver.currSol.routeMaxVisitsViolation[r2] = newMaxVisitsViolR2

    customerI1 = solver.currSol.routes[r1][i]
    customerI2 = solver.currSol.routes[r1][i+1]
    customerJ = solver.currSol.routes[r2][j]
    solver.currSol.routes[r1][i] = customerJ
    deleteat!(solver.currSol.routes[r1], i+1)
    solver.currSol.routes[r2][j] = customerI1
    insert!(solver.currSol.routes[r2], j+1, customerI2)
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[8, r1, r2] = solver.currSol.timeStamp
    solver.currSol.lastModif[r1] = solver.currSol.timeStamp
    solver.currSol.lastModif[r2] = solver.currSol.timeStamp
end

function applyMoveFamiliarSwap(solver::Solver, newDist::Float64, newCost::Float64, newCapViol::Float64, newMinVisitsViol::Int, newMaxVisitsViol::Int, r::Int, i::Int, outer::Int)
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost
    solver.currSol.capViolation = solver.currSol.capViolation - solver.currSol.routeCapViolation[r] + newCapViol
    solver.currSol.routeCapViolation[r] = newCapViol

    solver.currSol.demands[r] -= demand(solver, solver.currSol.routes[r][i])
    solver.currSol.demands[r] += demand(solver, outer)

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation - solver.currSol.routeMinVisitsViolation[r] + newMinVisitsViol
    solver.currSol.routeMinVisitsViolation[r] = newMinVisitsViol

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation - solver.currSol.routeMaxVisitsViolation[r] + newMaxVisitsViol
    solver.currSol.routeMaxVisitsViolation[r] = newMaxVisitsViol

    delete!(solver.currSol.notVisited[solver.data.vertices[outer].family], outer)    
    push!(solver.currSol.notVisited[solver.data.vertices[solver.currSol.routes[r][i]].family], solver.currSol.routes[r][i])

    solver.currSol.routes[r][i] = outer
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[9, r, r] = solver.currSol.timeStamp
    solver.currSol.lastModif[r] = solver.currSol.timeStamp
    solver.currSol.lastModif[r] = solver.currSol.timeStamp
end

function applyMoveFamiliarRelocateSwap(
    solver::Solver,
    newDist::Float64,
    newCost::Float64,
    newCapViolOut::Float64,
    newCapViolIn::Float64,
    newMinVisitsViolOut::Int,
    newMinVisitsViolIn::Int,
    newMaxVisitsViolOut::Int,
    newMaxVisitsViolIn::Int,
    rin::Int, pos::Int,
    rout::Int, i::Int,
    outer::Int
    )
    # Atualiza custos globais
    solver.currSol.dist = newDist
    solver.currSol.cost = newCost

    # Atualiza violações agregadas
    solver.currSol.capViolation = solver.currSol.capViolation -
        solver.currSol.routeCapViolation[rout] - solver.currSol.routeCapViolation[rin] + newCapViolOut + newCapViolIn

    solver.currSol.minVisitsViolation = solver.currSol.minVisitsViolation -
        solver.currSol.routeMinVisitsViolation[rout] - solver.currSol.routeMinVisitsViolation[rin] + newMinVisitsViolOut + newMinVisitsViolIn

    solver.currSol.maxVisitsViolation = solver.currSol.maxVisitsViolation -
        solver.currSol.routeMaxVisitsViolation[rout] - solver.currSol.routeMaxVisitsViolation[rin] + newMaxVisitsViolOut + newMaxVisitsViolIn

    # --- Atualiza demandas das rotas ---
    leaving = solver.currSol.routes[rout][i]
    solver.currSol.demands[rout] -= demand(solver, leaving)
    solver.currSol.demands[rin]  += demand(solver, outer)

    # --- Atualiza violações por rota ---
    solver.currSol.routeCapViolation[rout] = newCapViolOut
    solver.currSol.routeCapViolation[rin]  = newCapViolIn

    solver.currSol.routeMinVisitsViolation[rout] = newMinVisitsViolOut
    solver.currSol.routeMaxVisitsViolation[rout] = newMaxVisitsViolOut
    solver.currSol.routeMinVisitsViolation[rin]  = newMinVisitsViolIn
    solver.currSol.routeMaxVisitsViolation[rin]  = newMaxVisitsViolIn

    # --- Atualiza rotas ---
    if rin == rout && pos > i
        # se for a mesma rota e a posição de inserção era depois do elemento removido,
        # depois da remoção a posição correta diminui em 1
        pos -= 1
    end

    deleteat!(solver.currSol.routes[rout], i)
    insert!(solver.currSol.routes[rin], pos, outer)
    # --- Atualiza notVisited ---
    delete!(solver.currSol.notVisited[solver.data.vertices[outer].family], outer)
    push!(solver.currSol.notVisited[solver.data.vertices[leaving].family], leaving)
    
    solver.currSol.timeStamp += 1
    solver.currSol.lastEval[10, rout, rin] = solver.currSol.timeStamp
    solver.currSol.lastModif[rout] = solver.currSol.timeStamp
    solver.currSol.lastModif[rin] = solver.currSol.timeStamp
end
