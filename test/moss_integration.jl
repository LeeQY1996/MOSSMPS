using Test
using Random
using LinearAlgebra
import MOSSQuantum as MQ
import MOSSMPS as MPS

# The backend instance owns the truncation policy; state copies are independent.
const EXACT_BACKEND = MPS.MatrixProductBackend(; trunc=MPS.NoTruncation())

@testset "Automatic mixed parameters through MPS backend" begin
    θ = MQ.Parameter(:θ)
    circuit = MQ.QCircuit([MQ.RyGate(1,.13;isparas=true),MQ.RxGate(2,θ),
        MQ.CNOTGate(1,2),MQ.RzGate(1,2θ+.1),MQ.RyGate(2,.2)])
    compiled = MQ.compile_parameters(circuit)
    a = first(MQ.parameter_order(compiled))
    observable = MQ.QubitsTerm(1=>"Z")+.3MQ.QubitsTerm(1=>"X",2=>"Y")
    initial = MPS.zero_state_mps(2)
    before = MPS.statevector(initial)
    dense = MQ.ExpectationObjective(compiled,observable,MQ.StateVector(2))
    compressed = MQ.ExpectationObjective(compiled,observable,initial;backend=EXACT_BACKEND)
    point = [.37,.21]
    expected_value,expected_gradient = MQ.value_and_gradient(MQ.AdjointGradient(),dense,point)
    @test MQ.parameter_order(compressed)==[a,θ]
    @test MQ.initial_parameters(compressed;values=Dict(θ=>point[2]))==[.13,point[2]]
    for method in (MQ.ParameterShift(),MQ.FiniteDifference(step=1e-5))
        value,gradient = MQ.value_and_gradient(method,compressed,point)
        @test value ≈ expected_value atol=1e-10
        @test gradient ≈ expected_gradient atol=1e-8
    end
    @test !MQ.supports_gradient(MQ.AdjointGradient(),compressed,point)
    @test MPS.statevector(initial)==before
    bound = MQ.bind_parameters(compiled,point)
    @test MQ.probabilities(EXACT_BACKEND,MQ.simulate(bound,initial;backend=EXACT_BACKEND).state) ≈
          MQ.probabilities(MQ.simulate(bound,MQ.StateVector(2)).state) atol=1e-10
    frozen = MQ.ExpectationObjective(compiled,observable,initial;backend=EXACT_BACKEND,fixed=Dict(a=>point[1]))
    @test MQ.parameter_order(frozen)==[θ]
    @test last(MQ.value_and_gradient(MQ.ParameterShift(),frozen,[point[2]])) ≈ [expected_gradient[2]] atol=1e-8
end

@testset "Named parameters through MPS backend" begin
    θ, φ = MQ.Parameter(:θ), MQ.Parameter(:φ)
    circuit = MQ.QCircuit([MQ.RyGate(1, θ), MQ.RzGate(2, φ + θ/2), MQ.CNOTGate(1, 2)])
    observable = MQ.QubitsTerm(1 => "Z") + 0.3 * MQ.QubitsTerm(2 => "X")
    initial = MPS.zero_state_mps(2)
    before = MPS.statevector(initial)
    dense = MQ.ExpectationObjective(circuit, observable, MQ.StateVector(2);
        parameter_order=[θ, φ], fixed=Dict(φ => 0.1))
    compressed = MQ.ExpectationObjective(circuit, observable, initial;
        backend=EXACT_BACKEND, parameter_order=[θ, φ], fixed=Dict(φ => 0.1))
    value, gradient = MQ.value_and_gradient(MQ.AdjointGradient(), dense, [0.37])
    for method in (MQ.ParameterShift(), MQ.FiniteDifference(; step=1e-5))
        mps_value, mps_gradient = MQ.value_and_gradient(method, compressed, [0.37])
        @test mps_value ≈ value atol=1e-10
        @test mps_gradient ≈ gradient atol=1e-8
    end
    @test MQ.parameter_order(compressed) == [θ]
    @test MPS.statevector(initial) == before
    @test_throws MQ.UnboundParameterError MQ.simulate(circuit, initial; backend=EXACT_BACKEND)
    @test MQ.execution_capability(EXACT_BACKEND, circuit, initial).status === :unknown
    saved_rng = copy(Random.default_rng())
    @test_throws MQ.UnboundParameterError MQ.apply!(EXACT_BACKEND,
        MQ.QCircuit([MQ.XGate(1), circuit]), initial)
    @test MPS.statevector(initial) == before &&
          rand(copy(Random.default_rng())) == rand(saved_rng)
    bound = MQ.bind_parameters(circuit, Dict(θ => 0.37, φ => 0.1))
    @test MQ.probabilities(EXACT_BACKEND, MQ.simulate(bound, initial; backend=EXACT_BACKEND).state) ≈
          MQ.probabilities(MQ.simulate(bound, MQ.StateVector(2)).state) atol=1e-10
end

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

@testset "Cross-backend experiment contracts" begin
    initial = MPS.zero_state_mps(2)
    original = MPS.statevector(initial)
    circuit = MQ.QCircuit([MQ.HGate(1), MQ.CNOTGate(1,2),
                           MQ.AmplitudeDamping(1; γ=0.2), MQ.XGate(2)])
    dense = MQ.simulate(circuit, MQ.StateVector(2)).state
    mps = MQ.simulate(circuit, initial; backend=EXACT_BACKEND).state
    @test mps isa MPS.DensityOperatorMPS
    @test MPS.densitymatrix(mps) ≈ MQ.storage(dense) atol=1e-10
    @test MPS.statevector(initial) == original

    # A downstream gate must continue using the supplied truncation policy,
    # including after a pure-to-mixed conversion.
    lossy = MPS.MatrixProductBackend(; trunc=MPS.truncdim(1))
    short = MQ.QCircuit([MQ.HGate(1), MQ.CNOTGate(1,2),
                         MQ.AmplitudeDamping(1; γ=0.2), MQ.XGate(2)])
    lossy_result = MQ.simulate(short, initial; backend=lossy).state
    @test lossy_result isa MPS.DensityOperatorMPS
    @test real(tr(lossy_result)) ≈ 0.5 atol=1e-10

    # Deterministic observables exercise state and circuit estimators without
    # requiring the random draws of two backends to coincide.
    bell = MQ.QCircuit([MQ.HGate(1), MQ.CNOTGate(1,2)])
    bell_mps = MQ.simulate(bell, initial; backend=EXACT_BACKEND).state
    zz = MQ.QubitsTerm(1=>"Z", 2=>"Z")
    xx = MQ.QubitsTerm(1=>"X", 2=>"X")
    for observable in (zz, xx)
        state_estimate = MQ.estimate(observable, bell_mps; shots=40,
                                    backend=EXACT_BACKEND, rng=MersenneTwister(22))
        circuit_estimate = MQ.estimate(observable, bell, initial; shots=40,
                                      backend=EXACT_BACKEND, rng=MersenneTwister(22))
        @test state_estimate.value ≈ 1 atol=1e-10
        @test circuit_estimate.value ≈ 1 atol=1e-10
        @test state_estimate.shots == circuit_estimate.shots == 40
    end

    # A flipped reported measurement controls the branch while the original
    # physical outcome is retained in the measurement record.
    flip = MQ.ReadoutError(1; p0_to_1=1, p1_to_0=1, scope=:measurement)
    feedback = MQ.QCircuit([MQ.QMeasure(1; key=:m, auto_reset=false),
                            MQ.Conditional(:m, MQ.XGate(2))])
    result = MQ.execute(feedback, initial; backend=EXACT_BACKEND, shots=8,
                        readout=flip, rng=MersenneTwister(41))
    @test result.counts == Dict("01"=>8)
    @test all(only(records).outcome == 0 && only(records).reported_outcome == 1
              for records in result.measurements)
    @test all(register[:m] == 1 for register in result.classical)
    @test MPS.statevector(initial) == original
end

@testset "Large-register terminal sampling" begin
    # A full reduced density matrix for all 20 selected sites would require
    # 4^20 entries. These execution paths instead use sequential sampling.
    initial = MPS.zero_state_mps(20)
    circuit = MQ.QCircuit()
    result = MQ.execute(circuit, initial; shots=3, backend=EXACT_BACKEND,
                        rng=MersenneTwister(19))
    @test size(result.samples) == (3,20)
    @test result.counts == Dict(repeat("0",20)=>3)

    flip = MQ.ReadoutError(20; p0_to_1=1, p1_to_0=1, scope=:terminal)
    counts = MQ.execute(circuit, initial; shots=3, backend=EXACT_BACKEND,
                        readout=flip, result=:counts, rng=MersenneTwister(19))
    @test counts.counts == Dict(repeat("0",19)*"1"=>3)
    @test counts.accepted == counts.shots == 3
    empty_result = MQ.execute(circuit, initial; shots=0, backend=EXACT_BACKEND,
                              rng=MersenneTwister(21))
    @test size(empty_result.samples) == (0,20)
    @test MQ.probabilities(EXACT_BACKEND, initial; qubits=(1,20)) ≈ [1,0,0,0]
end

@testset "MPS execution capability reports" begin
    initial = MPS.zero_state_mps(2)
    original = MPS.statevector(initial)
    branch = MQ.QCircuit([MQ.HGate(1), MQ.QMeasure(1; key=:m, auto_reset=false),
                          MQ.Conditional(:m, MQ.AmplitudeDamping(2; γ=0.2);
                                         otherwise=MQ.XGate(2)),
                          MQ.XGate(1)])
    for mode in (:simulate, :execute)
        report = MQ.execution_capability(EXACT_BACKEND, branch, initial; mode=mode)
        @test report.status === :supported
        @test Set(report.final_state_types) == Set([MPS.MPS, MPS.DensityOperatorMPS])
    end
    seen = Set{Int}()
    for seed in 1:8
        mps = MQ.simulate(branch, initial; backend=EXACT_BACKEND, rng=MersenneTwister(seed))
        dense = MQ.simulate(branch, MQ.StateVector(2); rng=MersenneTwister(seed))
        bit = mps.classical[:m]
        push!(seen, bit)
        @test bit == dense.classical[:m]
        @test mps.state isa (bit == 1 ? MPS.DensityOperatorMPS : MPS.MPS)
        @test MQ.expectation(EXACT_BACKEND, MQ.QubitsTerm(2=>"Z"), mps.state) ≈
              MQ.expectation(MQ.QubitsTerm(2=>"Z"), dense.state) atol=1e-10
    end
    @test seen == Set([0,1])
    unsupported = MQ.execution_capability(EXACT_BACKEND,
        MQ.QCircuit([MQ.QMeasure(1; keep=false)]), initial; mode=:simulate)
    @test unsupported.status === :unsupported
    @test any(issue -> issue.path == (1,), unsupported.issues)
    @test MQ.execution_capability(EXACT_BACKEND, branch, initial; mode=:apply).status === :unsupported
    estimate_report = MQ.execution_capability(EXACT_BACKEND, MQ.QCircuit([MQ.HGate(1)]), initial;
        mode=:estimate, observable=MQ.QubitsTerm(1=>"X"), shots=16)
    @test estimate_report.status === :supported
    selection_report = MQ.execution_capability(EXACT_BACKEND, MQ.QCircuit([MQ.QSelect(1, 0)]), initial;
        mode=:estimate, observable=MQ.QubitsTerm(1=>"Z"), shots=16)
    @test selection_report.status === :unsupported
    @test MPS.statevector(initial) == original
end
