mutable struct Solution
    routes::Vector{Vector{Int}} # routes of the solution
    dist::Float64
    cost::Float64 # total cost of the solution
    demands::Vector{Float64}
    capacities::Vector{Float64}
    notVisited::Vector{Set{Int}}

    routeCapViolation::Vector{Float64}
    capViolation::Float64

    routeMinVisitsViolation::Vector{Int}
    minVisitsViolation::Int

    routeMaxVisitsViolation::Vector{Int}
    maxVisitsViolation::Int

    lastEval::Array{Int, 3}
    lastModif::Vector{Int}
    timeStamp::Int
end
Solution() = Solution(Vector{Vector{Int}}(), 0.0, 0.0, Vector{Float64}(), Vector{Float64}(), Vector{Set{Int}}(), Vector{Float64}(), 0.0, Vector{Int}(), 0, Vector{Int}(), 0,
    Array{Int,3}(undef, 10, 10, 10), Vector{Int}(), 0)

getCost(solution::Solution) = solution.cost
getRoute(solution::Solution, r::Int) = solution.routes[r]
getRoutes(solution::Solution) = solution.routes

function copy_solution!(dest::Solution, src::Solution)
    # --- routes ---
    n_routes = length(src.routes)
    resize!(dest.routes, n_routes)
    for i in 1:length(src.routes)
        # Check if the inner vector is undefined or has a different size
        if !isassigned(dest.routes, i)
            dest.routes[i] = similar(src.routes[i])  # aloca uma vez só
        end
        resize!(dest.routes[i], length(src.routes[i]))
        copyto!(dest.routes[i], src.routes[i])
    end

    # --- escalares ---
    dest.dist = src.dist
    dest.cost = src.cost
    dest.capViolation = src.capViolation
    dest.minVisitsViolation = src.minVisitsViolation
    dest.maxVisitsViolation = src.maxVisitsViolation

    # --- vetores simples ---
    resize!(dest.demands, length(src.demands))
    copyto!(dest.demands, src.demands)

    resize!(dest.capacities, length(src.capacities))
    copyto!(dest.capacities, src.capacities)

    resize!(dest.routeCapViolation, length(src.routeCapViolation))
    copyto!(dest.routeCapViolation, src.routeCapViolation)

    resize!(dest.routeMinVisitsViolation, length(src.routeMinVisitsViolation))
    copyto!(dest.routeMinVisitsViolation, src.routeMinVisitsViolation)

    resize!(dest.routeMaxVisitsViolation, length(src.routeMaxVisitsViolation))
    copyto!(dest.routeMaxVisitsViolation, src.routeMaxVisitsViolation)

    # --- conjuntos ---
    n_notVisited = length(src.notVisited)
    resize!(dest.notVisited, n_notVisited)
    for i in 1:n_notVisited
        if !isassigned(dest.notVisited, i) || dest.notVisited[i] === nothing
            dest.notVisited[i] = Set(src.notVisited[i])
        else
            empty!(dest.notVisited[i])
            union!(dest.notVisited[i], src.notVisited[i])
        end
    end
end





mutable struct Parameters
    restarts::Int
    iterMax::Int
    alpha::Float64
    capPenalty::Float64
    capPenaltyFactor::Float64
    minVisitsPenalty::Float64
    minVisitsPenaltyFactor::Float64
    maxVisitsPenalty::Float64
    maxVisitsPenaltyFactor::Float64

end
Parameters() = Parameters(1, 1, 0.995, 100.0, 0.01, 100.0, 0.01, 100.0, 0.01)
function updatePenalties(params::Parameters, sol::Solution)
    if sol.capViolation <= 1e-6
        params.capPenalty = max(0.0001, (1 - params.capPenaltyFactor) * params.capPenalty)
    else
        params.capPenalty = min(10000.0, (1 + params.capPenaltyFactor) * params.capPenalty)
    end

    if sol.minVisitsViolation <= 1e-6
        params.minVisitsPenalty = max(0.01, (1 - params.minVisitsPenaltyFactor) * params.minVisitsPenalty)
    else
        params.minVisitsPenalty = min(10000.0, (1 + params.minVisitsPenaltyFactor) * params.minVisitsPenalty)
    end

    if sol.maxVisitsViolation <= 1e-6
        params.maxVisitsPenalty = max(0.01, (1 - params.maxVisitsPenaltyFactor) * params.maxVisitsPenalty)
    else
        params.maxVisitsPenalty = min(10000.0, (1 + params.maxVisitsPenaltyFactor) * params.maxVisitsPenalty)
    end
end

mutable struct Diversification
    shift::Int
    swap::Int
end
Diversification() = Diversification(3,3)

mutable struct Vertex
    id::Int
    x::Float64
    y::Float64
    demand::Float64
    family::Int
end
Base.:(==)(a::Vertex, b::Vertex) = a.id == b.id
Base.hash(v::Vertex, h::UInt) = hash(v.id, h)


mutable struct Vehicle
    capacity::Int
end
mutable struct ProblemData
    depot::Vertex
    vertices::Vector{Vertex}
    costMatrix::Matrix{Float64}
    maxNbRoutes::Int
    vehicles::Vector{Vehicle}
    minVisits::Int
    maxVisits::Int
    numFamilies::Int
    families::Vector{Int}
    visits::Vector{Int}
end
ProblemData() = ProblemData(Vertex(0, 0.0, 0.0, 0), Vector{Vertex}(), zeros(2,2), 0, Int[], 0, 0, 0, Int[], Int[])

mutable struct Solver
    seed::Random.MersenneTwister
    params::Parameters
    data::ProblemData
    currSol::Solution
    bestSol::Solution
    bestFeasSol::Solution
    diversification::Diversification
    neighborhoods::Vector{Int}
    active_neighs::Vector{Int}
    pool::Dict{Vector{Int}, Int}
    poolCosts::Dict{Vector{Int}, Float64}
    hashes::Set{UInt64}
    buffer::Vector{Int}
end


function Solver(; 
    seed = 1,
    params = Parameters(),
    data = ProblemData(),
    currSol = Solution(),
    bestSol = Solution(),
    bestFeasSol = Solution(),
    diversification = Diversification(),
    neighborhoods = [i for i = 1:10],
    active_neighs = [i for i = 1:10],
    pool = Dict{Vector{Int}, Int}(),
    poolCosts = Dict{Vector{Int}, Float64}(),
    hashes = Set{UInt64}(),
    buffer = Vector{Int}()
)
    Solver(
        Random.MersenneTwister(seed), params, data, currSol, bestSol, bestFeasSol,
        diversification, neighborhoods, active_neighs, pool, poolCosts, hashes, buffer
    )
end

getCurrSol(solver::Solver) = solver.currSol
getBestSol(solver::Solver) = solver.bestSol
getCostMatrix(solver::Solver) = solver.data.costMatrix



demand(solver::Solver, customer::Int) = solver.data.vertices[customer].demand





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
                print("0 [$(Int(load))] ($(round(risk, digits = 2))")
            else
                print("$(sol.routes[r][i]) [$(Int(load))] ($(round(risk, digits = 2))) -> ")
            end
        end
        print("0 [$(Int(load))] ($(round(risk, digits = 2)))")

        println()
    end
    println("\nCost: $(sol.cost)")
    println("Violation: $(sol.violation)")
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

function plotSolution(path::String, name::String, solver::Solver, sol::Solution)
    f = Figure(size = (800, 600))
    ax = Axis(f[1, 1], title="Cost = $(round(sol.cost, digits = 2)), Viol = $(round(sol.violation, digits = 2))", xlabel="x", ylabel="y")
    rotas = sol.routes
    data = solver.data
    # Construir dicionário id => Vertex
    vertices_dict = Dict(v.id => v for v in [data.depot; data.vertices])

    # Paleta de cores
    # cores = distinguishable_colors(length(rotas))

    # Plotar cada rota
    for (idx, rota) in enumerate(rotas)
        xs = [vertices_dict[i].x for i in rota]
        ys = [vertices_dict[i].y for i in rota]
        lines!(ax, xs, ys, color=:black, linewidth=2)
        scatter!(ax, xs, ys, color=:black, markersize=10)
    end

    # Plotar o depósito
    scatter!(ax, [data.depot.x], [data.depot.y], 
        color=:red, marker=:star5, markersize=20, label="Depósito")

    # Plotar os clientes
    xs_clientes = [v.x for v in data.vertices if v != data.depot]
    ys_clientes = [v.y for v in data.vertices if v != data.depot]
    scatter!(ax, xs_clientes, ys_clientes, 
        color=:black, marker=:circle, markersize=12, label="Clientes")

    # Adicionar labels nos nós
    for v in [data.depot; data.vertices]
        text!(ax, string(v.id), position = (v.x + 0.1, v.y + 0.1), 
              align = (:left, :bottom), fontsize=10)
    end
    # axislegend(ax)
    # f
    save("$(path)/$(name).pdf", f)
end
