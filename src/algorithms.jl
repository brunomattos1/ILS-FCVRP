
function ILS(solver::Solver)
    solver.bestSol.cost = Inf
    solver.bestFeasSol.cost = Inf
    ts = time()
    println("-"^144)
    @printf("| %8s | %10s | %16s | %16s | %12s | %12s | %10s | %10s | %6s | %10s |\n",
            "Restart", "Iter", "Best Feas.", "Best", "Current", "CapPen", "MinVisPen", "MaxVisPen", "Pool", "Time(s)")
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
    #    if c > 1.05*solver.bestFeasSol.cost
    #        delete!(solver.pool, r)
    #    end
    # end
    solver.bestSol = setPartitioning(solver)
end


function ILS(solver::Solver, r::Int)
    it = 0
    ts = time()
    header_time = 10.0
    
    while it < solver.params.iterMax
        it += 1
        perturb!(solver)
        RVND!(solver)
        push!(solver)
        # @show solver.currSol.capViolation, solver.currSol.minVisitsViolation, solver.currSol.maxVisitsViolation
        accepted = acceptSol(solver)
        total_algorithm_time = time() - ts
        # if total_algorithm_time >= header_time
        #     println("-"^144)
        #     @printf("| %8s | %10s | %14s | %12s | %12s | %12s | %14s | %14s | %6s | %10s |\n",
        #             "Restart", "Iter", "Best Feas.", "Best", "Current", "CapPen", "MinVisPen", "MaxVisPen", "Pool", "Time(s)")
        #     println("-"^144)
        #     header_time += 20.0
        # end

        if mod(it, 1) == 0
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
            flush(stdout)
        end

        if accepted
            copy_solution!(solver.bestSol, solver.currSol)
            if solver.currSol.capViolation <= 1e-6 && solver.currSol.minVisitsViolation <= 1e-6 && solver.currSol.maxVisitsViolation <= 1e-6
                copy_solution!(solver.bestFeasSol, solver.currSol)
                it = 0
            end
        elseif solver.currSol.cost < solver.bestFeasSol.cost - 1e-6 && solver.currSol.capViolation <= 1e-6 && solver.currSol.minVisitsViolation <= 1e-6 && solver.currSol.maxVisitsViolation <= 1e-6
            copy_solution!(solver.bestFeasSol, solver.currSol)
            it = 0
        end
    end
end