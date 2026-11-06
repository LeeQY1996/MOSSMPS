# MPSCore 逐项 API 参考

[返回 API 目录](../api.md)


导入方式：`import MOSSQuantumMPS.MPSCore as C`。这是数值张量网络基础层，`CanonicalMPS` 不是模拟器外层的 `MOSSQuantumMPS.MPS`。MPS 张量轴序 `(左键,物理,右键)`，MPO 轴序 `(左键,输出物理,右键,输入物理)`。正则链的 `scaling` 是每站点尺度，网络整体带 `scaling^L`。

```julia
import MOSSQuantumMPS.MPSCore as C
using LinearAlgebra
psi = C.prodmps(ComplexF64, [2, 2], [1, 1]) # 局域状态索引从 1 开始
@assert norm(psi) ≈ 1
u, s, vt, err = C.tsvd([1.0 0; 0 0.5]; trunc=C.NoTruncation())
@assert u * Diagonal(s) * vt ≈ [1.0 0; 0 0.5]
```


本页逐项列出公开符号。函数条目保留源码已有的完整签名与契约，补充未独立文档化的基础接口；签名中的类型均相对于当前子模块。源码链接可用于核对该方法的精确重载。


## 符号索引

| 符号 | 说明位置 |
|---|---|
| `TruncationScheme` | [逐项参考](#api-TruncationScheme) |
| `NoTruncation` | [逐项参考](#api-NoTruncation) |
| `TruncateDim` | [逐项参考](#api-TruncateDim) |
| `TruncateRelError` | [逐项参考](#api-TruncateRelError) |
| `TruncateDimCutoff` | [逐项参考](#api-TruncateDimCutoff) |
| `truncdim` | [逐项参考](#api-truncdim) |
| `truncrelerr` | [逐项参考](#api-truncrelerr) |
| `truncdimcutoff` | [逐项参考](#api-truncdimcutoff) |
| `truncate!` | [逐项参考](#api-truncate-mutating) |
| `QR` | [逐项参考](#api-QR) |
| `QRpos` | [逐项参考](#api-QRpos) |
| `LQ` | [逐项参考](#api-LQ) |
| `LQpos` | [逐项参考](#api-LQpos) |
| `SVD` | [逐项参考](#api-SVD) |
| `SDD` | [逐项参考](#api-SDD) |
| `Polar` | [逐项参考](#api-Polar) |
| `tsvd!` | [逐项参考](#api-tsvd-mutating) |
| `tsvd` | [逐项参考](#api-tsvd) |
| `leftorth!` | [逐项参考](#api-leftorth-mutating) |
| `leftorth` | [逐项参考](#api-leftorth) |
| `rightorth!` | [逐项参考](#api-rightorth-mutating) |
| `rightorth` | [逐项参考](#api-rightorth) |
| `tie` | [逐项参考](#api-tie) |
| `permute` | [逐项参考](#api-permute) |
| `scalar` | [逐项参考](#api-scalar) |
| `isometry` | [逐项参考](#api-isometry) |
| `renyi_entropy` | [逐项参考](#api-renyi-entropy) |
| `distance` | [逐项参考](#api-distance) |
| `distance2` | [逐项参考](#api-distance2) |
| `fidelity` | [逐项参考](#api-fidelity) |
| `infidelity` | [逐项参考](#api-infidelity) |
| `AbstractMPS` | [逐项参考](#api-AbstractMPS) |
| `AbstractMPO` | [逐项参考](#api-AbstractMPO) |
| `MPSTensor` | [逐项参考](#api-MPSTensor) |
| `MPOTensor` | [逐项参考](#api-MPOTensor) |
| `CanonicalMPS` | [逐项参考](#api-CanonicalMPS) |
| `CanonicalMPO` | [逐项参考](#api-CanonicalMPO) |
| `MPO` | [逐项参考](#api-MPO) |
| `MPOHamiltonian` | [逐项参考](#api-MPOHamiltonian) |
| `Orthogonalize` | [逐项参考](#api-Orthogonalize) |
| `SchurMPOTensor` | [逐项参考](#api-SchurMPOTensor) |
| `SparseMPOHamiltonian` | [逐项参考](#api-SparseMPOHamiltonian) |
| `OpTerm` | [逐项参考](#api-OpTerm) |
| `OpSum` | [逐项参考](#api-OpSum) |
| `Coeff` | [逐项参考](#api-Coeff) |
| `isconstant` | [逐项参考](#api-isconstant) |
| `term` | [逐项参考](#api-term) |
| `tompotensor` | [逐项参考](#api-tompotensor) |
| `tompotensors` | [逐项参考](#api-tompotensors) |
| `todense` | [逐项参考](#api-todense) |
| `vectorize` | [逐项参考](#api-vectorize) |
| `devectorize` | [逐项参考](#api-devectorize) |
| `superoperator` | [逐项参考](#api-superoperator) |
| `ExpDecayOpTerm` | [逐项参考](#api-ExpDecayOpTerm) |
| `ExpDecayOpSum` | [逐项参考](#api-ExpDecayOpSum) |
| `PairOpTerm` | [逐项参考](#api-PairOpTerm) |
| `isleftcanonical` | [逐项参考](#api-isleftcanonical) |
| `isrightcanonical` | [逐项参考](#api-isrightcanonical) |
| `iscanonical` | [逐项参考](#api-iscanonical) |
| `canonicalize!` | [逐项参考](#api-canonicalize-mutating) |
| `canonicalize` | [逐项参考](#api-canonicalize) |
| `space_l` | [逐项参考](#api-space-l) |
| `space_r` | [逐项参考](#api-space-r) |
| `phydim` | [逐项参考](#api-phydim) |
| `ophydim` | [逐项参考](#api-ophydim) |
| `iphydim` | [逐项参考](#api-iphydim) |
| `phydims` | [逐项参考](#api-phydims) |
| `ophydims` | [逐项参考](#api-ophydims) |
| `iphydims` | [逐项参考](#api-iphydims) |
| `bonddim` | [逐项参考](#api-bonddim) |
| `bonddims` | [逐项参考](#api-bonddims) |
| `scaling` | [逐项参考](#api-scaling) |
| `setscaling!` | [逐项参考](#api-setscaling-mutating) |
| `svectors_uninitialized` | [逐项参考](#api-svectors-uninitialized) |
| `unset_svectors!` | [逐项参考](#api-unset-svectors-mutating) |
| `normalize_tr!` | [逐项参考](#api-normalize-tr-mutating) |
| `expectation` | [逐项参考](#api-expectation) |
| `expectationvalue` | [逐项参考](#api-expectationvalue) |
| `entanglement_entropy` | [逐项参考](#api-entanglement-entropy) |
| `entanglement_spectrum` | [逐项参考](#api-entanglement-spectrum) |
| `schmidt_values` | [逐项参考](#api-schmidt-values) |
| `prodmps` | [逐项参考](#api-prodmps) |
| `randommps` | [逐项参考](#api-randommps) |
| `DensityOperator` | [逐项参考](#api-DensityOperator) |
| `infinite_temperature_state` | [逐项参考](#api-infinite-temperature-state) |
| `changebond!` | [逐项参考](#api-changebond-mutating) |
| `identitympo` | [逐项参考](#api-identitympo) |
| `prodmpo` | [逐项参考](#api-prodmpo) |
| `randommpo` | [逐项参考](#api-randommpo) |
| `⊙` | [逐项参考](#api-hadamard-op) |
| `copyphydims` | [逐项参考](#api-copyphydims) |
| `tomps` | [逐项参考](#api-tomps) |
| `tompo` | [逐项参考](#api-tompo) |
| `AbstractGate` | [逐项参考](#api-AbstractGate) |
| `Gate` | [逐项参考](#api-Gate) |
| `apply!` | [逐项参考](#api-apply-mutating) |
| `swap!` | [逐项参考](#api-swap-mutating) |
| `positions` | [逐项参考](#api-positions) |
| `shift` | [逐项参考](#api-shift) |
| `TraceCache` | [逐项参考](#api-TraceCache) |


<a id="api-TruncationScheme"></a>

## `TruncationScheme`


    TruncationScheme

Abstract type for tensor truncation schemes, specifying how singular values are truncated (by dimension, by truncation error, or both).


源码：[src/mpscore/tensorops/truncation.jl:3](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L3)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type TruncationScheme end
```



<a id="api-NoTruncation"></a>

## `NoTruncation`


    NoTruncation()

A truncation scheme that performs no truncation, keeping all singular values.


源码：[src/mpscore/tensorops/truncation.jl:11](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L11)



<a id="api-TruncateDim"></a>

## `TruncateDim`

```julia
TruncateDim(D::Int)
TruncateDim(; D::Int)
```

维数截断方案，只保留最大的至多 `D` 个奇异值；`truncdim(D)` 返回同类型。只构造配置，不修改张量。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct TruncateDim <: TruncationScheme
TruncateDim(;D::Int) = TruncateDim(D)
```



<a id="api-TruncateRelError"></a>

## `TruncateRelError`

```julia
TruncateRelError(ϵ::Float64)
TruncateRelError(; ϵ::Real)
```

阈值截断配置；保留严格大于 `norm(s,p)*ϵ` 的奇异值。`ϵ` 是逐奇异值相对阈值，不是整个算法的误差界；使用 `truncrelerr(ϵ)` 构造。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct TruncateRelError <: TruncationScheme
TruncateRelError(;ϵ::Real) = TruncateRelError(convert(Float64, ϵ))
```



<a id="api-TruncateDimCutoff"></a>

## `TruncateDimCutoff`


    TruncateDimCutoff(D, ϵ, add_back)
    TruncateDimCutoff(; D, ϵ, add_back=0)

A truncation scheme combining dimension and cutoff: the truncation point is first determined by the relative norm `ϵ`,
then capped at `D` singular values while keeping at least `add_back` of them.


源码：[src/mpscore/tensorops/truncation.jl:49](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L49)



<a id="api-truncdim"></a>

## `truncdim`


    truncdim(d::Int)

Construct a dimension-truncated scheme `TruncateDim(d)` that keeps only the `d` largest singular values.


源码：[src/mpscore/tensorops/truncation.jl:22](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L22)


    truncdim(; D::Int)

Keyword form of the dimension-truncated scheme constructor, equivalent to `truncdim(D)`.


源码：[src/mpscore/tensorops/truncation.jl:28](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L28)



<a id="api-truncrelerr"></a>

## `truncrelerr`


    truncrelerr(ϵ::Real)
    truncrelerr(; ϵ::Real)

Construct a `TruncateRelError` scheme that discards singular values with relative norm below `ϵ`.


源码：[src/mpscore/tensorops/truncation.jl:39](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L39)



<a id="api-truncdimcutoff"></a>

## `truncdimcutoff`


    truncdimcutoff(D, ϵ; add_back=0)

Positional-argument convenience constructor for `TruncateDimCutoff`, equivalent to `TruncateDimCutoff(D, ϵ, add_back)`.


源码：[src/mpscore/tensorops/truncation.jl:62](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L62)


    truncdimcutoff(; D, ϵ, add_back=0)

Keyword convenience constructor for `TruncateDimCutoff`, equivalent to `TruncateDimCutoff(D, ϵ, add_back)`.


源码：[src/mpscore/tensorops/truncation.jl:68](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L68)



<a id="api-truncate-mutating"></a>

## `truncate!`


	truncate!(ψ::CanonicalMPS; trunc=Defaults.alg_orth_trunc()) -> (ψ, err)

Truncate `ψ` by canonicalizing with an SVD sweep under the truncation scheme `trunc`.
Returns `ψ` and the maximal truncation error.


源码：[src/mpscore/states/initializers.jl:168](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L168)


	truncate!(ρ::CanonicalMPO; trunc=Defaults.alg_orth_trunc()) -> (ρ, err)

Truncate the operator chain `ρ` by canonicalizing with an SVD sweep under the truncation
scheme `trunc` (the operator-space analog of the `CanonicalMPS` method). Returns
`ρ` and the maximal truncation error.


源码：[src/mpscore/states/initializers.jl:177](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L177)


    truncate!(v, trunc, p=2) -> (v′, err)

Public wrapper of the internal `_truncate!`: truncate the (descending) singular value vector `v`
according to `trunc`, returning the truncated vector and the (relative for cutoff schemes) error.


源码：[src/mpscore/tensorops/truncation.jl:104](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/truncation.jl#L104)



<a id="api-QR"></a>

## `QR`

```julia
QR()
```

QR 分解驱动，无字段配置；用于 `leftorth!`，该路径的 `atol` 必须为零。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct QR <: OrthogonalFactorizationAlgorithm
```



<a id="api-QRpos"></a>

## `QRpos`

```julia
QRpos()
```

对角符号固定的 QR 分解驱动；`leftorth!` 默认矩阵驱动，无字段配置。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct QRpos <: OrthogonalFactorizationAlgorithm
```



<a id="api-LQ"></a>

## `LQ`

```julia
LQ()
```

右正交化的 LQ 驱动标记，传给 `rightorth` / `rightorth!` 的 `alg`；不保存张量数据。`LQ()' == QR()`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct LQ <: OrthogonalFactorizationAlgorithm
```



<a id="api-LQpos"></a>

## `LQpos`

```julia
LQpos()
```

对角符号固定的 LQ 分解驱动；`rightorth!` 默认矩阵驱动。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct LQpos <: OrthogonalFactorizationAlgorithm
```



<a id="api-SVD"></a>

## `SVD`

```julia
SVD()
```

使用 QR iteration 的奇异值分解驱动，用于 `tsvd` 或正交化；矩阵/张量分解的返回因子与误差见对应函数。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct SVD <: OrthogonalFactorizationAlgorithm
```



<a id="api-SDD"></a>

## `SDD`

```julia
SDD()
```

使用 divide-and-conquer 的奇异值分解驱动；`tsvd!` 使用安全回退版本，返回因子与 `SVD()` 相同。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct SDD <: OrthogonalFactorizationAlgorithm # lapack's default divide and conquer algorithm
```



<a id="api-Polar"></a>

## `Polar`

```julia
Polar()
```

极分解正交化驱动标记，可用于矩阵/张量 `leftorth`、`rightorth`；本身只返回无字段配置对象。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct Polar <: OrthogonalFactorizationAlgorithm
```



<a id="api-tsvd-mutating"></a>

## `tsvd!`


    tsvd!(a; trunc=NoTruncation(), alg=SDD())

Truncated singular value decomposition of the matrix `a`; returns `(u, s, v, err)`.

**Reconstruction convention (plain):** `a = u * Diagonal(s) * v` — the factors multiply
*without any further adjoint*: `v` is the adjoint `V†` of the right singular vectors,
already conjugated and stored as an ordinary array. With `trunc = NoTruncation()` the
decomposition is exact up to round-off; with truncation only the leading `r` singular
values are kept and `err = sqrt(Σ_{k>r} σk²)` is the discarded weight. The factors are

* `u` (`m × r`): orthonormal columns, `u' * u = I`;
* `v` (`r × n`): orthonormal rows, `v * v' = I` (the isometry `V†`);
* `s`: the kept singular values in descending order.

`alg` selects the SVD driver: `SDD()` (divide-and-conquer with safe fallback) or
`SVD()` (QR iteration, LAPACK `gesvd`).

Note: the input matrix `a` is used as workspace and may be **destroyed** in place;
pass a copy if the input must be preserved.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:72](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L72)


    tsvd!(a, left, right; trunc=NoTruncation(), alg=SDD())

Truncated SVD of the tensor `a` with dimensions grouped into `left`/`right`; returns
`(u, s, v, err)`.

The flattening `mat(a) = (left) × (right)` is decomposed as `mat(a) = u_mat *
Diagonal(s) * v_mat` (plain multiplication; `v_mat` is the adjoint `V†` of the right
singular vectors, already conjugated — see `tsvd!`), and the factors are
reshaped back to tensors:

* `u` has dimensions `(left..., r)`: an isometry from `left` to the singular index,
  `Σ u[l, r] * conj(u[l', r]) = δ`;
* `v` has dimensions `(r, right...)`: an isometry from `right` to the singular index,
  `Σ v[r, ri] * conj(v[r', ri]) = δ`;
* `err`: the discarded weight; `trunc` selects how many singular values are kept.

Note: the input tensor `a` itself is not modified (the flattened matrix is copied
internally, since the decomposition requires a contiguous workspace); the `!` marks the
variant that reuses that copy as workspace.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:115](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L115)



<a id="api-tsvd"></a>

## `tsvd`


    tsvd(a; trunc=NoTruncation(), alg=SDD())

Non-mutating version of `tsvd!`: the input matrix is copied before the
decomposition (see the matrix method for the reconstruction convention and the factor
properties).


源码：[src/mpscore/tensorops/tensorfactorizations.jl:106](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L106)


    tsvd(a, left, right; trunc=NoTruncation(), alg=SDD())

Non-mutating version of `tsvd!`: the input tensor is copied before the
decomposition.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:145](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L145)



<a id="api-leftorth-mutating"></a>

## `leftorth!`


	leftorth!(ψ::CanonicalMPS; alg::Orthogonalize=Orthogonalize(QR()))

Orthogonalize `ψ` into left-canonical form (in place). `SVD` paths record bond spectra in `ψ.s`
and support truncation; `QR` ignores truncation.


源码：[src/mpscore/states/orth.jl:29](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L29)


	leftorth!(ρ::CanonicalMPO; alg::Orthogonalize=Orthogonalize(QR()))

Orthogonalize the density-matrix chain into left-canonical form (in place).


源码：[src/mpscore/states/orth.jl:148](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L148)


	leftorth!(A, alg, atol=0)

Left-orthogonalize the matrix `A` into `(Q, R)` such that `A = Q * R` with `Q` having orthonormal columns.
`alg` may be `QR`/`QRpos` (QR factorization, `atol` must be 0), `SVD`/`SDD` (singular value
decomposition, where small singular values below `atol` are truncated), or `Polar` (polar
decomposition). Returns `(Q, R)`.

Note: the input `A` is used as workspace and may be **destroyed/overwritten**; pass a copy if the input must be preserved.


源码：[src/mpscore/tensorops/matrixalgebra.jl:36](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/matrixalgebra.jl#L36)


    leftorth!(A; alg=QRpos(), atol=0)

Keyword version of `leftorth!` acting on plain matrices, equivalent to `leftorth!(A, alg, atol)`.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:153](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L153)


    leftorth!(A, left, right; alg=QRpos(), atol=0)

Left-orthogonalize the tensor `A` with dimensions grouped into `left`/`right`, returning `(u, v)`,
where `u` has dimensions `(left..., s)` and `v` has dimensions `(s, right...)`.

Note: the input tensor `A` itself is not modified (the permuted matrix is copied internally, since the
factorization requires a contiguous workspace); the `!` marks the variant that reuses that copy as workspace.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:159](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L159)



<a id="api-leftorth"></a>

## `leftorth`


    leftorth(A; alg=QRpos(), atol=0)
    leftorth(A, left, right; alg=QRpos(), atol=0)

Non-mutating version of `leftorth!`: the input is copied before orthogonalization.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:177](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L177)



<a id="api-rightorth-mutating"></a>

## `rightorth!`


	rightorth!(ψ::CanonicalMPS; alg::Orthogonalize=Orthogonalize(SVD(), normalize=false))

Orthogonalize `ψ` into right-canonical form (in place); the Schmidt values of all bonds are
recorded (normalized, with the norm carried by `scaling`).


源码：[src/mpscore/states/orth.jl:73](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L73)


	rightorth!(ρ::CanonicalMPO; alg::Orthogonalize=Orthogonalize(SVD(), normalize=false))

Orthogonalize the density-matrix chain into right-canonical form (in place); the Schmidt
values of all bonds are recorded.


源码：[src/mpscore/states/orth.jl:193](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L193)


	rightorth!(A, alg, atol=0)

Right-orthogonalize the matrix `A` into `(L, Q)` such that `A = L * Q` with `Q` having orthonormal rows.
`alg` may be `LQ`/`LQpos` (LQ factorization, `atol` must be 0), `SVD`/`SDD` (singular value
decomposition, where small singular values below `atol` are truncated), or `Polar` (polar
decomposition). Returns `(L, Q)`.

Note: the input `A` is used as workspace and may be **destroyed/overwritten**; pass a copy if the input must be preserved.


源码：[src/mpscore/tensorops/matrixalgebra.jl:61](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/matrixalgebra.jl#L61)


    rightorth!(A; alg=LQpos(), atol=0)

Keyword version of `rightorth!` acting on plain matrices, equivalent to `rightorth!(A, alg, atol)`.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:186](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L186)


    rightorth!(A, left, right; alg=LQpos(), atol=0)

Right-orthogonalize the tensor `A` with dimensions grouped into `left`/`right`, returning `(u, v)`,
where `u` has dimensions `(left..., s)` and `v` has dimensions `(s, right...)`.

Note: the input tensor `A` itself is not modified (the permuted matrix is copied internally, since the
factorization requires a contiguous workspace); the `!` marks the variant that reuses that copy as workspace.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:192](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L192)



<a id="api-rightorth"></a>

## `rightorth`


    rightorth(A; alg=LQpos(), atol=0)
    rightorth(A, left, right; alg=LQpos(), atol=0)

Non-mutating version of `rightorth!`: the input is copied before orthogonalization.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:210](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L210)



<a id="api-tie"></a>

## `tie`

```julia
tie(a::AbstractArray, axs::NTuple{N,Int}) -> AbstractArray
```

按连续轴组 reshape 张量；`axs` 每个数表示一组包含的原轴数，要求 `sum(axs)==ndims(a)`。例如 `tie(rand(2,3,4),(2,1))` 为 `(6,4)`。返回 reshape 视图，存储可能共享，不做数值收缩。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
function tie(a::AbstractArray{T, N}, axs::NTuple{N1, Int}) where {T, N, N1}
```



<a id="api-permute"></a>

## `permute`


	permute(x, perm; kwargs...) -> typeof(x)

Non-mutating `permute!`: the site contents of `x` reordered according to
`perm`, returned as a new chain. This chain-level `permute` extends the tensor
`permute` of the tensorops layer.


源码：[src/mpscore/states/linalg.jl:238](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/linalg.jl#L238)


    permute(m::AbstractArray, perm)

Return a view of `m` with its dimensions permuted according to `perm` (a `PermutedDimsArray`), without copying data.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:7](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L7)


    permute(m::AbstractArray, left, right)

Group the dimensions into `left` and `right` and place them in that order, equivalent to `permute(m, (left..., right...))`.


源码：[src/mpscore/tensorops/tensorfactorizations.jl:13](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L13)



<a id="api-scalar"></a>

## `scalar`

```julia
scalar(x::AbstractArray{<:Number}) -> Number
```

返回 `only(x)`，要求恰有一个元素；不修改数组。多个元素或空数组由 `only` 抛错。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
scalar(x::AbstractArray{T}) where {T<:Number} = only(x)
```



<a id="api-isometry"></a>

## `isometry`


    isometry(T, m, n)
    isometry(T, d)
    isometry(m, n)
    isometry(d)

Return the rectangular identity (isometry) matrix of size `m × n` (`d × d`) with element type `T` (default `Float64`).


源码：[src/mpscore/tensorops/tensorfactorizations.jl:34](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L34)



<a id="api-renyi-entropy"></a>

## `renyi_entropy`


    renyi_entropy(v::AbstractVector{<:Real}; α::Real=1)

Compute the Rényi entropy of the vector `v`. For `α=1` this reduces to the Shannon entropy `-Σᵢ vᵢ log(vᵢ)`,
and otherwise it is `1/(1-α) * log(Σᵢ vᵢ^α)`.
The entries of `v` must be nonnegative and sum to 1 (e.g. normalized squared singular values).


源码：[src/mpscore/tensorops/tensorfactorizations.jl:232](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/tensorfactorizations.jl#L232)



<a id="api-distance"></a>

## `distance`


	distance(ψA, ψB)
	distance2(ψA, ψB)

Distance between two states, based on overlaps and including `scaling` factors.


源码：[src/mpscore/states/linalg.jl:137](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/linalg.jl#L137)


    distance(x, y)

The 2-norm distance between two arrays (or tensor networks) of the same shape, equal to `sqrt(distance2(x, y))`.


源码：[src/mpscore/tensorops/distance.jl:24](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/distance.jl#L24)



<a id="api-distance2"></a>

## `distance2`


	distance(ψA, ψB)
	distance2(ψA, ψB)

Distance between two states, based on overlaps and including `scaling` factors.


源码：[src/mpscore/states/linalg.jl:137](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/linalg.jl#L137)


    distance2(x, y)

Compute the squared distance between two arrays (or tensor networks) of the same shape:

`‖x - y‖² = ‖x‖² + ‖y‖² - 2 Re⟨x, y⟩`; the absolute value is returned to avoid negative values from floating-point rounding.

Typically used to verify the accuracy of tensor network multiplication against a naive reference implementation. See also `distance`.


源码：[src/mpscore/tensorops/distance.jl:14](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/tensorops/distance.jl#L14)



<a id="api-fidelity"></a>

## `fidelity`


	fidelity(hA::MPO, hB::MPO) -> Real
	fidelity(hA::MPOHamiltonian, hB::MPOHamiltonian) -> Real
	fidelity(hA::CanonicalMPO, hB::CanonicalMPO) -> Real

The Hilbert-Schmidt fidelity `|tr(conj(hA)·hB)| / (‖hA‖_HS·‖hB‖_HS)` of two operator
chains of the same kind. The absolute value discards the overall phase: two chains
differing by a global phase (or external scale) have `fidelity = 1`, while their
`distance` is generically nonzero. For `CanonicalMPO` operands the fidelity is
computed from the raw (scale-free) contractions — the `scaling` factors cancel exactly,
so it stays finite for arbitrarily large scalings.


源码：[src/mpscore/operators/linalg.jl:206](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/linalg.jl#L206)


	fidelity(ψA::CanonicalMPS, ψB::CanonicalMPS) -> Real

The fidelity `|⟨ψA|ψB⟩| / (‖ψA‖·‖ψB‖)` of the represented chains. Like `distance`
it includes the per-site `scaling` factors, but the absolute value discards the overall
phase: two chains differing by a global phase (or external scale) have `fidelity = 1`,
while their `distance` is generically nonzero. Computed from raw (scale-free) transfer
contractions — the `scaling` factors cancel exactly (equivalent to the direct formula
with `dot`/`norm`), so it stays finite for arbitrarily large scalings.


源码：[src/mpscore/states/linalg.jl:152](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/linalg.jl#L152)



<a id="api-infidelity"></a>

## `infidelity`


	infidelity(hA::MPO, hB::MPO) -> Real
	infidelity(hA::MPOHamiltonian, hB::MPOHamiltonian) -> Real
	infidelity(hA::CanonicalMPO, hB::CanonicalMPO) -> Real

The complement of `fidelity`: `1 - fidelity`.


源码：[src/mpscore/operators/linalg.jl:228](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/linalg.jl#L228)


	infidelity(ψA::CanonicalMPS, ψB::CanonicalMPS) -> Real

The complement of `fidelity`: `1 - fidelity`.


源码：[src/mpscore/states/linalg.jl:167](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/linalg.jl#L167)



<a id="api-AbstractMPS"></a>

## `AbstractMPS`

```julia
abstract type AbstractMPS{T<:Number} end
```

数值 MPS 基类；不同于顶层模拟器的同名类型。站点张量物理维可以不为 2，具体数据结构为 `CanonicalMPS`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type AbstractMPS{T<:Number} end
```



<a id="api-AbstractMPO"></a>

## `AbstractMPO`

```julia
abstract type AbstractMPO{T<:Number} end
```

数值 MPO 基类，具体类型包括 `MPO`、`CanonicalMPO`、`MPOHamiltonian`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type AbstractMPO{T<:Number} end
```



<a id="api-MPSTensor"></a>

## `MPSTensor`

```julia
const MPSTensor{T} = AbstractArray{T,3}
```

站点张量类型别名，轴为 `(左键,物理,右键)`；不是会分配数据的构造函数。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
const MPSTensor{T}  = AbstractArray{T,3}     # A[aL, p, aR]
```



<a id="api-MPOTensor"></a>

## `MPOTensor`

```julia
const MPOTensor{T} = AbstractArray{T,4}
```

MPO 张量类型别名，轴为 `(左键,输出物理,右键,输入物理)`；物理输入与输出维数可不等。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
const MPOTensor{T}  = AbstractArray{T,4}     # W[aL, p_out, aR, p_in]
```



<a id="api-CanonicalMPS"></a>

## `CanonicalMPS`


    CanonicalMPS{T<:Number, R<:Real} <: AbstractMPS{T}

One-dimensional canonical tensor network representing a finite quantum state.
Site tensor conventions:

- Dimension 1: left auxiliary (bond) index, dimension 1 at the leftmost site
- Dimension 2: physical index
- Dimension 3: right auxiliary (bond) index, dimension 1 at the rightmost site

#### Fields
- `data::Vector{Array{T,3}}`: list of site tensors
- `s::Vector{Union{Missing, Vector{R}}}`: Schmidt values; `s[b+1]` stores the spectrum at bond `b`
  (bond `b` lies between site `b` and `b+1`); `missing` when uninitialized
- `scaling::Ref{Float64}`: per-site overall scaling factor (total scaling = `scaling^L`)


源码：[src/mpscore/states/canonicalmps.jl:4](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/canonicalmps.jl#L4)


    CanonicalMPS(::Type{T}, ds) -> CanonicalMPS
    CanonicalMPS(::Type{T}, L; d=2)

A bond-dimension-1 `CanonicalMPS` of all-ones site tensors with physical dimensions `ds`.


源码：[src/mpscore/states/canonicalmps.jl:46](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/canonicalmps.jl#L46)



<a id="api-CanonicalMPO"></a>

## `CanonicalMPO`


    CanonicalMPO{T<:Number, R<:Real} <: AbstractMPO{T}

One-dimensional canonical tensor network representing a density matrix (process tensor).
Site tensor conventions:

- Dimension 1: left auxiliary (bond) index, dimension 1 (vacuum) at the leftmost site
- Dimension 2: output physical index
- Dimension 3: right auxiliary (bond) index, dimension 1 (vacuum) at the rightmost site
- Dimension 4: input physical index

Fields `s` and `scaling` follow the same conventions as `CanonicalMPS`.


源码：[src/mpscore/states/canonicalmpo.jl:5](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/canonicalmpo.jl#L5)


    CanonicalMPO(::Type{T}, ds) -> CanonicalMPO
    CanonicalMPO(::Type{T}, L; d=2)

The identity `CanonicalMPO` with vacuum boundaries: site tensors `reshape(isometry(T, d), 1, d, 1, d)`.


源码：[src/mpscore/states/canonicalmpo.jl:44](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/canonicalmpo.jl#L44)



<a id="api-MPO"></a>

## `MPO`


    MPO{T<:Number} <: AbstractMPO{T}

A finite matrix product operator: a chain of rank-4 site tensors representing a quantum operator.
Site tensor conventions:

- Dimension 1: left auxiliary (bond) index, dimension 1 at the leftmost site
- Dimension 2: output physical index
- Dimension 3: right auxiliary (bond) index
- Dimension 4: input physical index


源码：[src/mpscore/operators/mpo.jl:4](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/mpo.jl#L4)


    MPO(::Type{T}, ds) -> MPO

The identity `MPO`: site tensors `reshape(isometry(T, d), 1, d, 1, d)` with bond dimension 1.


源码：[src/mpscore/operators/mpo.jl:26](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/mpo.jl#L26)



<a id="api-MPOHamiltonian"></a>

## `MPOHamiltonian`


	MPOHamiltonian(s::ExpDecayOpSum, L::Int, [hloc]) -> MPOHamiltonian
	MPOHamiltonian(t::ExpDecayOpTerm, L::Int, [hloc]) -> MPOHamiltonian

The exponentially decaying operator as an `L`-site Hamiltonian chain (assembled from the
per-site `SchurMPOTensor`s of `s`, with the optional on-site term `hloc` in
every `D` corner).


源码：[src/mpscore/operators/longrangeop.jl:143](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/longrangeop.jl#L143)


	MPOHamiltonian(s::ExpDecayOpSum, hlocs::AbstractVector{<:AbstractMatrix}) -> MPOHamiltonian

The exponentially decaying operator on a chain whose length is `length(hlocs)`, with a
**per-site** on-site operator `hlocs[i]` in the `D` corner of site `i` (each `hlocs[i]`
must match the common local dimension `phydim(s)`; the operator content may differ from
site to site).


源码：[src/mpscore/operators/longrangeop.jl:156](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/longrangeop.jl#L156)


	MPOHamiltonian(t::PairOpTerm, [hloc]) -> MPOHamiltonian
	MPOHamiltonian(t::PairOpTerm, hlocs::AbstractVector{<:AbstractMatrix}) -> MPOHamiltonian

The pair-coupled operator as an `L`-site Hamiltonian chain (`L = length(t)`), assembled
from the per-site `SchurMPOTensor`s. The optional on-site operator `hloc` (the
same on every site) — or the per-site operators `hlocs` (each `hlocs[s]` at site `s`,
operator content may differ) — accumulates in the `D` corners.


源码：[src/mpscore/operators/longrangeop.jl:264](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/longrangeop.jl#L264)


	MPOHamiltonian{T<:Number}
	MPOHamiltonian(data::AbstractVector{<:SchurMPOTensor})
	MPOHamiltonian(data::Vector{<:Matrix})
	MPOHamiltonian(L::Int, terms::OpTerm...)

An MPO representation of a Hamiltonian whose site tensors are matrices of local `d×d`
operators (sparse matrix-of-matrices form). The first site tensor is the first row of
the chain, the last site the last column; the interior encodes started operator strings.

Each site tensor carries **its own local dimension** (`phydim` inferred from its stored
blocks), so a lattice with differing per-site dimensions is supported: build the terms on
an `OpSum(ds)` carrying the per-site dimensions, and every operator is validated
against its own `ds[pos]` (an `OpTerm` itself only requires square operators).
`MPOHamiltonian(L, terms...)` carries no lattice and therefore needs one common dimension.

Assemble from product terms with `OpTerm` or from a vector of block matrices;
convert to the dense 4-index chain with `MPO(h)` / `tompotensors`.
This is the standard operator input of `ground_state`, `excited_state` and TDVP1.


源码：[src/mpscore/operators/mpohamiltonian.jl:5](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/mpohamiltonian.jl#L5)


	MPOHamiltonian(L::Int, terms::OpTerm...)
	MPOHamiltonian(ds::AbstractVector{<:Integer}, terms::OpTerm...)
	MPOHamiltonian(terms::OpSum)

Assemble the Schur-form (Jordan upper-triangular) MPO Hamiltonian from the product
terms `terms` (given individually on `L` sites, on a lattice `ds` with possibly differing
per-site dimensions, or as a validated `OpSum`). Each multi-site term gets its own
private chain of channels (one per partially-completed operator string): logical channel 1
is the vacuum identity and the last channel the closing identity; on-site terms accumulate
in the `D` corner block. Site tensors are built directly in the `A`/`B`/`C`/`D` block
storage: interior sites are square `n×n` Jordan blocks, the first site keeps the vacuum row
(`1×n`) and the last site the closing column (`n×1`).

The `L` form carries no lattice and therefore requires a **uniform** local dimension: every
operator of every term must share one `d` (otherwise it throws a `DimensionMismatch`). Use
`MPOHamiltonian(ds, terms...)` or `MPOHamiltonian(OpSum(ds))` for a lattice with differing
per-site dimensions, where every operator is validated against its own `ds[pos]`.


源码：[src/mpscore/operators/mpohamiltonian.jl:112](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/mpohamiltonian.jl#L112)



<a id="api-Orthogonalize"></a>

## `Orthogonalize`


    Orthogonalize{A<:Union{QR,SVD}, T<:TruncationScheme}

Configuration of the orthogonalization scheme, used by `leftorth!`, `rightorth!` and `canonicalize!`.

#### Fields
- `orth::A`: underlying orthogonalization algorithm (`QR` or `SVD`)
- `trunc::T`: truncation scheme; only effective with `SVD`, no effect with `QR`
- `normalize::Bool`: whether to normalize (instead of distributing the norm into `scaling`)
- `verbosity::Int`: verbosity level


源码：[src/mpscore/abstractdefs.jl:12](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/abstractdefs.jl#L12)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
struct Orthogonalize{A<:Union{QR,SVD}, T<:TruncationScheme} <: MatrixProductOrthogonalAlgorithm
Orthogonalize(a::Union{QR,SVD}, trunc::TruncationScheme; normalize::Bool=false, verbosity::Int=0) =
Orthogonalize(a::Union{QR,SVD}, trunc::TruncationScheme, normalize::Bool) =
Orthogonalize(a::Union{QR,SVD}; trunc::TruncationScheme=NoTruncation(), normalize::Bool=false, verbosity::Int=0) =
Orthogonalize(; alg::Union{QR,SVD}=SVD(), trunc::TruncationScheme=NoTruncation(), normalize::Bool=false, verbosity::Int=0) =
```



<a id="api-SchurMPOTensor"></a>

## `SchurMPOTensor`


	SchurMPOTensor{T}

Schur (upper-triangular) block-matrix tensor of an MPO (symmetry-free version); see
the module comment. Supports block-matrix style access `W[i, j]` returning the `(d, d)`
local operator. The logical block matrix may be rectangular — the left and right
channel spaces (`size(W, 1)` / `size(W, 2)`) may differ.


源码：[src/mpscore/operators/schurmpotensor.jl:34](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/schurmpotensor.jl#L34)


	SchurMPOTensor(W::AbstractMatrix) -> SchurMPOTensor

Construct from an `n × n` operator matrix: `W[i, j]` is the `(d, d)` local
operator from row `i` (left level) to column `j` (right level); entries may be
`Missing`, `Number`s, or matrices. `[1,1]` and `[end,end]` are implied
identities (entries should be `1` or `Missing`).


源码：[src/mpscore/operators/schurmpotensor.jl:124](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/schurmpotensor.jl#L124)



<a id="api-SparseMPOHamiltonian"></a>

## `SparseMPOHamiltonian`

```julia
const SparseMPOHamiltonian = MPOHamiltonian
```

兼容类型别名，与 `MPOHamiltonian` 是同一对象；所有构造和方法适用相同契约，不引入第二种存储类型。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
const SparseMPOHamiltonian = MPOHamiltonian
```



<a id="api-OpTerm"></a>

## `OpTerm`


	OpTerm(coeff, positions, operators)
	OpTerm(coeff, i₁ => O₁, i₂ => O₂, ...)

A product operator term `coeff * O₁ ⊗ O₂ ⋯` acting on the site positions `positions`
(each position at most once; the term is symmetrized in any order, since the operators
commute on distinct sites). The coefficient may be a number, a time-dependent function
`t -> x(t)` or a `Coeff` — time-dependent terms are only supported by
`trotter_propagator`. The operators only have to be *square*: the local dimension
may differ from site to site, and `OpSum` checks every operator against its own
`ds[pos]`. Terms are combined into sums with `+`
(`OpTerm + OpTerm -> OpSum`, `OpSum + OpTerm`, `OpTerm + OpSum`, `OpSum + OpSum`),
multiplied by a number (`x * term`, `term * x`) and evaluated at a real time
(`term(t)` freezes the coefficient at `t`).


源码：[src/mpscore/operators/opsum.jl:35](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/opsum.jl#L35)



<a id="api-OpSum"></a>

## `OpSum`


	OpSum(ds)
	OpSum(ds, terms)
	OpSum(ds, terms...)

A validated collection of `OpTerm`s on a lattice with physical dimensions
`ds::Vector{Int}`. The terms are validated against `ds` on construction (positions in
range, every operator matching the local dimension), so an `OpSum` is self-consistent
by construction; it is the input of `MPOHamiltonian(::OpSum)`. The scalar type `T` is
the promoted scalar type of the term operators and coefficients (a time-dependent
`Coeff` keeps its own function). An empty `OpSum(ds)` serves as the starting
point of an incremental build: terms are accumulated with `+=`
(`OpSum + OpTerm -> OpSum`), every added term is validated against the lattice. Terms
can also be summed lattice-free (`OpTerm + OpTerm -> OpSum`, `OpTerm + OpSum`,
`OpSum + OpSum`), in which case `ds` is inferred from the operators (sites without
operators default to the first term's dimension). A sum can be multiplied by a number
(`x * sum`, `sum * x`) and evaluated at a real time (`sum(t)` freezes every
coefficient at `t`).


源码：[src/mpscore/operators/opsum.jl:119](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/opsum.jl#L119)



<a id="api-Coeff"></a>

## `Coeff`


	Coeff(x)
	Coeff(f)

A scalar coefficient of an `OpTerm`: a plain number `x`, or a time-dependent
function `f` mapping a real time to a number (a bare function is wrapped as `Coeff(f)`).
`(c::Coeff)(t::Real)` evaluates the coefficient at the real time `t` (a constant
ignores `t`), `isconstant` says whether it is time-independent, and
`scalartype(c)` probes the produced number type (a function coefficient is probed at
`t = 0.0`). Multiplying a coefficient by a number scales it pointwise.
Time-dependent coefficients are only supported by `trotter_propagator`.


源码：[src/mpscore/operators/opsum.jl:4](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/opsum.jl#L4)



<a id="api-isconstant"></a>

## `isconstant`


	isconstant(term)
	isconstant(sum)

Whether the coefficient(s) of an `OpTerm` / `OpSum` are
time-independent. Time-dependent terms are only supported by
`trotter_propagator`; every other consumer requires `isconstant == true`.


源码：[src/mpscore/operators/opsum.jl:150](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/opsum.jl#L150)



<a id="api-term"></a>

## `term`


	term(coeff, i₁ => O₁, ...)
	term(i₁ => O₁, ...)

Convenience constructor of `OpTerm` (coefficient defaults to 1).


源码：[src/mpscore/operators/opsum.jl:110](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/opsum.jl#L110)



<a id="api-tompotensor"></a>

## `tompotensor`


	tompotensor(W::SchurMPOTensor) -> Array{T,4}

Densify into the package's 4-index MPO tensor `(wl, u, wr, d)`: the identity
channels live at level `1` and level `space_r`, i.e.
`Wd[1,:,1,:] = Wd[end,:,end,:] = I`.


源码：[src/mpscore/operators/schurmpotensor.jl:167](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/schurmpotensor.jl#L167)



<a id="api-tompotensors"></a>

## `tompotensors`


	tompotensors(h::MPOHamiltonian)

Convert an `MPOHamiltonian` to the list of dense 4-index site tensors of a finite
`MPO`: the vacuum row (channel 1) is kept at the first site, the closing column
(last channel) at the last site.


源码：[src/mpscore/operators/mpohamiltonian.jl:78](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/mpohamiltonian.jl#L78)



<a id="api-todense"></a>

## `todense`


	todense(h::AbstractMPO; order=:msb) -> Matrix

Dense matrix of the operator chain. Per site the physical pair is ordered `(p_out,
p_in)`; the `order` keyword selects the endianness of the merged row/column indices:

- `order = :msb` — **big-endian / Kronecker order** (default): site 1 is the most
  significant (slowest) index on both the bra and the ket side, i.e. the matrix reads
  like the `kron` product of the local `(p_out, p_in)` factors site by site — the
  convention of most quantum-information texts.
- `order = :lsb` — **little-endian / column-major flattening**: site 1 is the least
  significant (fastest) index on both sides, the natural reading of
  `vec(reshape(M, ds, ds))` in Julia's column-major memory layout.

The `scaling` of a `CanonicalMPO` is included as `scaling(h)^L`, applied **per site
during the contraction** (no `scaling^L` power is materialized).


源码：[src/mpscore/operators/linalg.jl:302](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/linalg.jl#L302)


	todense(h::MPOHamiltonian) -> Matrix

Dense matrix of the Hamiltonian MPO: the block-sparse chain is expanded with
`tompotensors` and contracted; see `todense(::AbstractMPO)` for the index
convention.


源码：[src/mpscore/operators/linalg.jl:407](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/linalg.jl#L407)


	todense(ψ::CanonicalMPS; order=:msb) -> Vector

Dense state vector of the MPS. The `order` keyword selects the endianness of the merged
physical index:

- `order = :msb` — **big-endian / Kronecker order** (default): site 1 is the most
  significant (slowest) index and site `L` the fastest, i.e. the vector reads like
  `ψ = v₁ ⊗ v₂ ⊗ ⋯ ⊗ v_L`, the Kronecker convention of `kron`-ing the local basis
  vectors site by site (the convention of most quantum-information texts).
- `order = :lsb` — **little-endian / column-major flattening**: site 1 is the least
  significant (fastest) index — the natural reading of `vec(reshape(v, ds...))` in
  Julia's column-major memory layout, which is also what a left-to-right TT-SVD
  sweep produces natively.

The chain `scaling` is included as `scaling(ψ)^L`, applied **per site during the
contraction** (no `scaling^L` power is materialized); the Schmidt vectors are not used
(the site tensors carry the full state).


源码：[src/mpscore/states/observables.jl:43](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/observables.jl#L43)



<a id="api-vectorize"></a>

## `vectorize`


	vectorize(ρ::AbstractMPO) -> CanonicalMPS

The vectorized state of the operator chain `ρ`: every site tensor `W[aL, p_out, aR,
p_in]` becomes `A[aL, (p_out, p_in), aR]` with the physical legs merged column major
(`p_out` the fastest), so the operator is represented as a state on a chain of the same
length with per-site physical dimension `d_out·d_in`. Bond dimensions and the `scaling`
of a `CanonicalMPO` are carried over; the Schmidt values are reset.


源码：[src/mpscore/operators/vectorize.jl:13](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/vectorize.jl#L13)



<a id="api-devectorize"></a>

## `devectorize`


	devectorize(ψ::AbstractMPS) -> CanonicalMPO

The inverse of `vectorize`: every site tensor `A[aL, m, aR]` is split back into
`W[aL, p_out, aR, p_in]` (the physical dimension must be a perfect square with matching
output/input dimensions). Bond dimensions and the `scaling` of a `CanonicalMPS` are
carried over; the Schmidt values are reset.


源码：[src/mpscore/operators/vectorize.jl:38](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/vectorize.jl#L38)



<a id="api-superoperator"></a>

## `superoperator`


	superoperator(a::AbstractMPO, b::AbstractMPO) -> MPO

The fused-space Kronecker product of two operator chains of equal length: site `i` of
the result carries the local Kronecker product of the site operators on the fused
physical space — from the site tensors `A[aL, po, aR, pin]` and `B[bL, q, bR, qin]` the
result tensor is

	S[(aL,bL), (po,q), (aR,bR), (pin,qin)] = A[aL, po, aR, pin] · B[bL, q, bR, qin]

(the legs of `a` are the fastest on every fused index, matching the `vectorize`
convention); the bond dimensions multiply. Acting on `vectorize(X)` this is the
superoperator of the two-sided map `X ↦ a·X·transpose(b)`; the one-sided multiplication
superoperators are the special cases

	superoperator(h, :left)  == superoperator(h, identity chain of `iphydims(h)`)
	superoperator(h, :right) == superoperator(identity chain of `ophydims(h)`, transpose(h))

(`Base.kron` orders its first dense factor slowest, i.e. with the roles swapped, so this
is deliberately not a `Base.kron` overload.) The `scaling` of `CanonicalMPO` inputs is
NOT folded (data-level convention).


源码：[src/mpscore/operators/vectorize.jl:75](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/vectorize.jl#L75)


	superoperator(h::MPO, side=:left) -> MPO
	superoperator(h::MPOHamiltonian, side=:left) -> MPO
	superoperator(h::CanonicalMPO, side=:left) -> CanonicalMPO

The superoperator induced by left/right multiplication with `h`: the map `X ↦ h·X`
(`side = :left`) or `X ↦ X·h` (`side = :right`) on the vectorized space, built from the
fused-space Kronecker product with the identity chain,

	superoperator(h, :left)  = superoperator(h, I)            # h acts on the output (po) legs
	superoperator(h, :right) = superoperator(I, transpose(h)) # hᵀ acts on the input (pi) legs

so the result is a chain on the doubled physical space (per-site dimension `d_out·d_in`)
with the same bond dimensions as `h`. Applying it to `vectorize(X)` and
devectorizing the result gives the operator product (up to the compression of the
chosen evaluation route). The represented superoperator is linear in the represented
`h`: a `CanonicalMPO` input carries its `scaling` into the result's `scaling` field,
while plain `MPO` / `MPOHamiltonian` inputs have no external scale. The `side` may also
be given as the keyword `side = :left`.


源码：[src/mpscore/operators/vectorize.jl:113](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/vectorize.jl#L113)



<a id="api-ExpDecayOpTerm"></a>

## `ExpDecayOpTerm`


	ExpDecayOpTerm(a, m, b, α, λ)
	ExpDecayOpTerm(a, b, α, λ)

An exponentially decaying long-range operator term
`O = α Σ_{i<j} λ^(j-i) · a_i m_(i+1) ⋯ m_(j-1) b_j` (see the module docstring). `a`,
`m`, `b` are `d×d` matrices, `λ` the decay factor per lattice spacing and `α` the
overall strength. The 4-argument form takes the propagator `m` to be the identity.
Converts directly to a `SchurMPOTensor`.


源码：[src/mpscore/operators/longrangeop.jl:33](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/longrangeop.jl#L33)



<a id="api-ExpDecayOpSum"></a>

## `ExpDecayOpSum`


	ExpDecayOpSum(a, m, b, αs, λs)
	ExpDecayOpSum(a, b, αs, λs)

The sum of the exponentially decaying terms `ExpDecayOpTerm(a, m, b, αs[k], λs[k])` over all parameter pairs (αs[k], λs[k]). The 4-argument form takes the
propagator `m` to be the identity. Converts directly to a
`SchurMPOTensor` with one internal channel per pair.


源码：[src/mpscore/operators/longrangeop.jl:72](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/longrangeop.jl#L72)



<a id="api-PairOpTerm"></a>

## `PairOpTerm`


	PairOpTerm(a, m, b, C)
	PairOpTerm(a, b, C)

A pair-coupled long-range operator term with an **arbitrary** coupling matrix (see the
module docstring): `O = Σ_{i<j} C[i,j] · a_i m_(i+1) ⋯ m_(j-1) b_j`. `a`, `m`, `b` are
`d×d` matrices and `C` a strictly upper triangular `L×L` coupling matrix — power-law,
random, any distance dependence. The 4-argument form takes the propagator `m` to be the
identity; with a Jordan-Wigner string as `m` the term represents fermionic `a_i† a_j`-type
couplings exactly. On-site terms are not tied to `C`: pass them through the `hloc`
argument of `SchurMPOTensor` / `MPOHamiltonian` (uniform or per-site).
Converts to per-site `SchurMPOTensor`s in the finite-state-machine layout (one
channel per coupled starting site, bond dimension `L + 1`).


源码：[src/mpscore/operators/longrangeop.jl:181](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/longrangeop.jl#L181)



<a id="api-isleftcanonical"></a>

## `isleftcanonical`

```julia
isleftcanonical(A::Union{MPSTensor,MPOTensor}; atol=1e-12) -> Bool
```

收缩左键及物理轴，检查剩余右键上是否为单位矩阵；MPO 把输出/输入物理轴一起融合。查询不修改张量。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
function isleftcanonical(A::MPSTensor; atol::Real=1e-12)
function isleftcanonical(W::MPOTensor; atol::Real=1e-12)
isleftcanonical(h::AbstractMPO; atol::Real=1e-12) = all(isleftcanonical(h[i]; atol) for i in eachindex(h))
```



<a id="api-isrightcanonical"></a>

## `isrightcanonical`

```julia
isrightcanonical(A::Union{MPSTensor,MPOTensor}; atol=1e-12) -> Bool
```

收缩右键及物理轴，检查剩余左键上是否为单位矩阵。链级重载检查正则链的数据张量；不修改输入。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
function isrightcanonical(A::MPSTensor; atol::Real=1e-12)
function isrightcanonical(W::MPOTensor; atol::Real=1e-12)
isrightcanonical(h::AbstractMPO; atol::Real=1e-12) = all(isrightcanonical(h[i]; atol) for i in eachindex(h))
```



<a id="api-iscanonical"></a>

## `iscanonical`


	iscanonical(ψ::CanonicalMPS; atol=1e-8)

Whether `ψ` is in canonical form: all site tensors right-orthogonal, all Schmidt values
initialized, and on every bond `Diagonal(s.^2) ≈` the left environment.


源码：[src/mpscore/states/orth.jl:266](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L266)



<a id="api-canonicalize-mutating"></a>

## `canonicalize!`


	canonicalize!(ψ::CanonicalMPS; alg::Orthogonalize=Orthogonalize(SVD(), Defaults.alg_orth_trunc(), false))
	-> (ψ, err)

Transform `ψ` into canonical form (in place): one QR left-orthogonalization sweep (without
truncation) followed by a right-orthogonalization sweep with `alg` (truncating when `alg.trunc`
says so). After the call `ψ` is right-canonical with all Schmidt values initialized. Returns
`ψ` and the maximal truncation error of the right sweep.


源码：[src/mpscore/states/orth.jl:117](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L117)


	canonicalize!(ρ::CanonicalMPO; alg::Orthogonalize=Orthogonalize(SVD(), Defaults.alg_orth_trunc(), false))
	-> (ρ, err)

Transform the density-matrix chain into canonical form (in place): QR left sweep + `alg`
right sweep. Returns `ρ` and the maximal truncation error of the right sweep.


源码：[src/mpscore/states/orth.jl:239](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L239)



<a id="api-canonicalize"></a>

## `canonicalize`


	apply!(g::AbstractGate, ψ::CanonicalMPS; trunc=Defaults.alg_trunc(),
	       canonicalize=!g.isunitary) -> ψ

Apply the gate `g` (acting on `N ≥ 1` distinct sites) to `ψ` in place, with the
Hastings update (aligned with TEMPO/GTEMPO; the multi-site block sweep after
MPSSimulator). The gate sites may be any distinct set of positions: non-adjacent
supports are first gathered into a contiguous block with exact content swaps
(`swap!`), the gate is applied on the block bond by bond, and the gathering
swaps are undone. Initializes the canonical form if needed.

**Mathematics of the Hastings update.** In the right-canonical gauge the left
environment at the current bond `b` is `diag(ψ.s[b]²)`. With the unweighted post-gate
block tensor `t` and the bond spectrum `Λ`, the wavefunction block in the left Schmidt
basis is the *folded* tensor `W = diag(Λ) · t`. Decompose it,

	W = u · diag(σ) · v,		u'·u = I,	v·v' = I,

(with truncation, `σ` keeps the leading singular values and `err` is the discarded
weight), and assign — moving left to right through the block —

	ψ[b] = t · v†,		ψ.s[b+1] = σ,		t ← v.

Three properties make this exact up to the discarded weights, without ever inverting a
spectrum:

* *state*: the block `t` is reproduced, because `v†·v` is the projector onto the row
  space of `W`, and the rows of `t` lie in it;
* *gauge*: for unitary gates the back-projected left factor `t · v†` is
  right-orthogonal — `t†·t = I`, since `t` contracts right-canonical factors and the
  gate drops out (`G†·G = I`);
* *spectrum*: the new left environment after the bond is
  `v · (t† · diag(Λ²) · t) · v† = v · (W†·W) · v† = diag(σ²)`.

If the input is right-canonical and the truncation error is small, the right-canonical
form is preserved without any `canonicalize!`. The fold–SVD–back-project step is the
two-site application trick introduced for the light-cone TEBD by M. Hastings, "Light
cone Matrix Product", *J. Math. Phys.* **50**, 095207 (2009) (aligned with
TEMPO/GTEMPO); its advantage is that both sides of every bond are updated from a
*single* decomposition while keeping the gauge and the local spectrum consistent.
**Caveat:** the exact preservation of the strict canonical form relies on the
truncated SVD being exact for the state at hand — for aggressive truncations the
*gauge* property degrades and the canonical form is only approximate. A non-unitary
gate breaks the *gauge* property outright, so `canonicalize` defaults to
`!g.isunitary`: the state is re-canonicalized with `truncate!` (an SVD sweep
under `trunc`) after every non-unitary gate.


源码：[src/mpscore/gates.jl:176](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L176)


	canonicalize(ψ::CanonicalMPS; kwargs...) -> (ψ′, err)

Non-mutating version of `canonicalize!`: returns the canonicalized copy and the
maximal truncation error.


源码：[src/mpscore/states/orth.jl:129](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/orth.jl#L129)



<a id="api-space-l"></a>

## `space_l`

```julia
space_l(A::Union{MPSTensor,MPOTensor}) -> Int
space_l(chain::Union{AbstractMPS,AbstractMPO}) -> Int
```

张量为第 1 轴大小；链为第一个站点的左边界维数。不修改数据。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
space_l(x::PositiveMPA) = size(x[1], 1)
space_l(A::MPSTensor) = size(A, 1)
space_l(W::MPOTensor) = size(W, 1)
space_l(ψ::Union{AbstractMPS,AbstractMPO}) = space_l(ψ[1])
space_l(W::SchurMPOTensor) = size(W.A, 1) + 2
```



<a id="api-space-r"></a>

## `space_r`

```julia
space_r(A::Union{MPSTensor,MPOTensor}) -> Int
space_r(chain::Union{AbstractMPS,AbstractMPO}) -> Int
```

张量为第 3 轴大小；链为最后站点的右边界维数。不修改数据。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
space_r(x::PositiveMPA) = size(x[length(x)], 3)
space_r(A::MPSTensor) = size(A, 3)
space_r(W::MPOTensor) = size(W, 3)
space_r(ψ::Union{AbstractMPS,AbstractMPO}) = space_r(ψ[end])
space_r(W::SchurMPOTensor) = size(W.A, 3) + 2
```



<a id="api-phydim"></a>

## `phydim`


    phydim(W::MPOTensor)

The physical dimension of an `MPOTensor`; for a square operator this is the common value of
the output (`ophydim`) and input (`iphydim`) dimensions, otherwise a `DimensionMismatch` is thrown.


源码：[src/mpscore/abstractdefs.jl:52](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/abstractdefs.jl#L52)



<a id="api-ophydim"></a>

## `ophydim`

```julia
ophydim(W::MPOTensor) -> Int
```

MPO 张量的第 2 轴：局域算符输出物理维数。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
ophydim(W::MPOTensor) = size(W, 2)                 # output physical dimension
ophydim(W::SchurMPOTensor) = size(W.A, 2)
```



<a id="api-iphydim"></a>

## `iphydim`

```julia
iphydim(W::MPOTensor) -> Int
```

MPO 张量的第 4 轴：局域算符输入物理维数。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
iphydim(W::MPOTensor) = size(W, 4)                 # input physical dimension
iphydim(W::SchurMPOTensor) = size(W.A, 4)
```



<a id="api-phydims"></a>

## `phydims`

```julia
phydims(psi::AbstractMPS) -> Vector{Int}
```

返回每个 MPS 站点的物理维数，长度为链长；不修改输入。MPO 分别用 `ophydims` 与 `iphydims`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
phydims(ψ::AbstractMPS) = [phydim(ψ[i]) for i in eachindex(ψ)]
phydims(x::OpSum) = x.ds
```



<a id="api-ophydims"></a>

## `ophydims`

```julia
ophydims(h::AbstractMPO) -> Vector{Int}
```

依站点顺序返回各 MPO 输出物理维数，长度为链长，不修改输入。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
ophydims(h::AbstractMPO) = [ophydim(h[i]) for i in eachindex(h)]
```



<a id="api-iphydims"></a>

## `iphydims`

```julia
iphydims(h::AbstractMPO) -> Vector{Int}
```

依站点顺序返回各 MPO 输入物理维数，长度为链长，不修改输入。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
iphydims(h::AbstractMPO) = [iphydim(h[i]) for i in eachindex(h)]
```



<a id="api-bonddim"></a>

## `bonddim`


    bonddim(ψ, b)
    bonddims(ψ)
    bonddim(ψ)

Bond dimension at bond `b` (bond `b` lies between site `b` and `b+1`), the vector of all bond
dimensions, and the maximal bond dimension.


源码：[src/mpscore/abstractdefs.jl:88](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/abstractdefs.jl#L88)



<a id="api-bonddims"></a>

## `bonddims`


    bonddim(ψ, b)
    bonddims(ψ)
    bonddim(ψ)

Bond dimension at bond `b` (bond `b` lies between site `b` and `b+1`), the vector of all bond
dimensions, and the maximal bond dimension.


源码：[src/mpscore/abstractdefs.jl:88](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/abstractdefs.jl#L88)



<a id="api-scaling"></a>

## `scaling`

```julia
scaling(x::Union{CanonicalMPS,CanonicalMPO}) -> Real
```

返回每站点外部尺度，完整网络带 `scaling(x)^length(x)`。不修改输入。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
scaling(x::Union{CanonicalMPS,CanonicalMPO}) = x.scaling[]
```



<a id="api-setscaling-mutating"></a>

## `setscaling!`

```julia
setscaling!(x::Union{CanonicalMPS,CanonicalMPO}, factor::Real)
```

原地修改正则链每站点的外部尺度；整个网络的尺度因子是 `scaling(x)^length(x)`，不是单个 `factor`。不修改站点数据以抵消变化；普通 MPO 没有该缩放字段。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
setscaling!(x::Union{CanonicalMPS,CanonicalMPO}, s::Real) = (x.scaling[] = s; x)
```



<a id="api-svectors-uninitialized"></a>

## `svectors_uninitialized`


    svectors_uninitialized(ψ) -> Bool

Whether any internal bond of `ψ` has uninitialized (`missing`) Schmidt values.


源码：[src/mpscore/states/canonicalmps.jl:70](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/canonicalmps.jl#L70)



<a id="api-unset-svectors-mutating"></a>

## `unset_svectors!`


    unset_svectors!(ψ)

Reset all internal Schmidt values to `missing` (boundary bonds keep their trivial `ones(1)`).


源码：[src/mpscore/states/canonicalmps.jl:77](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/canonicalmps.jl#L77)



<a id="api-normalize-tr-mutating"></a>

## `normalize_tr!`


    normalize_tr!(ρ::CanonicalMPO) -> ρ

Normalize the density-matrix chain to unit trace **without touching the site tensors**:
the trace deficit is folded into the `scaling` field (the represented state
`scaling^L · (data contraction)` is rescaled to unit trace by rescaling `scaling`).


源码：[src/mpscore/states/canonicalmpo.jl:74](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/canonicalmpo.jl#L74)



<a id="api-expectation"></a>

## `expectation`


	expectation(pt::PauliTerm, camp::CAMPS) -> ComplexF64

Expectation value `⟨ψ|pt|ψ⟩` of a Pauli string on the physical state represented by a
`CAMPS`. The ket stored in a CAMPS lives in the Clifford-rotated picture
(`|ket⟩ = U|ψ⟩`), so the Pauli string is conjugated **through the recorded circuits** —
`U† P U` up to phase, computed gate by gate: a Clifford maps a two-qubit Pauli string
back to a single Pauli string with a phase, so each gate only touches the two sites it
acts on (a 4×4 conjugation plus a Pauli decomposition). The conjugated string is then
contracted with the MPS directly; no circuit is ever applied to the state itself.


源码：[src/mpsalgorithms/algorithms/experimental/cadmrg.jl:434](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpsalgorithms/algorithms/experimental/cadmrg.jl#L434)


	expectation(ψA::CanonicalMPS, h::AbstractMPO, ψB::CanonicalMPS) -> Number

The matrix element `⟨ψA|h|ψB⟩` of the represented chains (no normalization; use
`expectationvalue` for the normalized value).

!!! warning "debug tool"
	The result includes the external scale, i.e. factors `scaling^L` per chain side.
	These powers overflow for large scalings or long chains, so `expectation` is meant
	for debugging on small systems; use `expectationvalue` instead.


源码：[src/mpscore/expectation.jl:11](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/expectation.jl#L11)


	expectation(h::AbstractMPO, ψ::CanonicalMPS) -> Number
	expectation(h::AbstractMPO, ρ::CanonicalMPO) -> Number

The (unnormalized) expectation value of the represented chains: `⟨ψ|h|ψ⟩` or `tr(h·ρ)`
(the mixed case via the crossed physical-index contraction).

!!! warning "debug tool"
	The result includes the external scale (`scaling^L` powers), which may overflow for
	large scalings or long chains. `expectation` is meant for debugging on small
	systems; use `expectationvalue` instead.


源码：[src/mpscore/expectation.jl:38](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/expectation.jl#L38)


	expectation(op::OpTerm, ψ::CanonicalMPS) -> Number

The matrix element `⟨ψ|op|ψ⟩` (unnormalized; see `expectationvalue`). Exploits the
mixed canonical form of `ψ`: on both sides of the term's support the environments collapse
(identity on the right, `Diagonal(s²)` on the left), so only the support sites are
contracted (sites in between the term's operators pass the environment through unchanged).

!!! warning "debug tool"
	The result includes the external scale (`scaling^2L`), which may overflow for large
	scalings or long chains. `expectation` is meant for debugging on small systems; use
	`expectationvalue` instead.


源码：[src/mpscore/expectation.jl:67](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/expectation.jl#L67)


	expectation(op::OpTerm, ρ::CanonicalMPO) -> Number
	expectation(op::OpTerm, ρ::CanonicalMPO, cache::TraceCache) -> Number

The (unnormalized) expectation value in the mixed state `ρ`: `tr(op·ρ)` including
`scaling`, contracted through the crossed physical indices. Sites outside the term's
support only propagate the `ρ` transfer (physical trace). Passing a `TraceCache`
reuses the pre-computed trace environments of `ρ` across many observables.

!!! warning "debug tool"
	The result includes the external scale (`scaling^L`), which may overflow for large
	scalings or long chains. `expectation` is meant for debugging on small systems; use
	`expectationvalue` instead.


源码：[src/mpscore/expectation.jl:182](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/expectation.jl#L182)



<a id="api-expectationvalue"></a>

## `expectationvalue`


	expectationvalue(h::AbstractMPO, ψ::CanonicalMPS) -> Number
	expectationvalue(h::AbstractMPO, ρ::CanonicalMPO) -> Number
	expectationvalue(op::OpTerm, ψ::CanonicalMPS) -> Number
	expectationvalue(op::OpTerm, ρ::CanonicalMPO, [cache::TraceCache]) -> Number

The normalized expectation value: `⟨ψ|h|ψ⟩ / ⟨ψ|ψ⟩` (pure states), `tr(h·ρ) / tr(ρ)`
(mixed states), or the corresponding term ratios. Computed from raw (scale-free)
transfer contractions: the external `scaling` factors of the chains `ψ` / `ρ` appear
with the same power in numerator and denominator and cancel exactly, so
`expectationvalue` is stable even when the represented `scaling^L` powers would
overflow (unlike `expectation`); the `scaling^L` of a `CanonicalMPO` operator
`h` is part of the represented value `h` and is kept.


源码：[src/mpscore/expectation.jl:215](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/expectation.jl#L215)



<a id="api-entanglement-entropy"></a>

## `entanglement_entropy`


	entanglement_entropy(x::Union{CanonicalMPS,CanonicalMPO}; bond=div(length(x), 2), α=1)

Rényi entropy `α` of the Schmidt spectrum at `bond` (`α = 1` gives the von Neumann entropy).
Requires the canonical form (initialized Schmidt values).


源码：[src/mpscore/states/observables.jl:13](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/observables.jl#L13)



<a id="api-entanglement-spectrum"></a>

## `entanglement_spectrum`


	entanglement_spectrum(x::Union{CanonicalMPS,CanonicalMPO}; bond=div(length(x), 2))

The Schmidt spectrum (squared Schmidt values) at `bond`.


源码：[src/mpscore/states/observables.jl:24](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/observables.jl#L24)



<a id="api-schmidt-values"></a>

## `schmidt_values`


	schmidt_values(x::Union{CanonicalMPS,CanonicalMPO}; bond=div(length(x), 2))

The Schmidt values at `bond` (equivalent to `x.s[bond+1]`).


源码：[src/mpscore/states/observables.jl:34](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/observables.jl#L34)



<a id="api-prodmps"></a>

## `prodmps`


	prodmps(::Type{T}, ds, states) -> CanonicalMPS
	prodmps(::Type{T}, vectors) -> CanonicalMPS

Product states: one-hot basis states (`states[i]` is the occupied basis index of site `i`),
or general product states from per-site amplitude vectors.


源码：[src/mpscore/states/initializers.jl:23](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L23)



<a id="api-randommps"></a>

## `randommps`


	randommps(::Type{T}, ds; D=Defaults.D, normalize=true) -> CanonicalMPS

Random MPS with bond-dimension profile `max_bonddims(ds, D)`, brought to canonical
form (right-canonical with initialized Schmidt values). With `normalize = true` the
state is normalized (total norm 1); otherwise the data keeps its natural magnitude and
the external scale stays in the `scaling` field.


源码：[src/mpscore/states/initializers.jl:45](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L45)



<a id="api-DensityOperator"></a>

## `DensityOperator`


	DensityOperator(ψ::CanonicalMPS) -> CanonicalMPO

The pure-state density matrix `ρ = |ψ⟩⟨ψ|` in operator (MPO) form: site tensors are the
per-site tensor products `ψᵢ ⊗ conj(ψᵢ)` with fused bond indices (bond dimensions squared).


源码：[src/mpscore/states/initializers.jl:96](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L96)



<a id="api-infinite-temperature-state"></a>

## `infinite_temperature_state`


	infinite_temperature_state(::Type{T}, ds) -> CanonicalMPO

The infinite-temperature state `I/prod(ds)` as a `CanonicalMPO` (`tr(ρ) = 1`).


源码：[src/mpscore/states/initializers.jl:115](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L115)



<a id="api-changebond-mutating"></a>

## `changebond!`


	changebond!(h::CanonicalMPO; D=Defaults.D, noise=1e-10) -> h

Bring the bond profile of `h` to `min(D, feasible)`: bonds larger than their target are
shrunk by slicing the leading bond indices (the first rows/columns of the bond space;
singular values are ignored), smaller bonds are grown with random entries of magnitude
`noise` (a small perturbation of the represented operator). The Schmidt values do not
survive the resize.

As for the MPS variant, the resize breaks the canonical gauge (the padded blocks are not
isometries), so the function ends with an exact right re-orthogonalization (`rightorth!`
with `NoTruncation`) and returns the chain in **right-canonical form**: every site but the
first is right-isometric and all internal Schmidt values are initialized, the overall norm
being carried by `scaling`. This is the gauge the sweeps expect from an initial guess.
Used to prepare initial guesses of the ALS operator products.


源码：[src/mpscore/operators/initializers.jl:39](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/initializers.jl#L39)


	changebond!(ψ::CanonicalMPS; D=Defaults.D, noise=1e-10) -> ψ

Bring the bond profile of `ψ` to `min(D, feasible)`: every bond larger than its target
is shrunk by slicing the leading bond indices (the first rows/columns of the bond space;
singular values are ignored), smaller bonds are grown with random entries of magnitude
`noise` (a small perturbation of the represented state). The Schmidt values do not
survive the resize.

The padded blocks of the resized site tensors are not isometries, so the resize breaks the
canonical gauge; the function ends with an exact right re-orthogonalization (`rightorth!`
with `NoTruncation`) and returns the chain in **right-canonical form**, with the
orthogonality center at site 1: every site but the first is right-isometric and all
internal Schmidt values are initialized, the overall norm being carried by `scaling` (the
first site cannot be made right-isometric in this convention). This is the gauge the
iterative algorithms (`DMRG1`, `TDVP1`, ...) expect from an initial guess. Used to prepare
initial guesses with bond headroom.


源码：[src/mpscore/states/initializers.jl:126](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L126)



<a id="api-identitympo"></a>

## `identitympo`


	identitympo(::Type{T}, ds) -> MPO

The identity operator chain with bond dimension 1 (equivalent to `MPO(T, ds)`).


源码：[src/mpscore/operators/initializers.jl:3](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/initializers.jl#L3)



<a id="api-prodmpo"></a>

## `prodmpo`


	prodmpo(::Type{T}, ds, positions, ops) -> MPO
	prodmpo(::Type{T}, ds, position, op) -> MPO

A bond-dimension-1 product chain for one operator term: `ops[i]` acts on `positions[i]`
(ascending, possibly with gaps — gap sites carry the identity), all other sites carry the
identity. Use the exact `+`/`*` on `MPO` to assemble general Hamiltonians.


源码：[src/mpscore/operators/initializers.jl:10](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/initializers.jl#L10)



<a id="api-randommpo"></a>

## `randommpo`


	randommpo(::Type{T}, ds; D=Defaults.D, normalize=true) -> CanonicalMPO

Random canonical MPO-form state (bond-dimension profile from the operator-chain
bound `b[i] = min(D, ∏_{j≤i} ds[j]², ∏_{j>i} ds[j]²)` — the chain carries an in and an
out physical leg per site, so the bond space grows by `ds²` per site, capped by `D` and
by the state-space bounds from both chain ends), brought to canonical form. With
`normalize = true` the state is normalized; otherwise the external scale stays in the
`scaling` field.


源码：[src/mpscore/states/initializers.jl:70](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/initializers.jl#L70)



<a id="api-hadamard-op"></a>

## `⊙`


	⊙(ψA::CanonicalMPS, ψB::CanonicalMPS) -> CanonicalMPS

Exact (strict) element-wise (Hadamard) product of two MPS: the amplitudes of the result
are the pointwise product `χ(i₁,…,i_L) = ψA(i₁,…,i_L)·ψB(i₁,…,i_L)`. The physical index is
shared and the bond indices are fused pairwise, so the bond dimensions multiply
(`D_χ = D_ψA·D_ψB`); no truncation or re-canonicalization is performed. The per-site
`scaling` of the result is `scaling(ψA)·scaling(ψB)`.

The compressed (finite-bond) approximation is obtained via `hadamard`.


源码：[src/mpscore/states/linalg.jl:107](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/linalg.jl#L107)



<a id="api-copyphydims"></a>

## `copyphydims`


	copyphydims(ψ::CanonicalMPS) -> CanonicalMPO

Reinterpret the MPS `ψ` as an operator chain on the same bond dimension: every site
tensor `A[aL, p, aR]` becomes the physical-space diagonal `W[aL, po, aR, pi] =
A[aL, po, aR]·δ_{po,pi}`, i.e. the physical dimensions are copied to both the bra and
the ket side. Applying the result to another MPS with the same bond structure
reproduces the element-wise (Hadamard) product, `copyphydims(ψA) * ψB == ⊙(ψA, ψB)`.
The `scaling` of `ψ` is carried over. The MPS Schmidt values do not satisfy the MPO
canonical conditions, so the Schmidt values of the result are uninitialized (as for
any freshly constructed chain).


源码：[src/mpscore/states/linalg.jl:193](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/linalg.jl#L193)



<a id="api-tomps"></a>

## `tomps`


	tomps(v, phydims; order=:msb, trunc=Defaults.alg_orth_trunc()) -> CanonicalMPS

Tensor-train (MPS) representation of the dense state vector `v` on the physical
dimensions `phydims`. The `order` keyword selects the endianness of the merged
physical index, matching `todense`:

- `order = :msb` — **big-endian / Kronecker order** (default): site 1 is the most
  significant (slowest) index, i.e. the vector reads like the `kron` product of the
  local basis amplitudes site by site.
- `order = :lsb` — **little-endian / column-major flattening**: site 1 is the least
  significant (fastest) index, the natural reading of `vec(reshape(v, ds...))` in
  Julia's column-major memory layout.

The chain is built from consecutive right-to-left SVDs (right-canonical form, the
center on the first site; the bond spectra are recorded), truncated with
`trunc::TruncationScheme` (`Defaults.alg_orth_trunc()` by default); with a bond-cap scheme
the result is exact whenever every intermediate rank stays within the cap. Any
external norm of `v` is folded into the chain `scaling`.


源码：[src/mpscore/states/observables.jl:82](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/states/observables.jl#L82)



<a id="api-tompo"></a>

## `tompo`


	tompo(M, phydims; order=:msb, trunc=Defaults.alg_orth_trunc()) -> CanonicalMPO

MPO representation of the dense operator matrix `M` on the physical dimensions
`phydims` — the inverse of `todense(::AbstractMPO)`. The `order` keyword
selects the endianness of the merged row/column indices, matching
`todense(::AbstractMPO)`:

- `order = :msb` — **big-endian / Kronecker order** (default): site 1 is the most
  significant (slowest) index on both the bra and the ket side.
- `order = :lsb` — **little-endian / column-major flattening**: site 1 is the least
  significant (fastest) index on both sides.

The chain is built from consecutive two-site SVDs on the interleaved (bra, ket) index
pairs (right-canonical form, the center on the first site; the bond spectra are
recorded), truncated with `trunc::TruncationScheme` (`Defaults.alg_orth_trunc()` by
default); with a bond-cap scheme the result is exact whenever every intermediate rank
stays within the cap. Any external scale of `M` is folded into the chain `scaling`.


源码：[src/mpscore/operators/linalg.jl:339](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/operators/linalg.jl#L339)



<a id="api-AbstractGate"></a>

## `AbstractGate`


	AbstractGate{N,T}

Abstract supertype of quantum gates acting on `N` sites: `positions(g)::NTuple{N,Int}`
(ascending), `g.op::Array{T,M}` — the rank-`M = 2N` operator tensor in the index
convention `(i1', i2', …, iN', i1, …, iN)`, i.e. all bra (output) indices first and all
ket (input) indices second, each block ordered with site 1 the slowest index.


源码：[src/mpscore/gates.jl:6](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L6)


实际声明（类型参数与关键字默认值以源码为准）：

```julia
abstract type AbstractGate{N, T} end
```



<a id="api-Gate"></a>

## `Gate`


	Gate(positions, op; isunitary=nothing, atol=1e-10)
	Gate(positions, op::AbstractMatrix, phydims; isunitary=nothing, atol=1e-10)

A quantum gate acting on the `N` distinct sites `positions`. The operator `op` is a
rank-`2N` tensor `(i1', …, iN', i1, …, iN)` — all bra (output) indices first, all
ket (input) indices second, each block ordered with `positions[1]` the slowest index.
The positions only have to be distinct: unsorted inputs are sorted internally (the
operator legs follow along). The input is copied and materialized as a dense array of
concrete element type.

The second form takes the usual operator matrix `op` with rows = bra and columns = ket
(Kronecker convention, `positions[1]` the slowest index) and reshapes it with the
local physical dimensions `phydims`: a vector of length `N` gives the dimensions of
the support sites in the order of `positions`, while a longer vector is the full
lattice dimensions indexed by position (`phydims[p]`), so `phydims(ψ)` can be passed
directly. A plain integer gives the same local dimension on every support site. The
matrix must be `D × D` with `D = prod(dims)`.

The gate carries an `isunitary::Bool` field: with the default `isunitary = nothing` it
is determined by checking `U†·U ≈ I` with `MatrixAlgebraKit.isunitary` (within `atol`)
on the fused operator matrix; a `Bool` is trusted as given. Since a non-unitary gate
does not preserve the canonical form under the Hastings update, `apply!`
re-canonicalizes the state with `truncate!` iff `!g.isunitary` (the `canonicalize`
keyword default).


源码：[src/mpscore/gates.jl:36](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L36)



<a id="api-apply-mutating"></a>

## `apply!`


	apply!(g::AbstractGate, ψ::CanonicalMPS; trunc=Defaults.alg_trunc(),
	       canonicalize=!g.isunitary) -> ψ

Apply the gate `g` (acting on `N ≥ 1` distinct sites) to `ψ` in place, with the
Hastings update (aligned with TEMPO/GTEMPO; the multi-site block sweep after
MPSSimulator). The gate sites may be any distinct set of positions: non-adjacent
supports are first gathered into a contiguous block with exact content swaps
(`swap!`), the gate is applied on the block bond by bond, and the gathering
swaps are undone. Initializes the canonical form if needed.

**Mathematics of the Hastings update.** In the right-canonical gauge the left
environment at the current bond `b` is `diag(ψ.s[b]²)`. With the unweighted post-gate
block tensor `t` and the bond spectrum `Λ`, the wavefunction block in the left Schmidt
basis is the *folded* tensor `W = diag(Λ) · t`. Decompose it,

	W = u · diag(σ) · v,		u'·u = I,	v·v' = I,

(with truncation, `σ` keeps the leading singular values and `err` is the discarded
weight), and assign — moving left to right through the block —

	ψ[b] = t · v†,		ψ.s[b+1] = σ,		t ← v.

Three properties make this exact up to the discarded weights, without ever inverting a
spectrum:

* *state*: the block `t` is reproduced, because `v†·v` is the projector onto the row
  space of `W`, and the rows of `t` lie in it;
* *gauge*: for unitary gates the back-projected left factor `t · v†` is
  right-orthogonal — `t†·t = I`, since `t` contracts right-canonical factors and the
  gate drops out (`G†·G = I`);
* *spectrum*: the new left environment after the bond is
  `v · (t† · diag(Λ²) · t) · v† = v · (W†·W) · v† = diag(σ²)`.

If the input is right-canonical and the truncation error is small, the right-canonical
form is preserved without any `canonicalize!`. The fold–SVD–back-project step is the
two-site application trick introduced for the light-cone TEBD by M. Hastings, "Light
cone Matrix Product", *J. Math. Phys.* **50**, 095207 (2009) (aligned with
TEMPO/GTEMPO); its advantage is that both sides of every bond are updated from a
*single* decomposition while keeping the gauge and the local spectrum consistent.
**Caveat:** the exact preservation of the strict canonical form relies on the
truncated SVD being exact for the state at hand — for aggressive truncations the
*gauge* property degrades and the canonical form is only approximate. A non-unitary
gate breaks the *gauge* property outright, so `canonicalize` defaults to
`!g.isunitary`: the state is re-canonicalized with `truncate!` (an SVD sweep
under `trunc`) after every non-unitary gate.


源码：[src/mpscore/gates.jl:176](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L176)


	apply!(gs, ψ::CanonicalMPS; kwargs...) -> ψ

Apply a sequence of gates (a circuit) in order — `apply!` gate by gate.


源码：[src/mpscore/gates.jl:254](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L254)



<a id="api-swap-mutating"></a>

## `swap!`


	swap!(ψ::CanonicalMPS, i::Integer; trunc=Defaults.alg_trunc()) -> ψ

Exchange the physical content of the neighboring sites `i` and `i+1` of `ψ` using the
Hastings SWAP gate (aligned with TEMPO/GTEMPO): the two-site block is formed with the
physical legs crossed, the Schmidt spectrum `psi.s[i]` on the left bond is contracted
into it, and the crossed block is re-decomposed with truncation. The right factor is
written directly to `psi[i+1]`, the renewed spectrum to `psi.s[i+1]`, and the left
site is recovered by back-projecting the crossed block. If the input is
right-canonical and the truncation error is small, the right-canonical form is
preserved without any `canonicalize!` (the SWAP gate is unitary). Sequences of
`swap!` (`permutation2swaps`) generate arbitrary permutations of the site contents.
Initializes the canonical form if needed.


源码：[src/mpscore/gates.jl:262](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L262)


	swap!(ρ::CanonicalMPO, i::Integer; trunc=Defaults.alg_trunc()) -> ρ

Exchange the physical content `(p_out, p_in)` of the neighboring sites `i` and `i+1`
of the operator chain `ρ` — the operator-space analog of the MPS `swap!`
(Hastings update, aligned with TEMPO/GTEMPO): the two-site block is formed with the
physical leg pairs crossed, the Schmidt spectrum `rho.s[i]` on the left bond is
contracted into it, and the crossed block is re-decomposed with truncation. The right
factor is written directly to `rho[i+1]`, the renewed spectrum to `rho.s[i+1]`, and
the left site is recovered by back-projecting the crossed block. If the input is
right-canonical and the truncation error is small, the right-canonical form is
preserved without any `canonicalize!`. Sequences of `swap!` (`permutation2swaps`)
generate arbitrary permutations of the site contents. Initializes the canonical form
if needed.


源码：[src/mpscore/gates.jl:296](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L296)



<a id="api-positions"></a>

## `positions`

```julia
positions(g::AbstractGate) -> NTuple{N,Int}
```

返回数值 Gate 的支持站点元组，构造器已按升序整理；比特位置从 1 开始。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
positions(g::AbstractGate) = g.positions
```



<a id="api-shift"></a>

## `shift`


	shift(g, by)

Shift all support positions of gate `g` by `by` sites.


源码：[src/mpscore/gates.jl:19](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/gates.jl#L19)



<a id="api-TraceCache"></a>

## `TraceCache`


	TraceCache(ρ::CanonicalMPO)

Pre-computed physical-trace environments of the density-matrix chain `ρ` (the crossed
transfer contractions with an identity on the physical legs, built from both chain
ends; stored as flat vectors, `left[k]` / `right[k]` being the environment at bond `k-1`,
to the left / right of site `k`; the per-site `scaling` of `ρ` is folded in site by
site — no `scaling^L` power is ever materialized). Passing a cache to
`expectation(op, ρ, cache)` / `expectationvalue(op, ρ, cache)` avoids rebuilding the
identity transfer for every observable of a fixed `ρ`. The cache keeps a reference to
`ρ`; the callers pass `ρ` again and it is checked with `===` against the cached one.


源码：[src/mpscore/expectation.jl:142](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpscore/expectation.jl#L142)
