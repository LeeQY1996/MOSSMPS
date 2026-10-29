module MigratedCoreTests
using Test
using LinearAlgebra
using Random
using TensorOperations
using MOSSQuantumMPS.MPSCore
using MOSSQuantumMPS.MPSCore: MPSCore, SVD, QR, QRpos, LQ, LQpos, SDD, Polar,
    max_bonddims, l_LL, r_RR
const Defaults = MPSCore.Defaults
include("core/helpers.jl")
@testset "MPSCore migrated foundations" begin
    @testset "tensor operations" begin
        include("core/tensorops/linalg.jl")
        include("core/tensorops/truncation.jl")
    end
    @testset "states" begin
        include("core/states/structures.jl")
        include("core/states/observables.jl")
    end
    @testset "operators" begin
        include("core/operators/mpo.jl")
        include("core/operators/longrangeop.jl")
        include("core/operators/sparsempo.jl")
        include("core/operators/vectorize.jl")
        include("core/operators/nonuniform.jl")
    end
end
end
