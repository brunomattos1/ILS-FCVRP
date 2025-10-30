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
        num_visits_per_route = 0
        for i = 1:length(sol.routes[r])-1
            cost += solver.data.costMatrix[sol.routes[r][i]+1, sol.routes[r][i+1]+1]
            if sol.routes[r][i] != 0
                num_visits_per_route += 1
                visits[solver.data.vertices[sol.routes[r][i]].family] += 1
            end
        end
        if (solver.data.minVisits > num_visits_per_route)
            println("a rota $r $(sol.routes[r]) esta visitando menos nós do q deveria")
        end
        if num_visits_per_route > solver.data.maxVisits
            println("a rota $r $(sol.routes[r]) esta visitando mais nós do q deveria")
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
            neighborhoods::Vector{Int} = [1, 2, 3, 4, 5, 6, 7, 8, 10]
            )
    # data = read_homogeneous_fleet(instance)
    data = read_heterogeneous_fleet(instance)
    # data = read_cunha(instance)
    
    data.maxNbRoutes = data.maxNbRoutes
    solver = Solver(
        seed = seed,
        params = Parameters(restarts, iterMax, 100.0, 0.01, 0.0, 0.01, 0.0, 0.01), 
        diversification = Diversification(randShift, randSwap),
        data = data, 
        neighborhoods = neighborhoods
    )
    time = @elapsed ILS(solver)
    checkSolution(solver, solver.bestSol)
    printSolution(solver, solver.bestSol)
    return time, solver.bestSol.cost
end
path = "/mnt/c/Users/bruno.mattos/OneDrive - americanas s.a/Documentos/GitHub/ILS-FCVRP/instances/heterogeneous_fleet/SYBier1002D.dat"
main(path;
    seed = 1,
    restarts = 1, 
    iterMax = 10000,
    randShift = 2,
    randSwap = 2)

# if length(ARGS) < 1
#     println("Uso: julia main.jl <path> [seed] [restarts] [iterMax] [randShift] [randSwap]")
#     exit(1)
# end

# # Lê argumentos do terminal
# path       = ARGS[1]
# seed       = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 1
# restarts   = length(ARGS) >= 3 ? parse(Int, ARGS[3]) : 1
# iterMax    = length(ARGS) >= 4 ? parse(Int, ARGS[4]) : 5000
# randShift  = length(ARGS) >= 5 ? parse(Int, ARGS[5]) : 1
# randSwap   = length(ARGS) >= 6 ? parse(Int, ARGS[6]) : 1

# # Exibe os parâmetros
# println("Executando com parâmetros:")
# println("  path       = $path")
# println("  seed       = $seed")
# println("  restarts   = $restarts")
# println("  iterMax    = $iterMax")
# println("  randShift  = $randShift")
# println("  randSwap   = $randSwap")

# seeds = 5
# # instance = split(path, "/")[end]
# # Chama sua função principal
# iters = [500, 1000, 2000, 5000, 10000]
# instances = readdir("/mnt/c/Users/bruno.mattos/OneDrive - americanas s.a/Documentos/GitHub/ILS-FCVRP/instances/params")

# for iter in iters
#     for inst in instances
#         path = "/mnt/c/Users/bruno.mattos/OneDrive - americanas s.a/Documentos/GitHub/ILS-FCVRP/instances/params/"*inst
#         avgCost = 0.0
#         avgTime = 0.0
#         # path = "/mnt/c/Users/bruno.mattos/OneDrive - americanas s.a/Documentos/GitHub/ILS-FCVRP/instances/params/P60_10_6_3.fcvrp"
#         for seed = 1:seeds
#             println("Executando instancia $inst na seed $seed com iter $iter")
#             time, cost = main(path; seed = seed, restarts = 1, iterMax = iter, randShift = 1, randSwap = 1)
#             avgTime += time
#             avgCost += cost
#             Profile.clear_malloc_data()
#             GC.gc()
#         end
#         avgTime = avgTime/seeds
#         avgCost = avgCost/seeds
#         open("/mnt/c/Users/bruno.mattos/OneDrive - americanas s.a/Documentos/GitHub/ILS-FCVRP/results/params.txt", "a") do f
#             write(f, "$iter,$inst,$avgCost,$avgTime\n")
#         end
#     end

# end



