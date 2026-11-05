# Two-site DMRG (DMRG2): the two-site update optimizes the two center tensors of
# sites (s, s+1) jointly against the two-site effective Hamiltonian and truncates the
# result by SVD under `alg.trunc`. The SVD itself moves the orthogonality center (singular
# values absorbed into the sweep direction), so no QR gauge moves are performed and the
# not-yet-swept tensors keep their canonical form.

# ---------- two-site effective Hamiltonian ----------

"""
	TwoSiteHeff{W1,W2,T}

Two-site effective Hamiltonian: the MPO tensors of sites `s` and `s+1` together with
their left and right environments.
"""
struct TwoSiteHeff{W1<:Union{MPOTensor,SchurMPOTensor},
				   W2<:Union{MPOTensor,SchurMPOTensor},T}
	W1::W1
	W2::W2
	left::Array{T,3}
	right::Array{T,3}
end

"""
    two_site_memory_estimate(x, heff)

Conservative bytes for the sequential two-site action, including dense site
copies for Schur tensors. This estimate has no `W_L*W_R*d1^2*d2^2` object.
"""
function two_site_memory_estimate(x, heff::TwoSiteHeff)
    W1, W2 = heff.W1, heff.W2
    Dl, d1, d2, Dr = size(x)
    Db = size(heff.right, 1)
    wl, wm, wr = space_l(W1), space_r(W1), space_r(W2)
    d1o, d2o = phydim(W1), phydim(W2)
    objects = big(Dl)*d1*d2*wr*Db + big(Dl)*d1*d2o*wm*Db +
              big(Dl)*wl*d1o*d2o*Db + big(size(heff.left,1))*d1o*d2o*Db + length(x)
    W1 isa SchurMPOTensor && (objects += big(wl)*d1o*wm*d1)
    W2 isa SchurMPOTensor && (objects += big(wm)*d2o*wr*d2)
    return objects * sizeof(promote_type(eltype(x), scalartype(W1), scalartype(W2)))
end

function ac2_prime(x::AbstractArray{T,4}, heff::TwoSiteHeff;
                   memory_budget::Integer=typemax(Int)) where {T}
    required = two_site_memory_estimate(x, heff)
    required <= memory_budget || throw(ArgumentError(
        "two-site contraction requires approximately $required bytes, budget=$memory_budget"))
    W1 = heff.W1 isa SchurMPOTensor ? tompotensor(heff.W1) : heff.W1
    W2 = heff.W2 isa SchurMPOTensor ? tompotensor(heff.W2) : heff.W2
    hl, hr = heff.left, heff.right
    # Contract with the state before joining MPO bonds. In particular, never
    # construct Wcomb[wl,p1o,p2o,wr,p1i,p2i].
    @tensor m1[b, q1, q2, wr, c] := x[b, q1, q2, r] * hr[c, wr, r]
    @tensor m2[b, q1, p2, wm, c] := m1[b, q1, q2, wr, c] * W2[wm, p2, wr, q2]
    @tensor m3[b, wl, p1, p2, c] := m2[b, q1, p2, wm, c] * W1[wl, p1, wm, q1]
    @tensor y[a, p1, p2, c] := hl[a, wl, b] * m3[b, wl, p1, p2, c]
    return y
end

# ---------- algorithm type ----------
# the `DMRG2{TR}` configuration struct and `_truncation_bond` live in algdefs.jl
# (shared with the arithmetics engines)

# ---------- sweeps ----------

"""
	leftsweep!(env::DMRGCache, alg::DMRG2) -> kvals

Left-to-right two-site DMRG sweep: the pair (s, s+1) is optimized jointly and the SVD
absorbs the singular values into site s+1 (the new orthogonality center); the swept
tensors stay left-canonical, the not-yet-swept tensors stay right-canonical.
"""
function leftsweep!(env::DMRGCache, alg::DMRG2)
	L = length(env.ket)
	kvals = zeros(Float64, L)
	for s in 1:L-1
		kvals[s], _ = _dmrg2_local_update!(env, s, alg; move_right=true)
		(alg.verbosity > 2) && _logupdate(stdout, "l2r", s, kvals[s])
		# rebuild the left environment with the updated site s
		updateleft!(env, s)
	end
	kvals[L] = kvals[L-1]
	return kvals
end

"""
	rightsweep!(env::DMRGCache, alg::DMRG2) -> kvals

Right-to-left two-site DMRG sweep (symmetric to `leftsweep!`): singular values are
absorbed into the left site of each pair, keeping the already-swept tensors
right-canonical. The SVD singular values are the true Schmidt spectrum at the swept
bond and are recorded on the state (`ket.s[bond+1]`); the final center (site 1) is
normalized, so the returned MPS satisfies `iscanonical`.
"""
function rightsweep!(env::DMRGCache, alg::DMRG2)
	L = length(env.ket)
	kvals = zeros(Float64, L)
	k = 1
	for s in L:-1:2
		kvals[k], _, sv = _dmrg2_local_update!(env, s - 1, alg; move_right=false)
		(alg.verbosity > 2) && _logupdate(stdout, "r2l", s - 1, kvals[k])
		# the SVD singular values are the Schmidt spectrum at bond s - 1
		env.ket.s[s] = collect(sv)
		k += 1
		# rebuild the right environment with the updated site s
		updateright!(env, s)
	end
	# the remaining center at site 1 carries the boundary bond's spectrum: normalize it
	# (and the recorded spectrum with it) so the full state is right-canonical, unit norm
	nrm = norm(env.ket[1])
	env.ket.data[1] = env.ket[1] ./ nrm
	env.ket.s[2] = collect(env.ket.s[2] ./ nrm)
	kvals[L] = kvals[L-1]
	return kvals
end

sweep!(env::DMRGCache, alg::DMRG2) = vcat(leftsweep!(env, alg), rightsweep!(env, alg))

function _dmrg2_local_update!(env::DMRGCache, s::Integer, alg::DMRG2; move_right::Bool=true)
	@assert s < length(env.ket)
	W1, W2 = env.H[s], env.H[s+1]
	heff = TwoSiteHeff(W1, W2, env.hstorage[s], env.hstorage[s+2])

	# Check the tensor and Krylov vectors before constructing the pair tensor.
	A, B = env.ket[s], env.ket[s+1]
	entries = big(size(A,1))*size(A,2)*size(B,2)*size(B,3)
	nvectors = hasproperty(alg.alg_eigsolve, :krylovdim) ? alg.alg_eigsolve.krylovdim + 5 : 40
	required = entries * sizeof(scalartype(env.ket)) * nvectors
	required <= alg.memory_budget || throw(ArgumentError(
		"two-site tensor and Krylov vectors require approximately $required bytes, budget=$(alg.memory_budget)"))
	# initial guess: the two-site tensor formed from the current site tensors
	@tensor guess[aL, p1, p2, aR] := env.ket[s][aL, p1, b] * env.ket[s+1][b, p2, aR]

	vals, vecs, info = eigsolve(y -> ac2_prime(y, heff; memory_budget=alg.memory_budget), guess, 1, :SR, alg.alg_eigsolve)
	Ψ = vecs[1]
	E = real(vals[1])

	# SVD truncate the optimal two-site tensor.
	# `move_right=true`  (left sweep):  absorb singular values into the right site (s+1).
	# `move_right=false` (right sweep): absorb singular values into the left  site (s).
	u, sv, v, _ = tsvd!(Ψ, (1, 2), (3, 4); trunc=alg.trunc)
	if move_right
		env.ket[s] = u
		sm = Diagonal(sv)
		@tensor vnew[nb, p2, aR] := sm[nb, j] * v[j, p2, aR]
		env.ket[s+1] = vnew
	else
		env.ket[s+1] = v
		sm = Diagonal(sv)
		@tensor unew[aL, p1, nb] := u[aL, p1, j] * sm[j, nb]
		env.ket[s] = unew
	end

	return E, info, sv
end

# ---------- driver ----------

"""
	ground_state!(ψ::CanonicalMPS, h::AbstractMPO, alg::DMRG2) -> info

Two-site DMRG ground-state search starting from the user-provided ansatz `ψ`
(modified in place; `alg.trunc` only affects the sweep truncations). Returns `info`,
the [`ALSConvergenceInfo`](@ref) of the sweeps (`info.losses` is the per-sweep
local-energy history).
"""
function ground_state!(ψ::CanonicalMPS, h::AbstractMPO, alg::DMRG2)
	env = DMRGCache(ψ, h)
	info = iterative_compute!(env, alg)
	setscaling!(ψ, 1.0)
	lmul!(1 / norm(ψ), ψ)
	return info
end

"""
	ground_state(h::MPOHamiltonian, alg::DMRG2) -> (E, ψ, info)

Ground-state energy and state of `h` found by two-site DMRG, starting from a random MPS
of bond `Defaults.D`; `info` is the [`ALSConvergenceInfo`](@ref) of the sweeps.
"""
function ground_state(h::MPOHamiltonian, alg::DMRG2)
	ψ = randommps(scalartype(h), ophydims(h); D=_guess_bond(alg.trunc))
	info = ground_state!(ψ, h, alg)
	(alg.verbosity > 1) && println("DMRG2 converged (delta = $(info.itererr))")
	return expectation(h, ψ), ψ, info
end