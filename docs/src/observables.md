# 可观测量与读取

MOSSQuantum 后端提供 `QubitsTerm` 和 `QubitsOperator` 的期望值，不需要构造整个稠密算符矩阵。读取接口接受显式 RNG：

```julia
using MOSSQuantum, MOSSQuantumMPS, Random
backend = MatrixProductBackend(trunc=NoTruncation())
state = zero_state_mps(2)
value = MOSSQuantum.expectation(backend, QubitsTerm(1=>Z), state)
samples = MOSSQuantum.sample(Xoshiro(42), state, 100; backend=backend)
```

`MOSSQuantum.sample` 在未指定 `readout` 时逐站点采样，不构造完整概率分布；每次采样会复制态并依次测量所选比特。指定 `readout` 时，它会调用通用 `execute` 读取路径。`MOSSQuantum.probabilities` 生成大小为 `2^k` 的分布（`k` 为读取比特数）。通用 `MOSSQuantum.execute` 的读取路径仍可能构造完整分布，不能假定具有逐站点采样的空间复杂度。

截断后的态若未归一化，读取会报错。纯态用 `LinearAlgebra.normalize!`、密度算符用 `MOSSQuantumMPS.normalize_tr!` 进行归一化后再读取。测量和后选择会改变状态；随机测量传入 `rng` 来控制随机性。
