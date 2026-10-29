# sparse (Schur matrix-of-matrices) MPO: construction and dense conversion

@testset "sparse MPO" begin
	Random.seed!(1234)
	σx = Float64[0 1; 1 0]
	σz = Float64[1 0; 0 -1]
	L = 6
	p = model_params(L)

	# Schur-form assembly from terms vs product-MPO assembly
	hs = mpo_model(p)          # OpTerm route
	hd = mpo_model_prod(p)     # prodmpo + `+` route

	@testset "Schur construction and dense conversion" begin
		@test hs[1] isa SchurMPOTensor
		# 6 on-site + 5 bond + 4 next-nearest terms -> 9 private channels + 2;
		# every site carries the full logical shape (boundaries are tompotensors' job)
		@test size(hs[1]) == (11, 11)
		@test size(hs[2]) == (11, 11)
		@test size(hs[end]) == (11, 11)
		@test all(W -> size(W) == (11, 11), hs)
		@test scalartype(hs) == ComplexF64
		@test todense(hs) ≈ todense(hd) atol = 1.0e-12
		@test todense(hs) ≈ dense_model(p) atol = 1.0e-12
		@test_throws ArgumentError OpTerm(-1.0, 1 => σz, 1 => σz)
	end

	@testset "rectangular sparse site tensors" begin
		# edge-shaped logical matrices (m < 2 or n < 2) are rejected — chain boundaries
		# are not SchurMPOTensor's business
		edata = Matrix{Any}(undef, 3, 1)
		edata[1, 1] = 0.0; edata[2, 1] = σx; edata[3, 1] = 1.0
		@test_throws ArgumentError SchurMPOTensor(edata)
		fdata = Matrix{Any}(undef, 1, 3)
		fdata[1, 1] = 1.0; fdata[1, 2] = σx; fdata[1, 3] = 0.0
		@test_throws ArgumentError SchurMPOTensor(fdata)
		# an all-scalar logical matrix cannot infer phydim
		sdata = fill(0.0, 2, 2)
		@test_throws ArgumentError SchurMPOTensor(sdata)
	end

	@testset "rectangular Schur tensors" begin
		# left ≠ right channel spaces (the square case is the special case m == n)
		rdata = Matrix{Any}(undef, 3, 4)
		rdata .= 0.0
		rdata[1, 1] = 1; rdata[3, 4] = 1            # implied identity corners
		rdata[1, 2] = σx                             # C: vacuum -> interior
		rdata[2, 2] = σz                             # A interior diagonal
		rdata[2, 4] = σx                             # B: interior -> closing
		rdata[1, 4] = 2.0                            # D corner
		Wr = SchurMPOTensor(rdata)
		@test size(Wr) == (3, 4)
		@test Wr[1, 2] ≈ σx && Wr[2, 2] ≈ σz && Wr[2, 4] ≈ σx
		@test Wr[1, 4] ≈ 2 * isometry(Float64, 2)
		@test Wr[1, 1] == isometry(Float64, 2) && Wr[3, 4] == isometry(Float64, 2)
		@test all(iszero, Wr[2, 3]) && all(iszero, Wr[3, 1])
		# dense conversion keeps the rectangular logical shape
		Wd3 = MPSCore.tompotensor(Wr)
		@test size(Wd3) == (3, 2, 4, 2)
		@test Wd3[1, :, 1, :] == isometry(Float64, 2)
		@test Wd3[3, :, 4, :] == isometry(Float64, 2)
		# lower-triangular assignments remain rejected
		@test_throws ArgumentError (Wr[3, 1] = σz)
		# block-native addition: the auxiliary (channel) dimensions add via block-diagonal
		# concatenation, only the D corners add element-wise
		wdata = Matrix{Any}(undef, 4, 3)
		wdata .= 0.0
		wdata[1, 1] = 1; wdata[4, 3] = 1          # implied identity corners
		wdata[1, 2] = σz                          # C: vacuum -> interior
		wdata[2, 2] = σx                          # A: interior diagonal
		wdata[2, 3] = σz                          # B: interior -> closing
		wdata[1, 3] = 0.5                         # D corner
		Wb = SchurMPOTensor(wdata)
		Wsum = Wr + Wb
		# the auxiliary dimensions add; the unit levels are shared (one vacuum / closing)
		@test space_l(Wsum) == space_l(Wr) + space_l(Wb) - 2
		@test space_r(Wsum) == space_r(Wr) + space_r(Wb) - 2
		@test Wsum.A == cat(Wr.A, Wb.A; dims=(1, 3))
		@test Wsum.B == cat(Wr.B, Wb.B; dims=1)
		@test Wsum.C == cat(Wr.C, Wb.C; dims=2)
		@test Wsum.D ≈ 2.5 * isometry(Float64, 2)
		# a physical-dimension mismatch is rejected
		mmdata = Matrix{Any}(undef, 2, 2)
		mmdata .= 0.0; mmdata[1, 1] = 1; mmdata[2, 2] = 1; mmdata[1, 2] = 1.0
		@test_throws ArgumentError Wr + SchurMPOTensor{Float64}(mmdata, 3)
	end

	@testset "rectangular MPOHamiltonian chain" begin
		# a two-site chain with rectangular site tensors (space_l ≠ space_r): site 1 is
		# 2×3 (vacuum + closing row, one interior column), site 2 is 3×2 (one interior
		# row, vacuum + closing column). The paths from (1,1) to the closing corner give
		# the represented operator H = D₂ + C₁⊗B₂
		o1 = Matrix{Any}(undef, 2, 3)
		o1 .= 0.0
		o1[1, 1] = 1; o1[2, 3] = 1            # the implied identity corners
		o1[1, 2] = σx                          # C₁: vacuum -> interior
		s1 = SchurMPOTensor(o1)
		o2 = Matrix{Any}(undef, 3, 2)
		o2 .= 0.0
		o2[1, 1] = 1; o2[3, 2] = 1
		o2[1, 2] = 0.5 * σz                    # D₂: on-site corner
		o2[2, 2] = σx                          # B₂: interior -> closing
		s2 = SchurMPOTensor(o2)
		hrect = MPOHamiltonian([s1, s2])
		@test size(hrect[1]) == (2, 3) && size(hrect[2]) == (3, 2)
		Hd = 0.5 * kron(I(2), σz) + kron(σx, σx)
		@test todense(MPO(hrect)) ≈ Hd atol = 1.0e-12
		# the dense roundtrip (test-side wrap) returns the same operator
		@test todense(hamiltonian(tompotensors(hrect))) ≈ Hd atol = 1.0e-12
	end

	@testset "MPOHamiltonian sums vs dense" begin
		# block-native chain sum: per site the auxiliary dimensions add
		h2 = MPOHamiltonian(ExpDecayOpSum(_SZ, I(2), _SZ, [0.3], [0.8]), L)
		Hsum = hs + h2
		@test Hsum isa MPOHamiltonian
		@test all(i -> size(Hsum[i]) == size(hs[i]) .+ size(h2[i]) .- 2, 1:L)
		# the block-native sum represents the same operator as the dense chain sum
		@test todense(MPO(Hsum)) ≈ todense(MPO(hs) + MPO(h2)) atol = 1.0e-12
	end

	@testset "expectation via sparse MPO" begin
		ψ = randommps(ComplexF64, fill(2, L); D=8)
		@test expectation(ψ, hs, ψ) ≈ expectation(ψ, hd, ψ) rtol = 1.0e-10

	end

end
