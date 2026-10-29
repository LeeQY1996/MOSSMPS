# 混合态与噪声

`MatrixProductBackend` 支持将 MOSSQuantum 的 `QuantumMap` 作用于 MPS。纯态输入会转换为 `DensityOperatorMPS`，因此必须保留返回态：

```julia
using MOSSQuantum, MOSSQuantumMPS
backend = MatrixProductBackend(trunc=NoTruncation())
state = zero_state_mps(2)
channel = AmplitudeDamping(1; γ=0.2)
state = MOSSQuantum.apply!(backend, channel, state)
```

后端转换 Kraus 矩阵的局域位序；对 MOSSQuantum 的通道不需要调用者自行调整。截断可能引入近似并改变迹；必要时使用 `MOSSQuantumMPS.normalize_tr!`，但归一化不修复近似所造成的误差或保证所有物理性质。其他噪声执行模式及整个实验工作流需独立验证，不能仅凭支持 `QuantumMap` 推断。
