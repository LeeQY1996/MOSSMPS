using Test
using LinearAlgebra
using Random
using MOSSMPS

Random.seed!(20260908)

@testset "MOSSMPS" begin
    include("tensorops.jl")
    include("moss_integration.jl")
end

include("core_suite.jl")

include("algorithms_suite/runtests.jl")
