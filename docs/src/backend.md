# MOSSQuantum 后端

命名线路参数复用主包的[仿射参数接口](https://github.com/LeeQY1996/MOSSQuantum/blob/main/docs/parameters.md)，桥接层接收绑定后的数值门。使用纯 MPS 和 `NoTruncation` 时，标量 `ExpectationObjective` 已验证共享变量、固定变量、`ParameterShift` 和 `FiniteDifference`；桥接层未提供原生伴随梯度。

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

批处理、GPU、自动微分以及所有实验、噪声和经典控制流程不因支持基本后端接口而自动获得支持。`MOSSQuantum.execution_capability(backend, circuit, state; mode=:execute)` 可对具体线路进行静态能力查询，结果区分 `:supported`、`:unsupported` 和 `:unknown`；检查不改变初态，也不消耗随机数。态的归一化等依赖数值的条件由执行时检查。

`MOSSQuantum.sample`、`execute` 和有限 shots 的 `estimate` 通过逐站点测量采样，不需要为所有读取比特构造完整概率分布；终态读出错误也复用该路径。显式调用 `probabilities` 仍会产生请求的完整分布。采样时后端的截断策略始终使用用户传入的实例；截断后未归一化的态需要用户自行归一化。
