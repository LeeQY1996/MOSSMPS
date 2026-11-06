import MOSSMPS
const SharedMPSCore = MOSSMPS.MPSCore
const FMA = MOSSMPS.MPSAlgorithms

@testset "shared MPSCore contract" begin
    @test FMA.CanonicalMPS === SharedMPSCore.CanonicalMPS
    @test FMA.CanonicalMPO === SharedMPSCore.CanonicalMPO
    @test FMA.MPOHamiltonian === SharedMPSCore.MPOHamiltonian
    @test FMA.NoTruncation === SharedMPSCore.NoTruncation
    @test FMA.apply! === SharedMPSCore.apply!
    @test FMA.expectation === SharedMPSCore.expectation
    @test FMA.bonddims === SharedMPSCore.bonddims
    @test FMA.space_l === SharedMPSCore.space_l
    @test FMA.space_r === SharedMPSCore.space_r
    @test FMA.phydim === SharedMPSCore.phydim
    state = MOSSMPS.zero_state_mps(3)
    @test state.core isa FMA.CanonicalMPS
    @test FMA.bonddims(state.core) == MOSSMPS.bonddims(state)
end
