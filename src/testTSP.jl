include("include.jl")

function printRCTVRP(solver::Solver, sol::Solution)
    for r = 1:length(sol.routes)
        risk = 0.
        load = 0.
        print("#$r: ")
        for i = 1:length(sol.routes[r]) - 1
            risk += load*solver.data.costMatrix[sol.routes[r][i]+1, sol.routes[r][i+1]+1]
            if sol.routes[r][i+1] != 0
                load += solver.data.vertices[sol.routes[r][i+1]].demand
            end
            if i == 1
                print("0 (0)", " -> ")
            elseif i == length(sol.routes[r])
                print("0 ($(round(risk, digits = 2))")
            else
                print("$(sol.routes[r][i]) ($(round(risk, digits = 2))) -> ")
            end
        end
        print("0 ($(round(risk, digits = 2)))")

        println()
    end
    println("\nCost: $(sol.cost)")
end

function checkRCTVRP(solver::Solver, sol::Solution)
    visits = zeros(Int, length(solver.data.vertices))
    cost = 0.
    for r = 1:length(sol.routes)
        load = 0.
        risk = 0.
        for i = 1:length(sol.routes[r])-1
            cost += solver.data.costMatrix[sol.routes[r][i]+1, sol.routes[r][i+1]+1]
            risk += load*solver.data.costMatrix[sol.routes[r][i]+1, sol.routes[r][i+1]+1]
            if sol.routes[r][i+1] != 0
                load += solver.data.vertices[sol.routes[r][i+1]].demand
            end
            # load -= solver.res.d[sol.routes[r][end-1]+1, sol.routes[r][end]+1]
            if sol.routes[r][i] > 0
                visits[sol.routes[r][i]] += 1
            end
        end            
    end
    viol = computeViolation(solver, sol)
    if abs(sol.cost - cost) > 1e-6
        throw("cost is: $(sol.cost) but should be $(cost)")
    end
    if abs(sol.violation - viol) > 1e-6
        throw("violation is: $(sol.violation) but should be $(viol)")

    end
    for i = 1:length(solver.data.vertices)
        if visits[i] > 1
            throw("customer $i visited more than once")
        end
        if visits[i] < 1
            throw("customer $i visited less than once")
        end
    end
end

instance = raw"C:\Users\bruno.mattos\OneDrive - americanas s.a\Documentos\GitHub\RCTVRP\instances\O\O81.rctvrp"

data = readData(instance)

solver = Solver(
    seed = 1,
    params = Parameters(20, 50, 10, 10), 
    diversification = Diversification(3, 3),
    data = data, 
    neighborhoods = Set([1, 2, 3, 4, 5, 6, 7])
)
ILS(solver)
printRCTVRP(solver, solver.bestSol)
