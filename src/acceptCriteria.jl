function acceptSol(solver::Solver)
    if solver.currSol.cost < solver.bestSol.cost  - 1e-4
        return true
    end
    return false
end