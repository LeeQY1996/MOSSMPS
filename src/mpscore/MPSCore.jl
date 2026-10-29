module MPSCore

using LinearAlgebra
using LinearAlgebra: BlasFloat
using Random
using TensorOperations
import TensorOperations: scalartype
using MatrixAlgebraKit: MatrixAlgebraKit, left_orth!, right_orth!, svd_compact!,
    QRIteration, DivideAndConquer, SafeDivideAndConquer, TruncatedAlgorithm, trunctol,
    LeftOrthAlgorithm, RightOrthAlgorithm, diagview, isunitary

# tensorops
export TruncationScheme, NoTruncation, TruncateDim, TruncateRelError, TruncateDimCutoff,
	truncdim, truncrelerr, truncdimcutoff, truncate!,
	QR, QRpos, LQ, LQpos, SVD, SDD, Polar,
	tsvd!, tsvd, leftorth!, leftorth, rightorth!, rightorth,
	tie, permute, scalar, isometry, renyi_entropy, distance, distance2, fidelity, infidelity
# structures
export AbstractMPS, AbstractMPO, MPSTensor, MPOTensor, CanonicalMPS, CanonicalMPO,
	MPO, MPOHamiltonian, Orthogonalize,
	SchurMPOTensor, SparseMPOHamiltonian,
	OpTerm, OpSum, Coeff, isconstant, term, tompotensor, tompotensors,
	todense, vectorize, devectorize, superoperator,
	ExpDecayOpTerm, ExpDecayOpSum, PairOpTerm,
	isleftcanonical, isrightcanonical, iscanonical, canonicalize!, canonicalize,
	space_l, space_r, phydim, ophydim, iphydim, phydims,
	ophydims, iphydims, bonddim, bonddims,
	scaling, setscaling!, svectors_uninitialized, unset_svectors!, normalize_tr!,
	expectation, expectationvalue, entanglement_entropy, entanglement_spectrum, schmidt_values,
	prodmps, randommps, DensityOperator, infinite_temperature_state,
	changebond!, truncate!, identitympo, prodmpo, randommpo, ⊙,
	copyphydims,
	tomps, tompo

export AbstractGate, Gate, apply!, swap!, positions, shift, TraceCache
include("tensorops/tensorops.jl")
module Defaults
using ..MPSCore: truncdimcutoff, truncrelerr
const D = 64
const tolgauge = 1.0e-14
alg_trunc() = truncdimcutoff(D=D, ϵ=tolgauge; add_back=1)
alg_orth_trunc() = truncrelerr(ϵ=tolgauge)
function alg_orth end
end
Defaults.alg_orth() = QRpos()
function expectation end
function expectationvalue end
include("abstractdefs.jl")
include("states/states.jl")
include("operators/operators.jl")
include("expectation.jl")
include("gates.jl")
end
