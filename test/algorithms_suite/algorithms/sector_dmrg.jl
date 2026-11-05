@testset "strict charge-sector DMRG and robust Born sampling" begin
    rng = MersenneTwister(20261103)
    ds = [2,3,4]
    charges = [[(0,0),(1,0)],[(0,0),(1,0),(0,1)],[(0,0),(1,0),(0,1),(1,1)]]
    I2,I3,I4 = [Matrix{ComplexF64}(I,d,d) for d in ds]
    locals = [Diagonal([0.2q[1]-0.13q[2]+0.04s*(q[1]+q[2]) for q in charges[s]]) for s in 1:3]
    terms = OpTerm[OpTerm(1.0,s=>Matrix(locals[s])) for s in 1:3]
    H = kron(Matrix(locals[1]),I3,I4) + kron(I2,Matrix(locals[2]),I4) + kron(I2,I3,Matrix(locals[3]))
    # Independently specify alpha/beta transfers as local matrix units.
    function unit(d,a,b)
        M=zeros(ComplexF64,d,d); M[a,b]=1; return M
    end
    for (s,t,p1,p2,q1,q2,c) in [(1,2,2,1,1,2,0.37+0.12im),
                                (2,3,3,1,1,3,-0.22+0.09im),
                                (1,3,2,1,3,4,0.18-0.07im)]
        O1,O2=unit(ds[s],p1,p2),unit(ds[t],q1,q2)
        push!(terms,OpTerm(c,s=>O1,t=>O2),OpTerm(conj(c),s=>O1',t=>O2'))
        matrices=[copy(I2),copy(I3),copy(I4)]; matrices[s]=O1; matrices[t]=O2
        T=c*kron(matrices...); H += T+T'
    end
    h=MPOHamiltonian(OpSum(ds,terms))
    configs = [Tuple(x) for x in Iterators.product((1:d for d in ds)...)]
    flat(x)=1+sum((x[s]-1)*prod(ds[s+1:end]) for s in 1:3)
    target=(1,1)
    indices=sort([flat(x) for x in configs if
        (sum(charges[s][x[s]][1] for s in 1:3),sum(charges[s][x[s]][2] for s in 1:3))==target])
    exact=minimum(eigvals(Hermitian(H[indices,indices])))
    result=sector_ground_state(h,charges; target,rng,max_bond=8,sweeps=8,tolerance=1e-11)
    @test result.energy ≈ exact atol=1e-10
    @test result.converged
    @test result.norm ≈ 1 atol=1e-12
    @test sector_leakage(result.mps,result.bond_charges,charges;target)==0
    dense=todense(result.mps)
    @test norm(dense[setdiff(1:length(dense),indices)]) < 1e-13
    @test norm(H[indices,indices]*dense[indices]-result.energy*dense[indices]) < 1e-10
    @test all(x->x.residual < 1e-9,result.local_iterations)
    @test all(x->x.discarded_weight >= 0,result.truncations)
    @test_throws ArgumentError sector_ground_state(h,charges;target,rng,max_bond=8,memory_budget=1)
    @test_throws ArgumentError sector_ground_state(h,charges;target=(9,9),rng)
    # Warm starts are copied. DMRG1 keeps its initial charge/bond space.
    before=deepcopy(result.mps.data)
    r1=sector_ground_state(h,charges;target,rng,initial=result,method=:dmrg1,max_bond=8,sweeps=3,tolerance=1e-11)
    @test r1.energy ≈ exact atol=1e-10
    @test result.mps.data==before
    @test r1.diagnostics.method==:dmrg1
    # Sampling works on noncanonical tensors and ignores stale Schmidt data.
    ψ=CanonicalMPS(deepcopy(result.mps.data))
    G=diagm(ComplexF64.(range(0.3,2;length=size(ψ[1],3))))
    ψ.data[1]=reshape(reshape(ψ[1],:,size(G,1))*G,size(ψ[1]))
    ψ.data[2]=reshape(inv(G)*reshape(ψ[2],size(G,1),:),size(ψ[2]))
    @test todense(ψ) ≈ dense atol=1e-12
    snapshot=deepcopy(ψ)
    samples=sample(MersenneTwister(31),ψ,40_000)
    @test samples==sample(MersenneTwister(31),ψ,40_000)
    @test ψ.data==snapshot.data && isequal(ψ.s,snapshot.s) && scaling(ψ)==scaling(snapshot)
    empirical=zeros(length(dense))
    for x in samples; empirical[flat(x)]+=1/length(samples); end
    # Fixed, conservative 6-sigma marginal confidence interval (all 24 bins).
    p=abs2.(dense); p/=sum(p)
    @test all(abs.(empirical.-p) .<= 6sqrt.(p.*(1 .-p)./length(samples)) .+ 6/length(samples))
    @test all((sum(charges[s][x[s]][1] for s in 1:3),sum(charges[s][x[s]][2] for s in 1:3))==target for x in samples)
    long=CanonicalMPS([fill(0.01+0im,1,2,1) for _ in 1:1200])
    @test length(sample(MersenneTwister(1),long,3))==3
    tiny=CanonicalMPS([fill(1e-200+0im,1,2,1) for _ in 1:4])
    @test length(sample(MersenneTwister(1),tiny,3))==3
    @test_throws ArgumentError sample(rng,CanonicalMPS([zeros(ComplexF64,1,2,1)]),1)
    @test_throws ArgumentError sample(rng,ψ,-1)
    # Independent old-style combined-MPO oracle only in this tiny test.
    W1=randn(rng,ComplexF64,2,2,3,2); W2=randn(rng,ComplexF64,3,3,2,3)
    hl=randn(rng,ComplexF64,2,2,2); hr=randn(rng,ComplexF64,2,2,2)
    x=randn(rng,ComplexF64,2,2,3,2)
    heff=MOSSQuantumMPS.MPSAlgorithms.TwoSiteHeff(W1,W2,hl,hr)
    @tensor combined[wl,p,q,wr,i,j] := W1[wl,p,k,i]*W2[k,q,wr,j]
    @tensor expected[a,p,q,b] := hl[a,wl,c]*combined[wl,p,q,wr,i,j]*x[c,i,j,d]*hr[b,wr,d]
    @test MOSSQuantumMPS.MPSAlgorithms.ac2_prime(x,heff) ≈ expected atol=1e-10
    @test_throws ArgumentError MOSSQuantumMPS.MPSAlgorithms.ac2_prime(x,heff;memory_budget=1)
    # A budgeted cache contracts each MPO site with its environment once,
    # then applies two packed matrix multiplies per Krylov step. Compare
    # both adaptive branches with the independent nonuniform Wcomb oracle.
    action,plan=MOSSQuantumMPS.MPSAlgorithms._sector_two_site_action(x,heff;memory_budget=2^20)
    @test plan.mode==:cached_halves
    @test action(x) ≈ expected atol=1e-10
    @test action(x) ≈ MOSSQuantumMPS.MPSAlgorithms.ac2_prime(x,heff) atol=1e-10
    @test plan.cache_bytes > 0
    @test plan.cached_flops_per_action < plan.sequential_flops_per_action
    @test plan.cached_workspace_bytes > plan.sequential_workspace_bytes
    fallback_budget=Int(plan.sequential_workspace_bytes)
    fallback,fallback_plan=MOSSQuantumMPS.MPSAlgorithms._sector_two_site_action(
        x,heff;memory_budget=fallback_budget)
    @test fallback_plan.mode==:sequential
    @test fallback_plan.cache_bytes==0
    @test fallback(x) ≈ expected atol=1e-10
    @test_throws ArgumentError MOSSQuantumMPS.MPSAlgorithms._sector_two_site_action(
        x,heff;memory_budget=1)
    @test sum(values(result.diagnostics.contraction_modes))==length(result.local_iterations)
    @test result.diagnostics.action_invocations==sum(z.action_invocations for z in result.local_iterations)
    # Eager Ritz checks avoid full 32-vector growth for an accurate warm start,
    # while the explicit residual tolerance remains the same.
    diag=vcat(0.0,range(0.5,2.0,length=127))
    diagonal=Diagonal(diag)
    warm=ComplexF64.(vcat(1.0,1e-5*randn(MersenneTwister(3),127)))
    warm/=norm(warm)
    K=MOSSQuantumMPS.MPSAlgorithms.KrylovKit
    _,_,lazy=K.eigsolve(v->diagonal*v,warm,1,:SR;
        ishermitian=true,tol=1e-10,maxiter=200,krylovdim=32,eager=false)
    value,_,eager=MOSSQuantumMPS.MPSAlgorithms._sector_eigensolve(
        x->reshape(diagonal*vec(x),size(x)),reshape(warm,1,128,1),collect(1:128);
        tolerance=1e-10,local_maxiter=200,memory_budget=2^20)
    @test abs(value) < 1e-10
    @test eager.residual < 1e-9
    @test eager.numops < lazy.numops
    @test result.diagnostics.local_eigensolver_eager

end
