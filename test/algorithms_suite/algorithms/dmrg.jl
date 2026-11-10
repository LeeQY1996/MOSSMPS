@testset "dmrg" begin
	Random.seed!(2024)
	L = 8
	p = model_params(L)
	H = mpo_model(p)
	Hd = dense_model(p)
	E_exact = eigmin(Hermitian(Hd))

	# DMRG1, random initial state (bond dimension D)
	E, ψ, info = ground_state(H, DMRG1(maxiter=50, tol=1e-12, verbosity=0, D=32))
	@test real(E) ≈ E_exact atol = 1e-8
	@test norm(ψ) ≈ 1 atol = 1e-8
	@test info isa ALSConvergenceInfo
	@test info.residual === nothing   # the loss is the energy up to a constant

	# DMRG1 from a caller-provided initial state
	ψ2 = randommps(ComplexF64, fill(2, L); D=8)
	khist = ground_state!(ψ2, H, DMRG1(maxiter=50, tol=1e-12, verbosity=0)).losses
	@test real(expectation(H, ψ2)) ≈ E_exact atol = 1e-8
	# per-sweep energies decrease towards E_exact
	@test abs(last(last(khist)) - E_exact) < abs(first(last(khist)) - E_exact) + 1e-12
	# the ALS sweeps only iterate; guesses and bond caps are caller-supplied

	# unified sweep interface drives the same iteration
	ψ3 = randommps(ComplexF64, fill(2, L); D=32)
	canonicalize!(ψ3)
	env = DMRGCache(ψ3, H)
	for _ in 1:30
		kvals = sweep!(env, DMRG1(maxiter=1, tol=0.0, verbosity=0))
	end
	@test real(expectation(H, ψ3)) ≈ E_exact atol = 1e-8

	# excited state
	p6 = model_params(6)
	H6 = mpo_model(p6)
	Hd6 = dense_model(p6)
	e = eigen(Hermitian(Hd6))
	E0, ψ0d = e.values[1], e.vectors[:, 1]
	E0gs, ψ0, _ = ground_state(H6, DMRG1(maxiter=50, tol=1e-12, verbosity=0, D=32))
	E1_exact = e.values[2]   # the first excited level (orthogonal to the exact GS)
	E1, ψ1, _ = excited_state(H6, DMRG1(maxiter=50, tol=1e-12, verbosity=0, D=32), ψ0)
	@test abs(real(E1) - E1_exact) < 1e-6
        @test abs(dot(todense(ψ1), todense(ψ0))) < 1e-6
end

@testset "excited-state constraints and energy shifts" begin
    p0 = prodmps(Float64, [2, 2], [1, 1])
    p1 = prodmps(Float64, [2, 2], [2, 1])
    scaled = copy(p0)
    scaled[1] .*= 3
    mixed = complex(p0) + im * complex(p1)
    alg = DMRG1(D=2, maxiter=20, tol=1e-12)
    for shift in (-5.0, 0.0, 5.0)
        H = MPOHamiltonian(2, OpTerm(1.0, 1 => [1+shift 0; 0 2+shift]),
                             OpTerm(1.0, 2 => [1.0 0; 0 3.0]))
        for constraints in ((p0,), (scaled,), (p0, scaled, p0))
            Random.seed!(1)
            E, state, _ = excited_state(H, alg, constraints...)
            @test E ≈ 3+shift atol=1e-10
            @test abs(dot(p0, state)) < 1e-10
            @test norm(state) ≈ 1 atol=1e-10
        end
        Random.seed!(1)
        E, state, _ = excited_state(complex(H), alg, complex(p0), mixed, mixed)
        @test E ≈ 4+shift atol=1e-10
        @test abs(dot(p0, state)) < 1e-10
        @test abs(dot(p1, state)) < 1e-10
    end
    H = MPO([reshape([1.0 0; 0 2.0], 1, 2, 1, 2)])
    states = [prodmps(Float64, [2], [p]) for p in 1:2]
    @test_throws ArgumentError excited_state!(copy(states[1]), H, states, DMRG1(D=1))
end

@testset "two-site algorithms reject single-site chains" begin
    state = prodmps(Float64, [2], [1])
    H = identitympo(Float64, [2])
    alg = DMRG2(maxiter=2, trunc=NoTruncation())
    for run in (() -> ground_state!(copy(state), H, alg),
                () -> compress(state, alg),
                () -> compress!(copy(state), state, alg),
                () -> add([state, state], alg),
                () -> add!(copy(state), [state, state], alg),
                () -> mult(H, state, alg),
                () -> mult!(copy(state), H, state, alg),
                () -> hadamard(state, state, alg),
                () -> hadamard!(copy(state), state, state, alg),
                () -> linsolve(H, state, ALSLinSolve2(maxiter=2)),
                () -> linsolve!(copy(state), H, state, ALSLinSolve2(maxiter=2)),
                () -> add([CanonicalMPO(Float64, [2])], alg))
        error = try
            run()
            nothing
        catch error
            error
        end
        @test error isa ArgumentError
        @test occursin("at least two sites", sprint(showerror, error))
    end
    env = DMRGCache(copy(state), H)
    @test_throws ArgumentError leftsweep!(env, alg)
    @test_throws ArgumentError rightsweep!(env, alg)
end

@testset "dmrg coverage" begin
	Random.seed!(77)
	p6 = model_params(6)
	H6 = mpo_model(p6)
	Hd6 = dense_model(p6)
	e = eigen(Hermitian(Hd6))

	# excited_state! (in-place variant, caller-provided random initial state)
	E0gs, ψ0, _ = ground_state(H6, DMRG1(maxiter=50, tol=1e-12, verbosity=0, D=32))
	ψex = randommps(ComplexF64, fill(2, 6); D=8)
	khist = excited_state!(ψex, H6, [ψ0], DMRG1(maxiter=50, tol=1e-12, verbosity=0))
	E1_exact = e.values[2]
	@test abs(real(expectation(H6, ψex)) - E1_exact) < 1e-6

	# the second excited state, projected against both lower states
	ψ2 = randommps(ComplexF64, fill(2, 6); D=8)
	excited_state!(ψ2, H6, [ψ0, ψex], DMRG1(maxiter=50, tol=1e-12, verbosity=0))
	@test abs(real(expectation(H6, ψ2)) - e.values[3]) < 1e-6
	@test abs(dot(todense(ψ2), todense(ψ0))) < 1e-6
	@test abs(dot(todense(ψ2), todense(ψex))) < 1e-6

	# leftsweep! / rightsweep! (explicit single-direction sweeps)
	H = mpo_model(p6)
	ψs = randommps(ComplexF64, fill(2, 6); D=4)
	canonicalize!(ψs)
	env = DMRGCache(ψs, H)
	kleft = leftsweep!(env, DMRG1(maxiter=1, tol=0.0, verbosity=0))
	@test length(kleft) == 6
	kright = rightsweep!(env, DMRG1(maxiter=1, tol=0.0, verbosity=0))
	@test length(kright) == 6

	# ac_prime / c_prime / Heff
	W = H[1]
	hl = env.hstorage[1]
	hr = env.hstorage[2]
	x = ψs[1]
	y_ac = ac_prime(x, W, hl, hr)
	@test size(y_ac) == (size(hl, 1), phydim(W), size(hr, 1))
	heff = Heff(W, hl, hr)
	@test heff isa MOSSMPS.MPSAlgorithms.CentralHeff
	y_heff = ac_prime(x, heff)
	@test y_heff ≈ y_ac atol = 1e-12
	hleft_c = randn(ComplexF64, 3, 2, 4)   # (a, w, b)
	hright_c = randn(ComplexF64, 5, 2, 6)  # (c, w, d)
	xmat = randn(ComplexF64, 4, 6)        # (b, d)
	yc = c_prime(xmat, hleft_c, hright_c)
	@test size(yc) == (3, 5)
	# c_prime vs the direct three-tensor contraction
	yref = @tensor yr[a, c] := hleft_c[a, w, b] * xmat[b, e] * hright_c[c, w, e]
	@test yc ≈ yref atol = 1e-12

	# --- ac_prime / Heff: dense branch vs the direct four-tensor contraction ---
	# the W-form requires identity corners at (1,1) and (wl,wr)
	Random.seed!(3)
	Wd = randn(ComplexF64, 3, 2, 4, 2)     # (wL, p', wR, p)
	Wd[1, :, 1, :] = Matrix{ComplexF64}(I, 2, 2)
	Wd[3, :, 4, :] = Matrix{ComplexF64}(I, 2, 2)
	# strictly upper-triangular Schur structure: lower-triangular blocks and the last
	# row (except the closing corner) have no Schur-form slot
	Wd[2, :, 1, :] .= 0; Wd[3, :, 1:3, :] .= 0
	hl = randn(ComplexF64, 5, 3, 6)        # (a', wL, l)
	hr = randn(ComplexF64, 7, 4, 8)        # (c', wR, r)
	xc = randn(ComplexF64, 6, 2, 8)        # (l, p, r)
	yd = ac_prime(xc, Wd, hl, hr)
	yref = @tensor yr[a, p2, c] := hl[a, wl, l] * Wd[wl, p2, wr, p] * xc[l, p, r] * hr[c, wr, r]
	@test yd ≈ yref atol = 1e-12
	# the bundled Heff applies identically
	@test ac_prime(xc, Heff(Wd, hl, hr)) ≈ yref atol = 1e-12

	# --- sparse branch vs the dense branch on an equivalent operator ---
	blocks = Matrix{Any}(undef, 3, 4)
	blocks .= 0
	blocks[1, 1] = 1; blocks[3, 4] = 1     # implied identity corners
	for j in 1:4, i in 1:3
		((i == 1 && j == 1) || (i == 3 && j == 4)) && continue
		iszero(Wd[i, :, j, :]) || (blocks[i, j] = Wd[i, :, j, :])
	end
	Ws = SchurMPOTensor(blocks)
	@test ac_prime(xc, Ws, hl, hr) ≈ yref atol = 1e-12
	heff_s = Heff(Ws, hl, hr)
	@test ac_prime(xc, heff_s) ≈ yref atol = 1e-12
	# the site tensor is stored as-is: Heff does not convert the Schur form
	@test heff_s.W == Ws && heff_s.left === hl && heff_s.right === hr
end

@testset "dmrg2" begin
	Random.seed!(77)
	L = 8
	p = model_params(L)
	H = mpo_model(p)
	Hd = dense_model(p)
	E_exact = eigmin(Hermitian(Hd))

	# DMRG2, random initial state (dimension truncation)
	E2, ψ2, _ = ground_state(H, DMRG2(maxiter=50, tol=1e-12, verbosity=0, trunc=truncdim(D=32)))
	@test real(E2) ≈ E_exact atol = 1e-8
	@test norm(ψ2) ≈ 1 atol = 1e-8

	# other truncation schemes work as the truncation policy
	E2n, ψ2n, _ = ground_state(H, DMRG2(maxiter=50, tol=1e-12, verbosity=0, trunc=NoTruncation()))
	@test real(E2n) ≈ E_exact atol = 1e-8

	# DMRG2 from a caller-provided initial state (alg.trunc only affects the sweeps)
	ψ0 = randommps(ComplexF64, fill(2, L); D=4)
	ground_state!(ψ0, H, DMRG2(maxiter=50, tol=1e-12, verbosity=0, trunc=truncdim(D=32)))
	@test real(expectation(H, ψ0)) ≈ E_exact atol = 1e-8

	# agreement with DMRG1 on the same model
	E1, _, _ = ground_state(H, DMRG1(maxiter=50, tol=1e-12, verbosity=0, D=32))
	@test real(E2) ≈ real(E1) atol = 1e-8

	# the right sweep keeps the SVD singular values as the bond Schmidt spectra and
	# normalizes the remaining center: the output MPS is canonical
	@test iscanonical(ψ2)
	# the recorded spectra match the exact ground-state Schmidt values (no truncation
	# at D = 32 for L = 8): bond-b spectrum = SVD of the ground state reshaped
	# (2^(L-b), 2^b), i.e. the first b sites on one side
	ψgs = vec(eigen(Hermitian(Hd)).vectors[:, 1])
	for b in (2, 4, 6)
		sv_ed = svdvals(reshape(ψgs, 2^(L - b), 2^b))
		@test schmidt_values(ψ2; bond=b) ≈ sv_ed atol = 1e-8
	end
end
