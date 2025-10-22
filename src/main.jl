include("include.jl")
Random.seed!(0)  # inicializa o GLOBAL_RNG (se precisar)
ENV["JULIA_HASH_SEED"] = "0"

function printSolution(solver::Solver, sol::Solution)
    for r = 1:length(sol.routes)
        route = sol.routes[r]
        load = 0.0

        print("#$r: 0 (0) -> ")

        for (idx, customer) in enumerate(route)
            if customer == 0
                continue
            end
            load += solver.data.vertices[customer].demand
            print("$(customer) ($(Int(load))) -> ")
        end

        println("0 ($(Int(load)))")
    end

    println("\nCost: $(sol.cost)")
end


function checkSolution(solver::Solver, sol::Solution)
    cost = 0.0
    visits = zeros(Int, solver.data.numFamilies)
    for r = 1:length(sol.routes)
        for i = 1:length(sol.routes[r])-1
            cost += solver.data.costMatrix[sol.routes[r][i]+1, sol.routes[r][i+1]+1]
            if sol.routes[r][i] != 0
                visits[solver.data.vertices[sol.routes[r][i]].family] += 1
            end
        end
    end
    if abs(cost - sol.dist) > 0.01
        println("custo da solução é $(sol.cost) e deveria ser $(cost)")
    end
    for f in solver.data.families
        if visits[f] != solver.data.visits[f]
            println("a familia $f foi visitada $(visits[f]) vezes e nao $(solver.data.visits[f])")
        end
    end
end

function main(instance::String; 
            plot::Bool = false,
            plotPath::String = "",
            plotName::String = "",
            seed::Int = 1,
            restarts::Int = 30,
            iterMax::Int = 50,
            nbGranular::Int = 10,
            penalty::Int = 100,
            randShift::Int = 3,
            randSwap::Int = 3,
            neighborhoods::Vector{Int} = [1, 2, 3, 5, 6, 7, 8, 10]
            )
    # data = read_problem_data(instance)
    data = read_heterogeneous_fleet(instance)
    data.maxNbRoutes = data.maxNbRoutes
    solver = Solver(
        seed = seed,
        params = Parameters(restarts, iterMax, 10.0, 0.01, 100.0, 0.01, 100.0, 0.01), 
        diversification = Diversification(randShift, randSwap),
        data = data, 
        neighborhoods = neighborhoods
    )
    @time ILS(solver)
    # @show solver.bestFeasSol.cost
    # @show solver.bestFeasSol.dist
    # @show solver.bestFeasSol.routes
    # @show solver.bestFeasSol.demands
    # @show solver.bestFeasSol.capacities
    # constructSol!(solver)
    checkSolution(solver, solver.bestSol)
    # @show solver.bestSol
    printSolution(solver, solver.bestSol)
    return 0
end
path = "/home/bruno/Documentos/GitHub/ILS-FCVRP/instances/heterogeneous_fleet/SYPr1003D.dat"
main(path;
    seed = 1,
    restarts = 1, 
    iterMax = 1000,
    randShift = 1,
    randSwap = 1)