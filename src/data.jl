function read_homogeneous_fleet(filename::String)::ProblemData
    open(filename, "r") do file
        coords = Dict{Int, Tuple{Float64, Float64}}()
        family_assignments = Dict{Int, Int}()  # cliente_id → família
        family_visits = Dict{Int, Int}()       # família → visitas requeridas
        family_demand = Dict{Int, Float64}()   # família → demanda total
        vertex_demand = Dict{Int, Float64}()   # cliente_id → demanda
        family_visits_vec = Vector{Int}()
        depot_id = 1
        num_vehicles = 0
        capacity = 0.0
        min_visits = 0
        max_visits = typemax(Int)
        
        section = ""

        for line in eachline(file)
            line = strip(line)
            isempty(line) && continue

            if startswith(line, "CAPACITY")
                capacity = parse(Float64, split(line, ":")[2])
            elseif startswith(line, "VEHICLES")
                num_vehicles = parse(Int, split(line, ":")[2])
            elseif startswith(line, "NODE_COORD_SECTION")
                section = "coords"
            elseif startswith(line, "FAMILY_SECTION")
                section = "families"
            elseif section == "coords"
                parts = split(line)
                id = parse(Int, parts[1])
                x = parse(Float64, parts[2])
                y = parse(Float64, parts[3])
                coords[id] = (x, y)
            elseif section == "families"
                parts = split(line)
                fam_id = parse(Int, parts[1])
                num_nodes = parse(Int, parts[2])
                visits = parse(Int, parts[3])
                demand = parse(Float64, parts[4])

                # Distribuir membros da família
                start_id = length(family_assignments) + 2  # pula depósito
                for i in 0:num_nodes-1
                    client_id = start_id + i
                    family_assignments[client_id] = fam_id
                end

                # Salvar visitas e demandas por família
                push!(family_visits_vec, visits)
                family_visits[fam_id] = visits
                family_demand[fam_id] = demand
            end
        end

        # Distribuir demanda entre os vértices da mesma família
        for (cid, fam) in family_assignments
            num_nodes = count(x -> x == fam, values(family_assignments))
            vertex_demand[cid] = family_demand[fam] / 1#num_nodes
        end

        # Criar vértices
        vertices = Vector{Vertex}()
        depot_coord = coords[depot_id]
        depot = Vertex(depot_id, depot_coord[1], depot_coord[2], 0.0, 0)

        for (id, (x, y)) in coords
            if id == depot_id
                continue
            end
            fam = get(family_assignments, id, 0)
            demand = get(vertex_demand, id, 0.0)
            push!(vertices, Vertex(id-1, x, y, demand, fam))
        end

        # Construir matriz de custo (distâncias euclidianas)
        n = length(vertices) + 1  # incluindo depósito
        costMatrix = zeros(n, n)
        orderedVertices = Vector{Vertex}()
        for i = 1:length(vertices)
            push!(orderedVertices, vertices[findfirst(x -> x.id == i, vertices)])
        end
        all_vertices = [depot; orderedVertices]
        for i in 1:n
            for j in 1:n
                dx = all_vertices[i].x - all_vertices[j].x
                dy = all_vertices[i].y - all_vertices[j].y
                costMatrix[i, j] = floor(sqrt(dx^2 + dy^2) + 0.5)
            end
        end

        # Frota homogênea: todos os veículos têm a mesma capacidade
        # vehicle_capacities = fill(round(Int, capacity), num_vehicles)
        vehicles = [Vehicle(capacity) for i = 1:num_vehicles]
        orderedVertices = Vector{Vertex}()
        for i = 1:length(vertices)
            push!(orderedVertices, vertices[findfirst(x -> x.id == i, vertices)])
        end
        return ProblemData(
            depot,
            orderedVertices,
            costMatrix,
            num_vehicles,
            vehicles,
            min_visits,
            max_visits,
            length(unique(values(family_assignments))),
            collect(1:length(unique(values(family_assignments)))),
            family_visits_vec

        )
    end
end

function read_heterogeneous_fleet(filename::String)::ProblemData
    open(filename, "r") do io
        # --- Leitura dos parâmetros principais ---
        n_nodes = parse(Int, readline(io))                  # número total de nós
        n_families = parse(Int, readline(io))               # número de famílias
        total_to_visit = parse(Int, readline(io))           # total de nós a visitar
        n_agents = parse(Int, readline(io))                 # número de veículos/agentes
        
        # Capacidades dos veículos
        capacities = parse.(Int, split(readline(io)))       
        vehicles = [Vehicle(c) for c in capacities]
        
        # Elementos por família
        elems_per_family = parse.(Int, split(readline(io)))
        
        # --- Leitura dos nós pertencentes a cada família ---
        families_nodes = Vector{Vector{Int}}()
        for _ in 1:n_families
            push!(families_nodes, parse.(Int, split(readline(io))))
        end
        
        # --- Leitura das visitas por família (id_fam, visits, weight) ---
        visits = Int[]
        weights = Float64[]
        for _ in 1:n_families
            line = split(readline(io))
            # Exemplo: "1 2 5"  => family_id, visits, weight
            push!(visits, parse(Int, line[2]))
            push!(weights, parse(Float64, line[3]))
        end
        
        # --- Leitura da matriz de distâncias ---
        costMatrix = zeros(Float64, n_nodes+1, n_nodes+1)
        for i in 1:n_nodes+1
            values = parse.(Float64, split(readline(io)))
            costMatrix[i, :] .= values
            costMatrix[i, i] = 0.0
        end
        
        # --- Construção dos vértices ---
        vertices = Vector{Vertex}()
        id_counter = 1
        for fam_id in 1:n_families
            for node in families_nodes[fam_id]
                # Coordenadas fictícias (não existem no arquivo!)
                # -> Vamos extrair do padrão: não há coords no arquivo,
                #    então podemos colocar zeros ou inferir via id (depende da aplicação)
                v = Vertex(node, 0.0, 0.0, weights[fam_id], fam_id)
                push!(vertices, v)
                id_counter += 1
            end
        end
        
        # O depósito é o primeiro nó da família 1 (por convenção)
        depot = Vertex(0, 0.0, 0.0, 0.0, 0)
        
        # --- Montagem da struct final ---
        # for vertex in vertices
        #     @show vertex
        # end
        # @show visits
        # @show n_families
        # @show elems_per_family
        # @show vehicles
        return ProblemData(
            depot,
            vertices,
            costMatrix,
            n_agents,                # maxNbRoutes
            vehicles,
            0,
            typemax(Int),
            n_families,
            collect(1:n_families),
            visits
        )
    end
end

function read_cunha(filename::String)::ProblemData
    open(filename, "r") do io
        # --- Cabeçalho principal ---
        n_nodes_excl_depot = parse(Int, readline(io))
        n_families = parse(Int, readline(io))
        total_visits = parse(Int, readline(io))
        n_tours = parse(Int, readline(io))
        
        # min e max visitas por tour
        min_max = parse.(Int, split(readline(io)))
        min_visits, max_visits = min_max

        # número de elementos por família
        elems_per_family = parse.(Int, split(readline(io)))

        # --- Nós pertencentes a cada família ---
        families_nodes = Vector{Vector{Int}}()
        for _ in 1:n_families
            push!(families_nodes, parse.(Int, split(readline(io))))
        end

        # --- Visitas por família ---
        visits = Int[]
        for _ in 1:n_families
            line = split(readline(io))
            # formato: id_family num_visits
            push!(visits, parse(Int, line[2]))
        end

        # --- Matriz de custos (depósito incluído) ---
        total_nodes = n_nodes_excl_depot + 1  # inclui o depósito
        costMatrix = zeros(Float64, total_nodes, total_nodes)
        for i in 1:total_nodes
            values = parse.(Float64, split(readline(io)))
            costMatrix[i, :] .= values
            costMatrix[i, i] = 0.0
        end

        # --- Construção dos vértices ---
        vertices = Vector{Vertex}()
        for fam_id in 1:n_families
            for node in families_nodes[fam_id]
                push!(vertices, Vertex(node, 0.0, 0.0, 0.0, fam_id))
            end
        end

        # --- Depósito ---
        depot = Vertex(0, 0.0, 0.0, 0.0, 0)

        # --- Veículos ---
        vehicles = [Vehicle(10000) for _ in 1:n_tours]
        # for vert in vertices
        #     @show vert
        # end
        # @show min_visits
        # @show max_visits
        # sleep(1000)
        # --- Struct final ---
        return ProblemData(
            depot,
            vertices,
            costMatrix,
            n_tours,          # maxNbRoutes
            vehicles,
            min_visits,
            max_visits,
            n_families,
            collect(1:n_families),
            visits
        )
    end
end

