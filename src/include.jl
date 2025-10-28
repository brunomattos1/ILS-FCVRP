using Random, JuMP, CPLEX, Printf, Profile
import Base: push!
import Base: hash
include("structs.jl")
include("data.jl")
include("setPartitioning.jl")
include("computeViolation.jl")
include("acceptCriteria.jl")
include("algorithms.jl")
include("applyMoves.jl")
include("construct.jl")
include("costFunctions.jl")
include("evalMoves.jl")
include("localSearch.jl")
include("neighborhood.jl")
include("perturb.jl")
