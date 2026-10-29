# 态与正则形式

纯态 `MPS` 每个站点的物理维度为 2；混合态 `DensityOperatorMPS` 每个站点的物理维度为 4，以融合指标表示密度算符。两者包装 `MOSSQuantumMPS.MPSCore.CanonicalMPS`，支持 `copy`、`bonddim`、`bonddims` 及正则形式查询。

常用初始化包括 `zero_state_mps`、`onehot_encoding_mps`、`qubit_encoding_mps`、`amplitude_encoding_mps` 和 `densitymatrix_mps`。`statevector`、`densitymatrix` 可用于小系统稠密对照，但输出大小随比特数指数增长。

```julia
using MOSSQuantumMPS, LinearAlgebra
state = zero_state_mps(2)
copy_of_state = copy(state)
rho = densitymatrix(state)
```

截断可能改变范数或迹。MOSSQuantum 读取操作会拒绝未归一化的态：纯态使用 `LinearAlgebra.normalize!(state)`，混合态使用 `MOSSQuantumMPS.normalize_tr!(rho)`。`normalize!(rho)` 使用的是算符的 2-范数，不等同于密度矩阵的迹归一化。归一化不消除截断误差。
