# Charge-sector MPS and conditional sampling

`MOSSMPS.MPSAlgorithms.sector_ground_state` uses the existing MPS/MPO
objects, environment contractions and Krylov effective-Hamiltonian actions.
Each virtual bond carries explicit cumulative `(Nα,Nβ)` labels. Random
initialization samples reachable paths using suffix charge sets; local Krylov
vectors contain only allowed entries; separate SVDs in each charge block and
a global Schmidt-value selection preserve these labels after truncation.
No global root-product list or effective Hamiltonian is constructed.

```julia
using Random
using MOSSMPS.MPSAlgorithms
result = sector_ground_state(mpo, root_charges;
    target=(4,4), rng=MersenneTwister(42), max_bond=36,
    cutoff=1e-12, sweeps=12, tolerance=1e-10, memory_budget=2^30)
samples = sample(MersenneTwister(43), result.mps, 1000)
```

`root_charges[s][p]` corresponds to local physical index `p` of site `s`.
The result records energy, norm, bond labels, every local Krylov convergence
flag/residual, sweep energies, and discarded squared Schmidt weight at each
split. The cutoff is an absolute singular-value threshold; `max_bond` limits
total rank across all charge blocks. A previous result can be passed as
`initial=result` and is copied. `method=:dmrg1` preserves its initial charge
and bond space: it is available for larger physical dimensions but has the
usual stronger dependence on the initial guess. Neither method guarantees a
global optimum; use several RNG seeds and increase bond dimension. Variance
is currently not computed by this routine, as explicitly recorded in diagnostics.

`sample(rng, psi, N; atol=1e-12)` accepts arbitrary gauge and finite nonzero
normalization. It contracts right norm environments, normalized at every site,
and rescales each sampled prefix. It never changes site tensors or Schmidt
values. The legacy `sample(psi,N)` uses `Random.default_rng()` and shares this
nonmutating contract. Zero/nonfinite states or conditional weights throw an
error. `sampling_right_environments(psi)` exposes the normalized bra-by-ket
right environments for connection modules; their scalar factors cancel in
conditional probabilities.

The two-site action contracts the state with the second MPO tensor, then the
first. It never joins both MPO tensors before applying them to the state.
`two_site_memory_estimate(x, heff)` estimates sequential workspaces, including
Schur-to-dense site copies where required. `DMRG2(memory_budget=...)` and the
strict-sector driver reject oversized local workspaces before allocation.
The strict-sector driver additionally checks initialization, environment,
Krylov-vector and block-SVD allocations. These estimates are working-array
bounds, not a promise about the process's Julia compiler/BLAS peak RSS.

The strict driver uses eager Lanczos convergence checks on every Krylov step.
This avoids growing all 32 Krylov vectors on already accurate local warm starts;
the convergence tolerance and explicit local residual checks are unchanged.
`diagnostics.local_eigensolver_eager` records this choice.

The strict two-site driver also estimates arithmetic and temporary storage for
precontracting each site MPO with its own environment. When this lowers the
estimated work and fits the memory budget (including Krylov storage), it caches
the two halves once per local eigensolve. Each action then uses two packed BLAS
matrix multiplications. When caching is too large or unhelpful, it retains the
sequential contraction. Neither branch forms a combined two-site MPO. Per-local
records include `contraction_mode`, cache bytes and estimated workspace bytes;
`diagnostics` aggregates `contraction_modes`, `max_contraction_cache_bytes` and
actual Hamiltonian `action_invocations` (including explicit residual checks).

`benchmark/sector_action.jl` reproduces the synthetic cache comparison, including
the H8-center tensor dimensions `(χL,χR,d1,d2,Wl,Wm,Wr)=(16,16,16,16,46,154,46)`.
It prints relative action error, setup time, per-action times, cache bytes and
working-array estimates. This is a contraction benchmark, not an extra chemical
accuracy test; both random complex operators are applied to the same tensor.
