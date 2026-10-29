# MPS and MPO algorithms

The `MOSSQuantumMPS.MPSAlgorithms` module contains the algorithms formerly
provided by `FiniteMPSAlgorithms`. It uses the same MPS/MPO types as
`MOSSQuantumMPS.MPSCore`; do not install the old package to use these APIs.
Import the module explicitly to avoid collisions with the simulator's `sample`,
`amplitude` and other names:

```julia
using MOSSQuantumMPS.MPSAlgorithms
# or: import MOSSQuantumMPS.MPSAlgorithms as MPSAlg
```

The module provides:

- Ground and excited states: `ground_state`, `ground_state!`, `excited_state`,
  `excited_state!` with `DMRG1`, `DMRG2` and experimental `CADMRG`.
- MPS/MPO arithmetic and compression: `mult`, `add`, `compress`, `hadamard`,
  `linsolve`, their in-place forms, `SVDCompression` and variational methods.
- Time evolution: `TDVP1`, `TDVP2`, `HadamardTDVP`, `HadamardTDVP2`, `WI`,
  `WII`, `ComplexStepper`, `TaylorCluster`, `timeevo`, `timeevo!`, and
  `timeevompo`; TEBD gate operations use `Gate`, `apply!`, `swap!`,
  `fuse_gates` and `trotter_propagator`.
- Modeling, sampling, and fitting: `MPSAlgorithms.Models` supplies finite-chain
  spin and Fermi–Hubbard models; `sample` and `amplitude` work on canonical MPS;
  `Seq2Seq` and `seq2seq` fit MPO mappings.
- Experimental algorithms include `PDMRG`, `thermalstate`, `ALSRecon`,
  `ALSRecon2` and `reconstruct`.

Canonical state, operator, gate and truncation types are re-exported in this
module for convenience. They are the identical objects provided by `MPSCore`.
In particular, states created by the simulator and canonical states accepted by
these methods use the same underlying tensor-network representation; consult
the individual method docstrings for supported input types and truncation.

To migrate existing code, replace `using FiniteMPSAlgorithms` with
`using MOSSQuantumMPS.MPSAlgorithms`, and replace
`using FiniteMPSAlgorithms.Models` with
`using MOSSQuantumMPS.MPSAlgorithms.Models`. The source package name and UUID
have not changed; `MOSSQuantumMPS` is the only MPS package required.
