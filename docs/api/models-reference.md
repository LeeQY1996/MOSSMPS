# Models 逐项 API 参考

[返回 API 目录](../api.md)

导入 `import MOSSQuantumMPS.MPSAlgorithms.Models as Models`。以下模型均为有限开放链，构造函数要求 `L ≥ 2`，不提供周期边界。

本页逐项列出公开符号。函数条目保留源码已有的完整签名与契约，补充未独立文档化的基础接口；签名中的类型均相对于当前子模块。源码链接可用于核对该方法的精确重载。


## 符号索引

| 符号 | 说明位置 |
|---|---|
| `σx` | [逐项参考](#api-σx) |
| `σy` | [逐项参考](#api-σy) |
| `σz` | [逐项参考](#api-σz) |
| `Sx` | [逐项参考](#api-Sx) |
| `Sy` | [逐项参考](#api-Sy) |
| `Sz` | [逐项参考](#api-Sz) |
| `heisenberg_hamiltonian` | [逐项参考](#api-heisenberg-hamiltonian) |
| `tfim_hamiltonian` | [逐项参考](#api-tfim-hamiltonian) |
| `fermi_hubbard` | [逐项参考](#api-fermi-hubbard) |


<a id="api-σx"></a>

## `σx`


	σx([T]), σy([T]), σz([T]) -> Matrix
	Sx([T]), Sy([T]), Sz([T]) -> Matrix

The Pauli matrices and the spin-1/2 operators (`S = σ/2`), as `2×2` matrices of element
type `T` (default `ComplexF64`). `σx`/`σz`/`Sx`/`Sz` keep `T`; `σy`/`Sy` are promoted to a
complex element type, since they are purely imaginary.


源码：[src/mpsalgorithms/models.jl:29](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpsalgorithms/models.jl#L29)



<a id="api-σy"></a>

## `σy`

```julia
σy(T=ComplexF64) -> Matrix
```

返回 `2×2` Pauli Y 矩阵，纯虚分量要求复数类型，实 `T` 会提升为 `complex(float(T))`。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
σy(::Type{T}=ComplexF64) where {T<:Number} = Matrix{complex(float(T))}([0 -im; im 0])
```



<a id="api-σz"></a>

## `σz`

```julia
σz(T=ComplexF64) -> Matrix
```

返回 `2×2` Pauli Z 矩阵，元素类型保持为 `T`；新分配矩阵。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
σz(::Type{T}=ComplexF64) where {T<:Number} = Matrix{T}([1 0; 0 -1])
```



<a id="api-Sx"></a>

## `Sx`


	σx([T]), σy([T]), σz([T]) -> Matrix
	Sx([T]), Sy([T]), Sz([T]) -> Matrix

The Pauli matrices and the spin-1/2 operators (`S = σ/2`), as `2×2` matrices of element
type `T` (default `ComplexF64`). `σx`/`σz`/`Sx`/`Sz` keep `T`; `σy`/`Sy` are promoted to a
complex element type, since they are purely imaginary.


源码：[src/mpsalgorithms/models.jl:29](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpsalgorithms/models.jl#L29)



<a id="api-Sy"></a>

## `Sy`

```julia
Sy(T=ComplexF64) -> Matrix
```

返回 `σy(T)/2`，即自旋 1/2 的 Y 算符，实类型自动提升为复数。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
Sy(::Type{T}=ComplexF64) where {T<:Number} = σy(T) ./ 2
```



<a id="api-Sz"></a>

## `Sz`

```julia
Sz(T=ComplexF64) -> Matrix
```

返回 `σz(T)/2`，即自旋 1/2 的 Z 算符；新分配矩阵。


实际声明（类型参数与关键字默认值以源码为准）：

```julia
Sz(::Type{T}=ComplexF64) where {T<:Number} = σz(T) ./ 2
```



<a id="api-heisenberg-hamiltonian"></a>

## `heisenberg_hamiltonian`


	heisenberg_hamiltonian(L::Int; J=1.0, Δ=1.0, h=0.0, T=ComplexF64) -> MPOHamiltonian

Spin-1/2 XXZ chain with a longitudinal field on `L` sites with open boundaries,

	H = J Σᵢ (SˣᵢSˣᵢ₊₁ + SʸᵢSʸᵢ₊₁ + Δ SᶻᵢSᶻᵢ₊₁) − h Σᵢ Sᶻᵢ,

so `Δ = 1` is the isotropic Heisenberg (XXX) chain and `Δ = 0` the XX chain.


源码：[src/mpsalgorithms/models.jl:46](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpsalgorithms/models.jl#L46)



<a id="api-tfim-hamiltonian"></a>

## `tfim_hamiltonian`


	tfim_hamiltonian(L::Int; J=1.0, h=1.0, T=ComplexF64) -> MPOHamiltonian

Transverse-field Ising chain on `L` sites with open boundaries,

	H = −J Σᵢ σˣᵢσˣᵢ₊₁ − h Σᵢ σᶻᵢ.

`J = h = 1` is the critical point (the infinite-chain ground-state energy density is
`−4/π`); `h = 0` gives the classical Ising limit.


源码：[src/mpsalgorithms/models.jl:73](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpsalgorithms/models.jl#L73)



<a id="api-fermi-hubbard"></a>

## `fermi_hubbard`


	fermi_hubbard(L::Int; t=1.0, U=0.0, μ=0.0, T=ComplexF64) -> MPOHamiltonian

Fermi-Hubbard chain on `L` sites with open boundaries, local basis
`(|0⟩, |↑⟩, |↓⟩, |↑↓⟩)` (the up factor the major one),

	H = −t Σᵢ Σσ (c†σ,ᵢ cσ,ᵢ₊₁ + h.c.) + U Σᵢ n↑,ᵢn↓,ᵢ − μ Σᵢ nᵢ.

The fermions are Jordan-Wigner transformed with the modes ordered site by site and `↑`
before `↓` within a site, every mode carrying the parity string of the modes that precede
it. The string is split between the local operators (the intra-site part, e.g. the ↑
parity that a ↓ mode carries) and the sites to the left, and for a *nearest-neighbour*
hopping the two inter-site strings collapse onto the parity `P = (−1)^n` of the left site
only — there are no sites in between. One bond term per species is therefore

	c†σ,ᵢ cσ,ᵢ₊₁ = (d†σ,ᵢ Pᵢ) ⊗ dσ,ᵢ₊₁,

with `d` the local mode operators, i.e. a nearest-neighbour term on the 4-dimensional
local space with the dressed creator `d†↑P = σ⁺↑ ⊗ σᶻ↓` for the up fermions and
`d†↓P = I⊗σ⁺↓` for the down ones, and its hermitian conjugate for the reverse hop. On an
open chain no boundary string appears; a periodic Hubbard chain would need one (a global
parity term), so it is not provided here.


源码：[src/mpsalgorithms/models.jl:100](https://github.com/LeeQY1996/MOSSQuantumMPS/blob/master/src/mpsalgorithms/models.jl#L100)
