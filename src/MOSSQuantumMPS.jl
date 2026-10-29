module MOSSQuantumMPS

using LinearAlgebra
using Random
using TensorOperations

import MOSSQuantum

# Dense MPS/MPO numerical foundation shared with algorithm packages.
include("mpscore/MPSCore.jl")
using .MPSCore: CanonicalMPS, Orthogonalize, prodmps, randommps, scaling, setscaling!,
    QR, QRpos, LQ, LQpos, SVD, SDD, Polar, TruncationScheme, NoTruncation,
    TruncateDim, TruncateRelError, TruncateDimCutoff, truncdim, truncrelerr,
    truncdimcutoff, tsvd, tsvd!, leftorth, leftorth!, rightorth, rightorth!,
    tie, renyi_entropy, swap!
import .MPSCore: apply!, canonicalize!, expectation, fidelity, distance, distance2,
    iscanonical, isrightcanonical, svectors_uninitialized, permute,
    bonddim, bonddims, phydim, phydims, normalize_tr!

import LinearAlgebra: normalize!, norm, dot, tr

# ── 张量操作层（re-export MPSCore）──────────────────────────────

# ── 默认参数 ────────────────────────────────────────────────────────────────
include("defaults.jl")

# ── 态 ──────────────────────────────────────────────────────────────────────
include("states/mps.jl")

# ── 核心层 ──────────────────────────────────────────────────────────────────
include("kernels.jl")
include("coreops.jl")
include("expecs.jl")
include("ops/ops.jl")
include("initializers.jl")

# ── MOSSQuantum 后端桥接 ──────────────────────────────────────────────────
include("moss_backend.jl")

# MPS/MPO algorithms share the same MPSCore objects as the simulator.
include("mpsalgorithms/MPSAlgorithms.jl")

# ── 导出 ────────────────────────────────────────────────────────────────────
export # 张量操作（MPSCore re-export）
    MPSAlgorithms,
    TruncationScheme, NoTruncation, TruncateDim, TruncateRelError, TruncateDimCutoff,
    truncdim, truncrelerr, truncdimcutoff,
    QR, QRpos, LQ, LQpos, SVD, SDD, Polar,
    tsvd, tsvd!, leftorth, leftorth!, rightorth, rightorth!,
    permute, tie, distance, distance2, renyi_entropy,
    # 态
    AbstractMPS, MPS, DensityOperatorMPS,
    zero_state_mps, rand_state_mps, qubit_encoding_mps, onehot_encoding_mps,
    amplitude_encoding_mps, statevector_mps, densitymatrix_mps, densitymatrix,
    bonddim, bonddims, phydim, phydims,
    iscanonical, isrightcanonical, svectors_uninitialized,
    # 核心操作
    apply, apply!, apply_kraus!, reset_qubit_zero!,
    probabilities, marginal_probabilities, measure!, sample, post_select, post_select!,
    partial_tr, expectation, fidelity, overlap, amplitude, statevector,
    canonicalize!, normalize!, normalize_tr!,
    # MOSSQuantum 后端桥接
    MatrixProductBackend

end # module
