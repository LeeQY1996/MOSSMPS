# 核心操作

包的底层 `MOSSQuantumMPS.apply!(state, matrix, positions; trunc=...)` 使用局域矩阵，`positions` 的第一项是矩阵最高位。MOSSQuantum 的门矩阵则将第一项视为最低位；`MatrixProductBackend` 在边界自动转换，调用者无需调整普通 MOSSQuantum 门。不要将两种矩阵约定混用。

非相邻目标通过相邻 SWAP 聚集并恢复；多站点操作可能进行截断。可使用 `NoTruncation()` 禁用键截断，或使用 `truncdim`、`truncrelerr`、`truncdimcutoff` 设置近似。默认后端截断为 `truncdimcutoff(50, 1e-8)`，结果可能为近似值。

低层 `apply_kraus!` 和 `reset_qubit_zero!` 等操作与 MOSSQuantum 同名函数有各自的参数和返回约定，调用时请使用模块限定名并查阅相应 docstring。保存作用函数的返回值：某些操作会替换态的类型。
