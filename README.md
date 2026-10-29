# MOSSQuantumMPS

MOSSQuantumMPS is an MPS simulator and companion backend for [MOSSQuantum](https://github.com/LeeQY1996/MOSSQuantum). It represents pure states as matrix product states (`MPS`) and mixed states as density-operator MPS (`DensityOperatorMPS`). The shared dense-tensor MPS/MPO foundation lives in `MOSSQuantumMPS.MPSCore`, and higher-level tensor-network algorithms live in `MOSSQuantumMPS.MPSAlgorithms`.

## Installation for local development

Julia 1.10 or later is required. Develop both source packages in the same Julia environment. Replace the paths below with the locations of your checkouts. A separate environment avoids relying on the checked-in manifest's former local paths.

```julia
using Pkg
Pkg.activate("/path/to/my-mps-environment")
Pkg.develop([
    PackageSpec(path="/path/to/MOSSQuantum"),
    PackageSpec(path="/path/to/MOSSMPS"),
])
Pkg.instantiate()
```

DMRG, TDVP, TEBD, compression, tensor-network arithmetic, models, and related algorithms are included in `MOSSQuantumMPS.MPSAlgorithms`; the separate FiniteMPSAlgorithms package is no longer required.

```julia
using MOSSQuantumMPS.MPSCore: OpTerm, MPOHamiltonian
using MOSSQuantumMPS.MPSAlgorithms: DMRG1, ground_state

Z = [1.0 0; 0 -1]
X = [0.0 1; 1 0]
hamiltonian = MPOHamiltonian(OpTerm(-1.0, 1 => Z) + OpTerm(-1.0, 2 => Z) +
                             OpTerm(-0.5, 1 => X, 2 => X))
energy, state, info = ground_state(hamiltonian, DMRG1(D=8, maxiter=50))
```

The submodule keeps algorithm names such as `sample` and `amplitude` separate from simulator APIs while using exactly the same `MPSCore` types and generic functions. Model builders are available through `MOSSQuantumMPS.MPSAlgorithms.Models`. See the [algorithm reference and migration guide](docs/mps-algorithms.md) for the main interfaces.


## Example

```julia
using MOSSQuantum, MOSSQuantumMPS, Random

# No bond truncation in this example; a compressed calculation can use truncdim(32).
backend = MatrixProductBackend(trunc=NoTruncation())
state = zero_state_mps(2)
circuit = QCircuit()
push!(circuit, HGate(1))
push!(circuit, CNOTGate(1, 2))
state = MOSSQuantum.apply!(backend, circuit, state)

MOSSQuantum.probabilities(backend, state)             # approximately [0.5, 0, 0, 0.5]
MOSSQuantum.expectation(backend, QubitsTerm(1=>Z, 2=>Z), state) # approximately 1
samples = MOSSQuantum.sample(Xoshiro(42), state, 100; backend=backend)
```

Pass the backend explicitly when using a nondefault truncation policy. `MOSSQuantum.backend(state)` selects a default `MatrixProductBackend()`. Application may return a replacement state: always use its return value, particularly when a channel promotes a pure state to a density-operator MPS.

## Conventions and truncation

Qubit indices start at one and qubit 1 is the least significant basis bit. The MOSSQuantum bridge converts local gate and Kraus matrix ordering to the MPS core convention; callers should pass ordinary MOSSQuantum gates and channels without manually reversing their matrices. Low-level MPS matrix operations retain their own documented convention.

The default backend truncation is `truncdimcutoff(50, 1e-8)` and can produce approximate results. `MatrixProductBackend(trunc=NoTruncation())` disables bond truncation; floating-point error remains. Bond dimensions and computational cost can grow rapidly, especially for highly entangled states or density-operator MPS. Truncation settings can affect normalization and physical properties; assess accuracy against an untruncated or dense reference for the target circuit.

## Supported operations and boundaries

The bridge implements MOSSQuantum gate and Kraus-map application, Pauli-term/operator expectation, computational-basis probabilities, retained measurement, post-selection and seeded sampling for MPS states. Use `MOSSQuantum.supports(backend, operation, state)` to inspect advertised capabilities. Measurement and other stochastic operations use the explicit RNG supplied to their MOSSQuantum entry points.

`MOSSQuantum.probabilities` materializes a distribution of length `2^k` for `k` requested qubits. Its current reduced-density-matrix intermediate can require `4^k` entries. The MPS `sample` method instead samples sequentially without constructing the complete distribution, but repeatedly copies and measures the state. MOSSQuantum's general experiment/shot execution paths may have different storage or backend limitations; do not assume they inherit this sampling behavior. Gradient methods, batches, GPU execution and every MOSSQuantum noise or classical-control workflow are not established by this bridge. Unsupported operations should be checked before use.

## Licenses and dependencies

This package includes its [GPL-3.0 license](LICENSE). MOSSQuantum's README states GNU GPL version 3.0. The `src/mpscore` foundation was migrated from FiniteMPSAlgorithms commit `ab117c6e09182699f450eb250224bebe0e928c9b`, which did not include an explicit license statement when checked. Its use and redistribution rights must be clarified with its copyright holder; the GPL license file in this repository does not establish authorization for that upstream code. See [provenance](PROVENANCE.md). MatrixAlgebraKit and TensorOperations include MIT license texts; preserve applicable third-party copyright and license notices when distributing dependencies.

After truncation, a state may no longer be normalized. MOSSQuantum readout rejects an unnormalized state; normalize a pure `MPS` with `LinearAlgebra.normalize!(state)` or a `DensityOperatorMPS` with `MOSSQuantumMPS.normalize_tr!(state)` before measuring or sampling. These operations rescale the state and do not undo truncation error.

The efficient sequential sampling described above applies to `MOSSQuantum.sample` on an MPS state when `readout` is omitted. Supplying `readout` delegates to the general `MOSSQuantum.execute` path, which can construct a full probability distribution for the selected qubits; its memory requirements can therefore be exponential in the number of selected qubits.
