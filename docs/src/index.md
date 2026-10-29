# MOSSQuantumMPS

MOSSQuantumMPS 为 MOSSQuantum 提供矩阵乘积态后端。`MPS` 表示纯态，`DensityOperatorMPS` 表示密度算符。`MatrixProductBackend` 将 MOSSQuantum 的线路指令转换为张量网络操作；MPS/MPO 基础组件位于包内 `MPSCore` 子模块；高层算法可由独立算法包提供。

参见[快速开始](gettingstarted.md)、[态](states.md)、[核心操作](coreops.md)、[可观测量与读取](observables.md)、[噪声](noise.md)和[后端](backend.md)。安装和授权信息见仓库 README。
