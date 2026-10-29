using Test
using LinearAlgebra
using Random
using MOSSQuantumMPS

Random.seed!(20260908)

@testset "MOSSQuantumMPS" begin
    include("tensorops.jl")
    include("moss_integration.jl")
end

include("core_suite.jl")
