function RVND!(solver::Solver)
    neighs = solver.active_neighs   # buffer reutilizável
    src    = solver.neighborhoods   # conjunto base

    # restaura o vetor de vizinhanças (sem alocar)
    resize!(neighs, length(src))
    copyto!(neighs, src)

    while !isempty(neighs)
        shuffle!(solver.seed, neighs)
        improv = false
        for neigh in neighs
            if neigh == 1
                improv = intraShift10!(solver)
            elseif neigh == 2
                improv = intraShift20!(solver)
            elseif neigh == 3
                improv = intraSwap11!(solver)
            elseif neigh == 4
                improv = twoOpt!(solver)
            elseif neigh == 5
                improv = interShift10!(solver)
            elseif neigh == 6
                improv = interShift20!(solver)
            elseif neigh == 7
                improv = interSwap11!(solver)
            elseif neigh == 8
                improv = interSwap22!(solver)
            elseif neigh == 9
                improv = familiarSwap!(solver)
            elseif neigh == 10
                improv = familiarRelocateSwap!(solver)
            elseif neigh == 11
                improv = interSwap21!(solver)
            end
            updatePenalties(solver.params, solver.currSol)
            if improv
                copyto!(neighs, src)
                break
            end
        end
        if !improv
            empty!(neighs)
        end
    end
end
