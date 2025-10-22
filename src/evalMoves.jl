function improved(cost::Float64, bestCost::Float64)
    if cost < bestCost - 1e-4
        return true
    end
    return false
end


function evalBestInsertion(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r::Int, customer::Int, j::Int)
    cost = bestInsertionCost(currCost, solver.data.costMatrix, routes[r], customer, j)
    return cost
end

function evalIntraShift10(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r::Int, i::Int, j::Int)
    cost = intraShift10Cost(currCost, solver.data.costMatrix, routes[r], i, j)
    return cost
end

function evalIntraShift20(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r::Int, i::Int, j::Int)
    cost = intraShift20Cost(currCost, solver.data.costMatrix, routes[r], i, j)
    return cost
end

function evalIntraSwap11(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r::Int, i::Int, j::Int)
    cost = intraSwap11Cost(currCost, solver.data.costMatrix, routes[r], i, j)
    return cost
end

function eval2opt(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r::Int, i::Int, j::Int)
    cost = twoOptCost(currCost, solver.data.costMatrix, routes[r], i, j)
    return cost
end

function evalInterShift10(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    cost = interShift10Cost(currCost, solver.data.costMatrix, routes[r1], routes[r2], i, j)
    return cost
end

function evalInterShift20(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    cost = interShift20Cost(currCost, solver.data.costMatrix, routes[r1], routes[r2], i, j)
    return cost
end

function evalInterSwap11(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    cost = interSwap11Cost(currCost, solver.data.costMatrix, routes[r1], routes[r2], i, j)
    return cost
end

function evalInterSwap22(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    cost = interSwap22Cost(currCost, solver.data.costMatrix, routes[r1], routes[r2], i, j)
    return cost
end

function evalInterSwap21(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r1::Int, r2::Int, i::Int, j::Int)
    cost = interSwap21Cost(currCost, solver.data.costMatrix, routes[r1], routes[r2], i, j)
    return cost
end

function evalFamiliarSwap(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, r::Int, i::Int, outer::Int)
    cost = familiarSwapCost(currCost, solver.data.costMatrix, routes[r], i, outer)
    return cost
end

function evalFamiliarRelocateSwap(currCost::Float64, routes::Vector{Vector{Int}}, solver::Solver, rout::Int, i::Int, rin::Int, pos::Int, outer::Int)
    cost = familiarRelocateSwapCost(currCost, routes, solver.data.costMatrix, rout, i, rin, pos, outer)
    return cost
end
