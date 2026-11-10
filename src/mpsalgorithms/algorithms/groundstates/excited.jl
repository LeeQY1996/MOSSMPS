# excited states: DMRG1 with orthogonality projectors against previously found states;
# reuses the same leftsweep!/rightsweep!/sweep! interface (no separate algorithm type)

# ---------- ExcitedStateCache: DMRG1 environments with orthogonality projectors ----------

struct ExcitedStateCache{M<:AbstractMPO, V<:CanonicalMPS, P<:CanonicalMPS, T, OC<:OverlapCache}
	H::M
	ket::V
	projectors::Vector{P}
	hstorage::Vector{Array{T,3}}
	cstorages::Vector{OC}
end

"""
	ExcitedStateCache(ψ::CanonicalMPS, h::AbstractMPO, projectors::Vector{CanonicalMPS})

Environment cache for the excited-state search of `ψ`: one overlap cache per projector.
"""
function ExcitedStateCache(ψ::CanonicalMPS, h::AbstractMPO, projectors::Vector{<:CanonicalMPS})
	env = DMRGCache(ψ, h)
	cs = [OverlapCache(ψ, p) for p in projectors]
	return ExcitedStateCache(h, ψ, projectors, env.hstorage, cs)
end

function updateleft!(env::ExcitedStateCache, site::Integer)
	env.hstorage[site+1] = _updateleft(env.hstorage[site], env.ket[site], env.H[site], env.ket[site])
	for c in env.cstorages
		updateleft!(c, site)
	end
	return env
end

function updateright!(env::ExcitedStateCache, site::Integer)
	env.hstorage[site] = _updateright(env.hstorage[site+1], env.ket[site], env.H[site], env.ket[site])
	for c in env.cstorages
		updateright!(c, site)
	end
	return env
end

# ---------- projected DMRG1 sweeps ----------

"""
	leftsweep!(env::ExcitedStateCache, alg::DMRG1) -> kvals

One left-to-right projected DMRG1 sweep: the local problem minimizes
`⟨x|H_eff|x⟩` in the orthogonal complement of all effective projector tensors.
An implicit QR basis reduces the eigensolve to this complement without forming a
dense local basis. Excluded directions never enter the eigenproblem.
"""
function leftsweep!(env::ExcitedStateCache, alg::DMRG1)
	L = length(env.ket)
	kvals = zeros(Float64, L)
	for s in 1:L-1
		kvals[s], _ = _projected_local_update!(env, s, alg)
		(alg.verbosity > 2) && _logupdate(stdout, "l2r", s, kvals[s])
		q, r = leftorth!(env.ket[s], (1, 2), (3,))
		env.ket[s] = q
		env.ket[s+1] = _contract_first(env.ket[s+1], r)
		updateleft!(env, s)
	end
	kvals[L], _ = _projected_local_update!(env, L, alg)
	(alg.verbosity > 2) && _logupdate(stdout, "l2r", L, kvals[L])
	return kvals
end

"""
	rightsweep!(env::ExcitedStateCache, alg::DMRG1) -> kvals

One right-to-left projected DMRG1 sweep. `kvals` is ordered by processing time —
sites `L, L-1, …, 1`.
"""
function rightsweep!(env::ExcitedStateCache, alg::DMRG1)
	L = length(env.ket)
	kvals = zeros(Float64, L)
	k = 1
	for s in L:-1:2
		kvals[k], _ = _projected_local_update!(env, s, alg)
		(alg.verbosity > 2) && _logupdate(stdout, "r2l", s, kvals[k])
		k += 1
		l, q = rightorth!(env.ket[s], (1,), (2, 3))
		env.ket[s] = q
		env.ket[s-1] = _contract_last(env.ket[s-1], l)
		updateright!(env, s)
	end
	kvals[L], _ = _projected_local_update!(env, 1, alg)
	(alg.verbosity > 2) && _logupdate(stdout, "r2l", 1, kvals[L])
	return kvals
end

sweep!(env::ExcitedStateCache, alg::DMRG1) = vcat(leftsweep!(env, alg), rightsweep!(env, alg))

function _projected_local_update!(env::ExcitedStateCache, s::Integer, alg::DMRG1)
	heff = Heff(env.H[s], env.hstorage[s], env.hstorage[s+1])
	# effective projector tensors: bra-side environments of the projectors at site s
	peff = [@tensor pe[-1, -2, -3] := c.cstorage[s][-1, 1] * c.ket[s][1, -2, 2] * c.cstorage[s+1][-3, 2]
			for c in env.cstorages]
	shape = size(env.ket[s])
	n = length(env.ket[s])
	constraints = isempty(peff) ? zeros(scalartype(env.ket), n, 0) : hcat(vec.(peff)...)
	# Normalize before rank detection so rescaled and repeated constraints keep the same span.
	for p in eachcol(constraints)
		scale = maximum(abs, p)
		isfinite(scale) || throw(ArgumentError("non-finite excited-state constraint"))
		if scale > 0
			p ./= scale
			p ./= norm(p)
		end
	end
	factor = qr(constraints, ColumnNorm())
	tolerance = max(size(constraints)...) * eps(real(float(eltype(constraints))))
	r = count(x -> abs(x) > tolerance, diag(factor.R))
	r < n || throw(ArgumentError("excited-state constraints leave no local orthogonal subspace"))
	# The implicit Q stores only the constraint reflectors, not an n×n complement matrix.
	lift(v) = reshape(factor.Q * vcat(zeros(eltype(v), r), v), shape)
	restrict(x) = (factor.Q' * vec(x))[r+1:end]
	guess = restrict(env.ket[s])
	norm(guess) <= tolerance * norm(env.ket[s]) && fill!(guess, one(eltype(guess)))
	vals, vecs, info = eigsolve(v -> restrict(ac_prime(lift(v), heff)), guess, 1, :SR, alg.alg_eigsolve)
	env.ket[s] = lift(vecs[1])
	return real(vals[1]), info
end

"""
	excited_state!(ψ::CanonicalMPS, h::AbstractMPO, projectors::Vector{CanonicalMPS},
				   alg::DMRG1=DMRG1()) -> info

Search for the lowest state orthogonal to all `projectors`, starting from the initial
state `ψ` (modified in place; e.g. `ψ = randommps(ComplexF64, ophydims(h); D=D)`).
Returns `info`, the [`ALSConvergenceInfo`](@ref) of the sweeps (`info.losses` is the
per-sweep local-energy history).
"""
function excited_state!(ψ::CanonicalMPS, h::AbstractMPO, projectors::Vector{<:CanonicalMPS}, alg::DMRG1=DMRG1())
	bonddim(ψ) != alg.D && changebond!(ψ; D=alg.D)
	env = ExcitedStateCache(ψ, h, projectors)
	info = iterative_compute!(env, alg)
	return info
end

"""
	excited_state(h::MPOHamiltonian, alg::DMRG1, ψ0::CanonicalMPS...) -> (E, ψ, info)

The lowest excited state orthogonal to all given previous states `ψ0`, starting from a
random initial state of bond dimension `alg.D`; `info` is the
[`ALSConvergenceInfo`](@ref) of the sweeps.
"""
function excited_state(h::MPOHamiltonian, alg::DMRG1, ψ0::CanonicalMPS...)
	ψ = randommps(scalartype(h), ophydims(h); D=alg.D)
	info = excited_state!(ψ, h, collect(ψ0), alg)
	(alg.verbosity > 1) && println("excited DMRG1 converged (delta = $(info.itererr))")
	return expectation(h, ψ), ψ, info
end

excited_state(h::MPOHamiltonian, ψ0::CanonicalMPS...) =
	excited_state(h, DMRG1(), ψ0...)
