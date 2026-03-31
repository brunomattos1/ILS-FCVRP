
function ILS(solver::Solver)
    solver.bestSol.cost = Inf
    solver.bestFeasSol.cost = Inf
    ts = time()
    println("-"^144)
    @printf("| %8s | %10s | %16s | %16s | %12s | %12s | %10s | %10s | %6s | %10s |\n",
            "Restart", "Temp.", "Best Feas.", "Best", "Current", "CapPen", "MinVisPen", "MaxVisPen", "Pool", "Time(s)")
    println("-"^144)
    for r = 1:solver.params.restarts
        constructSol!(solver)
        RVND!(solver)
        push!(solver)
        accepted = acceptSol(solver)
        if accepted
            copy_solution!(solver.bestSol, solver.currSol)
            if solver.currSol.capViolation <= 1e-6 && solver.currSol.minVisitsViolation <= 1e-6 && solver.currSol.maxVisitsViolation <= 1e-6
                copy_solution!(solver.bestFeasSol, solver.currSol)
            end
        end
        it = 0
        total_algorithm_time = time() - ts
        if mod(it, 500) == 0
            @printf("| %8d | %10d | %16.2f | %16.2f | %12.2f | %12.2f | %10.2f | %10.2f | %6d | %10.4f |\n",
                r,
                it,
                solver.bestFeasSol.cost,
                solver.bestSol.cost,
                solver.currSol.cost,
                solver.params.capPenalty,
                solver.params.minVisitsPenalty,
                solver.params.maxVisitsPenalty,
                length(solver.pool),
                total_algorithm_time
            )
        end
        ILS(solver, r)
    end
    # for (r, c) in solver.pool
    #    if solver.poolCosts[r] > 1.05*solver.bestFeasSol.cost
    #        delete!(solver.pool, r)
    #    end
    # end
    solver.bestFeasSol = setPartitioning(solver)
end


function ILS(solver::Solver, r::Int)
    it = 0
    ts = time()
    header_time = 10.0
    T = 100.0
    while T > 0.01
    # while it < solver.params.iterMax
        it += 1
        perturb!(solver)
        RVND!(solver)
        push!(solver)
        accepted = acceptSol(solver)
        total_algorithm_time = time() - ts
        if mod(total_algorithm_time, 1.0) == 0
            @printf("| %8d | %10.3f | %16.2f | %16.2f | %12.2f | %12.2f | %10.2f | %10.2f | %6d | %10.4f |\n",
                r,
                T,
                solver.bestFeasSol.cost,
                solver.bestSol.cost,
                solver.currSol.cost,
                solver.params.capPenalty,
                solver.params.minVisitsPenalty,
                solver.params.maxVisitsPenalty,
                length(solver.pool),
                total_algorithm_time
            )
            flush(stdout)
        end
        newCost = solver.currSol.cost
        Δ = newCost - solver.bestSol.cost

        if solver.currSol.cost < solver.bestFeasSol.cost - 1e-6 && solver.currSol.capViolation <= 1e-6 && solver.currSol.minVisitsViolation <= 1e-6 && solver.currSol.maxVisitsViolation <= 1e-6
            copy_solution!(solver.bestFeasSol, solver.currSol)
        end
        if Δ <= 0 || rand(solver.seed) < exp(-Δ / T)
            copy_solution!(solver.bestSol, solver.currSol)
        else
            copy_solution!(solver.currSol, solver.bestSol)
        end
        # if accepted
        #     copy_solution!(solver.bestSol, solver.currSol)
        #     if solver.currSol.capViolation <= 1e-6 && solver.currSol.minVisitsViolation <= 1e-6 && solver.currSol.maxVisitsViolation <= 1e-6
        #         copy_solution!(solver.bestFeasSol, solver.currSol)
        #         it = 0
        #     end
        # elseif solver.currSol.cost < solver.bestFeasSol.cost - 1e-6 && solver.currSol.capViolation <= 1e-6 && solver.currSol.minVisitsViolation <= 1e-6 && solver.currSol.maxVisitsViolation <= 1e-6
        #     copy_solution!(solver.bestFeasSol, solver.currSol)
        #     it = 0
        # end
        # copy_solution!(solver.currSol, solver.bestSol)
        T *= solver.params.alpha
        # T = T0*(1-(time() - ts)/maxTime)^2
    end
end