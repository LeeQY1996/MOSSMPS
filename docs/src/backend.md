# MOSSQuantum 后端

`MatrixProductBackend(; trunc=...)` 实现 MOSSQuantum 的状态和后端接口。桥接层支持门、`QuantumMap`、保留比特的测量、后选择、Pauli 项与算符的期望，以及计算基读取。可通过 `MOSSQuantum.supports(backend, operation, state)` 查询支持情况；位置有效性仍需单独校验。

```julia
using MOSSQuantum, MOSSQuantumMPS
backend = MatrixProductBackend(trunc=truncdim(32))
state = zero_state_mps(3)
gate = HGate(1)
if MOSSQuantum.supports(backend, gate, state)
    state = MOSSQuantum.apply!(backend, gate, state)
end
```

`MOSSQuantum.backend(state)` 返回使用默认截断的后端。选择其他策略时需在相关操作中显式传入后端；线路作用可能返回不同类型的态。

批处理、GPU、自动微分以及所有实验、噪声和经典控制流程不因支持基本后端接口而自动获得支持。逐站点 `MOSSQuantum.sample` 与通用 `MOSSQuantum.execute` 的读取路径也不同；后者可能为所选比特构造完整的概率分布。
