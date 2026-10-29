using Test
using Random
using LinearAlgebra
import MOSSQuantum as MQ
import MOSSQuantumMPS as MPS

# The backend instance owns the truncation policy; state copies are independent.
const EXACT_BACKEND = MPS.MatrixProductBackend(; trunc=MPS.NoTruncation())

function evolve_pair(operations, n=3)
    dense = MQ.StateVector(n)
    compressed = MPS.zero_state_mps(n)
    for op in operations
        dense = MQ.apply!(MQ.CPUBackend(), op, dense)
        compressed = MQ.apply!(EXACT_BACKEND, op, compressed)
    end
    return dense, compressed
end

@testset "MOSSQuantum MPS backend integration" begin
    @testset "asymmetric gates, qubit order, and nonlocal gates" begin
        # A complex asymmetric permutation with phases detects more than a
        # probability-only comparison and exercises both position orderings.
        u = ComplexF64[0 0 0 1; 1 0 0 0; 0 im 0 0; 0 0 -im 0]
        for positions in ((1,2), (2,1), (1,3), (3,1))
            operations = [MQ.HGate(1), MQ.RyGate(2, 0.37), MQ.HGate(3),
                          MQ.QuantumGate(positions, u), MQ.CNOTGate(3,1)]
            dense, compressed = evolve_pair(operations)
            @test MQ.nqubits(compressed) == 3
            @test MPS.statevector(compressed) ≈ MQ.storage(dense) atol=1e-10
            for qubits in ([1,2,3], [3,1,2], [3,1], [2], Int[])
                @test MQ.probabilities(EXACT_BACKEND, compressed; qubits=qubits) ≈
                      MQ.probabilities(dense; qubits=qubits) atol=1e-10
            end
        end
    end

    @testset "expectations and copy ownership" begin
        dense, compressed = evolve_pair([MQ.HGate(1), MQ.RyGate(2, 0.46),
                                          MQ.CNOTGate(1,3)])
        obs = MQ.QubitsTerm(1=>"X", 3=>"Z"; coeff=0.7) +
              MQ.QubitsTerm(2=>"Y"; coeff=0.2) + 0.15
        @test MQ.expectation(EXACT_BACKEND, obs, compressed) ≈
              MQ.expectation(obs, dense) atol=1e-10
        before = MPS.statevector(compressed)
        copied = copy(compressed)
        changed = MQ.apply!(EXACT_BACKEND, MQ.XGate(2), copied)
        @test MPS.statevector(compressed) ≈ before
        @test MPS.statevector(changed) ≉ before
    end

    @testset "seeded intermediate measurement" begin
        circuit = MQ.QCircuit([MQ.HGate(1), MQ.CNOTGate(1,2),
                               MQ.QMeasure(1; auto_reset=false),
                               MQ.QMeasure(2; auto_reset=false)])
        initial = MPS.zero_state_mps(2)
        before = MPS.statevector(initial)
        for seed in (1, 2, 17, 938)
            compressed = MQ.simulate(circuit, initial; backend=EXACT_BACKEND,
                                     rng=MersenneTwister(seed))
            repeated = MQ.simulate(circuit, initial; backend=EXACT_BACKEND,
                                   rng=MersenneTwister(seed))
            dense = MQ.simulate(circuit, MQ.StateVector(2); rng=MersenneTwister(seed))
            @test getproperty.(compressed.measurements, :outcome) ==
                  getproperty.(repeated.measurements, :outcome) ==
                  getproperty.(dense.measurements, :outcome)
            @test getproperty.(compressed.measurements, :probability) ≈
                  getproperty.(dense.measurements, :probability) atol=1e-10
            @test MPS.statevector(compressed.state) ≈ MQ.storage(dense.state) atol=1e-10
        end
        @test MPS.statevector(initial) ≈ before

        _, bell = evolve_pair([MQ.HGate(1), MQ.CNOTGate(1,2)], 2)
        samples = MQ.sample(MersenneTwister(44), bell, 100)
        @test samples == MQ.sample(MersenneTwister(44), bell, 100)
        @test size(samples) == (100, 2)
        @test samples[:,1] == samples[:,2]
    end

    @testset "Kraus channel and mixed evolution" begin
        prep = [MQ.HGate(1), MQ.RyGate(2, 0.4), MQ.CNOTGate(1,3)]
        dense, compressed = evolve_pair(prep)
        # Asymmetric two-site unitary Kraus map exercises the same local bit
        # ordering contract on a long-range, reversed channel.
        x = ComplexF64[0 1; 1 0]
        unitary = kron(Matrix{ComplexF64}(I, 2, 2), x)
        two_site = MQ.QuantumMap((3,1), [unitary]; check_tp=true)
        dense_two = MQ.apply!(MQ.CPUBackend(), two_site, copy(dense))
        compressed_two = MQ.apply!(EXACT_BACKEND, two_site, copy(compressed))
        @test MPS.densitymatrix(compressed_two) ≈ MQ.storage(dense_two) atol=1e-10

        channel = MQ.AmplitudeDamping(3; γ=0.27)
        dense = MQ.apply!(MQ.CPUBackend(), channel, dense)
        compressed = MQ.apply!(EXACT_BACKEND, channel, compressed)
        @test compressed isa MPS.DensityOperatorMPS
        @test MPS.densitymatrix(compressed) ≈ MQ.storage(dense) atol=1e-10
        dense = MQ.apply!(MQ.CPUBackend(), MQ.CNOTGate(3,1), dense)
        compressed = MQ.apply!(EXACT_BACKEND, MQ.CNOTGate(3,1), compressed)
        @test MPS.densitymatrix(compressed) ≈ MQ.storage(dense) atol=1e-10
        @test MQ.probabilities(EXACT_BACKEND, compressed; qubits=[3,1,2]) ≈
              MQ.probabilities(dense; qubits=[3,1,2]) atol=1e-10
    end
end

@testset "MOSSQuantum control and readout integration" begin
    @testset "nested circuits, reset and classical feedback" begin
        inner = MQ.QCircuit([MQ.HGate(1), MQ.QMeasure(1; key=:m, auto_reset=false)])
        circuit = MQ.QCircuit([inner, MQ.Conditional(:m, MQ.XGate(1)),
                               MQ.QMeasure(1; key=:end, auto_reset=true)])
        initial = MPS.zero_state_mps(2)
        before = MPS.statevector(initial)
        for seed in (1, 41, 91)
            mps = MQ.simulate(circuit, initial; backend=EXACT_BACKEND, rng=MersenneTwister(seed))
            dense = MQ.simulate(circuit, MQ.StateVector(2); rng=MersenneTwister(seed))
            @test getproperty.(mps.measurements, :outcome) ==
                  getproperty.(dense.measurements, :outcome)
            @test mps.classical[:m] == dense.classical[:m]
            @test mps.classical[:end] == 0
            @test MQ.probabilities(EXACT_BACKEND, mps.state) ≈ [1,0,0,0]
        end
        @test MPS.statevector(initial) == before

        reset = MQ.QCircuit([MQ.XGate(1), MQ.QMeasure(1; auto_reset=true)])
        measured = MQ.simulate(reset, initial; backend=EXACT_BACKEND, rng=MersenneTwister(2))
        @test only(measured.measurements).outcome == 1
        @test only(measured.measurements).probability ≈ 1
        @test MQ.probabilities(EXACT_BACKEND, measured.state) ≈ [1,0,0,0]
        result = MQ.execute(circuit, initial; shots=64, backend=EXACT_BACKEND,
                            rng=MersenneTwister(42))
        repeat = MQ.execute(circuit, initial; shots=64, backend=EXACT_BACKEND,
                            rng=MersenneTwister(42))
        @test result.counts == Dict("00"=>64)
        @test result.samples == repeat.samples
        @test [r[:m] for r in result.classical] == [r[:m] for r in repeat.classical]
        @test MPS.statevector(initial) == before
    end

    @testset "selection with copied input" begin
        initial = MPS.zero_state_mps(2)
        before = MPS.statevector(initial)
        selection = MQ.QCircuit([MQ.HGate(1), MQ.CNOTGate(1,2),
                                 MQ.QCircuit([MQ.QSelect(1,1)])])
        mps = MQ.simulate(selection, initial; backend=EXACT_BACKEND, rng=MersenneTwister(3))
        dense = MQ.simulate(selection, MQ.StateVector(2); rng=MersenneTwister(3))
        @test MPS.statevector(mps.state) ≈ MQ.storage(dense.state) atol=1e-10
        @test only(mps.measurements).probability ≈ 0.5
        result = MQ.execute(selection, initial; shots=64, backend=EXACT_BACKEND,
                            rng=MersenneTwister(81))
        accepted = count(result.accepted)
        @test 0 < accepted < 64
        @test result.counts == Dict("11"=>accepted)
        @test MPS.statevector(initial) == before
    end

    @testset "terminal order, readout errors and capability rejection" begin
        basis = MPS.onehot_encoding_mps([1,0,0])
        original = MPS.statevector(basis)
        @test MQ.sample(MersenneTwister(9), basis, 5; qubits=[3,1]) == repeat([0 1], 5, 1)
        @test MQ.counts(MersenneTwister(9), basis, 5; qubits=[3,1]) == Dict("01"=>5)
        err = MQ.ReadoutError(1; p0_to_1=1, p1_to_0=1, scope=:terminal)
        @test MQ.sample(MersenneTwister(9), basis, 5; qubits=[3,1], readout=err) == repeat([0 0], 5, 1)
        @test !MQ.supports(EXACT_BACKEND, MQ.QMeasure(1; keep=false), basis)
        @test !MQ.supports(EXACT_BACKEND, MQ.QuantumGate((), reshape(ComplexF64[1],1,1)), basis)
        @test_throws MQ.UnsupportedOperation MQ.apply!(EXACT_BACKEND, MQ.QMeasure(1; keep=false), basis)
        @test_throws ArgumentError MQ.apply!(EXACT_BACKEND, MQ.XGate(4), basis)
        @test MPS.statevector(basis) == original
    end
end

@testset "Randomized local axis permutations" begin
    rng = MersenneTwister(382)
    for arity in (2,3), positions in (arity == 2 ? ((1,3),(3,1)) : ((1,2,3),(3,1,2),(2,3,1)))
        # Haar-like unitary: generic dense complex matrix, not a symmetric gate.
        d = 1 << arity
        u = Matrix(qr(randn(rng, ComplexF64, d, d)).Q)
        prep = [MQ.HGate(1), MQ.RyGate(2, 0.72), MQ.RzGate(3, 0.31)]
        dense, mps = evolve_pair(prep)
        gate = MQ.QuantumGate(positions, u)
        gate_dense = MQ.apply!(MQ.CPUBackend(), gate, copy(dense))
        gate_mps = MQ.apply!(EXACT_BACKEND, gate, copy(mps))
        @test MPS.statevector(gate_mps) ≈ MQ.storage(gate_dense) atol=1e-10

        # Reference channel = 0.4 |ψ><ψ| + 0.6 U|ψ><ψ|U†. This is
        # independent of the dense backend's two-qubit channel arity limit.
        channel = MQ.QuantumMap(positions, [sqrt(0.4) * Matrix{ComplexF64}(I,d,d),
                                            sqrt(0.6) * u]; check_tp=true)
        mixed = MQ.apply!(EXACT_BACKEND, channel, copy(mps))
        v, w = MQ.storage(dense), MQ.storage(gate_dense)
        reference = 0.4 * (v * v') + 0.6 * (w * w')
        @test MPS.densitymatrix(mixed) ≈ reference atol=1e-10
    end
end

@testset "Truncation and explicit normalization" begin
    lossy = MPS.MatrixProductBackend(; trunc=MPS.truncdim(1))
    psi = MPS.zero_state_mps(2)
    psi = MQ.apply!(lossy, MQ.HGate(1), psi)
    psi = MQ.apply!(lossy, MQ.CNOTGate(1,2), psi)
    @test norm(psi)^2 ≈ 0.5 atol=1e-10
    before = MPS.statevector(psi)
    @test_throws ArgumentError MQ.probabilities(lossy, psi)
    @test_throws ArgumentError MQ.sample(MersenneTwister(23), psi, 10; backend=lossy)
    @test_throws ArgumentError MQ.measure!(lossy, psi, 1; rng=MersenneTwister(23))
    @test MPS.statevector(psi) ≈ before

    # Pure-to-mixed conversion must preserve the original norm and not mutate
    # its input; a subsequent identity channel must preserve it as well.
    converted = MPS.densitymatrix(psi; trunc=MPS.NoTruncation())
    @test tr(converted) ≈ 0.5 atol=1e-10
    @test MPS.densitymatrix(converted) ≈ before * before' atol=1e-10
    @test MPS.statevector(psi) ≈ before
    identity_channel = MQ.QuantumMap(1, [Matrix{ComplexF64}(I,2,2)]; check_tp=true)
    through_channel = MQ.apply!(EXACT_BACKEND, identity_channel, copy(psi))
    @test MPS.densitymatrix(through_channel) ≈ before * before' atol=1e-10
    @test tr(through_channel) ≈ norm(psi)^2 atol=1e-10
    @test MPS.statevector(psi) ≈ before

    # Also exercise truncation performed directly on a density-operator MPS.
    rho = MPS.densitymatrix_mps(2)
    rho = MQ.apply!(lossy, MQ.HGate(1), rho)
    rho = MQ.apply!(lossy, MQ.CNOTGate(1,2), rho)
    @test tr(rho) ≈ 0.5 atol=1e-10
    @test_throws ArgumentError MQ.probabilities(lossy, rho)
    @test_throws ArgumentError MQ.sample(MersenneTwister(23), rho, 10; backend=lossy)
    MPS.normalize_tr!(rho)
    @test tr(rho) ≈ 1 atol=1e-10
    @test sum(MQ.probabilities(lossy, rho)) ≈ 1
    @test size(MQ.sample(MersenneTwister(23), rho, 10; backend=lossy)) == (10,2)

    normalize!(psi)
    @test norm(psi) ≈ 1 atol=1e-10
    @test sum(MQ.probabilities(lossy, psi)) ≈ 1
    @test size(MQ.sample(MersenneTwister(23), psi, 10; backend=lossy)) == (10,2)
end

@testset "NoTruncation propagates through pure-to-mixed channels" begin
    # Density-MPS contains a ~1e-10 Schmidt value, below the package's
    # default relative cutoff 1e-8; an exact backend must retain it.
    psi = MPS.zero_state_mps(2)
    psi = MQ.apply!(EXACT_BACKEND, MQ.RyGate(1, 2e-5), psi)
    psi = MQ.apply!(EXACT_BACKEND, MQ.CNOTGate(1,2), psi)
    vector = MPS.statevector(psi)
    channel = MQ.QuantumMap(1, [Matrix{ComplexF64}(I,2,2)]; check_tp=true)
    rho = MQ.apply!(EXACT_BACKEND, channel, copy(psi))
    actual = MPS.densitymatrix(rho)
    expected = vector * vector'
    @test abs(expected[4,4]) > 1e-11
    @test abs(actual[4,4] - expected[4,4]) < 1e-13
    @test actual ≈ expected atol=1e-13
    @test MPS.statevector(psi) ≈ vector
end
