function computeViolationInsertion(solver::Solver, r::Int, customer::Int, j::Int)
    capViol = max(0, solver.currSol.demands[r] + solver.data.vertices[customer].demand - solver.currSol.capacities[r])
    visits = length(solver.currSol.routes[r]) - 2 + 1
    minVisitsViol = max(0, solver.data.minVisits - visits)
    maxVisitsViol = max(0, visits - solver.data.maxVisits)
    return capViol, minVisitsViol, maxVisitsViol
end


function computeViolIntraShift10(solver::Solver, r::Int, i::Int, j::Int)
    capViol = max(0, solver.currSol.demands[r] - solver.currSol.capacities[r])
    visits = length(solver.currSol.routes[r]) - 2
    minVisitsViol = max(0, solver.data.minVisits - visits)
    maxVisitsViol = max(0, visits - solver.data.maxVisits)
    return capViol, minVisitsViol, maxVisitsViol
end

function computeViolIntraShift20(solver::Solver, r::Int, i::Int, j::Int)
    capViol = max(0, solver.currSol.demands[r] - solver.currSol.capacities[r])
    visits = length(solver.currSol.routes[r]) - 2
    minVisitsViol = max(0, solver.data.minVisits - visits)
    maxVisitsViol = max(0, visits - solver.data.maxVisits)
    return capViol, minVisitsViol, maxVisitsViol
end

function computeViol2opt(solver::Solver, r::Int, i::Int, j::Int)
    capViol = max(0, solver.currSol.demands[r] - solver.currSol.capacities[r])
    visits = length(solver.currSol.routes[r]) - 2
    minVisitsViol = max(0, solver.data.minVisits - visits)
    maxVisitsViol = max(0, visits - solver.data.maxVisits)
    return capViol, minVisitsViol, maxVisitsViol
end

function computeViolIntraSwap11(solver::Solver, r::Int, i::Int, j::Int)
    capViol = max(0, solver.currSol.demands[r] - solver.currSol.capacities[r])
    visits = length(solver.currSol.routes[r]) - 2
    minVisitsViol = max(0, solver.data.minVisits - visits)
    maxVisitsViol = max(0, visits - solver.data.maxVisits)
    return capViol, minVisitsViol, maxVisitsViol
end


function computeViolInterShift10(solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    firstRouteDemand = solver.currSol.demands[r1] - demand(solver, solver.currSol.routes[r1][i])
    secondRouteDemand = solver.currSol.demands[r2] + demand(solver, solver.currSol.routes[r1][i])

    firstRouteCapViol = max(0, firstRouteDemand - solver.currSol.capacities[r1])
    secondRouteCapViol = max(0, secondRouteDemand - solver.currSol.capacities[r2])

    firstRouteVisits = length(solver.currSol.routes[r1]) - 2 - 1
    secondRouteVisits = length(solver.currSol.routes[r2]) - 2 + 1

    firstRouteMinVisitsViol = max(0, solver.data.minVisits - firstRouteVisits)
    firstRouteMaxVisitsViol = max(0, firstRouteVisits - solver.data.maxVisits)
    
    secondRouteMinVisitsViol = max(0, solver.data.minVisits - secondRouteVisits)
    secondRouteMaxVisitsViol = max(0, secondRouteVisits - solver.data.maxVisits)
    return firstRouteCapViol, secondRouteCapViol, firstRouteMinVisitsViol, firstRouteMaxVisitsViol, secondRouteMinVisitsViol, secondRouteMaxVisitsViol
end

function computeViolInterShift20(solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    firstRouteDemand = solver.currSol.demands[r1] - demand(solver, solver.currSol.routes[r1][i]) - demand(solver, solver.currSol.routes[r1][i+1])
    secondRouteDemand = solver.currSol.demands[r2] + demand(solver, solver.currSol.routes[r1][i]) + demand(solver, solver.currSol.routes[r1][i+1])

    firstRouteCapViol = max(0, firstRouteDemand - solver.currSol.capacities[r1])
    secondRouteCapViol = max(0, secondRouteDemand - solver.currSol.capacities[r2])

    firstRouteVisits = length(solver.currSol.routes[r1]) - 2 - 2
    secondRouteVisits = length(solver.currSol.routes[r2]) - 2 + 2

    firstRouteMinVisitsViol = max(0, solver.data.minVisits - firstRouteVisits)
    firstRouteMaxVisitsViol = max(0, firstRouteVisits - solver.data.maxVisits)
    secondRouteMinVisitsViol = max(0, solver.data.minVisits - secondRouteVisits)
    secondRouteMaxVisitsViol = max(0, secondRouteVisits - solver.data.maxVisits)
    return firstRouteCapViol, secondRouteCapViol, firstRouteMinVisitsViol, firstRouteMaxVisitsViol, secondRouteMinVisitsViol, secondRouteMaxVisitsViol
end

function computeViolInterSwap11(solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    firstRouteDemand = solver.currSol.demands[r1] - demand(solver, solver.currSol.routes[r1][i]) + demand(solver, solver.currSol.routes[r2][j])
    secondRouteDemand = solver.currSol.demands[r2] - demand(solver, solver.currSol.routes[r2][j]) + demand(solver, solver.currSol.routes[r1][i])

    firstRouteCapViol = max(0, firstRouteDemand - solver.currSol.capacities[r1])
    secondRouteCapViol = max(0, secondRouteDemand - solver.currSol.capacities[r2])

    firstRouteVisits = length(solver.currSol.routes[r1]) - 2
    secondRouteVisits = length(solver.currSol.routes[r2]) - 2

    firstRouteMinVisitsViol = max(0, solver.data.minVisits - firstRouteVisits)
    firstRouteMaxVisitsViol = max(0, firstRouteVisits - solver.data.maxVisits)
    secondRouteMinVisitsViol = max(0, solver.data.minVisits - secondRouteVisits)
    secondRouteMaxVisitsViol = max(0, secondRouteVisits - solver.data.maxVisits)

    return firstRouteCapViol, secondRouteCapViol, firstRouteMinVisitsViol, firstRouteMaxVisitsViol, secondRouteMinVisitsViol, secondRouteMaxVisitsViol
end

function computeViolInterSwap22(solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    firstRouteDemand = solver.currSol.demands[r1] - demand(solver, solver.currSol.routes[r1][i]) - demand(solver, solver.currSol.routes[r1][i+1]) + demand(solver, solver.currSol.routes[r2][j]) + demand(solver, solver.currSol.routes[r2][j+1])
    secondRouteDemand = solver.currSol.demands[r2] - demand(solver, solver.currSol.routes[r2][j]) - demand(solver, solver.currSol.routes[r2][j+1]) + demand(solver, solver.currSol.routes[r1][i]) + demand(solver, solver.currSol.routes[r1][i+1])
    
    firstRouteCapViol = max(0, firstRouteDemand - solver.currSol.capacities[r1])
    secondRouteCapViol = max(0, secondRouteDemand - solver.currSol.capacities[r2])

    firstRouteVisits = length(solver.currSol.routes[r1]) - 2
    secondRouteVisits = length(solver.currSol.routes[r2]) - 2

    firstRouteMinVisitsViol = max(0, solver.data.minVisits - firstRouteVisits)
    firstRouteMaxVisitsViol = max(0, firstRouteVisits - solver.data.maxVisits)
    secondRouteMinVisitsViol = max(0, solver.data.minVisits - secondRouteVisits)
    secondRouteMaxVisitsViol = max(0, secondRouteVisits - solver.data.maxVisits)
    return firstRouteCapViol, secondRouteCapViol, firstRouteMinVisitsViol, firstRouteMaxVisitsViol, secondRouteMinVisitsViol, secondRouteMaxVisitsViol
end

function computeViolInterSwap21(solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    firstRouteDemand = solver.currSol.demands[r1] - solver.currSol.routes[r1][i].demand - solver.currSol.routes[r1][i+1].demand + solver.currSol.routes[r2][j].demand
    secondRouteDemand = solver.currSol.demands[r2] - solver.currSol.routes[r2][j].demand + solver.currSol.routes[r1][i].demand + solver.currSol.routes[r1][i+1].demand
    firstRouteCapViol = max(0, firstRouteDemand - solver.currSol.capacities[r1])
    secondRouteCapViol = max(0, secondRouteDemand - solver.currSol.capacities[r2])

    firstRouteVisits = length(solver.currSol.routes[r1]) - 2 - 1
    secondRouteVisits = length(solver.currSol.routes[r2]) - 2 + 1

    firstRouteMinVisitsViol = max(0, solver.data.minVisits - firstRouteVisits)
    firstRouteMaxVisitsViol = max(0, firstRouteVisits - solver.data.maxVisits)
    secondRouteMinVisitsViol = max(0, solver.data.minVisits - secondRouteVisits)
    secondRouteMaxVisitsViol = max(0, secondRouteVisits - solver.data.maxVisits)
    return firstRouteCapViol, secondRouteCapViol, firstRouteMinVisitsViol, firstRouteMaxVisitsViol, secondRouteMinVisitsViol, secondRouteMaxVisitsViol
end

function computeViolFamiliarSwap(solver::Solver, r::Int, i::Int, outer::Int)
    routeDemand = solver.currSol.demands[r] - demand(solver, solver.currSol.routes[r][i]) + demand(solver, outer)
    capViol = max(0, routeDemand - solver.currSol.capacities[r])
    visits = length(solver.currSol.routes[r]) - 2
    minVisitsViol = max(0, solver.data.minVisits - visits)
    maxVisitsViol = max(0, visits - solver.data.maxVisits)
    return capViol, minVisitsViol, maxVisitsViol
end

function computeViolFamiliarRelocateSwap(solver::Solver, rout::Int, i::Int, rin::Int, pos::Int, outer::Int)
    sol = solver.currSol
    data = solver.data

    inner = sol.routes[rout][i]
    d_inner = demand(solver, inner)
    d_outer = demand(solver, outer)

    capViolOut = 0.0
    capViolIn  = 0.0
    minVisitsViolOut = 0
    minVisitsViolIn  = 0
    maxVisitsViolOut = 0
    maxVisitsViolIn  = 0

    if rout != rin
        # --- rota de onde o cliente é removido ---
        newDemandOut = sol.demands[rout] - d_inner
        newVisitsOut = length(sol.routes[rout]) - 2 - 1  # -2 depots, -1 cliente
        capViolOut = max(0, newDemandOut - sol.capacities[rout])
        minVisitsViolOut = max(0, data.minVisits - newVisitsOut)
        maxVisitsViolOut = max(0, newVisitsOut - data.maxVisits)

        # --- rota onde o novo cliente é inserido ---
        newDemandIn = sol.demands[rin] + d_outer
        newVisitsIn = length(sol.routes[rin]) - 2 + 1  # -2 depots, +1 cliente
        capViolIn = max(0, newDemandIn - sol.capacities[rin])
        minVisitsViolIn = max(0, data.minVisits - newVisitsIn)
        maxVisitsViolIn = max(0, newVisitsIn - data.maxVisits)

    else
        # --- mesma rota: substituição dentro da própria rota ---
        newDemand = sol.demands[rout] - d_inner + d_outer
        newVisits = length(sol.routes[rout]) - 2  # nº de clientes não muda
        capViolOut = max(0, newDemand - sol.capacities[rout])
        minVisitsViolOut = max(0, data.minVisits - newVisits)
        maxVisitsViolOut = max(0, newVisits - data.maxVisits)
        capViolIn = max(0, newDemand - sol.capacities[rin])
        minVisitsViolIn = max(0, data.minVisits - newVisits)
        maxVisitsViolIn = max(0, newVisits - data.maxVisits)
    end

    return capViolOut, minVisitsViolOut, maxVisitsViolOut,
           capViolIn,  minVisitsViolIn,  maxVisitsViolIn
end
