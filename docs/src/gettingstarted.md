# 快速开始

将 MOSSQuantum 和 MOSSQuantumMPS 两个源码目录开发挂接到同一个 Julia 环境；具体安装命令和依赖授权说明见仓库 README。

```julia
using MOSSQuantum, MOSSQuantumMPS, Random

backend = MatrixProductBackend(trunc=NoTruncation())
state = zero_state_mps(2)
circuit = QCircuit()
push!(circuit, HGate(1))
push!(circuit, CNOTGate(1, 2))
state = MOSSQuantum.apply!(backend, circuit, state)

MOSSQuantum.probabilities(backend, state) # 约为 [0.5, 0, 0, 0.5]
MOSSQuantum.expectation(backend, QubitsTerm(1=>Z, 2=>Z), state) # 约为 1
samples = MOSSQuantum.sample(Xoshiro(42), state, 100; backend=backend)
```

计算基按小端序排列，比特 1 是最低有效位。通过 MOSSQuantum 后端传入普通 MOSSQuantum 门时，桥接层自动转换局域矩阵的位序。低层矩阵原语的约定见[核心操作](coreops.md)。

调用会返回结果态，可能因复数提升或噪声信道而替换原态，应始终使用返回值。显式传入后端可保留所选截断方案。
