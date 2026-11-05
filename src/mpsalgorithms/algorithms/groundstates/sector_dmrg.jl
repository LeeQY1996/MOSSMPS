# Dense-array U(1)×U(1) MPS with explicit cumulative bond charges.
# Only reachable blocks participate in initialization, optimization and SVD.
const _SectorCharge = Tuple{Int,Int}
_qadd(a, b) = (a[1]+b[1], a[2]+b[2])
_qsub(a, b) = (a[1]-b[1], a[2]-b[2])
_qinside(a, target) = 0 <= a[1] <= target[1] && 0 <= a[2] <= target[2]

function _sector_budget(bytes, budget, description)
    bytes <= budget || throw(ArgumentError("$description requires approximately $bytes bytes, budget=$budget"))
end

function _sector_suffix(charges, target)
    L = length(charges)
    suffix = Vector{Set{_SectorCharge}}(undef, L+1)
    suffix[end] = Set([(0,0)])
    for s in L:-1:1
        suffix[s] = Set(_qadd(q, t) for q in unique(charges[s]) for t in suffix[s+1]
                        if _qinside(_qadd(q,t), target))
    end
    target in suffix[1] || throw(ArgumentError("target sector is not reachable from local charges"))
    return suffix
end

function _sector_initial(rng, charges, target, max_bond, memory_budget)
    L = length(charges)
    suffix = _sector_suffix(charges, target)
    # A sum of random reachable paths supplies charge multiplicities without
    # enumerating root combinations. Dense arrays never exceed max_bond.
    bonds = [Vector{_SectorCharge}() for _ in 1:L+1]
    bonds[1] = [(0,0)]
    bonds[end] = [target]
    for _ in 1:max_bond
        q = (0,0)
        for s in 1:L
            choices = [p for p in eachindex(charges[s])
                       if _qsub(target, _qadd(q,charges[s][p])) in suffix[s+1]]
            q = _qadd(q, charges[s][rand(rng, choices)])
            s < L && push!(bonds[s+1], q)
        end
    end
    bytes = 16sum(big(length(bonds[s]))*length(charges[s])*length(bonds[s+1]) for s in 1:L)
    _sector_budget(bytes, memory_budget, "initial sector MPS")
    data = [zeros(ComplexF64, length(bonds[s]), length(charges[s]), length(bonds[s+1])) for s in 1:L]
    for s in 1:L, b in eachindex(bonds[s+1]), p in eachindex(charges[s]), a in eachindex(bonds[s])
        _qadd(bonds[s][a], charges[s][p]) == bonds[s+1][b] &&
            (data[s][a,p,b] = randn(rng, ComplexF64))
    end
    ψ = CanonicalMPS(data)
    _sector_right_canonicalize!(ψ, bonds, charges; memory_budget)
    return ψ, bonds
end

function _sector_right_canonicalize!(ψ, bonds, charges; memory_budget)
    for s in length(ψ):-1:2
        A = ψ[s]
        Dl, d, Dr = size(A)
        M = reshape(A, Dl, d*Dr)
        # Rows and columns refer to the same cumulative charge on bond s-1.
        rowcharges = bonds[s]
        colcharges = [_qsub(bonds[s+1][b],charges[s][p]) for b in 1:Dr for p in 1:d]
        blocks = []
        for q in sort(unique(rowcharges))
            rows, cols = findall(==(q), rowcharges), findall(==(q), colcharges)
            isempty(cols) && continue
            _sector_budget(16big(length(rows))*length(cols)*4, memory_budget, "charge-block canonicalization")
            F = LinearAlgebra.svd(M[rows,cols]; full=false)
            keep = findall(>(eps(Float64)*maximum(F.S; init=0.0)*max(size(M)...)), F.S)
            isempty(keep) || push!(blocks, (q, rows, cols, F, keep))
        end
        rank = sum(length(b[5]) for b in blocks; init=0)
        rank > 0 || throw(ArgumentError("initial sector MPS has zero norm"))
        left = zeros(ComplexF64, Dl, rank)
        right = zeros(ComplexF64, rank, d*Dr)
        newcharges = _SectorCharge[]
        k = 0
        for (q,rows,cols,F,keep) in blocks, j in keep
            k += 1
            left[rows,k] = F.U[:,j] * F.S[j]
            right[k,cols] = F.Vt[j,:]
            push!(newcharges,q)
        end
        ψ.data[s] = reshape(right, rank,d,Dr)
        P = ψ[s-1]
        ψ.data[s-1] = reshape(reshape(P,:,Dl)*left, size(P,1),size(P,2),rank)
        bonds[s] = newcharges
    end
    ψ.data[1] ./= norm(ψ.data[1])
    setscaling!(ψ,1)
    unset_svectors!(ψ)
    return ψ
end

function _sector_split(θ, qleft, qright, c1, c2; max_bond, cutoff, move_right, memory_budget)
    Dl,d1,d2,Dr = size(θ)
    M = reshape(θ, Dl*d1,d2*Dr)
    rowsq = [_qadd(qleft[a],c1[p]) for p in 1:d1 for a in 1:Dl]
    colsq = [_qsub(qright[b],c2[p]) for b in 1:Dr for p in 1:d2]
    blocks = []
    candidates = Tuple{Float64,Int,Int}[]
    for q in sort(intersect(unique(rowsq),unique(colsq)))
        rows,cols = findall(==(q),rowsq),findall(==(q),colsq)
        _sector_budget(16big(length(rows))*length(cols)*4, memory_budget, "charge-block SVD")
        F = LinearAlgebra.svd(M[rows,cols]; full=false)
        push!(blocks,(q,rows,cols,F))
        b = length(blocks)
        for j in eachindex(F.S)
            push!(candidates,(F.S[j],b,j))
        end
    end
    isempty(candidates) && throw(ArgumentError("no allowed two-site charge blocks"))
    sort!(candidates; by=x->(-x[1],x[2],x[3]))
    total = sum(x[1]^2 for x in candidates)
    total > 0 || throw(ArgumentError("zero norm in sector SVD"))
    nkeep = min(max_bond, max(1,count(x->x[1] > cutoff,candidates)))
    kept = candidates[1:nkeep]
    discarded = sum(x[1]^2 for x in candidates[nkeep+1:end]; init=0.0)/total
    left = zeros(ComplexF64,Dl*d1,nkeep)
    right = zeros(ComplexF64,nkeep,d2*Dr)
    newq = _SectorCharge[]
    sv = Float64[]
    for (k,(value,b,j)) in enumerate(kept)
        q,rows,cols,F = blocks[b]
        left[rows,k] = F.U[:,j] .* (move_right ? 1.0 : value)
        right[k,cols] = F.Vt[j,:] .* (move_right ? value : 1.0)
        push!(newq,q)
        push!(sv,value)
    end
    return reshape(left,Dl,d1,nkeep),reshape(right,nkeep,d2,Dr),newq,discarded,sv
end

function _sector_allowed(qleft,qright,c1,c2)
    indices = Int[]
    Dl,d1,d2,Dr = length(qleft),length(c1),length(c2),length(qright)
    k = 0
    for b in 1:Dr, p2 in 1:d2, p1 in 1:d1, a in 1:Dl
        k += 1
        _qadd(_qadd(qleft[a],c1[p1]),c2[p2]) == qright[b] && push!(indices,k)
    end
    return indices
end

# Cache the left and right halves of a local two-site problem when this
# reduces arithmetic and fits the working-array budget. Each half combines ONE
# MPO tensor with its environment. No pair-MPO Wcomb is ever constructed.
function _sector_two_site_plan(x, heff::TwoSiteHeff; memory_budget, reserve_bytes=0)
    B,d1,d2,R = size(x)
    A,C = size(heff.left,1),size(heff.right,1)
    wl,wm,wr = space_l(heff.W1),space_r(heff.W1),space_r(heff.W2)
    p,q = phydim(heff.W1),phydim(heff.W2)
    left = big(A)*p*wm*B*d1
    right = big(wm)*q*C*d2*R
    tmp = big(A)*p*wm*d2*R
    out = big(A)*p*q*C
    bytes_per_element = sizeof(promote_type(eltype(x),scalartype(heff.W1),scalartype(heff.W2)))
    dense_copies = (heff.W1 isa SchurMPOTensor ? big(wl)*p*wm*d1 : 0) +
                   (heff.W2 isa SchurMPOTensor ? big(wm)*q*wr*d2 : 0)
    # Includes packing/LAPACK-like contraction work while preparing either
    # half. Matvecs themselves use already packed matrices and two GEMMs.
    cached_bytes = bytes_per_element*(left+right+max(3left,3right,tmp+out)+
                                      length(x)+dense_copies)+reserve_bytes
    sequential_bytes = two_site_memory_estimate(x,heff)+reserve_bytes
    sequential_flops = big(B)*d1*d2*wr*C*R + big(B)*d1*q*wm*C*d2*wr +
                       big(B)*wl*p*q*C*d1*wm + out*B*wl
    cached_flops = tmp*B*d1 + out*wm*d2*R
    setup_flops = left*wl+right*wr
    # Four actions amortize packing even with eager warm-start convergence.
    beneficial = 4cached_flops+setup_flops < 4sequential_flops
    use_cache = beneficial && cached_bytes <= memory_budget
    return (mode=use_cache ? :cached_halves : :sequential,
            cache_bytes=use_cache ? Int(bytes_per_element*(left+right)) : 0,
            workspace_bytes=use_cache ? cached_bytes : sequential_bytes,
            cached_workspace_bytes=cached_bytes,sequential_workspace_bytes=sequential_bytes,
            cached_flops_per_action=cached_flops,sequential_flops_per_action=sequential_flops,
            setup_flops=setup_flops,beneficial=beneficial,
            dimensions=(A,p,wm,B,d1,R,q,C,d2))
end

function _sector_cached_two_site(x, left::AbstractMatrix, right::AbstractMatrix, dimensions)
    A,p,wm,B,d1,R,q,C,d2 = dimensions
    # Packing uses (a,p,wm ; b,i) and (wm,j,r ; q,c), so neither GEMM
    # needs to permute or copy a cached half on every Krylov action.
    tmp = left*reshape(x,B*d1,d2*R)
    y = reshape(tmp,A*p,wm*d2*R)*right
    return reshape(y,A,p,q,C)
end

function _sector_two_site_action(x,heff::TwoSiteHeff;memory_budget,reserve_bytes=0)
    plan = _sector_two_site_plan(x,heff;memory_budget,reserve_bytes)
    _sector_budget(plan.workspace_bytes,memory_budget,"$(plan.mode) local two-site action")
    if plan.mode == :sequential
        return y->ac2_prime(y,heff;memory_budget),plan
    end
    W1 = heff.W1 isa SchurMPOTensor ? tompotensor(heff.W1) : heff.W1
    W2 = heff.W2 isa SchurMPOTensor ? tompotensor(heff.W2) : heff.W2
    hl,hr = heff.left,heff.right
    @tensor L[a,p,k,b,i] := hl[a,w,b]*W1[w,p,k,i]
    @tensor R[k,j,r,q,c] := W2[k,q,w,j]*hr[c,w,r]
    A,p,wm,B,d1,Rdim,q,C,d2 = plan.dimensions
    left = reshape(L,A*p*wm,B*d1)
    right = reshape(R,wm*d2*Rdim,q*C)
    return y->_sector_cached_two_site(y,left,right,plan.dimensions),plan
end

function _sector_eigensolve(action, guess, allowed; tolerance, local_maxiter, memory_budget)
    n = length(allowed)
    n > 0 || throw(ArgumentError("empty local target sector"))
    # Krylov vectors and full tensor workspaces are budgeted before allocation.
    kdim = min(n,32)
    _sector_budget(16big(n)*(kdim+5) + 16big(length(guess))*5, memory_budget, "sector local eigensolve")
    x = vec(guess)[allowed]
    if norm(x) <= eps(Float64)
        fill!(x, inv(sqrt(n)))
    else
        x ./= norm(x)
    end
    shape = size(guess)
    invocations = Ref(0)
    function restricted(v)
        invocations[] += 1
        full = zeros(ComplexF64,shape)
        full[allowed] = v
        return vec(action(full))[allowed]
    end
    if n == 1
        value = real(restricted(ones(ComplexF64,1))[1])
        full = zeros(ComplexF64,shape)
        full[allowed] .= 1
        return value, full, (converged=true,residual=0.0,numops=1,numiter=0,dimension=n,
                            action_invocations=invocations[])
    end
    vals, vecs, info = eigsolve(restricted,x,1,:SR;
        ishermitian=true,tol=tolerance,maxiter=local_maxiter,krylovdim=kdim,eager=true,verbosity=0)
    v = vecs[1]
    residual = norm(restricted(v)-vals[1]*v)
    full = zeros(ComplexF64,shape)
    full[allowed] = v
    return real(vals[1]), full, (converged=info.converged >= 1,
        residual=Float64(residual),numops=info.numops,numiter=info.numiter,dimension=n,
        action_invocations=invocations[])
end

"""
    sector_leakage(ψ, bond_charges, charges; target)

Maximum magnitude of a tensor entry violating a cumulative bond-charge rule.
Together with the boundary charges `(0,0)` and `target`, zero leakage proves
that every represented configuration has the requested two-component charge.
"""
function sector_leakage(ψ::CanonicalMPS,bonds,charges;target)
    bonds[1] == [(0,0)] && bonds[end] == [target] || return Inf
    leakage = 0.0
    for s in 1:length(ψ), b in axes(ψ[s],3), p in axes(ψ[s],2), a in axes(ψ[s],1)
        if _qadd(bonds[s][a],charges[s][p]) != bonds[s+1][b]
            leakage = max(leakage,abs(ψ[s][a,p,b]))
        end
    end
    return leakage
end

"""
    sector_ground_state(h, charges; target, rng, max_bond=64, cutoff=1e-12,
        sweeps=12, tolerance=1e-10, memory_budget=2^30, initial=nothing,
        method=:dmrg2, local_maxiter=200)

Strict two-component nonnegative integer charge-sector DMRG on arbitrary local
physical dimensions. `charges[s][p]` is the charge of physical root `p`.
Ordinary arrays store only values consistent with explicit cumulative bond
labels. Initialization, restricted local Krylov solves, and block SVD all
preserve the target exactly. `cutoff` is an absolute Schmidt-value threshold;
`max_bond` also caps the total retained rank across charges.

`initial=nothing` draws a reachable random charge MPS with the supplied RNG;
an earlier result (with fields `mps,bond_charges`) is accepted as a copied warm
start. Inputs are never changed. `:dmrg1` retains this initial bond/charge space
and can be trapped at a local minimum. `:dmrg2` grows it at each block SVD.
Convergence requires both sweep-energy stability and converged local solves;
it does not certify the global variational minimum. Diagnostics report whether
a variance was computed (currently false), plus budget and initialization.
"""
function sector_ground_state(h::AbstractMPO, charges;
        target, rng::AbstractRNG, max_bond::Integer=64, cutoff::Real=1e-12,
        sweeps::Integer=12, tolerance::Real=1e-10, memory_budget::Integer=2^30,
        initial=nothing, method::Symbol=:dmrg2, local_maxiter::Integer=200)
    max_bond > 0 && sweeps > 0 && memory_budget > 0 && local_maxiter > 0 ||
        throw(ArgumentError("bond, sweeps, iteration and memory budgets must be positive"))
    isfinite(cutoff) && cutoff >= 0 && isfinite(tolerance) && tolerance > 0 ||
        throw(ArgumentError("invalid truncation or eigensolver tolerance"))
    method in (:dmrg1,:dmrg2) || throw(ArgumentError("method must be :dmrg1 or :dmrg2"))
    target = (Int(target[1]),Int(target[2]))
    all(>=(0),target) || throw(ArgumentError("target charges must be nonnegative"))
    cs = [[(Int(q[1]),Int(q[2])) for q in c] for c in charges]
    L = length(cs)
    L == length(h) && L >= 1 || throw(DimensionMismatch("one charge list is required per MPO site"))
    all(length(cs[s]) == ophydim(h[s]) == iphydim(h[s]) for s in 1:L) ||
        throw(DimensionMismatch("charge lists must match MPO physical dimensions"))
    all(all(q->q[1] >= 0 && q[2] >= 0,c) for c in cs) ||
        throw(ArgumentError("local charges must be nonnegative"))
    _sector_suffix(cs,target)
    if initial === nothing
        ψ,bonds = _sector_initial(rng,cs,target,max_bond,memory_budget)
    else
        ψ = CanonicalMPS([ComplexF64.(copy(A)) for A in initial.mps.data])
        bonds = deepcopy(initial.bond_charges)
        maximum(length,bonds) <= max_bond || throw(ArgumentError("warm-start bond dimension exceeds max_bond"))
        phydims(ψ) == length.(cs) || throw(DimensionMismatch("warm-start dimensions differ"))
        sector_leakage(ψ,bonds,cs;target) <= 1e-13 || throw(ArgumentError("warm start violates target-sector rules"))
        _sector_right_canonicalize!(ψ,bonds,cs;memory_budget)
    end
    # The environment stack is the existing DMRG implementation's contraction
    # machinery; only the local subspace and charge-aware factorization differ.
    envbytes = 16sum(big(size(ψ[s],1))^2*space_l(h[s]) for s in 1:L) + 16
    _sector_budget(envbytes,memory_budget,"DMRG environment stack")
    env = DMRGCache(ψ,h)
    energies = Float64[]
    local_iterations = NamedTuple[]
    truncations = NamedTuple[]
    converged = false
    initial_energy = real(expectation(h,ψ))/real(dot(ψ,ψ))
    previous = initial_energy
    for sweep in 1:sweeps
        local_ok = true
        if L == 1
            allowed = [p for p in eachindex(cs[1]) if cs[1][p] == target]
            heff = Heff(h[1],env.hstorage[1],env.hstorage[2])
            _,full,info = _sector_eigensolve(x->ac_prime(x,heff),ψ[1],allowed;
                tolerance,local_maxiter,memory_budget)
            ψ.data[1] = full
            push!(local_iterations,merge((sweep=sweep,site=1,direction=:single),info))
            local_ok &= info.converged
        elseif method == :dmrg2
            for direction in (:right,:left)
                sites = direction == :right ? (1:L-1) : (L-1:-1:1)
                for s in sites
                    A,B = ψ[s],ψ[s+1]
                    _sector_budget(16big(size(A,1))*size(A,2)*size(B,2)*size(B,3)*2,
                                   memory_budget,"two-site MPS tensor")
                    @tensor guess[a,p,q,b] := A[a,p,k]*B[k,q,b]
                    heff = TwoSiteHeff(h[s],h[s+1],env.hstorage[s],env.hstorage[s+2])
                    allowed = _sector_allowed(bonds[s],bonds[s+2],cs[s],cs[s+1])
                    reserve = 16big(length(allowed))*(min(length(allowed),32)+5)+16big(length(guess))*5
                    action,plan = _sector_two_site_action(guess,heff;memory_budget,reserve_bytes=reserve)
                    _,θ,info = _sector_eigensolve(action,guess,allowed;
                        tolerance,local_maxiter,memory_budget)
                    info = merge(info,(contraction_mode=plan.mode,
                        contraction_cache_bytes=plan.cache_bytes,
                        contraction_workspace_bytes=plan.workspace_bytes))
                    left,right,qnew,discarded,sv = _sector_split(θ,bonds[s],bonds[s+2],cs[s],cs[s+1];
                        max_bond,cutoff,move_right=direction==:right,memory_budget)
                    ψ.data[s],ψ.data[s+1] = left,right
                    bonds[s+1] = qnew
                    push!(local_iterations,merge((sweep=sweep,site=s,direction=direction),info))
                    push!(truncations,(sweep=sweep,bond=s,direction=direction,
                        discarded_weight=discarded,rank=length(sv)))
                    local_ok &= info.converged
                    direction == :right ? updateleft!(env,s) : updateright!(env,s+1)
                end
            end
        else
            # Charge-preserving one-site updates; gauge moves are implemented
            # by block SVD of a pair without a two-site optimization.
            for direction in (:right,:left)
                sites = direction == :right ? (1:L) : (L:-1:1)
                for s in sites
                    A = ψ[s]
                    allowed = Int[]
                    k = 0
                    for b in axes(A,3),p in axes(A,2),a in axes(A,1)
                        k += 1
                        _qadd(bonds[s][a],cs[s][p]) == bonds[s+1][b] && push!(allowed,k)
                    end
                    heff = Heff(h[s],env.hstorage[s],env.hstorage[s+1])
                    _,full,info = _sector_eigensolve(x->ac_prime(x,heff),A,allowed;
                        tolerance,local_maxiter,memory_budget)
                    ψ.data[s] = full
                    local_ok &= info.converged
                    push!(local_iterations,merge((sweep=sweep,site=s,direction=direction),info))
                    if direction == :right && s < L
                        A,B=ψ[s],ψ[s+1]
                        @tensor θ[a,p,q,b] := A[a,p,k]*B[k,q,b]
                        left,right,qnew,discarded,sv = _sector_split(θ,bonds[s],bonds[s+2],cs[s],cs[s+1];
                            max_bond=length(bonds[s+1]),cutoff=0.0,move_right=true,memory_budget)
                        ψ.data[s],ψ.data[s+1]=left,right
                        bonds[s+1]=qnew
                        updateleft!(env,s)
                    elseif direction == :left && s > 1
                        A,B=ψ[s-1],ψ[s]
                        @tensor θ[a,p,q,b] := A[a,p,k]*B[k,q,b]
                        left,right,qnew,discarded,sv = _sector_split(θ,bonds[s-1],bonds[s+1],cs[s-1],cs[s];
                            max_bond=length(bonds[s]),cutoff=0.0,move_right=false,memory_budget)
                        ψ.data[s-1],ψ.data[s]=left,right
                        bonds[s]=qnew
                        updateright!(env,s)
                    end
                end
            end
        end
        ψ.data[1] ./= norm(ψ.data[1])
        E = real(expectation(h,ψ))/real(dot(ψ,ψ))
        push!(energies,E)
        if sweep >= 2 && abs(E-previous) <= tolerance*max(1,abs(E)) && local_ok
            converged=true
            break
        end
        previous=E
    end
    setscaling!(ψ,1)
    unset_svectors!(ψ)
    leakage=sector_leakage(ψ,bonds,cs;target)
    leakage <= 1e-13 || error("internal charge-sector leakage")
    contraction_modes = Dict("cached_halves"=>0,"sequential"=>0,"single_site"=>0)
    for info in local_iterations
        mode=string(get(info,:contraction_mode,:single_site))
        contraction_modes[mode]=get(contraction_modes,mode,0)+1
    end
    max_cache_bytes=maximum((get(info,:contraction_cache_bytes,0) for info in local_iterations);init=0)
    action_invocations=sum(info.action_invocations for info in local_iterations)
    return (mps=ψ, energy=last(energies), norm=norm(ψ), bond_charges=bonds,
        converged=converged, energies=energies, local_iterations=local_iterations,
        truncations=truncations, diagnostics=(method=method,
            initialization=initial === nothing ? :random_reachable_paths : :warm_start,
            initial_energy=initial_energy,max_bond=max_bond,cutoff=cutoff,local_eigensolver_eager=true,
            memory_budget=memory_budget,sector_leakage=leakage,
            contraction_modes=contraction_modes,max_contraction_cache_bytes=max_cache_bytes,
            action_invocations=action_invocations,variance_computed=false,variance=nothing))
end
