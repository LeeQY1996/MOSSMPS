# MPSAlgorithms 逐项 API 参考

[返回 API 目录](../api.md)


导入方式：`import MOSSMPS.MPSAlgorithms as A`。公共基础类型与 `MPSCore` 的对象相同；索引表将再导出项链接到基础层参考。算法新增项在下方分别列出；`experimental/` 来源的条目属于实验接口。

`SVDCompression` 通常返回压缩后的对象；反复扫描的算术算法一般返回 `(对象, ALSConvergenceInfo)`，DMRG 返回值请查具体方法，不能以一种返回形状代替全部重载。收敛状态、残差、截断与内存限制均应随结果核查。

```julia
import MOSSMPS.MPSAlgorithms as A
psi = A.prodmps(ComplexF64, [2, 2], [1, 1])
compressed = A.compress(psi, A.SVDCompression(trunc=A.NoTruncation()))
```

局域维不必为 2。数值基础的 `Gate` 与核心 MOSSQuantum 的线路门是不同对象，矩阵与站点约定以本模块条目为准。


本页逐项列出公开符号。函数条目保留源码已有的完整签名与契约，补充未独立文档化的基础接口；签名中的类型均相对于当前子模块。源码链接可用于核对该方法的精确重载。


## 符号索引

| 符号 | 说明位置 |
|---|---|
| `TruncationScheme` | [与 MPSCore 相同](core-reference.md#api-TruncationScheme) |
| `NoTruncation` | [与 MPSCore 相同](core-reference.md#api-NoTruncation) |
| `TruncateDim` | [与 MPSCore 相同](core-reference.md#api-TruncateDim) |
| `TruncateRelError` | [与 MPSCore 相同](core-reference.md#api-TruncateRelError) |
| `TruncateDimCutoff` | [与 MPSCore 相同](core-reference.md#api-TruncateDimCutoff) |
| `truncdim` | [与 MPSCore 相同](core-reference.md#api-truncdim) |
| `truncrelerr` | [与 MPSCore 相同](core-reference.md#api-truncrelerr) |
| `truncdimcutoff` | [与 MPSCore 相同](core-reference.md#api-truncdimcutoff) |
| `truncate!` | [与 MPSCore 相同](core-reference.md#api-truncate-mutating) |
| `QR` | [与 MPSCore 相同](core-reference.md#api-QR) |
| `QRpos` | [与 MPSCore 相同](core-reference.md#api-QRpos) |
| `LQ` | [与 MPSCore 相同](core-reference.md#api-LQ) |
| `LQpos` | [与 MPSCore 相同](core-reference.md#api-LQpos) |
| `SVD` | [与 MPSCore 相同](core-reference.md#api-SVD) |
| `SDD` | [与 MPSCore 相同](core-reference.md#api-SDD) |
| `Polar` | [与 MPSCore 相同](core-reference.md#api-Polar) |
| `tsvd!` | [与 MPSCore 相同](core-reference.md#api-tsvd-mutating) |
| `tsvd` | [与 MPSCore 相同](core-reference.md#api-tsvd) |
| `leftorth!` | [与 MPSCore 相同](core-reference.md#api-leftorth-mutating) |
| `leftorth` | [与 MPSCore 相同](core-reference.md#api-leftorth) |
| `rightorth!` | [与 MPSCore 相同](core-reference.md#api-rightorth-mutating) |
| `rightorth` | [与 MPSCore 相同](core-reference.md#api-rightorth) |
| `tie` | [与 MPSCore 相同](core-reference.md#api-tie) |
| `permute` | [与 MPSCore 相同](core-reference.md#api-permute) |
| `scalar` | [与 MPSCore 相同](core-reference.md#api-scalar) |
| `isometry` | [与 MPSCore 相同](core-reference.md#api-isometry) |
| `renyi_entropy` | [与 MPSCore 相同](core-reference.md#api-renyi-entropy) |
| `distance` | [与 MPSCore 相同](core-reference.md#api-distance) |
| `distance2` | [与 MPSCore 相同](core-reference.md#api-distance2) |
| `fidelity` | [与 MPSCore 相同](core-reference.md#api-fidelity) |
| `infidelity` | [与 MPSCore 相同](core-reference.md#api-infidelity) |
| `AbstractMPS` | [与 MPSCore 相同](core-reference.md#api-AbstractMPS) |
| `AbstractMPO` | [与 MPSCore 相同](core-reference.md#api-AbstractMPO) |
| `MPSTensor` | [与 MPSCore 相同](core-reference.md#api-MPSTensor) |
| `MPOTensor` | [与 MPSCore 相同](core-reference.md#api-MPOTensor) |
| `CanonicalMPS` | [与 MPSCore 相同](core-reference.md#api-CanonicalMPS) |
| `CanonicalMPO` | [与 MPSCore 相同](core-reference.md#api-CanonicalMPO) |
| `MPO` | [与 MPSCore 相同](core-reference.md#api-MPO) |
| `MPOHamiltonian` | [与 MPSCore 相同](core-reference.md#api-MPOHamiltonian) |
| `Orthogonalize` | [与 MPSCore 相同](core-reference.md#api-Orthogonalize) |
| `SchurMPOTensor` | [与 MPSCore 相同](core-reference.md#api-SchurMPOTensor) |
| `SparseMPOHamiltonian` | [与 MPSCore 相同](core-reference.md#api-SparseMPOHamiltonian) |
| `OpTerm` | [与 MPSCore 相同](core-reference.md#api-OpTerm) |
| `OpSum` | [与 MPSCore 相同](core-reference.md#api-OpSum) |
| `Coeff` | [与 MPSCore 相同](core-reference.md#api-Coeff) |
| `isconstant` | [与 MPSCore 相同](core-reference.md#api-isconstant) |
| `term` | [与 MPSCore 相同](core-reference.md#api-term) |
| `tompotensor` | [与 MPSCore 相同](core-reference.md#api-tompotensor) |
| `tompotensors` | [与 MPSCore 相同](core-reference.md#api-tompotensors) |
| `todense` | [与 MPSCore 相同](core-reference.md#api-todense) |
| `vectorize` | [与 MPSCore 相同](core-reference.md#api-vectorize) |
| `devectorize` | [与 MPSCore 相同](core-reference.md#api-devectorize) |
| `superoperator` | [与 MPSCore 相同](core-reference.md#api-superoperator) |
| `ExpDecayOpTerm` | [与 MPSCore 相同](core-reference.md#api-ExpDecayOpTerm) |
| `ExpDecayOpSum` | [与 MPSCore 相同](core-reference.md#api-ExpDecayOpSum) |
| `PairOpTerm` | [与 MPSCore 相同](core-reference.md#api-PairOpTerm) |
| `isleftcanonical` | [与 MPSCore 相同](core-reference.md#api-isleftcanonical) |
| `isrightcanonical` | [与 MPSCore 相同](core-reference.md#api-isrightcanonical) |
| `iscanonical` | [与 MPSCore 相同](core-reference.md#api-iscanonical) |
| `canonicalize!` | [与 MPSCore 相同](core-reference.md#api-canonicalize-mutating) |
| `canonicalize` | [与 MPSCore 相同](core-reference.md#api-canonicalize) |
| `space_l` | [与 MPSCore 相同](core-reference.md#api-space-l) |
| `space_r` | [与 MPSCore 相同](core-reference.md#api-space-r) |
| `phydim` | [与 MPSCore 相同](core-reference.md#api-phydim) |
| `ophydim` | [与 MPSCore 相同](core-reference.md#api-ophydim) |
| `iphydim` | [与 MPSCore 相同](core-reference.md#api-iphydim) |
| `phydims` | [与 MPSCore 相同](core-reference.md#api-phydims) |
| `ophydims` | [与 MPSCore 相同](core-reference.md#api-ophydims) |
| `iphydims` | [与 MPSCore 相同](core-reference.md#api-iphydims) |
| `bonddim` | [与 MPSCore 相同](core-reference.md#api-bonddim) |
| `bonddims` | [与 MPSCore 相同](core-reference.md#api-bonddims) |
| `scaling` | [与 MPSCore 相同](core-reference.md#api-scaling) |
| `setscaling!` | [与 MPSCore 相同](core-reference.md#api-setscaling-mutating) |
| `svectors_uninitialized` | [与 MPSCore 相同](core-reference.md#api-svectors-uninitialized) |
| `unset_svectors!` | [与 MPSCore 相同](core-reference.md#api-unset-svectors-mutating) |
| `normalize_tr!` | [与 MPSCore 相同](core-reference.md#api-normalize-tr-mutating) |
| `expectation` | [与 MPSCore 相同](core-reference.md#api-expectation) |
| `expectationvalue` | [与 MPSCore 相同](core-reference.md#api-expectationvalue) |
| `entanglement_entropy` | [与 MPSCore 相同](core-reference.md#api-entanglement-entropy) |
| `entanglement_spectrum` | [与 MPSCore 相同](core-reference.md#api-entanglement-spectrum) |
| `schmidt_values` | [与 MPSCore 相同](core-reference.md#api-schmidt-values) |
| `prodmps` | [与 MPSCore 相同](core-reference.md#api-prodmps) |
| `randommps` | [与 MPSCore 相同](core-reference.md#api-randommps) |
| `DensityOperator` | [与 MPSCore 相同](core-reference.md#api-DensityOperator) |
| `infinite_temperature_state` | [与 MPSCore 相同](core-reference.md#api-infinite-temperature-state) |
| `changebond!` | [与 MPSCore 相同](core-reference.md#api-changebond-mutating) |
| `identitympo` | [与 MPSCore 相同](core-reference.md#api-identitympo) |
| `prodmpo` | [与 MPSCore 相同](core-reference.md#api-prodmpo) |
| `randommpo` | [与 MPSCore 相同](core-reference.md#api-randommpo) |
| `hadamard` | [逐项参考](#api-hadamard) |
| `⊙` | [与 MPSCore 相同](core-reference.md#api-hadamard-op) |
| `copyphydims` | [与 MPSCore 相同](core-reference.md#api-copyphydims) |
| `tomps` | [与 MPSCore 相同](core-reference.md#api-tomps) |
| `tompo` | [与 MPSCore 相同](core-reference.md#api-tompo) |
| `mult` | [逐项参考](#api-mult) |
| `add` | [逐项参考](#api-add) |
| `compress` | [逐项参考](#api-compress) |
| `compress!` | [逐项参考](#api-compress-mutating) |
| `svdguess_mult` | [逐项参考](#api-svdguess-mult) |
| `svdguess_add` | [逐项参考](#api-svdguess-add) |
| `svdguess_compress` | [逐项参考](#api-svdguess-compress) |
| `svdguess_hadamard` | [逐项参考](#api-svdguess-hadamard) |
| `mult!` | [逐项参考](#api-mult-mutating) |
| `add!` | [逐项参考](#api-add-mutating) |
| `linsolve!` | [逐项参考](#api-linsolve-mutating) |
| `hadamard!` | [逐项参考](#api-hadamard-mutating) |
| `ground_state` | [逐项参考](#api-ground-state) |
| `ground_state!` | [逐项参考](#api-ground-state-mutating) |
| `excited_state` | [逐项参考](#api-excited-state) |
| `excited_state!` | [逐项参考](#api-excited-state-mutating) |
| `leftsweep!` | [逐项参考](#api-leftsweep-mutating) |
| `rightsweep!` | [逐项参考](#api-rightsweep-mutating) |
| `sweep!` | [逐项参考](#api-sweep-mutating) |
| `SVDCompression` | [逐项参考](#api-SVDCompression) |
| `DMRG1` | [逐项参考](#api-DMRG1) |
| `DMRG2` | [逐项参考](#api-DMRG2) |
| `TDVP1` | [逐项参考](#api-TDVP1) |
| `TDVP2` | [逐项参考](#api-TDVP2) |
| `HadamardTDVP` | [逐项参考](#api-HadamardTDVP) |
| `HadamardTDVP2` | [逐项参考](#api-HadamardTDVP2) |
| `IterativeMPSAlgorithm` | [逐项参考](#api-IterativeMPSAlgorithm) |
| `ALSConvergenceInfo` | [逐项参考](#api-ALSConvergenceInfo) |
| `SingleSiteUpdate` | [逐项参考](#api-SingleSiteUpdate) |
| `TwoSiteUpdate` | [逐项参考](#api-TwoSiteUpdate) |
| `ALSLinSolve2` | [逐项参考](#api-ALSLinSolve2) |
| `Seq2Seq` | [逐项参考](#api-Seq2Seq) |
| `ALSLinSolve` | [逐项参考](#api-ALSLinSolve) |
| `ac_prime` | [逐项参考](#api-ac-prime) |
| `c_prime` | [逐项参考](#api-c-prime) |
| `Heff` | [逐项参考](#api-Heff) |
| `FirstOrderStepper` | [逐项参考](#api-FirstOrderStepper) |
| `SecondOrderStepper` | [逐项参考](#api-SecondOrderStepper) |
| `GeneralStepper` | [逐项参考](#api-GeneralStepper) |
| `iterative_compute!` | [逐项参考](#api-iterative-compute-mutating) |
| `AddCache` | [逐项参考](#api-AddCache) |
| `MultCache` | [逐项参考](#api-MultCache) |
| `HadamardCache` | [逐项参考](#api-HadamardCache) |
| `LinsolveCache` | [逐项参考](#api-LinsolveCache) |
| `Seq2SeqCache` | [逐项参考](#api-Seq2SeqCache) |
| `TDVPCache` | [逐项参考](#api-TDVPCache) |
| `HadamardTDVPCache` | [逐项参考](#api-HadamardTDVPCache) |
| `WI` | [逐项参考](#api-WI) |
| `WII` | [逐项参考](#api-WII) |
| `ComplexStepper` | [逐项参考](#api-ComplexStepper) |
| `complex_stepper` | [逐项参考](#api-complex-stepper) |
| `TaylorCluster` | [逐项参考](#api-TaylorCluster) |
| `timeevompo` | [逐项参考](#api-timeevompo) |
| `timeevo` | [逐项参考](#api-timeevo) |
| `timeevo!` | [逐项参考](#api-timeevo-mutating) |
| `linsolve` | [逐项参考](#api-linsolve) |
| `seq2seq` | [逐项参考](#api-seq2seq) |
| `seq2seq!` | [逐项参考](#api-seq2seq-mutating) |
| `sample` | [逐项参考](#api-sample) |
| `amplitude` | [逐项参考](#api-amplitude) |
| `sampling_right_environments` | [逐项参考](#api-sampling-right-environments) |
| `sector_ground_state` | [逐项参考](#api-sector-ground-state) |
| `sector_leakage` | [逐项参考](#api-sector-leakage) |
| `two_site_memory_estimate` | [逐项参考](#api-two-site-memory-estimate) |
| `DMRGCache` | [逐项参考](#api-DMRGCache) |
| `ExcitedStateCache` | [逐项参考](#api-ExcitedStateCache) |
| `OverlapCache` | [逐项参考](#api-OverlapCache) |
| `TraceCache` | [与 MPSCore 相同](core-reference.md#api-TraceCache) |
| `PDMRG` | [逐项参考](#api-PDMRG) |
| `CADMRG` | [逐项参考](#api-CADMRG) |
| `PositiveMPA` | [逐项参考](#api-PositiveMPA) |
| `ThermalDMRGCache` | [逐项参考](#api-ThermalDMRGCache) |
| `randompmpa` | [逐项参考](#api-randompmpa) |
| `thermalstate` | [逐项参考](#api-thermalstate) |
| `thermalstate!` | [逐项参考](#api-thermalstate-mutating) |
| `freeenergy` | [逐项参考](#api-freeenergy) |
| `tr` | [逐项参考](#api-tr) |
| `CAMPS` | [逐项参考](#api-CAMPS) |
| `ALSRecon` | [逐项参考](#api-ALSRecon) |
| `ALSRecon2` | [逐项参考](#api-ALSRecon2) |
| `ALSReconCache` | [逐项参考](#api-ALSReconCache) |
| `reconstruct` | [逐项参考](#api-reconstruct) |
| `reconstruct!` | [逐项参考](#api-reconstruct-mutating) |
| `AbstractGate` | [与 MPSCore 相同](core-reference.md#api-AbstractGate) |
| `Gate` | [与 MPSCore 相同](core-reference.md#api-Gate) |
| `apply!` | [与 MPSCore 相同](core-reference.md#api-apply-mutating) |
| `swap!` | [与 MPSCore 相同](core-reference.md#api-swap-mutating) |
| `positions` | [与 MPSCore 相同](core-reference.md#api-positions) |
| `shift` | [与 MPSCore 相同](core-reference.md#api-shift) |
| `fuse_gates` | [逐项参考](#api-fuse-gates) |
| `trotter_propagator` | [逐项参考](#api-trotter-propagator) |


<a id="api-hadamard"></a>

## `hadamard`


	hadamard(ψA, ψB, alg=SVDCompression(trunc=Defaults.alg_trunc())) -> χ
	hadamard(ψA, ψB, alg::DMRG1) -> (χ, info)

Compressed pointwise (Hadamard) product ψA ⊙ ψB: the result is a finite-bond MPS approximation
obtained with `alg` (`SVDCompression`: exact product + one SVD sweep; `DMRG1`: site-by-site
variational ALS on a `svdguess_hadamard(ψA, ψB, alg.D)` initial guess; the iterative
routes return `(χ, info)` with `info`, the `ALSConvergenceInfo` of the sweeps,
while the SVD route returns the chain only). To refine a custom
ansatz with its own bond profile (ignoring `alg.D` entirely), call
`hadamard!(χ, ψA, ψB, alg)`.

The exact (strict) product without compression is the operator `⊙` (`ψA ⊙ ψB`).


源码：[src/mpsalgorithms/algorithms/arithmetics/hadamard.jl:327](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/hadamard.jl#L327)



<a id="api-mult"></a>

## `mult`


	mult(h, x, alg=SVDCompression(trunc=Defaults.alg_trunc())) -> CanonicalMPO

Apply the operator `h` to the state / operator `x` (SVD route): the exact product is
formed and compressed by a single SVD sweep under `alg.trunc`. For the variational ALS
route supply a bond cap: `mult(h, x, DMRG1(; ...); D=D)` — the initial guess is drawn
by `svdguess_mult(h, x, D)`.


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:381](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L381)


	mult(h, x, alg::DMRG1) -> (chain, info)

Variational (ALS) evaluation of h·x with bond cap `alg.D`: the initial guess is drawn by
`svdguess_mult(h, x, alg.D)` and refined by sweeps. The operands may be static `MPO`s or
canonical chains (density matrices / process tensors); the external per-site scales of
canonical operands are inherited through the output's `scaling` field (never
materialized as a scaling^L power). The result is always a `CanonicalMPO`. To refine a
custom ansatz with its own bond profile (ignoring `alg.D` entirely), call
`mult!(out, h, x, alg)`. Returns `(chain, info)` with `info`, the
`ALSConvergenceInfo` of the sweeps (the SVD route returns the chain only).


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:394](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L394)



<a id="api-add"></a>

## `add`


	add(ψs::Vector{<:CanonicalMPS}, alg=SVDCompression(trunc=Defaults.alg_trunc())) -> CanonicalMPS
	add(ψs::Vector{<:CanonicalMPS}, alg::DMRG1) -> (CanonicalMPS, info)
	add(ρs::Vector{<:CanonicalMPO}, alg) / add(ρs, alg::DMRG1) -> CanonicalMPO / (CanonicalMPO, info)

Sum of chains: the SVD route forms the exact block-diagonal sum and compresses it with
a single SVD sweep; the variational (ALS) route draws a `svdguess_add(ψs, alg.D)` initial
guess and refines it by sweeps, returning `(chain, info)` with `info`, the
`ALSConvergenceInfo` of the sweeps (the SVD route returns the chain only). The
exact sum is `Base.:+` (block-diagonal, no truncation).


源码：[src/mpsalgorithms/algorithms/arithmetics/add.jl:193](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/add.jl#L193)



<a id="api-compress"></a>

## `compress`


	compress(ψ::CanonicalMPS, alg=SVDCompression(trunc=Defaults.alg_trunc())) -> CanonicalMPS
	compress(h::AbstractMPO, alg=...) -> CanonicalMPO
	compress(x, alg::DMRG1) -> (chain, info)

Compress a single chain: the SVD route canonicalizes a copy of the input with a
truncating SVD sweep; the variational (ALS) route draws a `svdguess_compress(x, D)`
initial guess and refines it by sweeps, returning `(chain, info)` with `info`, the
`ALSConvergenceInfo` of the sweeps (the SVD route returns the chain only).


源码：[src/mpsalgorithms/algorithms/arithmetics/compress.jl:139](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/compress.jl#L139)



<a id="api-compress-mutating"></a>

## `compress!`


	compress!(out, x, alg::DMRG1) -> (out, info)

Single-site variational (ALS) compression of `x` refined in place on the initial guess
`out`. The sweeps determine direction and magnitude together at the data level; the
input's external scale is attached through the per-site `scaling` field of the output
(a scaling^L power is never materialized). Returns `(out, info)` with `info`, the
`ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/arithmetics/compress.jl:122](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/compress.jl#L122)



<a id="api-svdguess-mult"></a>

## `svdguess_mult`


	svdguess_mult(h, x, D::Int)

On-the-fly naive SVD of the exact product h·x as an initial guess for the iterative
`mult`: the site tensors of h·x are formed one at a time and streamed through a
truncating right-orthogonalization with bond cap `D` (`truncdim(D)`; the exact product
itself is never materialized).


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:320](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L320)



<a id="api-svdguess-add"></a>

## `svdguess_add`


	svdguess_add(chains, D::Int)

On-the-fly naive SVD of the exact block-diagonal sum as an initial guess for the
iterative `add` (the exact sum itself is never materialized): site i is the bond-wise
cat of the inputs, each input's external scaling is folded relative to the first input
into every site tensor (per site — a scaling^L power is never formed). The bond
dimension is capped at `D` (`truncdim(D)`).


源码：[src/mpsalgorithms/algorithms/arithmetics/add.jl:131](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/add.jl#L131)



<a id="api-svdguess-compress"></a>

## `svdguess_compress`


	svdguess_compress(x, D::Int)

A truncating SVD re-compression of `x` (bond cap `D`) as an initial guess for the
iterative `compress` (accurate but costly compared to zero padding).


源码：[src/mpsalgorithms/algorithms/arithmetics/compress.jl:111](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/compress.jl#L111)



<a id="api-svdguess-hadamard"></a>

## `svdguess_hadamard`


	svdguess_hadamard(ψA, ψB, D::Int)

On-the-fly naive SVD of the exact pointwise product as an initial guess for the
iterative hadamard (the exact product itself is never materialized). The bond
dimension is capped at `D` (`truncdim(D)`).


源码：[src/mpsalgorithms/algorithms/arithmetics/hadamard.jl:231](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/hadamard.jl#L231)



<a id="api-mult-mutating"></a>

## `mult!`


	mult!(out, h, x, alg::DMRG1) -> (out, info)

Single-site variational (ALS) evaluation of h·x refined in place on the user-supplied
initial guess `out`. The ansatz is taken exactly as supplied — its bond profile is
neither grown nor truncated, and in particular `alg.D` is ignored (it only sets the bond
cap when the guess is drawn automatically by `mult`). Supply a right-canonical `out`.
The sweeps determine direction and magnitude together at the data level (the exact
product is never formed); the external scales of canonical operands are attached through
the per-site `scaling` field of the output — a scaling^L power is never materialized.
Returns `(out, info)` with `info`, the `ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:354](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L354)



<a id="api-add-mutating"></a>

## `add!`


	add!(out, chains, alg::DMRG1) -> (out, info)

Single-site variational (ALS) sum of `chains` refined in place on the initial guess
`out`. The sweeps determine direction and magnitude at the data level; the sum is
expressed in the first input's per-site `scaling` convention (a scaling^L power is
never materialized). Returns `(out, info)` with `info`, the
`ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/arithmetics/add.jl:176](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/add.jl#L176)



<a id="api-linsolve-mutating"></a>

## `linsolve!`


	linsolve!(x, A, y, alg::ALSLinSolve = ALSLinSolve()) -> (x, info)

Single-site variational (ALS) solve of `A·x ≈ y` refined in place on the initial guess
`x`; iterated by the generic `iterative_compute!` on the exact global residual². The
sweeps solve the raw-data problem, and the solution carries the per-site scale
`scaling(y)/scaling(A)` — the represented equation `A·x = y` holds with the operands'
external scales (a scaling^L power is never materialized). Returns `(x, info)` with
`info`, the `ALSConvergenceInfo` of the sweeps; since the loss *is* the
(residual-norm-squared) residual here, `info.residual` holds the final loss.


源码：[src/mpsalgorithms/algorithms/arithmetics/linsolve.jl:217](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/linsolve.jl#L217)



<a id="api-hadamard-mutating"></a>

## `hadamard!`


	hadamard!(χ, ψA, ψB, alg::DMRG1) -> (χ, info)

Single-site variational (ALS) pointwise product of `ψA` and `ψB` refined in place on
the user-supplied initial guess `χ`. The ansatz is taken exactly as supplied — its bond
profile is neither grown nor truncated, and in particular `alg.D` is ignored (it only
sets the bond cap when the guess is drawn automatically by `hadamard`). Supply a
right-canonical `χ`. The sweeps determine direction and magnitude together at the data
level (the exact hadamard product is never formed); the external scale is attached
through the per-site `scaling` field, with the ⊙ convention
`scaling(ψA ⊙ ψB) = scaling(ψA)·scaling(ψB)` — a scaling^L power is never materialized.
Returns `(χ, info)` with `info`, the `ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/arithmetics/hadamard.jl:295](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/hadamard.jl#L295)



<a id="api-ground-state"></a>

## `ground_state`


	ground_state(h::MPOHamiltonian, alg::CADMRG) -> (CAMPS, info)

Ground state of `h` found by CA-DMRG, starting from a random MPS with the bond cap
carried by `alg.trunc`,
returned as a `CAMPS`: the canonical MPS in the Clifford-rotated picture
together with every applied two-qubit Clifford circuit (in application order);
`info` is the `ALSConvergenceInfo` of the sweeps.
Observables on the original Hamiltonian picture are evaluated with
`expectation(::PauliTerm, ::CAMPS)`; e.g. the ground-state energy is the sum of the
Hamiltonian's Pauli-term expectations.


源码：[src/mpsalgorithms/algorithms/experimental/cadmrg.jl:408](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/cadmrg.jl#L408)


	ground_state(h::MPOHamiltonian, alg=DMRG1()) -> (E, ψ, info)

Ground-state energy and (canonical) state of the Hamiltonian `h`, starting from a
random initial state of bond dimension `alg.D`; `info` is the
`ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg.jl:140](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg.jl#L140)


	ground_state(h::MPOHamiltonian, alg::DMRG2) -> (E, ψ, info)

Ground-state energy and state of `h` found by two-site DMRG, starting from a random MPS
of bond `Defaults.D`; `info` is the `ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg2.jl:174](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg2.jl#L174)



<a id="api-ground-state-mutating"></a>

## `ground_state!`


	ground_state!(ψ::CanonicalMPS, h::AbstractMPO, alg::CADMRG) -> info

Clifford-augmented ground-state search starting from the user-provided ansatz `ψ`
(modified in place; `alg.trunc` only affects the sweep truncations when an explicit
ansatz is given). The MPO `h`
is converted to dense form and rewritten in place (transformed by the optimal Clifford
circuits). Returns `info`, the `ALSConvergenceInfo` of the sweeps
(`info.losses` is the per-sweep local-energy history). To obtain the applied
Clifford circuits together with the state, use `ground_state(h, alg)` which returns a
`CAMPS`.


源码：[src/mpsalgorithms/algorithms/experimental/cadmrg.jl:387](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/cadmrg.jl#L387)


	ground_state!(ψ::CanonicalMPS, h::AbstractMPO, alg::DMRG1=DMRG1()) -> info

Ground-state search starting from the initial state `ψ` (modified in place; e.g.
`ψ = randommps(ComplexF64, ophydims(h); D=D)`). Returns `info`, the
`ALSConvergenceInfo` of the sweeps (`info.losses` is the per-sweep local-energy
history, `info.itererr` the final relative loss difference). The returned state is
data-normalized: the external scale is reset through the `scaling` field, never
materialized as a scaling^L power.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg.jl:121](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg.jl#L121)


	ground_state!(ψ::CanonicalMPS, h::AbstractMPO, alg::DMRG2) -> info

Two-site DMRG ground-state search starting from the user-provided ansatz `ψ`
(modified in place; `alg.trunc` only affects the sweep truncations). Returns `info`,
the `ALSConvergenceInfo` of the sweeps (`info.losses` is the per-sweep
local-energy history).


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg2.jl:158](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg2.jl#L158)



<a id="api-excited-state"></a>

## `excited_state`


	excited_state(h::MPOHamiltonian, alg::DMRG1, ψ0::CanonicalMPS...) -> (E, ψ, info)

The lowest excited state orthogonal to all given previous states `ψ0`, starting from a
random initial state of bond dimension `alg.D`; `info` is the
`ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/groundstates/excited.jl:138](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/excited.jl#L138)



<a id="api-excited-state-mutating"></a>

## `excited_state!`


	excited_state!(ψ::CanonicalMPS, h::AbstractMPO, projectors::Vector{CanonicalMPS},
				   alg::DMRG1=DMRG1()) -> info

Search for the lowest state orthogonal to all `projectors`, starting from the initial
state `ψ` (modified in place; e.g. `ψ = randommps(ComplexF64, ophydims(h); D=D)`).
Returns `info`, the `ALSConvergenceInfo` of the sweeps (`info.losses` is the
per-sweep local-energy history).


源码：[src/mpsalgorithms/algorithms/groundstates/excited.jl:122](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/excited.jl#L122)



<a id="api-leftsweep-mutating"></a>

## `leftsweep!`


	leftsweep!(m::HadamardCache, alg::DMRG1) -> kvals

ALS left sweep of the hadamard problem: at each site the local target is the environment
contraction `Cleft · ψA · ψB · Cright`; the chain is moved by QR and the loss
`norm(target)` is recorded per site. The losses are non-decreasing across the sweep. Each
site fuses `(Cleft · ψA · ψB)` once and uses the fused tensor both for the target and
(with the updated bra) for the next environment.


源码：[src/mpsalgorithms/algorithms/arithmetics/hadamard.jl:170](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/hadamard.jl#L170)


	leftsweep!(m::LinsolveCache, alg::ALSLinSolve) -> kvals

One left-to-right ALS sweep: at each site the local normal equation H z = t is solved
by `alg.alg_linsolve`,
the chain is moved by QR and both environment stacks incremented. `kvals` collects the
exact global residual² ‖A·x − y‖² after every site update (non-increasing).


源码：[src/mpsalgorithms/algorithms/arithmetics/linsolve.jl:136](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/linsolve.jl#L136)


	leftsweep!(m::MultCache, alg::DMRG1) -> kvals

ALS left sweep for the `mult` problem: the local target at each site is the environment
contraction `Cleft · imps · mpo · Cright`; the bra is moved by QR and the loss
`norm(target)` is recorded per site. Each site fuses `(Cleft · imps · mpo)` once and uses
the fused tensor both for the target and (with the updated bra) for the next environment.


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:168](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L168)


	leftsweep!(env::CADMRGCache, alg::CADMRG) -> kvals

Left-to-right CA-DMRG sweep: two-site local minimization (sites s, s+1) with Clifford
augmentation. The SVD itself moves the orthogonality center (singular values absorbed
into site s+1); no QR gauge moves are performed, so the not-yet-swept tensors stay
right-canonical and the precomputed right environments remain valid. Every applied
Clifford circuit is recorded on `env.gates`.


源码：[src/mpsalgorithms/algorithms/experimental/cadmrg.jl:336](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/cadmrg.jl#L336)


	leftsweep!(env::ThermalDMRGCache, alg::PDMRG; β) -> fvals

Left-to-right p-DMRG sweep. At each site the local thermal state is computed, then the
center is moved one site to the right by an SVD of `M · B`; the cache's PMPA is updated
in place through its `Ref` fields. When the local space at the center is too small to
carry the rank-`alg.R` purification (boundary sites), the center is merged with
neighbouring sites (`_merged_left_move!`) so the local effective Hamiltonian can
support rank `R` again.


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:407](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L407)


	leftsweep!(c::ALSReconCache, alg::ALSRecon) -> kvals

Left-to-right single-site ALS sweep: matrix-free KrylovKit local normal-equation
solves, QR gauge moves, left-context and ridge transfers. `kvals[s]` is the exact
global data objective after updating site `s` (non-increasing; the ridge is excluded).


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:300](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L300)


	leftsweep!(env::DMRGCache, alg::DMRG1) -> kvals

One left-to-right DMRG1 sweep: at each site the single-site effective Hamiltonian
(`CentralHeff`) is diagonalized with `KrylovKit.eigsolve` (`:SR`), the site tensor updated,
the center moved by QR, and the environment incremented. Returns the per-site local energies.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg.jl:60](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg.jl#L60)


	leftsweep!(env::DMRGCache, alg::DMRG2) -> kvals

Left-to-right two-site DMRG sweep: the pair (s, s+1) is optimized jointly and the SVD
absorbs the singular values into site s+1 (the new orthogonality center); the swept
tensors stay left-canonical, the not-yet-swept tensors stay right-canonical.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg2.jl:65](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg2.jl#L65)


	leftsweep!(env::ExcitedStateCache, alg::DMRG1) -> kvals

One left-to-right projected DMRG1 sweep: the local problem minimizes
`⟨x|H_eff|x⟩` under the constraint `x ⊥ ψ₀⁽ˡ⁾` for all projectors `ψ₀⁽ˡ⁾`,
implemented as the symmetrized projected linear map `Q†·H_eff·Q`
(`Q = Πₖ (I-Pₖ)`). Symmetrizing keeps the map Hermitian (so Lanczos applies); on the
subspace orthogonal to all `ψ₀⁽ˡ⁾` it coincides with `H_eff`, i.e. the same constrained
problem.


源码：[src/mpsalgorithms/algorithms/groundstates/excited.jl:43](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/excited.jl#L43)


	leftsweep!(m::Seq2SeqCache, alg) -> kvals

One left-to-right ALS sweep: at each site the local normal equation is solved densely,
the chain is moved by QR and all three environment stacks are incremented. `kvals`
collects the exact global data objective after every site update.


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:222](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L222)


	leftsweep!(env::HadamardTDVPCache, alg::HadamardTDVP) -> Float64[]

Left half of one Hadamard-flow step: every site tensor (including the last) evolves with
`exp(+dt/2·H_eff)` under the projected pointwise generator, every bond tensor with
`exp(-dt/2·H_bond)` (the generator's bond passing straight through), and the environments
follow the updated state — the same skeleton as the `TDVP1` left sweep.


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:224](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L224)


	leftsweep!(env::HadamardTDVPCache, alg::HadamardTDVP2) -> Float64[]

Left half of one two-site Hadamard step: every pair of sites evolves with
`exp(+dt/2·H_pair)` and is re-split by a truncating SVD (singular values absorbed into the
right site of the pair, which moves the orthogonality center), followed — except for the
last pair — by the single-site backward half-step `exp(-dt/2·H_site)` on the new center.
The environments follow the updated state.


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:322](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L322)


	leftsweep!(env, alg::TDVP1) -> Float64[]

Left half of one TDVP1 time step: every site tensor (including the last) evolves with
`exp(+dt/2·H_eff)` and every bond tensor with `exp(-dt/2·H_bond)` (complement space, both
environments anchored at the bond). The gauge moves are those of the manifold of
`env`'s state (MPS leg groups `(1, 2) | (3,)`, density-operator ones `(1, 2, 4) | (3,)`).


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:343](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L343)


	leftsweep!(env, alg::TDVP2)

Left half of one TDVP2 step: every pair of sites evolves with `exp(+dt/2·H_pair)` and is
re-split by a truncating SVD (singular values absorbed into the right site of the pair),
followed — except for the last pair — by the single-site backward half-step
`exp(-dt/2·H_site)` on the new center. The environments follow the updated state.


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:503](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L503)



<a id="api-rightsweep-mutating"></a>

## `rightsweep!`


	rightsweep!(m::HadamardCache, alg::DMRG1) -> kvals

ALS right sweep (symmetric to `leftsweep!`, LQ gauge moves). `kvals` is ordered by
processing time (sites `L, L-1, …, 1`); the losses are non-decreasing.


源码：[src/mpsalgorithms/algorithms/arithmetics/hadamard.jl:199](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/hadamard.jl#L199)


	rightsweep!(m::LinsolveCache, alg::ALSLinSolve) -> kvals

One right-to-left ALS sweep (symmetric, LQ gauge moves). `kvals` is ordered by processing
time — sites `L, L-1, …, 1` — and collects the exact global residual² ‖A·x − y‖² after
every site update (non-increasing).


源码：[src/mpsalgorithms/algorithms/arithmetics/linsolve.jl:164](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/linsolve.jl#L164)


	rightsweep!(m::MultCache, alg::DMRG1) -> kvals

ALS right sweep for the `mult` problem (symmetric to `leftsweep!`, LQ gauge moves).
`kvals` is ordered by processing time — sites `L, L-1, …, 1`. The fused right tensors
`(Cright · imps · mpo)` serve the target and the next environment alike.


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:196](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L196)


	rightsweep!(env::CADMRGCache, alg::CADMRG) -> kvals

Right-to-left CA-DMRG sweep (symmetric to `leftsweep!`): singular values are absorbed
into the left site of each pair, keeping the already-swept tensors right-canonical.
Every applied Clifford circuit is recorded on `env.gates`.


源码：[src/mpsalgorithms/algorithms/experimental/cadmrg.jl:360](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/cadmrg.jl#L360)


	rightsweep!(env::ThermalDMRGCache, alg::PDMRG; β) -> fvals

Right-to-left p-DMRG sweep (symmetric to `leftsweep!`, with merged boundary updates at
the left edge).


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:462](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L462)


	rightsweep!(c::ALSReconCache, alg::ALSRecon) -> kvals

Right-to-left ALS sweep (symmetric, LQ gauge moves). `kvals` is ordered by processing
time (sites `L, …, 1`); the losses are non-increasing.


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:327](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L327)


	rightsweep!(env::DMRGCache, alg::DMRG1) -> kvals

One right-to-left DMRG1 sweep (symmetric to `leftsweep!`, LQ gauge moves). `kvals` is
ordered by processing time — sites `L, L-1, …, 1`.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg.jl:83](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg.jl#L83)


	rightsweep!(env::DMRGCache, alg::DMRG2) -> kvals

Right-to-left two-site DMRG sweep (symmetric to `leftsweep!`): singular values are
absorbed into the left site of each pair, keeping the already-swept tensors
right-canonical. The SVD singular values are the true Schmidt spectrum at the swept
bond and are recorded on the state (`ket.s[bond+1]`); the final center (site 1) is
normalized, so the returned MPS satisfies `iscanonical`.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg2.jl:85](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg2.jl#L85)


	rightsweep!(env::ExcitedStateCache, alg::DMRG1) -> kvals

One right-to-left projected DMRG1 sweep. `kvals` is ordered by processing time —
sites `L, L-1, …, 1`.


源码：[src/mpsalgorithms/algorithms/groundstates/excited.jl:69](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/excited.jl#L69)


	rightsweep!(m::Seq2SeqCache, alg) -> kvals

One right-to-left ALS sweep (symmetric, LQ gauge moves). `kvals` is ordered by processing
time (sites `L, L-1, …, 1`); the losses are non-increasing.


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:248](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L248)


	rightsweep!(env::HadamardTDVPCache, alg::HadamardTDVP) -> Float64[]

Right half of one Hadamard-flow step (symmetric to `leftsweep!`).


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:247](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L247)


	rightsweep!(env::HadamardTDVPCache, alg::HadamardTDVP2) -> Float64[]

Right half of one two-site Hadamard step (symmetric to `leftsweep!`, singular
values absorbed into the left site of each pair).


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:347](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L347)


	rightsweep!(env, alg::TDVP1) -> Float64[]

Right half of one TDVP1 time step (symmetric to `leftsweep!`, the gauge moves run
right-to-left).


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:366](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L366)


	rightsweep!(env, alg::TDVP2)

Right half of one TDVP2 step (symmetric to `leftsweep!`, singular values absorbed into the
left site of each pair).


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:527](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L527)



<a id="api-sweep-mutating"></a>

## `sweep!`


	sweep!(env::DMRGCache, alg::DMRG1) -> kvals

One full DMRG1 sweep: `leftsweep!` followed by `rightsweep!`.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg.jl:107](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg.jl#L107)


	sweep!(env::HadamardTDVPCache, alg::HadamardTDVP)

One full Hadamard-product time step of size `alg.stepsize` (`leftsweep!` + `rightsweep!`),
i.e. the elementwise `env.state ↦ exp(stepsize·env.H) .* env.state`. Time-evolution loops
are driven by the caller: repeat `sweep!(env, alg)`.


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:267](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L267)


	sweep!(env::HadamardTDVPCache, alg::HadamardTDVP2)

One full two-site Hadamard time step of size `alg.stepsize` (`leftsweep!` + `rightsweep!`),
adapting the bond dimensions under `alg.trunc`.


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:369](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L369)


	sweep!(env, alg::TDVP1)

One full TDVP1 time step of size `alg.stepsize` (`leftsweep!` + `rightsweep!`).
Time evolution loops are driven by the caller: repeat `sweep!(env, alg)`.


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:387](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L387)


	sweep!(env, alg::TDVP2)

One full TDVP2 time step of size `alg.stepsize` (`leftsweep!` + `rightsweep!`).


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:549](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L549)



<a id="api-SVDCompression"></a>

## `SVDCompression`


	SVDCompression(; trunc=truncdimcutoff(D=Defaults.D, ϵ=Defaults.tol, add_back=0), verbosity=0)

Parameters of the SVD-sweep (one-pass) compression route: the exact product is formed first
and then compressed by an SVD right-orthogonalization sweep under the scheme `trunc`.


源码：[src/mpsalgorithms/algorithms/algdefs.jl:22](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L22)



<a id="api-DMRG1"></a>

## `DMRG1`


	DMRG1(; maxiter=Defaults.maxiter, tol=Defaults.tol, D=Defaults.D,
	      alg_eigsolve=Defaults.alg_eigsolve(), alg_orth=Defaults.alg_orth(), verbosity=0)

Parameters of the single-site variational (ALS) sweep engine: pure iteration parameters
(maximal sweeps, convergence tolerance, verbosity) and the bond
dimension `D` of the working guess: the out-of-place entry points draw their initial
guess with bond cap `alg.D` (`svdguess_add`, `svdguess_mult`, `svdguess_hadamard`,
`svdguess_compress`, `randommps` / `randommpo`), and the in-place variants re-fit a
caller-provided guess to `alg.D` bonds with `changebond!`. `DMRG1` itself does not
truncate.

The local problems are configured by the two solver fields: `alg_eigsolve` (a
`KrylovKit` algorithm object, see `Defaults.alg_eigsolve`) drives the local
effective-Hamiltonian `eigsolve`, and `alg_orth` (a tensor factorization such as
`QRpos()`, see `Defaults.alg_orth`) the QR/LQ gauge moves — the right-to-left
moves use the adjoint `alg_orth'`.


源码：[src/mpsalgorithms/algorithms/algdefs.jl:33](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L33)



<a id="api-DMRG2"></a>

## `DMRG2`


	DMRG2(; maxiter=Defaults.maxiter, tol=Defaults.tol, trunc=Defaults.alg_trunc(),
	      alg_eigsolve=Defaults.alg_eigsolve(), alg_orth=Defaults.alg_orth(), verbosity=0)

Parameters of the two-site variational sweep engine: the neighboring site pair is
optimized jointly and re-split by an SVD under `trunc::TruncationScheme`, so the bond
dimension adapts during the sweeps (growth where the environment demands it, truncation
where the scheme caps it). All engines accepting a `DMRG1` (`mult`, `add`, `compress`,
`hadamard`, `linsolve`, `ground_state`) accept a `DMRG2` as well; the dedicated
two-site `linsolve` configuration is `ALSLinSolve2`. `alg.trunc` is also
consulted for the bond cap of automatically drawn initial guesses
(`_truncation_bond`).

`alg_eigsolve` (a `KrylovKit` algorithm object, see `Defaults.alg_eigsolve`)
drives the local effective-Hamiltonian `eigsolve`. `alg_orth`
(`Defaults.alg_orth`) is accepted for interface uniformity with `DMRG1`; the
two-site re-splits are truncating SVDs under `alg.trunc` (factorization `SDD`) and
carry the gauge themselves, so no QR/LQ moves consume it.


源码：[src/mpsalgorithms/algorithms/algdefs.jl:60](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L60)



<a id="api-TDVP1"></a>

## `TDVP1`


	TDVP1(; stepsize, D=Defaults.D, ishermitian=true, verbosity=Defaults.verbosity)

Configuration of single-site TDVP. `stepsize` is the complex time increment itself: one
`sweep!` applies `exp(stepsize·H)` (as two half-steps of `exp(stepsize/2·H)`), so

- real-time evolution by `τ`: `stepsize = -im*τ`, i.e. `exp(-i·τ·H)`;
- imaginary-time evolution (cooling) by `τ`: `stepsize = -τ`, i.e. `exp(-τ·H)`.

`ishermitian` selects the default local exponential solver (Lanczos for hermitian,
Arnoldi otherwise); a fully configured `KrylovKit` algorithm object can be passed as
`alg_expsolve` (see `Defaults.alg_expsolve`), which then takes precedence. The
QR/LQ gauge moves of the sweeps take the tensor factorization `alg_orth`
(`Defaults.alg_orth`; the right-to-left moves use the adjoint).

#### Accuracy, and initial states of too low rank

The sweep is not invariant under a bond-gauge transformation of the state: it integrates
the same projected flow only while the guess carries a canonically determined gauge. If
the initial state is *rank deficient* on some bond — a product state whose bond profile
was grown with `changebond!(...; noise=0)`, which pads the new bond directions with exact
zeros, is the typical case — the canonicalization does not single out a gauge (the
completion of the null directions of the factorization is arbitrary) and the trajectory
becomes representation dependent: rotating one bond of the (bitwise unchanged) state can
shift a single sweep by `~1e-7`, and two equivalent representations of the same guess (the
density-operator and the vectorized routes) can drift apart by `~1e-2` in the represented
density operator. A full-rank guess has a unique gauge and the results agree to roundoff.
Padding with a small `noise` (the `changebond!` default of `1e-10`) removes the
degeneracy and restores gauge independence; recipes that must resize exactly (e.g.
thermal-state preparation, where noise would be amplified by the cooling flow) should be
aware of this limitation.

The guess must also be canonical at all (`iscanonical`), since the environments are those
of an isometric chain; `vectorize(infinite_temperature_state(...))` is not (its site
tensors are the plain identities) and needs a `rightorth!` (SVD, `NoTruncation`) first.


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:26](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L26)



<a id="api-TDVP2"></a>

## `TDVP2`


	TDVP2(; stepsize, trunc=Defaults.alg_trunc(), ishermitian=true, verbosity=Defaults.verbosity)

Configuration of two-site TDVP. `stepsize` carries the same convention as
`TDVP1` — the complex time increment itself, `-τ` for cooling by `τ` and `-im*τ`
for real time — and one `sweep!` advances the state by it. The local exponentials are
configured by `alg_expsolve` (a `KrylovKit` algorithm object,
`Defaults.alg_expsolve`; `ishermitian` only selects its default) and the
re-split is a truncating SVD under `trunc::TruncationScheme`.

Where `TDVP1` freezes the bond dimensions of the guess, `TDVP2` adapts them: the site pair
is evolved jointly against the two-site effective generator and re-split by a *truncating*
SVD under `trunc::TruncationScheme`, so a low-rank guess (a product state, or the
infinite-temperature state of `infinite_temperature_state`) grows its bonds as the
entanglement builds up, up to the cap `trunc` carries (`_truncation_bond`), and is trimmed
where the spectrum allows. The bond profile needs no preparation: no `changebond!` call is
required on the initial state.

The sweeps follow MPSKit's `TDVP2`: pair step `exp(+dt/2·H_pair)`, splitting SVD with the
singular values absorbed into the sweep direction (which is what moves the orthogonality
center), then — except at the far edge of each sweep — a single-site backward half-step
`exp(-dt/2·H_site)` on the new center. The state and generator conventions are those of the
cache (see `TDVPCache`): with a `CanonicalMPS` state this is ordinary two-site MPS
TDVP, with a `CanonicalMPO` state the density-operator left action

    ρ ↦ exp(stepsize·H)·ρ.

The local generators are evaluated against the environments of the *current* state — the
sweeps refresh them as the orthogonality center moves, which is also what MPSKit's lazily
recalculated environments amount to. They cannot be held fixed for the whole step: a pair
update may change the bond dimension, and the single-site backward step then needs the
environment of the *new* bond.

#### The guess

The guess must be in canonical form (`iscanonical`), as for every algorithm driven by
`DMRGCache`/`TDVPCache`: the environments and the local generators are those of an
isometric chain, and only in that gauge do the pair and the backward single-site
projectors compose into the tangent-space flow. `vectorize(infinite_temperature_state(...))`
represents the identity exactly, but its site tensors are the plain identities and are
therefore *not* isometric — regauge it with `rightorth!` (SVD, `NoTruncation`), which
resizes nothing. The bond profile itself needs no preparation: unlike
`changebond!`-padded recipes, a bond-dimension-1 guess is grown by the pair updates
themselves, up to the cap `trunc` carries.

#### Accuracy

Where the manifold is complete — a guess whose bonds already fill the profile the
truncation allows — the pair and backward projectors are all the identity and one sweep
reproduces `exp(stepsize·H)` to roundoff. While the bonds are still growing the sweep runs
on a restricted manifold and leaves a remainder linear in `stepsize`: on the
next-nearest-neighbour test model at L = 4 a β = 1 cooling comes out at 2.3e-3, 1.1e-3 and
5.7e-4 (density-matrix error) for 20, 40 and 80 sweeps, the same numbers MPSKit's `TDVP2`
produces. Once the profile has grown, only the truncation under `trunc` remains.


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:71](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L71)



<a id="api-HadamardTDVP"></a>

## `HadamardTDVP`


	HadamardTDVP(; stepsize, ishermitian=false, alg_expsolve=Defaults.alg_expsolve(ishermitian),
	             alg_orth=Defaults.alg_orth(), verbosity=Defaults.verbosity)

Configuration of the Hadamard-product TDVP flow `dz/dτ = H ∘ z` between two MPS chains:
the generator `H` and the state `z` are both `CanonicalMPS`, and their product is
the pointwise (Hadamard) one. `stepsize` is the complex time increment itself — one
`sweep!` applies the elementwise `exp(stepsize·H)`, so

- the cooling `z ↦ e^{-τ·H}.*z`: `stepsize = -τ`;
- the real-time flow `z ↦ e^{-i·τ·H}.*z`: `stepsize = -im*τ`.

`ishermitian` selects the default Krylov exponentiate driver (Lanczos for hermitian,
Arnoldi otherwise) of the local projected generator; a fully configured `KrylovKit`
algorithm object can be passed as `alg_expsolve`
(`Defaults.alg_expsolve`), which then takes precedence. The QR/LQ gauge moves of
the sweeps take the tensor factorization `alg_orth` (`Defaults.alg_orth`). Only
the bra side of the environments is
conjugated, so that generator is *not* hermitian in general — hence the `false` default,
as in TEMPO's `tdvpif` — and `true` is only safe for chains where the local maps are known
to be hermitian.

Drive it exactly like the MPO TDVP: build the cache once and repeat `sweep!(env, alg)`.

#### Accuracy

On a manifold that can hold the pointwise product `H ∘ z` — in particular the full space
of a short chain, or a product state zero-padded to the profile the flow needs
(`changebond!(ψ; D=D, noise=0)`, which also canonicalizes the padded directions) — one
sweep reproduces the elementwise `exp(stepsize·H).*z` to roundoff, so several sweeps
accumulate the exact flow. On a restricted manifold the sweep realizes the projected flow
instead, which leaves a remainder linear in `stepsize` (halving `stepsize` halves it).


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:37](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L37)



<a id="api-HadamardTDVP2"></a>

## `HadamardTDVP2`


	HadamardTDVP2(; stepsize, trunc=Defaults.alg_trunc(), ishermitian=false,
	              alg_expsolve=Defaults.alg_expsolve(ishermitian), alg_orth=Defaults.alg_orth(),
	              verbosity=Defaults.verbosity)

Configuration of the two-site Hadamard flow `dz/dτ = H ∘ z`. `stepsize` carries the same
convention as `HadamardTDVP` — the complex time increment itself, so one `sweep!`
applies the elementwise `exp(stepsize·H)` — and `trunc::TruncationScheme` caps the bond
dimensions of the pair SVD.

Where `HadamardTDVP` freezes the bond profile of the guess, `HadamardTDVP2` grows
it: the site pair is evolved against the two-site projected pointwise generator and
re-split with truncation, so a bond-dimension-1 guess reaches the profile the pointwise
product needs without any `changebond!` preparation, up to the cap carried by `trunc`. Use
it whenever the profile is unknown (the `tdvpif` preparation with `changebond!(ψ; D=D)` is
the single-site alternative), and `HadamardTDVP` when the profile is known and a cheaper
sweep is wanted.

The two conventions of the single-site variant hold unchanged: only the bra side of the
environments is conjugated, so the projected generator is generally not hermitian (Arnoldi
by default), and the generator's `scaling` is folded into the local generators as the
factor `scaling(H)^L`. The sweeps are documented with their implementations below.


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:78](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L78)



<a id="api-IterativeMPSAlgorithm"></a>

## `IterativeMPSAlgorithm`

```julia
abstract type IterativeMPSAlgorithm <: MPSAlgorithm end
```

反复扫描算法的抽象配置基类，不能直接实例化；具体类型实现单站点或双站点更新。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type IterativeMPSAlgorithm <: MPSAlgorithm end
```



<a id="api-ALSConvergenceInfo"></a>

## `ALSConvergenceInfo`


	ALSConvergenceInfo(niter, converged, losses, itererr, residual)
	ALSConvergenceInfo(losses, converged; residual=nothing)

Convergence report appended as the last return value of every `IterativeMPSAlgorithm`
entry point:

* `niter`: number of sweeps performed;
* `converged`: whether `iterative_compute!` reached `alg.tol`;
* `losses`: the per-sweep loss history (what `iterative_compute!` used to return);
* `itererr`: the final relative loss difference (the convergence measure);
* `residual`: the problem's residual when it is exactly the loss (set by `linsolve`,
  `seq2seq` and `reconstruct`, whose loss *is* the residual), `nothing` for the other
  drivers (there the loss is the residual up to an unknown constant or not directly
  the residual at all).


源码：[src/mpsalgorithms/algorithms/algdefs.jl:134](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L134)



<a id="api-SingleSiteUpdate"></a>

## `SingleSiteUpdate`


	SingleSiteUpdate

Abstract base of the single-site (ALS) sweep engines: `DMRG1`, `ALSLinSolve`,
`ALSRecon` and `Seq2Seq`.


源码：[src/mpsalgorithms/algorithms/algdefs.jl:6](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L6)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type SingleSiteUpdate <: IterativeMPSAlgorithm end
```



<a id="api-TwoSiteUpdate"></a>

## `TwoSiteUpdate`


	TwoSiteUpdate

Abstract base of the two-site sweep engines: `DMRG2` (the concrete `ALSLinSolve2`),
`CADMRG` and `PDMRG`.


源码：[src/mpsalgorithms/algorithms/algdefs.jl:14](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L14)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type TwoSiteUpdate <: IterativeMPSAlgorithm end
```



<a id="api-ALSLinSolve2"></a>

## `ALSLinSolve2`


	ALSLinSolve2(; maxiter=Defaults.maxiter, tol=Defaults.tol, trunc=Defaults.alg_trunc(),
	             alg_linsolve=Defaults.alg_linsolve(), verbosity=0)

Algorithm configuration of the two-site iterative `linsolve`: two-site ALS sweeps over
the normal-equation stacks with the bond profile `alg.trunc`; the local normal equations
are solved by the KrylovKit iterative solver `alg.alg_linsolve` (matrix-free, the current
site-pair tensor as warm start).


源码：[src/mpsalgorithms/algorithms/algdefs.jl:106](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L106)



<a id="api-Seq2Seq"></a>

## `Seq2Seq`


	Seq2Seq(; maxiter=Defaults.maxiter, tol=Defaults.tol, D=Defaults.D, α=1.0e-4,
	        nadd=8, nbuffer=1024, verbosity=0)

Algorithm configuration of the `seq2seq` MPO fit: single-site ALS sweeps with the
bond profile `alg.D` and the Hilbert-Schmidt ridge `α·‖W‖²_HS` added to the local
normal equations for conditioning (the seq2seq regularization; not part of the
reported loss). The local normal equations are solved densely (a direct `\` on the
explicit local Hessian). `nadd`/`nbuffer` drive the adaptive data-enrichment loop of the
oracle-based entry point `seq2seq(pairfun, dxs, dys, alg)` (unused by the
fixed-dataset entry points).


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:16](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L16)



<a id="api-ALSLinSolve"></a>

## `ALSLinSolve`


	ALSLinSolve(; maxiter=Defaults.maxiter, tol=Defaults.tol, D=Defaults.D,
	            alg_linsolve=Defaults.alg_linsolve(), verbosity=0)

Algorithm configuration of the iterative `linsolve`: single-site ALS sweeps over the
normal-equation stacks with the bond profile `alg.D`; the local normal equations are
solved by the KrylovKit iterative solver `alg.alg_linsolve` (matrix-free, the current
site tensor as warm start).


源码：[src/mpsalgorithms/algorithms/algdefs.jl:89](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L89)



<a id="api-ac-prime"></a>

## `ac_prime`


	ac_prime(x, W, hleft, hright)

Single-site effective Hamiltonian action: `y = hleft · x · W · hright`, where `hleft/hright`
are the (bra, MPO, ket) environments at both sides of the site. The ket (MPS) bonds —
the large dimensions — are contracted first, against the small physical legs and MPO
bonds of `W`; the MPO bonds are folded in afterwards through the environments.


源码：[src/mpsalgorithms/algorithms/derivatives.jl:3](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/derivatives.jl#L3)



<a id="api-c-prime"></a>

## `c_prime`


	c_prime(x, hleft, hright)

Bond-space effective Hamiltonian action (the second TDVP1 projector):
`y[a, c] = Σ hleft[a, w, b] x[b, e] hright[c, w, e]`.


源码：[src/mpsalgorithms/algorithms/derivatives.jl:59](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/derivatives.jl#L59)



<a id="api-Heff"></a>

## `Heff`


	Heff(W, hleft, hright) -> CentralHeff

Bundle the MPO site tensor with its environments (no contraction, no conversion): the
site tensor keeps its own form (dense or Schur), and the repeated `eigsolve` actions
dispatch on it.


源码：[src/mpsalgorithms/algorithms/derivatives.jl:90](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/derivatives.jl#L90)



<a id="api-FirstOrderStepper"></a>

## `FirstOrderStepper`

```julia
abstract type FirstOrderStepper <: MPSAlgorithm end
```

一阶时间步进器的抽象基类，不能实例化；具体类型为 `WI` 与 `WII`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type FirstOrderStepper <: MPSAlgorithm end
```



<a id="api-SecondOrderStepper"></a>

## `SecondOrderStepper`

```julia
abstract type SecondOrderStepper <: MPSAlgorithm end
```

二阶时间步进器的抽象基类，不能实例化；具体配置使用 `ComplexStepper`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type SecondOrderStepper <: MPSAlgorithm end
```



<a id="api-GeneralStepper"></a>

## `GeneralStepper`

```julia
abstract type GeneralStepper <: MPSAlgorithm end
```

通用时间步进器的抽象基类，不能实例化；例如 `TaylorCluster`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type GeneralStepper <: MPSAlgorithm end
```



<a id="api-iterative-compute-mutating"></a>

## `iterative_compute!`


	iterative_compute!(cache, alg; residual=false, kwargs...) -> info::ALSConvergenceInfo

Repeat `sweep!(cache, alg)` until the relative difference of the LAST loss of two
successive sweeps satisfies `|lₙ - lₙ₋₁| / |lₙ₋₁| < alg.tol` (or `alg.maxiter` is
reached). The per-site losses of a sweep are monotone in processing time, so the last
value of a sweep is the best (most recently updated) loss and is comparable across
sweeps. Returns `info`, the `ALSConvergenceInfo` carrying the per-sweep loss
history and the convergence report; with `residual = true` the `residual` field is set
to the final loss (for the drivers whose loss *is* the problem's residual — `linsolve`,
`seq2seq`, `reconstruct`). Remaining `kwargs` are forwarded to `sweep!`.

The sweeps keep the working data in mixed canonical form but never touch the Schmidt
values; the cache constructors therefore reset them (`unset_svectors!`) on the working
guess, so no stale spectrum can masquerade as a canonical gauge.

Logging follows the package-wide `verbosity` convention (header of
`MOSSMPS.MPSAlgorithms`): level ≥ 2 summarizes the final (best) loss of every sweep
(`_logiter`); level ≥ 3 additionally prints the loss of every local update from within
the sweeps, tagged with the half-sweep direction (`_logupdate`).


源码：[src/mpsalgorithms/algorithms/algdefs.jl:164](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/algdefs.jl#L164)



<a id="api-AddCache"></a>

## `AddCache`


	AddCache(bra, kets)

Build the `AddCache` of the iterative `add`: every per-input overlap environment
(`OverlapCache`) is constructed and initialized here.


源码：[src/mpsalgorithms/algorithms/arithmetics/add.jl:38](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/add.jl#L38)



<a id="api-MultCache"></a>

## `MultCache`


MultCache: the ALS "problem" carrier of `mult` — find the bra chain `bra` maximizing
`|⟨bra| H |ket⟩|` (single-site alternating sweeps).


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:74](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L74)


	MultCache(bra, h, x)

Build the `MultCache` of the iterative `mult`: allocate the environment stack and
precompute the right environments from the chains as supplied — no regularization is
performed on any chain, and `alg.D` is ignored. Callers provide a right-canonical `bra`
(the `mult!` driver never re-gauges or truncates it).


源码：[src/mpsalgorithms/algorithms/arithmetics/mult.jl:336](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/mult.jl#L336)



<a id="api-HadamardCache"></a>

## `HadamardCache`


HadamardCache: the ALS "problem" carrier of the iterative hadamard product — find the
chain `omps` maximizing `|⟨omps| ψA ⊙ ψB⟩|` by single-site alternating sweeps.


源码：[src/mpsalgorithms/algorithms/arithmetics/hadamard.jl:84](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/hadamard.jl#L84)


	HadamardCache(bra, ketx, kety)

Build the `HadamardCache` of the iterative hadamard product: allocate the environment
stack and precompute the right environments from the chains as supplied — no
regularization is performed on any chain, and `alg.D` is ignored. Callers provide a
right-canonical `bra` (the `hadamard!` driver never re-gauges or truncates it).


源码：[src/mpsalgorithms/algorithms/arithmetics/hadamard.jl:277](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/hadamard.jl#L277)



<a id="api-LinsolveCache"></a>

## `LinsolveCache`


LinsolveCache: ALS problem carrier for `linsolve` — find x minimizing ||A·x − y||²
with single-site sweeps over the two (A†A and A†) environment stacks. `ynorm2` is the
raw-data ‖y‖², the constant of the global objective.


源码：[src/mpsalgorithms/algorithms/arithmetics/linsolve.jl:81](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/linsolve.jl#L81)


	LinsolveCache(x, A, y)

Build the `LinsolveCache` of the iterative `linsolve`: allocate the h/b environment
stacks and initialize them by a data-level right-orthogonalization of `x`.


源码：[src/mpsalgorithms/algorithms/arithmetics/linsolve.jl:198](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/linsolve.jl#L198)



<a id="api-Seq2SeqCache"></a>

## `Seq2SeqCache`


Seq2SeqCache: ALS problem carrier for `seq2seq` — fit W minimizing
Σ_n ||W·x_n − y_n||² (+ alpha·||W||²_HS ridge on the local solves) with single-site
sweeps over the three (quadratic / linear / ridge) environment stacks.


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:78](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L78)


	Seq2SeqCache(H, kets, bras)

Build the `Seq2SeqCache` of the seq2seq fit: allocate the per-sample h/b environment
stacks, the ridge stack and the target norm, and initialize everything. The ridge
strength α enters at solve time from the `Seq2Seq` algorithm.


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:339](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L339)



<a id="api-TDVPCache"></a>

## `TDVPCache`


	TDVPCache{M<:AbstractMPO, V<:Union{CanonicalMPO,CanonicalMPS}, T}

Environment stack for single-site TDVP1 under the **left** action of the generator MPO
`H`: `state` is the evolved canonical chain, `estorage` the stack of `(bra bond, H bond,
ket bond)` environments at all bonds (`estorage[1]` the left boundary, `estorage[L+1]`
the right boundary, the right environments precomputed). There is only one stack — the
generator acts from the left only — and it has the same shape as the `hstorage` of a
`DMRGCache`. The type of `state` selects the manifold and the flow:

#### Usage

`alg.stepsize` is the complex time increment itself, so one `sweep!` applies
`exp(stepsize·H)`: `stepsize = -τ` cools by `τ` (`exp(-τ·H)`), `stepsize = -im*τ` evolves
real time by `τ` (`exp(-i·τ·H)`).

- `state::CanonicalMPS` (plain `MPO`/`MPOHamiltonian` generator, matching physical
  dimensions) — the ordinary MPS TDVP1, for real and imaginary time alike. Environment
  stack and sweeps coincide with those of a `DMRGCache` holding the same `H` and the same
  state; `TDVPCache` merely adds the density-operator manifold below.

- `state::CanonicalMPO` (generator with matching operator dimensions) — the state evolves
  by the *left action* of the generator, i.e. one `sweep!` implements

      ρ ↦ exp(stepsize·H)·ρ,       so dρ/dτ = -H·ρ   for `stepsize = -τ`.

  This imaginary-time step is the meaningful use: it is a cooling route to the Gibbs
  state. From the infinite-temperature state `ρ₀ ∝ identity`
  (`infinite_temperature_state`), `n` steps of size `τ` give
  `exp(-n·τ·H) ∝ ρ(β_eff = n·τ)` — the same `β_eff` as the symmetric two-sided cooling
  `exp(-τ/2·H)·ρ₀·exp(-τ/2·H)` at half the cost per site update.

- Real-time evolution of a density operator is **not** the left multiplication
  `exp(-i·t·H)·ρ` (which is what a complex `stepsize = -im*τ` would produce, i.e.
  `dρ/dt = -i·H·ρ`) but the two-sided `exp(-i·t·H)·ρ·exp(+i·t·H)`, which this cache does not
  implement — it stores the left-action environment only. Vectorize the density operator
  and drive it with a `DMRGCache` on the superoperator (the same manifold as an MPS chain
  of physical dimension `d²`):

  ```julia
  # unitary / Liouville flow  dρ/dt = -i[H, ρ]
  env = DMRGCache(vectorize(ρ), superoperator(H, :left) - superoperator(H, :right))
  sweep!(env, TDVP1(stepsize=-im * τ))

  # symmetric two-sided cooling (imaginary time)
  env = DMRGCache(vectorize(ρ), (superoperator(H, :left) + superoperator(H, :right)) / 2)
  sweep!(env, TDVP1(stepsize=-τ))
  ```


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:137](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L137)


	TDVPCache(state, h::AbstractMPO) -> TDVPCache

Build the environment stack of the right-canonical guess `state` for the left action of
`h`; the type of `state` selects the manifold (see `TDVPCache`). The constructor
resets the Schmidt values of the guess, so "initialized" always implies "properly
canonical". For a `CanonicalMPS` state, `h` is the MPO acting on the state directly (for
a vectorized density-operator flow, the superoperator of `superoperator`); for a
`CanonicalMPO` state it is the operator multiplying the density operator from the left.


源码：[src/mpsalgorithms/algorithms/timeevo/tdvp.jl:226](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tdvp.jl#L226)



<a id="api-HadamardTDVPCache"></a>

## `HadamardTDVPCache`


	HadamardTDVPCache(ψ::CanonicalMPS, H::CanonicalMPS)

Environment stack of the Hadamard-product flow `dz/dτ = H ∘ z`: `state` (`ψ`) is the
evolved chain, `H` the diagonal generator, both MPS on the same lattice, and `hstorage`
the stack of the three-chain environments ⟨state| H |state⟩ at all bonds
(`hstorage[1]`/`hstorage[L+1]` the boundaries, the right environments precomputed). Each
environment carries legs `(bra bond, H bond, ket bond)`, exactly like the MPO environment
stack of a `TDVPCache` — the bra chain is the conjugated state, so the stack is
built from the state twice.

The state must be canonical (`iscanonical`) and must carry its bond profile already: the
sweeps are single-site and resize nothing, so padding the guess with
`changebond!(ψ; D=D, noise=0)` (which also right-canonicalizes with SVD/`NoTruncation`) is
the way to give the flow room to grow, as in TEMPO's `tdvpif`. The generator may be in any
gauge, and both chains may carry a non-unit `scaling` (the `scaling^L·∏tensors`
convention): the environments contract the site tensors, so the generator's `scaling` is
turned into the equivalent factor `scaling(H)^L` on the local generators (what
`tdvpif`'s `_absorb_scaling!(H)` achieves by absorbing it into the tensors), while the
state's `scaling` is bookkeeping only and flows through untouched.


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:110](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L110)


	HadamardTDVPCache(ψ::CanonicalMPS, H::CanonicalMPS) -> HadamardTDVPCache

Build the three-chain environment stack of the guess `ψ` for the Hadamard flow generated
by `H` (see `HadamardTDVPCache`); the Schmidt values of the guess are reset.


源码：[src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl:137](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/hadamardtdvp.jl#L137)



<a id="api-WI"></a>

## `WI`


	WI(; tol=Defaults.tol, maxiter=Defaults.maxiter)

First-order W-type (WI) time evolution: the evolved MPO tensor is
`W = [[I + dt·D, δ₂·C], [δ₁·B, A]]` with `δ₁δ₂ = dt`.


源码：[src/mpsalgorithms/algorithms/timeevo/w1w2.jl:9](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/w1w2.jl#L9)



<a id="api-WII"></a>

## `WII`


	WII(; tol=Defaults.tol, maxiter=Defaults.maxiter)

First-order W-type (WII) time evolution: each site tensor contains block submatrices
of the block-matrix exponential, giving higher accuracy per step than `WI`.


源码：[src/mpsalgorithms/algorithms/timeevo/w1w2.jl:20](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/w1w2.jl#L20)



<a id="api-ComplexStepper"></a>

## `ComplexStepper`


	ComplexStepper(stepper::FirstOrderStepper)

Combine a first-order stepper into a second-order stepper: two steps with
`dt₁ = (1-im)·dt/2` and `dt₂ = (1+im)·dt/2` (real time) compose to second order.


源码：[src/mpsalgorithms/algorithms/timeevo/w1w2.jl:31](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/w1w2.jl#L31)



<a id="api-complex-stepper"></a>

## `complex_stepper`


	complex_stepper(dt) -> (dt₁, dt₂)

The two half steps of `ComplexStepper`: `U₁ = exp(H·dt₁)`, `U₂ = exp(H·dt₂)`,
`U₁U₂` is a second-order stepper.


源码：[src/mpsalgorithms/algorithms/timeevo/w1w2.jl:41](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/w1w2.jl#L41)



<a id="api-TaylorCluster"></a>

## `TaylorCluster`


	TaylorCluster(; N=2, extension=true, compression=false)

Algorithm constructing the `N`-th order time-evolution MPO using the Taylor cluster
expansion (`timeevompo` builds the MPO, which is then applied like the
`WI`/`WII` steppers). The virtual channels of the evolved MPO are the
Tucker-symmetrized `N`-fold products of the Hamiltonian channels, fused back into the
Schur form by the cluster loop-back.

#### Fields

- `N::Int`: order of the Taylor expansion;
- `extension::Bool`: incorporate the higher-order corrections from `H^(N+1)`
  (Algorithm 3 of the reference);
- `compression::Bool`: approximate compression of the corrections, accurate up to
  order `N` (Algorithm 4 of the reference).

#### References

- Van Damme et al., SciPost Phys. 17, 135 (2024).


源码：[src/mpsalgorithms/algorithms/timeevo/taylorcluster.jl:5](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/taylorcluster.jl#L5)



<a id="api-timeevompo"></a>

## `timeevompo`


	timeevompo(m::SchurMPOTensor, dt, alg::TaylorCluster)
	timeevompo(h::MPOHamiltonian, dt, alg::TaylorCluster)

Evolve a Schur-form Hamiltonian by one step `dt` with the `TaylorCluster`
algorithm: the `N`-th order time-evolution MPO of the Taylor cluster expansion is built
on the `N`-fold fused channel space and fused back into the Schur form. The
`SchurMPOTensor` method returns the site-tensor block dictionary; the Hamiltonian
method assembles the dense finite-chain `MPO` (vacuum row of the first site,
closing column of the last).


源码：[src/mpsalgorithms/algorithms/timeevo/taylorcluster.jl:262](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/taylorcluster.jl#L262)


	timeevompo(m::SchurMPOTensor, dt, alg)
	timeevompo(h::MPOHamiltonian, dt, alg=WII())

Evolve a Schur-form Hamiltonian by one step `dt` with the stepping algorithm `alg`
(`WI`, `WII`, or `ComplexStepper`). The single-tensor methods
return the evolved full-logical-shape 4-index tensor; the Hamiltonian method assembles
them into the dense finite-chain `MPO` (the vacuum row of the first site and the
closing column of the last site; the channel-1 diagonal carries the on-site evolution).
`ComplexStepper` returns the pair of half-step results.


源码：[src/mpsalgorithms/algorithms/timeevo/w1w2.jl:71](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/w1w2.jl#L71)



<a id="api-timeevo"></a>

## `timeevo`


	timeevo(ψ::CanonicalMPS, h::MPOHamiltonian, dt, alg::GeneralStepper;
		trunc=Defaults.alg_trunc()) -> ψ'

`GeneralStepper` application path (the `TaylorCluster` stepper): the
evolved MPO is applied with `mult` under the truncation `trunc`, exactly like the
first-order steppers; `timeevo!` handles it through its `MPSAlgorithm` fallback.


源码：[src/mpsalgorithms/algorithms/timeevo/taylorcluster.jl:332](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/taylorcluster.jl#L332)


	timeevo(ψ::CanonicalMPS, h::MPOHamiltonian, dt, alg::FirstOrderStepper;
			trunc=Defaults.alg_trunc()) -> ψ'
	timeevo(ψ, h, dt, alg::ComplexStepper; trunc) -> ψ'

Non-mutating variant of `timeevo!`: one W-matrix time step — build the evolved
MPO with `timeevompo` and apply it to `ψ` with the truncation `trunc` (via
`mult`) — returned as a new `CanonicalMPS`, leaving `ψ` untouched. The
`ComplexStepper` composes the two half steps for second-order accuracy.


源码：[src/mpsalgorithms/algorithms/timeevo/w1w2.jl:171](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/w1w2.jl#L171)



<a id="api-timeevo-mutating"></a>

## `timeevo!`


	timeevo!(ψ::CanonicalMPS, h::MPOHamiltonian, dt, alg=WII(); trunc=Defaults.alg_trunc())
	timeevo!(ψ, h, dt, ComplexStepper(); trunc)

In-place one W-matrix time step: `copy!`s the result of the non-mutating `timeevo`
into `ψ` (see there for the algorithm; `ComplexStepper` composes the two half steps for
second-order accuracy).


源码：[src/mpsalgorithms/algorithms/timeevo/w1w2.jl:192](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/w1w2.jl#L192)



<a id="api-linsolve"></a>

## `linsolve`


	linsolve(A, y, alg=ALSLinSolve()) -> (x, info)

Solve `A·x ≈ y` variationally: find a finite-bond MPS `x` of bond dimension `alg.D`
minimizing the residual norm `||A·x - y||` by single-site ALS sweeps (normal equation
A†A x = A† y). The initial guess is a random state. Block-sparse (Hamiltonian) inputs
are expanded to the dense MPO layer. Returns `(x, info)` with `info`, the
`ALSConvergenceInfo` of the sweeps (`info.residual` = final loss = ‖A·x − y‖²).


源码：[src/mpsalgorithms/algorithms/arithmetics/linsolve.jl:247](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/arithmetics/linsolve.jl#L247)



<a id="api-seq2seq"></a>

## `seq2seq`


	seq2seq(xs, ys, alg::Seq2Seq = Seq2Seq()) -> (W, info)

Fit an MPO `W` to a dataset of MPS pairs `(xs[n], ys[n])` by DMRG (single-site ALS)
sweeps, following guochu/MPSLearning.jl: minimize `Σ_n ||W·x_n − y_n||²`, with a
Hilbert-Schmidt ridge `α·||W||²` (`alg.α`) added to the local solves for conditioning
(the default `α = 0.01` follows MPSLearning; the ridge is not part of the
reported loss). The input (output) physical dimensions of `W` match the dimensions
of `xs` (`ys`), so rectangular maps `dx → dy` are supported. The initial guess is a
random MPO of bond dimension `alg.D`; the data scalings are folded into the site tensors
at entry. `info` is the `ALSConvergenceInfo` of the sweeps: the per-sweep loss
history (`info.losses`) collects the exact global data objective after every site
update, grouped per sweep; each vector is in processing-time order (the left sweep sites
`1:L`, the right sweep sites `L:-1:1`), so the losses are non-increasing; convergence
follows the unified `iterative_compute!` criterion (relative difference of the last
loss of two successive sweeps below `alg.tol`). Since the loss *is* the (squared)
data residual here, `info.residual` holds the final loss.


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:360](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L360)


	seq2seq(pairfun::Function, dxs, dys, alg::Seq2Seq = Seq2Seq())
		-> (W, info::NamedTuple{(:loss, :maxerr, :npairs, :rounds)})

Adaptive seq2seq fit from a black-box pair oracle `pairfun(x) -> y`: alternate the
inner ALS fit on the current training set with residual-driven data enrichment —
the seq2seq analog of ALSRecon's sample enrichment. Each round evaluates the
relative prediction error `‖W·x′ − y′‖/‖y′‖` of the current `W` on a fresh pool of
`alg.nbuffer` random input states `x′`, queries the oracle for the targets of the
`alg.nadd` worst inputs and adds those pairs to the training set. Stops when the
maximal pool error drops below `alg.tol` or after `alg.maxiter` rounds. Candidate
inputs are random normalized MPS of bond 2 over `dxs`. Returns `(W, info)` with the
final training loss, the maximal pool error, the number of training pairs and the
number of enrichment rounds.


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:419](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L419)



<a id="api-seq2seq-mutating"></a>

## `seq2seq!`


	seq2seq!(W::AbstractMPO, xs, ys, alg::Seq2Seq = Seq2Seq()) -> (W, info)

In-place variant of `seq2seq`: fit the provided MPO `W` to the dataset
`(xs[n], ys[n])` (its site tensors are updated in place, so `W` doubles as the initial
guess). The data scalings are folded into the site tensors at entry. Returns
`(W, info)` with `info`, the `ALSConvergenceInfo` of `iterative_compute!`
(`info.residual` = final loss = the global data objective `Σ_n ||W·x_n − y_n||²`).


源码：[src/mpsalgorithms/algorithms/ml/seq2seq.jl:385](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/ml/seq2seq.jl#L385)



<a id="api-sample"></a>

## `sample`


    sample(rng::AbstractRNG, ψ::CanonicalMPS, N::Integer; atol=1e-12)
    sample(ψ::CanonicalMPS, N::Integer; atol=1e-12)

Draw Born samples with one-based local indices for arbitrary (also nonuniform)
physical dimensions. `ψ` may have any gauge and any finite nonzero normalization;
it is never canonicalized or modified. The method contracts normalized right norm
environments and rescales each sampled prefix. It does not use stored Schmidt
values, expand the state, or silently accept an all-zero conditional distribution.
The legacy overload uses `Random.default_rng()`.


源码：[src/mpsalgorithms/algorithms/sampling.jl:3](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/sampling.jl#L3)



<a id="api-amplitude"></a>

## `amplitude`


	amplitude(ψ::CanonicalMPS, 𝐱) -> Number

The amplitude `ψ(𝐱) = ⟨𝐱|ψ⟩` of the represented state at the configuration `𝐱`
(`𝐱[s] ∈ 1:ds[s]`, following the package's **1-based convention**; a `Vector{Int}` or
a tuple), including the per-site `scaling` factor (matching `todense`). The
scaling is applied **per site during the contraction** — no `scaling^L` power is ever
materialized, so the amplitude stays finite even for scalings whose `scaling(ψ)^L`
would overflow. The rows of the site tensors are contracted left to right.


源码：[src/mpsalgorithms/algorithms/sampling.jl:96](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/sampling.jl#L96)



<a id="api-sampling-right-environments"></a>

## `sampling_right_environments`


    sampling_right_environments(ψ)

Right norm environments `R[s][bra,ket]` for sites `s:L`, individually rescaled
by a positive scalar to avoid long-chain underflow. Their scalar normalizations
cancel in conditional probabilities. Does not modify `ψ`.


源码：[src/mpsalgorithms/algorithms/sampling.jl:72](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/sampling.jl#L72)



<a id="api-sector-ground-state"></a>

## `sector_ground_state`


    sector_ground_state(h, charges; target, rng, max_bond=64, cutoff=1e-12,
        sweeps=12, tolerance=1e-10, memory_budget=2^30, initial=nothing,
        method=:dmrg2, local_maxiter=200)

Strict two-component nonnegative integer charge-sector DMRG on arbitrary local
physical dimensions. `charges[s][p]` is the charge of physical root `p`.
Ordinary arrays store only values consistent with explicit cumulative bond
labels. Initialization, restricted local Krylov solves, and block SVD all
preserve the target exactly. `cutoff` is an absolute Schmidt-value threshold;
`max_bond` also caps the total retained rank across charges.

`initial=nothing` draws a reachable random charge MPS with the supplied RNG;
an earlier result (with fields `mps,bond_charges`) is accepted as a copied warm
start. Inputs are never changed. `:dmrg1` retains this initial bond/charge space
and can be trapped at a local minimum. `:dmrg2` grows it at each block SVD.
Convergence requires both sweep-energy stability and converged local solves;
it does not certify the global variational minimum. Diagnostics report whether
a variance was computed (currently false), plus budget and initialization.


源码：[src/mpsalgorithms/algorithms/groundstates/sector_dmrg.jl:260](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/sector_dmrg.jl#L260)



<a id="api-sector-leakage"></a>

## `sector_leakage`


    sector_leakage(ψ, bond_charges, charges; target)

Maximum magnitude of a tensor entry violating a cumulative bond-charge rule.
Together with the boundary charges `(0,0)` and `target`, zero leakage proves
that every represented configuration has the requested two-component charge.


源码：[src/mpsalgorithms/algorithms/groundstates/sector_dmrg.jl:242](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/sector_dmrg.jl#L242)



<a id="api-two-site-memory-estimate"></a>

## `two_site_memory_estimate`


    two_site_memory_estimate(x, heff)

Conservative bytes for the sequential two-site action, including dense site
copies for Schur tensors. This estimate has no `W_L*W_R*d1^2*d2^2` object.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg2.jl:23](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg2.jl#L23)



<a id="api-DMRGCache"></a>

## `DMRGCache`


	DMRGCache(ψ::CanonicalMPS, h::AbstractMPO) -> DMRGCache

Build the environment stack `⟨ψ|W|ψ⟩` for a right-canonical guess `ψ`: `hstorage[1]` is
the left boundary, `hstorage[L+1]` the right boundary, and the right environments of all
sites are precomputed (matching the left-to-right first sweep of DMRG1 / TDVP1). One
full sweep is `leftsweep!` (sites `1:L`, QR moves the orthogonality center right)
followed by `rightsweep!` (sites `L:1`) — this order must not be exchanged.


源码：[src/mpsalgorithms/algorithms/groundstates/dmrg.jl:12](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/dmrg.jl#L12)



<a id="api-ExcitedStateCache"></a>

## `ExcitedStateCache`


	ExcitedStateCache(ψ::CanonicalMPS, h::AbstractMPO, projectors::Vector{CanonicalMPS})

Environment cache for the excited-state search of `ψ`: one overlap cache per projector.


源码：[src/mpsalgorithms/algorithms/groundstates/excited.jl:14](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/groundstates/excited.jl#L14)



<a id="api-OverlapCache"></a>

## `OverlapCache`

```julia
OverlapCache(bra::CanonicalMPS, ket::CanonicalMPS)
OverlapCache(bra::AbstractMPO, ket::AbstractMPO)
```

构建重叠环境缓存供扫描算法使用；链长必须相同，`bra` 是被优化侧、`ket` 是固定输入。持有原始对象引用，并使正则 `bra` 的 Schmidt 信息失效，构造本身有变更。不要在缓存外修改其张量。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct OverlapCache{A, B, T}
function OverlapCache(ψA::CanonicalMPS, ψB::CanonicalMPS)
function OverlapCache(hA::AbstractMPO, hB::AbstractMPO)
```



<a id="api-PDMRG"></a>

## `PDMRG`


	PDMRG(; maxiter=Defaults.maxiter, tol=Defaults.tol, trunc=Defaults.alg_trunc(), R=20,
	      alg_eigsolve=Defaults.alg_eigsolve(), alg_orth=Defaults.alg_orth(), verbosity=0)

Parameters of the positive DMRG thermal-state search. `trunc` is the truncation scheme
applied to the center-movement SVDs (its bond cap bounds the MPS bond dimension of the
isometric part of the PMPA) and `R` the rank of the orthogonal center (the maximal
Schmidt number of the represented mixed state). `alg_eigsolve` (a `KrylovKit` algorithm
object, see `Defaults.alg_eigsolve`) drives the Krylov local thermalization —
its Krylov dimension is overridden with the problem-dependent `2·min(R, dim)`, every
other parameter is kept. `alg_orth` (`Defaults.alg_orth`) is accepted for
interface uniformity; the center-movement re-splits are truncating SVDs under
`alg.trunc` and carry the gauge themselves.


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:26](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L26)



<a id="api-CADMRG"></a>

## `CADMRG`


	CADMRG(; maxiter=Defaults.maxiter, tol=Defaults.tol, trunc=Defaults.alg_trunc(),
	      alg_eigsolve=Defaults.alg_eigsolve(), alg_orth=Defaults.alg_orth(), verbosity=0)

Parameters of the Clifford-augmented two-site DMRG ground-state search. `trunc` is the
truncation scheme applied to the SVD after each two-site update (its bond cap bounds
the bond dimension). `alg_eigsolve` (a `KrylovKit` algorithm object, see
`Defaults.alg_eigsolve`) drives the local effective-Hamiltonian `eigsolve`;
`alg_orth` (`Defaults.alg_orth`) is accepted for interface uniformity — the
re-splits are truncating SVDs under `alg.trunc` and carry the gauge themselves.


源码：[src/mpsalgorithms/algorithms/experimental/cadmrg.jl:15](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/cadmrg.jl#L15)



<a id="api-PositiveMPA"></a>

## `PositiveMPA`


	PositiveMPA{T}

Positive matrix product ansatz for a mixed quantum state. `data` stores the left-
canonical tensors `A_l` (sites `l < center`) and right-canonical tensors `B_l`
(sites `l > center`); `mcenter` is the rank-4 center tensor `M[aL, p, aR, τ]` with
`τ` the purification index of size `R`. The represented density operator is
`ρ = Σ_τ V·M[:,:,:,τ] ⊗ conj(M[:,:,:,τ])·V†` with `V` the isometry of `data`.
The mutable state (the center position and its tensor) lives in `Ref` fields, so the
ansatz itself is immutable: sweeps update `rho.center[]` / `rho.mcenter[]` in place.


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:52](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L52)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct PositiveMPA{T<:Number}
```



<a id="api-ThermalDMRGCache"></a>

## `ThermalDMRGCache`


	ThermalDMRGCache{H,V,T}

Environment stack for p-DMRG: `H` the MPO, `rho` the PMPA, `hstorage` the
`⟨A/B | H | A/B⟩` environments built from the isometric part of the PMPA.


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:107](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L107)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct ThermalDMRGCache{H<:AbstractMPO,V<:PositiveMPA,T}
function ThermalDMRGCache(rho::PositiveMPA, h::AbstractMPO)
```



<a id="api-randompmpa"></a>

## `randompmpa`


	randompmpa(T, ds; D, R) -> PositiveMPA

Random PMPA of physical dimensions `ds`, bond cap `D` and purification rank `R`, in
right-canonical form with center at site 1.


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:79](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L79)



<a id="api-thermalstate"></a>

## `thermalstate`


	thermalstate(h::AbstractMPO, β::Real, alg::PDMRG=PDMRG()) -> (F, rho, info)

Free energy `F = -log(Z)/β` and the PMPA equilibrium state of `h` at inverse temperature
`β`, starting from a random PMPA with the bond cap carried by `alg.trunc` and rank
`alg.R`; `info` is the `ALSConvergenceInfo` of the sweeps.


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:534](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L534)



<a id="api-thermalstate-mutating"></a>

## `thermalstate!`


	thermalstate!(rho::PositiveMPA, h::AbstractMPO, β::Real, alg::PDMRG=PDMRG()) -> (rho, info)

Variational search for the equilibrium state `ρ = exp(-β h) / Z` in the PMPA `rho`.
The canonical `data` tensors are updated in place; because the ansatz is immutable, the
updated PMPA is **returned** and should be reassigned:
`rho, info = thermalstate!(rho, h, β, alg)`.
The iteration loop is the generic `iterative_compute!` with `β` forwarded to the sweeps;
`info` is the returned `ALSConvergenceInfo`.


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:518](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L518)



<a id="api-freeenergy"></a>

## `freeenergy`


	freeenergy(h::AbstractMPO, rho::PositiveMPA, β::Real) -> Real

Full-chain free energy `F = tr(H ρ) - T S(ρ)` of the PMPA state `rho` at inverse
temperature `β` (`T = 1/β`), with the entropy from the center's local spectrum (the
spectrum of `ρ` equals that of its center block).


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:548](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L548)



<a id="api-tr"></a>

## `tr`


	tr(x::PositiveMPA) -> Real

Trace of the represented density operator (1 for a properly normalized state).


源码：[src/mpsalgorithms/algorithms/experimental/pdmrg.jl:93](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/pdmrg.jl#L93)


	tr(h::AbstractMPO)

The trace of the operator chain, including `scaling` of `CanonicalMPO` inputs
(applied per site during the contraction — no `scaling^L` power is materialized).


源码：[src/mpscore/operators/linalg.jl:71](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpscore/operators/linalg.jl#L71)



<a id="api-CAMPS"></a>

## `CAMPS`


	CAMPS

A CA-DMRG result: the canonical MPS `ket` produced by the algorithm **together with the
recorded Clifford circuits** that were absorbed into the (transformed) MPO. The ket
lives in the Clifford-rotated picture, `|ket⟩ = U|ψ⟩` with `U` the product of all
recorded gates in application order, so observables must be evaluated with
`expectation(::PauliTerm, ::CAMPS)`, which conjugates the Pauli string back through the
circuits instead of using `ket` directly.


源码：[src/mpsalgorithms/algorithms/experimental/cadmrg.jl:147](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/cadmrg.jl#L147)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct CAMPS{T<:Number}
```



<a id="api-ALSRecon"></a>

## `ALSRecon`


	ALSRecon(; maxiter=Defaults.maxiter, tol=Defaults.tol, D=Defaults.D, α=1.0e-4,
	         alg_linsolve=Defaults.alg_linsolve(), nbuffer=1024, nadd=128, nrounds=20,
	         verbosity=0)

Sample-amplitude MPS reconstruction by quadratic (least-squares) optimization —
the variational alternative to tensor cross interpolation. Given the sample set
`{(𝐱⁽ᵏ⁾, aₖ)}`, the fitted objective is the data loss

	ℒ(ψ) = Σₖ |⟨𝐱⁽ᵏ⁾|ψ⟩ − aₖ|²

where `⟨𝐱⁽ᵏ⁾|ψ⟩` is the wave-function amplitude of `ψ` on the basis product
`|𝐱⁽ᵏ⁾⟩ = ⊗ⱼ|xⱼ⁽ᵏ⁾⟩` and `aₖ ∈ ℂ` the measured amplitude (possibly noisy).

Single-site ALS sweeps with a fixed bond profile `alg.D` (the DMRG1 discipline: the
out-of-place entry points draw a random guess of bond `alg.D`, the in-place route
re-fits the caller's guess with `changebond!`). `α ≥ 0` is the Hilbert-Schmidt ridge
added to the local normal equations for conditioning (the seq2seq regularization; not
part of the reported loss). The local normal equations are solved by the KrylovKit
iterative solver `alg.alg_linsolve`. `nbuffer`/`nadd`/`nrounds` drive the adaptive
sample-enrichment loop of `reconstruct`: an initial random pool of `nbuffer`
oracle queries, then `nadd` Born samples of the current fit (re-evaluated by the
oracle) per round, for at most `nrounds` rounds.


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:19](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L19)



<a id="api-ALSRecon2"></a>

## `ALSRecon2`


	ALSRecon2(; maxiter=Defaults.maxiter, tol=Defaults.tol, trunc=truncdim(D=Defaults.D),
	          α=1.0e-4, alg_linsolve=Defaults.alg_linsolve(), nbuffer=1024, nadd=128,
	          nrounds=20, verbosity=0)

Two-site variant of `ALSRecon`: the neighboring site pair is optimized jointly
(the same rank-4 local normal equation structure, solved matrix-free by
`alg.alg_linsolve`) and re-split by a truncating SVD under
`alg.trunc::TruncationScheme`, so the bond
dimension adapts during the sweeps — growth where the samples demand it, truncation
where the scheme caps it. The single-site ALS losses stay monotone; the two-site
re-split further relieves local minima of the single-site problem. Shares the
adaptive sample-enrichment loop of `reconstruct`.


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:55](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L55)



<a id="api-ALSReconCache"></a>

## `ALSReconCache`


	ALSReconCache: ALS problem carrier of `reconstruct` — the working chain `ψ`
	(raw data convention: `scaling == 1`, the represented amplitudes are fitted),
	the sample coordinates `X` (L×N) and target amplitudes `a`, the per-sample context
	stacks `Lmat`/`Rmat` and the HS ridge stack `gstorage` (seq2seq's third stack,
	rank-3 version).


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:140](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L140)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct ALSReconCache{CP,T}
function ALSReconCache(ψ::CanonicalMPS, X::Vector{Vector{Int}}, a::Vector)
```



<a id="api-reconstruct"></a>

## `reconstruct`


	reconstruct(samples, ds, alg = ALSRecon()) -> (ψ, info)

Fit an MPS `ψ` to a fixed sample set of tensor amplitudes by ALS sweeps
(`samples::Vector` of `Pair{Vector{Int},T}` or `(𝐱, a)` tuples with
`𝐱::Vector{Int}`; `alg` is an `ALSRecon` or `ALSRecon2`). The
initial guess is a random chain of the bond profile demanded by `alg`. Returns `ψ`
(scaling 1; the represented amplitudes are fitted) and `info`, the
`ALSConvergenceInfo` of the sweeps (the loss *is* the squared data residual
here, so `info.residual` holds the final loss).


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:473](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L473)


	reconstruct(Afun, ds, alg = ALSRecon())
	-> (ψ, info::NamedTuple{(:loss, :nsamples, :rounds)})

Adaptive black-box reconstruction: alternate the inner ALS fit on the current sample
pool with **active sample enrichment** — each round queries the oracle on `alg.nadd`
fresh configurations, half drawn from the Born distribution of the current fit
(`sample`, exploitation) and half uniformly random (exploration: an overfitted chain
concentrates its Born distribution on the training points, so pure Born sampling
would starve the loop of new information). This is the least-squares analog of TCI's
pivot selection. The initial pool is `alg.nbuffer` uniformly random queries.

The fresh Born samples act as the round's **held-out validation set** before joining
the training pool: the loop stops when the validation loss drops below `alg.tol` or
stagnates (relative change < `alg.tol`), or after `alg.nrounds` rounds. The
validation-based criterion is essential — an overparameterized chain can drive the
*training* loss to zero on any sample set, which carries no generalization
information. Each round runs the inner sweeps of `iterative_compute!` up to
`alg.maxiter`.


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:510](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L510)



<a id="api-reconstruct-mutating"></a>

## `reconstruct!`


	reconstruct!(ψ, samples, alg = ALSRecon()) -> (ψ, info)

In-place variant of `reconstruct`: refine the provided chain on the fixed
sample set (the per-site scaling is folded into the data and the bond profile is
re-fitted to `alg`'s demand with `changebond!`). Returns `(ψ, info)` with `info`, the
`ALSConvergenceInfo` of the sweeps (`info.residual` = final loss).


源码：[src/mpsalgorithms/algorithms/experimental/reconstruct.jl:492](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/experimental/reconstruct.jl#L492)



<a id="api-fuse-gates"></a>

## `fuse_gates`


	fuse_gates(gates::AbstractVector{<:AbstractGate}) -> Vector{Gate}

Fuse a gate sequence (circuit) into as few gates as possible (aligned with
QuantumSpins): every gate is absorbed backwards into the closest earlier gate with an
intersecting support — two gates commute exactly when their supports are disjoint —
and a second pass on the adjointed circuit (a forward pass) merges the boundary gates
of repeated layers. Single-site gates are absorbed into any intersecting multi-site
gate, so a gate whose support covers a site swallows that site's single-site gates. No
gate is left out: every intersecting pair is mergeable, and the fused circuit applies
the same product of operators as the input.


源码：[src/mpsalgorithms/algorithms/timeevo/tebd.jl:74](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tebd.jl#L74)



<a id="api-trotter-propagator"></a>

## `trotter_propagator`


	trotter_propagator(ham::OpSum, tspan::Tuple{<:Real,<:Real};
					   order=2, stepsize=0.01) -> Vector{Gate}

Build the gate sequence (circuit) of the Trotter-Suzuki propagator `exp(τ · ham)` over
the real interval `tspan` in steps of length `stepsize` (aligned with QuantumSpins;
algorithm reference: "Higher order decompositions of ordered operator exponentials").
Only even `order` is supported: `order = 2` is the Strang splitting (a purely
nearest-neighbor `ham` uses the even/odd bond splitting; the generic case builds one
gate per distinct term support), higher orders recurse into the Suzuki fractal of five
half-order layers. One-site terms are absorbed into nearest-neighbor terms
(`h ⊗ I`).

Time-dependent coefficients (`Coeff` functions) are supported: every (sub-)
layer freezes the coefficients at its own (real) midpoint.

The circuit realizes the *bare* exponential `exp(τ · H)` of the hamiltonian that is
passed in: the gate on a support is `exp(τ · H_support)`, with `τ` real. Hence the
physical propagators are obtained by scaling the hamiltonian, while `tspan` stays
real:

- imaginary-time evolution `exp(-β · H)`: pass `-ham` with `tspan = (0, β)`;
- real-time evolution `exp(-i · t · H)`: pass `-im * ham` with `tspan = (0, t)`.

Passing `ham` unscaled yields `exp(+τ · H)`, i.e. the imaginary-time propagator of
`-ham`, not `exp(-i t H)`. A complex `tspan` is rejected (the time must be real).
The circuit can be compressed with `fuse_gates` and applied with
`apply!`).


源码：[src/mpsalgorithms/algorithms/timeevo/tebd.jl:191](https://github.com/LeeQY1996/MOSSMPS/blob/master/src/mpsalgorithms/algorithms/timeevo/tebd.jl#L191)
