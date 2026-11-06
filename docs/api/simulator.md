# 模拟器 API：态、门、观测量与读出

[返回 API 目录](../api.md)。本页覆盖 `MOSSMPS` 顶层导出的全部符号。算法模块另见 [MPSAlgorithms](algorithms-reference.md)。下文用 `MP = MOSSMPS`、`MQ = MOSSQuantum` 区分同名接口。

## 数据约定

比特编号从 1 开始，站点 `k` 对应比特 `k`；完整振幅向量中比特 1 为最低位。站点张量轴序为 `(左键, 物理维, 右键)`，采用开放边界。纯态物理维为 2；密度算符物理维为 4，融合指标零基值为 `ket + 2bra`。

直接传入局域矩阵的 `MP.apply!` 以 `positions[1]` 对应矩阵最高位。`MQ.apply!(backend, gate, state)` 会转换核心库的局域最低位约定。两种接口不能简单互换同一位置序列。`apply_kraus!` 的 Kraus 矩阵应已按升序站点的最低位约定排列；建议通过 `MQ.QuantumMap` 和后端桥接使用通道。

## 态与初始化

### `AbstractMPS`、`MPS`、`DensityOperatorMPS`

```julia
MPS(core::MOSSMPS.MPSCore.CanonicalMPS)
MPS(data::AbstractVector{<:AbstractArray{T,3}}, svectors=nothing)
DensityOperatorMPS(core::MOSSMPS.MPSCore.CanonicalMPS)
DensityOperatorMPS(data::AbstractVector{<:AbstractArray{T,3}}, svectors=nothing)
```

`AbstractMPS{T}` 是核心 `AbstractQuantumState` 的子类型。构造器校验开放边界、键维匹配、物理维及 Schmidt 谱数值类型；不会自动证明密度算符正性或迹为 1。`data[k]` 是第 `k` 站点张量；可选 `svectors` 给出键谱。传入已有 `core` 会包装该对象，张量构造可能复用兼容数组；需要独立存储时用 `copy(state)`，它深拷贝张量与谱。`length(state)` 为站点数，`state[k]` 返回底层张量，直接修改会影响该态且可能使正则信息失效。

### `zero_state_mps`、`statevector_mps`、`onehot_encoding_mps`

```julia
zero_state_mps([T=ComplexF64,] n::Int) -> MPS
statevector_mps([T=ComplexF64,] n::Int) -> MPS
statevector_mps(T, bits::Vector{Int}) -> MPS
onehot_encoding_mps([T=ComplexF64,] bits::AbstractVector{Int}) -> MPS
```

返回键维为 1 的乘积态，`n ≥ 1`。`bits[k] ∈ (0,1)` 指比特 `k` 的值；`statevector_mps` 的位串重载需要显式类型参数，位串无类型参数时使用 `onehot_encoding_mps(bits)`。输入数组不成为可变共享的站点存储。

### `qubit_encoding_mps`

```julia
qubit_encoding_mps([T=ComplexF64,] values::AbstractVector{<:Real}) -> MPS
```

第 `k` 比特编码为 `cos(πvalues[k]/2)|0⟩ + sin(πvalues[k]/2)|1⟩`，返回乘积态。`values` 非空；值没有限制到 `[0,1]`。

### `amplitude_encoding_mps`

```julia
amplitude_encoding_mps([T=ComplexF64,] v;
    nqubits=ceil(Int, log2(length(v))), trunc=NoTruncation()) -> MPS
```

将非零振幅向量 `v` 归一化、补零到 `2^nqubits` 后逐站点 SVD；要求 `nqubits ≥ 1` 且输入长度不超过目标维数。截断后重新归一化。返回新 MPS，不修改 `v`；不归一化输入会给出警告。该初始化需要稠密输入，因此有指数级输入成本。

### `rand_state_mps`

```julia
rand_state_mps([T=ComplexF64,] n::Int; D::Int=8) -> MPS
```

随机高斯张量经正则化、归一化生成纯态，内部键维上限 `D`；`n ≥ 1`。该接口使用默认 RNG，没有 `rng` 关键字。

### `densitymatrix_mps`、`densitymatrix`

```julia
densitymatrix_mps([T=ComplexF64,] n::Int) -> DensityOperatorMPS
densitymatrix_mps(T, bits::Vector{Int}) -> DensityOperatorMPS
densitymatrix(psi::MPS; trunc=MP.DefaultMPSTruncation) -> DensityOperatorMPS
densitymatrix(rho::DensityOperatorMPS) -> Matrix
```

前两个构造计算基的密度算符；位串重载需要显式 `T`。纯态转换构造 `|ψ⟩⟨ψ|` 再压缩；不自动归一化，无截断时迹为 `norm(psi)^2`。密度算符参数的 `densitymatrix` 则展开为 `2^n × 2^n` 稠密矩阵，行是 ket、列是 bra，内存指数增长。

### `bonddim`、`bonddims`、`phydim`、`phydims`

```julia
bonddim(state, b::Int) -> Int
bonddim(state) -> Int
bonddims(state) -> Vector{Int}
phydim(state, k::Int) -> Int
phydims(state) -> Vector{Int}
```

键 `b` 位于站点 `b` 与 `b+1` 之间；无位置参数的 `bonddim` 返回最大键维，单站点时为 1。`bonddims` 长度为 `n-1`；`phydims` 长度为 `n`。查询不修改态。

### `iscanonical`、`isrightcanonical`、`svectors_uninitialized`

```julia
iscanonical(state; atol=1e-8) -> Bool
isrightcanonical(state; atol=1e-12) -> Bool
svectors_uninitialized(state) -> Bool
```

前者检查站点 `2:n` 右正则且 Schmidt 谱已初始化并与数据一致；站点 1 可携带整体尺度。当前 `iscanonical` 对长度小于 2 返回 `false`。`isrightcanonical` 要求所有站点张量右正则，故与前者含义不同。未知谱会让 `svectors_uninitialized` 返回 `true`。

### `canonicalize!`、`normalize!`、`normalize_tr!`

```julia
canonicalize!(psi::MPS; trunc=NoTruncation(), normalize=true) -> error
canonicalize!(rho::DensityOperatorMPS;
    trunc=NoTruncation(), normalize=false) -> error
normalize!(state::AbstractMPS) -> state
normalize_tr!(rho::DensityOperatorMPS) -> rho
```

正则化先 QR 再反向 SVD，修改态并返回最大单键截断误差；此误差不是整体物理误差界。纯态默认单位范数，密度算符默认保持原尺度。`normalize!` 按融合空间 2 范数归一化，密度算符时是 Hilbert–Schmidt 范数；物理混态应使用按迹归一化的 `normalize_tr!`。零范数或零迹会抛 `ArgumentError`。

## 作用与重置

### `apply`、`apply!`

```julia
MP.apply!(state, m::AbstractMatrix, positions::NTuple{N,Int}; trunc=...)
MP.apply!(state, m::AbstractMatrix, positions::Vector{Int}; trunc=...)
MP.apply(state, m::AbstractMatrix, positions; trunc=...) -> newstate
```

`positions` 是合法、互异的比特位置，可非相邻。`m` 是 `2^N × 2^N` 局域矩阵或 `4^N × 4^N` 超算符。纯态执行 `mψ`；密度算符执行 `mρm†` 或直接作用超算符。多体门可能先正则化并通过 SWAP 聚集/恢复站点；每次分解受 `trunc` 影响。`apply` 先深拷贝；`apply!` 尽量原地执行，但实数态遇复数矩阵可能返回新态，纯态遇超算符返回密度算符，始终保留返回值。

### `apply_kraus!`

```julia
apply_kraus!(state, ks, positions::Union{NTuple{N,Int},Vector{Int}};
    trunc=MP.DefaultMPSTruncation) -> DensityOperatorMPS
```

`ks` 是局域 Kraus 矩阵集合；每矩阵大小为 `2^N × 2^N`，其数值顺序须满足本页数据约定。将它们组合为局域超算符，执行 `ΣKρK†`；纯态先转换为密度算符。调用方应确保通道满足 `ΣK†K=I`，底层接口只检查形状。非幺正更新可能使正则谱失效，按需再次正则化。

### `reset_qubit_zero!`

```julia
reset_qubit_zero!(state, q::Int; trunc=...) -> state
```

`q` 从 1 开始。密度算符通过 `|0⟩⟨0|`、`|0⟩⟨1|` Kraus 重置并按迹归一化。纯态实现使用相干映射 `|0⟩(⟨0|+⟨1|)` 后归一化，结果可因振幅抵消而无法归一化；它与纠缠态的非相干物理重置含义不同。需要物理重置时在后端接口中应用核心 `ResetChannel`，并保留密度算符返回值。

## 观测量与转换

### `expectation`、`overlap`

```julia
MP.expectation(ops::AbstractVector{<:Pair{Int,<:AbstractMatrix}}, psi::MPS)
MP.expectation(ops, bra::MPS, ket::MPS)
MP.expectation(ops, rho::DensityOperatorMPS)
overlap(bra::MPS, rho::DensityOperatorMPS, ket::MPS)
```

`ops` 给出 `比特 => 2×2 局域矩阵`，缺失比特视为恒等；返回收缩标量，分别是 `⟨ψ|O|ψ⟩`、`⟨bra|O|ket⟩`、`tr(ρO)`、`⟨bra|ρ|ket⟩`，不自动归一化。局域算符转为字典，重复位置会被最后一个条目覆盖；不要用重复位置表示矩阵乘积。

### `amplitude`、`statevector`

```julia
MP.amplitude(psi::MPS, bits::AbstractVector{Int}; scaling=1) -> Number
statevector(psi::MPS) -> Vector
```

`bits` 长度必须等于站点数、每值为 0/1；返回该基态的复振幅。可选 `scaling` 使结果乘以 `scaling^n`，一般不需要。`statevector` 展开完整长度 `2^n` 的向量，不修改输入。

### `fidelity`、`distance`、`distance2`

```julia
MP.fidelity(psi::MPS, phi::MPS) -> Real
MP.fidelity(rho::DensityOperatorMPS, psi::MPS) -> Real
MP.fidelity(psi::MPS, rho::DensityOperatorMPS) -> Real
MP.distance(psi::MPS, phi::MPS) -> Real
MP.distance2(psi::MPS, phi::MPS) -> Real
```

保真度分别为 `abs2(dot(psi,phi))` 和 `real(⟨ψ|ρ|ψ⟩)`；要求输入自行规范化以获得物理保真度。两个混合 MPS 的保真度明确抛 `ArgumentError`。距离为纯态向量的欧氏距离或其平方；没有自动消除全局相位，也没有为封装混态提供距离方法。

### `partial_tr`

```julia
MP.partial_tr(state, sites::AbstractVector{Int}) -> Matrix | Number
MP.partial_tr(state, sites::Int...) -> Matrix | Number
```

`sites` 是被求迹、被丢弃的比特，必须合法且互异。剩余比特按升序组成稠密约化矩阵，第一剩余比特为最低位。空集合展开完整密度矩阵；全部求迹返回纯态范数平方或混态迹的标量。输出大小随保留比特数指数增长。

## 测量、采样与后选择

### `probabilities`、`marginal_probabilities`

```julia
MP.probabilities(state) -> Vector{Float64}
marginal_probabilities(state, qs::AbstractVector{Int}) -> Vector{Float64}
marginal_probabilities(state, q::Int) -> Vector{Float64}
```

非破坏性读出；输出长度为 `2^length(qs)`，`qs[1]` 是概率索引最低位。低层 `MP` 接口不强制输入规范化。核心 `MQ.probabilities(state; qubits=...)` 还检查概率有限、非负及总和为 1，并支持空读出集合；优先用核心接口进行实验读取。

### `measure!`

```julia
MP.measure!(state, q::Integer; trunc=..., rng=Random.default_rng()) -> Int
MP.measure!(state, qs::AbstractVector{Int}; trunc=..., rng=...) -> Vector{Int}
MP.measure!(state; trunc=..., rng=...) -> Int
```

原地坍缩并归一化，不删除比特、不自动复位；单比特返回 0/1，列表返回按指定顺序的位串，全部测量返回小端编码整数。与返回 `(outcome, probability)` 且默认自动复位的核心 `MQ.measure!` 区分。

### `sample`

```julia
MP.sample(state, qs::AbstractVector{Int}, shots::Int) -> Dict{Int,Int}
MP.sample(state, shots::Int) -> Dict{Int,Int}
MQ.sample(rng, state, shots::Integer;
    qubits=1:length(state), readout=nothing, backend=MQ.backend(state)) -> Matrix{Int}
```

`shots ≥ 0`。`MP.sample` 先生成边缘概率，使用全局默认 RNG，返回整数基态到次数的字典，其空间与子集大小呈指数关系。核心 `MQ.sample` 逐次拷贝态并做条件测量，返回 `(shots, length(qubits))`，输入不变，支持显式 RNG；`readout` 可传经典读出误差。不构造完整概率分布。

### `post_select`、`post_select!`

```julia
MP.post_select!(state, q::Integer, val::Integer=0; trunc=...) -> probability
MP.post_select(state, q::Integer, val::Integer=0; trunc=...) -> (newstate, probability)
```

投影到 `val ∈ (0,1)` 并归一化；`!` 修改输入，非变更版本深拷贝；概率为零时抛 `ArgumentError`。比特保留。核心 `execute` 的拒绝采样语义另见核心包文档。

## 后端与子模块

### `MatrixProductBackend`

```julia
MatrixProductBackend(; trunc=MP.DefaultMPSTruncation)
MQ.apply!(backend, gate_or_channel, state) -> state
MQ.measure!(backend, state, q::Int; auto_reset=true, rng=...) -> (Int, probability)
```

无状态数值后端配置，只保存截断方案；`MQ.backend(state)` 返回默认配置。支持核心局域门、`QuantumMap`、保留比特的 `QMeasure`、`QSelect`、Pauli 算符期望与终态采样。纯态遇信道转换为 `DensityOperatorMPS`。`execute` 要求通道迹保持。`simulate`/`execute` 会通过核心能力检查处理完整线路；后端未实现解析梯度承诺。用 `MQ.execution_capability(circuit, state; backend=b, mode=:simulate)` 检查具体配置。

### `MPSAlgorithms` 与张量分解再导出

顶层导出 `MPSAlgorithms` 模块。它使用 `MPSCore.CanonicalMPS` / MPO 类型；封装态的底层对象是 `psi.core`，算法不会把 `MPS` 包装类型当作任意正则 MPS 自动处理。见 [算法逐项参考](algorithms-reference.md)。

以下全部顶层符号与 `MPSCore` 为同一函数/类型对象，逐项签名、因子形状、变更行为见 [MPSCore 参考](core-reference.md)：`TruncationScheme`、`NoTruncation`、`TruncateDim`、`TruncateRelError`、`TruncateDimCutoff`、`truncdim`、`truncrelerr`、`truncdimcutoff`、`QR`、`QRpos`、`LQ`、`LQpos`、`SVD`、`SDD`、`Polar`、`tsvd`、`tsvd!`、`leftorth`、`leftorth!`、`rightorth`、`rightorth!`、`permute`、`tie`、`renyi_entropy`。

## 直接矩阵调用示例

```julia
import MOSSMPS as MP
using LinearAlgebra, Random

psi = MP.zero_state_mps(2)
psi = MP.apply!(psi, [1 1; 1 -1] / sqrt(2), (1,); trunc=MP.NoTruncation())
@assert MP.marginal_probabilities(psi, 1) ≈ [0.5, 0.5]
collapsed, p = MP.post_select(psi, 1, 0)
@assert p ≈ 0.5
@assert MP.statevector(collapsed) ≈ ComplexF64[1, 0, 0, 0]
rho = MP.densitymatrix(psi; trunc=MP.NoTruncation())
@assert tr(rho) ≈ 1
```
