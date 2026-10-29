# MOSSQuantum execution bridge.  The tensor primitives keep the original
# MSB-first local matrix convention; MOSSQuantum uses LSB-first positions.

"""
    MatrixProductBackend(; trunc=DefaultMPSTruncation)

MOSSQuantum backend for MPS and density-operator MPS states. `trunc` controls
bond truncation during gates, channels and measurement. Use `NoTruncation()`
for an untruncated calculation. The default may introduce approximation.
"""
struct MatrixProductBackend{T<:TruncationScheme} <: MOSSQuantum.AbstractBackend
    trunc::T
end
MatrixProductBackend(; trunc::TruncationScheme=DefaultMPSTruncation) = MatrixProductBackend(trunc)

MOSSQuantum.nqubits(state::AbstractMPS) = length(state)
MOSSQuantum.backend(::AbstractMPS) = MatrixProductBackend()

function MOSSQuantum.supports(::MatrixProductBackend, operation, ::AbstractMPS; action::Symbol=:apply)
    if action === :apply
        return (operation isa MOSSQuantum.Gate && MOSSQuantum.nqubits(operation) >= 1) ||
               operation isa MOSSQuantum.QuantumMap ||
               (operation isa MOSSQuantum.QMeasure && operation.keep) ||
               operation isa MOSSQuantum.QSelect
    elseif action === :expectation
        return operation isa Union{MOSSQuantum.QubitsTerm,MOSSQuantum.QubitsOperator}
    elseif action === :probabilities
        return operation === MOSSQuantum.probabilities
    end
    return false
end

# Resolve dispatch against the generic circuit capability method. Both pure and
# mixed MPS support the same advertised operations, including the state change
# caused by a channel.
function MOSSQuantum.supports(b::MatrixProductBackend, circuit::MOSSQuantum.QCircuit,
                              state::AbstractMPS; action::Symbol=:apply)
    action === :apply || return false
    return all(instruction -> MOSSQuantum.supports(b, instruction, state; action=:apply), circuit)
end

function MOSSQuantum.apply!(b::MatrixProductBackend, gate::MOSSQuantum.Gate, state::AbstractMPS)
    MOSSQuantum.supports(b, gate, state) || throw(MOSSQuantum.UnsupportedOperation(b, gate, state, :apply))
    MOSSQuantum.validate_positions(gate, length(state))
    # Reversing positions maps MOSS's least-significant-first local axes to
    # this package's most-significant-first axes without changing the matrix.
    positions = reverse(Tuple(MOSSQuantum.positions(gate)))
    return apply!(state, MOSSQuantum.mat(gate), positions; trunc=b.trunc)
end

function MOSSQuantum.apply!(b::MatrixProductBackend, channel::MOSSQuantum.QuantumMap,
                            state::AbstractMPS)
    MOSSQuantum.validate_positions(channel, length(state))
    positions = Tuple(MOSSQuantum.positions(channel))
    # apply_kraus! expects operators already in ascending-site, low-bit-first
    # order. Unlike the gate path, it does not reorder each Kraus matrix.
    ordered = Tuple(sort(collect(positions)))
    ks = [_reorder_gate(k, reverse(positions)) for k in MOSSQuantum.kraus_matrices(channel)]
    return apply_kraus!(state, ks, ordered; trunc=b.trunc)
end

function MOSSQuantum.apply!(b::MatrixProductBackend, instruction::MOSSQuantum.QMeasure,
                            state::AbstractMPS; rng::Random.AbstractRNG=Random.default_rng())
    MOSSQuantum.supports(b, instruction, state) || throw(MOSSQuantum.UnsupportedOperation(b, instruction, state, :apply))
    return MOSSQuantum.measure!(b, state, instruction.position; auto_reset=instruction.auto_reset, rng=rng)
end

function MOSSQuantum.apply!(b::MatrixProductBackend, instruction::MOSSQuantum.QSelect, state::AbstractMPS)
    MOSSQuantum.validate_positions(instruction, length(state))
    MOSSQuantum.probabilities(b, state; qubits=(instruction.position,))
    return post_select!(state, instruction.position, instruction.state; trunc=b.trunc)
end

function MOSSQuantum.expectation(b::MatrixProductBackend, term::MOSSQuantum.QubitsTerm, state::AbstractMPS)
    MOSSQuantum.validate_positions(term, length(state))
    operators = Pair{Int,AbstractMatrix}[p => op for (p, op) in zip(MOSSQuantum.positions(term), MOSSQuantum.oplist(term))]
    return MOSSQuantum.coeff(term) * expectation(operators, state)
end

function MOSSQuantum.expectation(b::MatrixProductBackend, op::MOSSQuantum.QubitsOperator, state::AbstractMPS)
    MOSSQuantum.validate_positions(op, length(state))
    # QubitsOperator currently exposes its terms through `data`; there is no
    # public term iterator in MOSSQuantum. Never expand the full dense matrix.
    result = zero(ComplexF64)
    for (positions, terms) in op.data, (operators, coefficient) in terms
        term = MOSSQuantum.QubitsTerm(positions, operators, coefficient)
        result += MOSSQuantum.expectation(b, term, state)
    end
    return result
end

function _moss_readout_qubits(state::AbstractMPS, qubits)
    qs = Int[qubits...]
    length(unique(qs)) == length(qs) || throw(ArgumentError("readout qubits must be distinct"))
    all(q -> 1 <= q <= length(state), qs) || throw(ArgumentError("readout qubit out of range"))
    return qs
end

function _moss_probabilities(state::AbstractMPS, qubits)
    qs = _moss_readout_qubits(state, qubits)
    # For no requested qubits partial_tr returns a scalar, not a 1x1 matrix.
    if isempty(qs)
        total = state isa MPS ? dot(state, state) : tr(state)
        diagvalues = [total]
    else
        retained = sort(qs)
        reduced = partial_tr(state, setdiff(collect(1:length(state)), retained))
        diagonal = diag(reduced)
        # Explicitly restore the requested order, including full reversed readout.
        axes = [findfirst(==(q), retained) for q in qs]
        diagvalues = similar(diagonal)
        for source in 0:length(diagonal)-1
            destination = sum(((source >> (axes[j]-1)) & 1) << (j-1) for j in eachindex(qs); init=0)
            diagvalues[destination+1] = diagonal[source+1]
        end
    end
    RT = typeof(real(zero(eltype(state))))
    tolerance = max(sqrt(eps(Float64)), RT <: AbstractFloat ? sqrt(Float64(eps(RT))) : 0.0)
    all(isfinite, diagvalues) || throw(ArgumentError("probabilities must be finite"))
    all(x -> abs(imag(x)) <= tolerance, diagvalues) || throw(ArgumentError("density-matrix diagonal must be real"))
    values = Float64[real(x) for x in diagvalues]
    minimum(values) >= -tolerance || throw(DomainError(minimum(values), "probabilities must be nonnegative"))
    values .= max.(values, 0)
    total = sum(values)
    isapprox(total, 1; atol=tolerance, rtol=tolerance) ||
        throw(ArgumentError("state probabilities must sum to one; normalize the state first (sum = $total)"))
    return values ./ total
end

MOSSQuantum.probabilities(::MatrixProductBackend, state::AbstractMPS; qubits=1:length(state)) =
    _moss_probabilities(state, qubits)
MOSSQuantum.probabilities(state::AbstractMPS; qubits=1:length(state)) =
    MOSSQuantum.probabilities(MOSSQuantum.backend(state), state; qubits=qubits)

function MOSSQuantum.measure!(b::MatrixProductBackend, state::AbstractMPS, position::Int;
                              auto_reset::Bool=true, rng::Random.AbstractRNG=Random.default_rng())
    probabilities = MOSSQuantum.probabilities(b, state; qubits=(position,))
    outcome = rand(rng) < probabilities[1] ? 0 : 1
    probability = probabilities[outcome+1]
    post_select!(state, position, outcome; trunc=b.trunc)
    if auto_reset && outcome == 1
        # A measured state has definite outcome, so X implements reset without
        # changing the representation or introducing an incoherent channel.
        apply!(state, [0 1; 1 0], (position,); trunc=b.trunc)
    end
    return outcome, probability
end

"""
Sample an MPS by sequential conditional measurements without materializing a
full `2^n` probability distribution. `readout` delegates to MOSSQuantum's shot
executor, which currently constructs the requested marginal distribution.
"""
function MOSSQuantum.sample(rng::Random.AbstractRNG, state::AbstractMPS, shots::Integer;
                            qubits=1:length(state), readout=nothing,
                            backend::MatrixProductBackend=MOSSQuantum.backend(state))
    shots isa Bool && throw(ArgumentError("shots must be a nonnegative integer, not Bool"))
    0 <= shots <= typemax(Int) || throw(ArgumentError("shots must fit a nonnegative Int"))
    qs = _moss_readout_qubits(state, qubits)
    if !isnothing(readout)
        return MOSSQuantum.execute(MOSSQuantum.QCircuit(), state;
                                   shots=shots, qubits=qs, rng=rng, backend=backend,
                                   readout=readout).samples
    end
    # Validate normalization even for zero shots or an empty selection.
    MOSSQuantum.probabilities(backend, state; qubits=())
    output = Matrix{Int}(undef, Int(shots), length(qs))
    for shot in 1:Int(shots)
        draw = copy(state)
        for (j, q) in enumerate(qs)
            output[shot,j], _ = MOSSQuantum.measure!(backend, draw, q; auto_reset=false, rng=rng)
        end
    end
    return output
end
