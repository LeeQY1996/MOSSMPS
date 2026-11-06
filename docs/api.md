# MOSSMPS API 与函数参考

Julia 包名是 `MOSSMPS`。本文按公开导出与源码实现整理；模拟器接口和数值算法子模块使用不同的类型与局域矩阵约定，调用时建议保留模块前缀。

| 文档 | 内容 |
|---|---|
| [态、门与读出](api/simulator.md) | 全部顶层公开符号、参数与返回值、变更行为及示例 |
| [MPSCore 逐项参考](api/core-reference.md) | 正则 MPS/MPO、张量分解、算符建模及逐符号源码说明 |
| [MPSAlgorithms 逐项参考](api/algorithms-reference.md) | DMRG、TDVP、算术、学习、采样、缓存与实验算法 |
| [Models 逐项参考](api/models-reference.md) | Pauli、自旋矩阵、Heisenberg、Ising 与 Hubbard 有限链模型 |
| [MPS/MPO 算法导读](mps-algorithms.md) | 模块边界与从旧包迁移 |
| [电荷扇区 DMRG](sector-dmrg.md) | 电荷标签、扇区采样、诊断与内存预算 |
| [原有使用指南](src/index.md) | 初始化、观测量、噪声与后端 |

## 最小示例

```julia
using MOSSQuantum, MOSSMPS, Random

initial = zero_state_mps(2)
circuit = QCircuit([HGate(1), CNOTGate(1, 2)])
b = MatrixProductBackend(trunc=NoTruncation())
result = MOSSQuantum.simulate(circuit, initial; backend=b)
MOSSQuantum.probabilities(result.state) # [0.5, 0, 0, 0.5]
MOSSQuantum.sample(MersenneTwister(42), result.state, 8; backend=b) # 8 × 2
```

`MOSSMPS.sample` 返回整数计数字典；`MOSSQuantum.sample` 返回逐次读出的矩阵。两个包都导出同名接口时，用限定名称明确选择。默认门截断是 `truncdimcutoff(50, 1e-8)`，可能产生近似；需要无截断计算时显式传入 `NoTruncation()`。

源码：[MOSSMPS](https://github.com/LeeQY1996/MOSSMPS)。家族核心文档：[MOSSQuantum](https://leeqy1996.github.io/MOSSQuantum/)。
