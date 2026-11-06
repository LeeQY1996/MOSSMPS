# Synthetic contraction benchmark; the larger dimensions match the H8 center pair.
# It tests action equivalence and resource cost, not molecular accuracy.
# Run from Quantum after preparing the Zoo environment:
# OPENBLAS_NUM_THREADS=1 julia --project=MOSSAlgorithmZoo MOSSQuantumMPS/benchmark/sector_action.jl
using LinearAlgebra, Random
import MOSSQuantumMPS
const A=MOSSQuantumMPS.MPSAlgorithms
rng=MersenneTwister(314)
function probe(D,d,wl,wm;repeats=2)
    W1=randn(rng,ComplexF64,wl,d,wm,d); W2=randn(rng,ComplexF64,wm,d,wl,d)
    hl=randn(rng,ComplexF64,D,wl,D); hr=randn(rng,ComplexF64,D,wl,D)
    x=randn(rng,ComplexF64,D,d,d,D)
    heff=A.TwoSiteHeff(W1,W2,hl,hr)
    setup=@elapsed action,plan=A._sector_two_site_action(x,heff;memory_budget=2^30)
    old=A.ac2_prime(x,heff); new=action(x)
    err=norm(new-old)/norm(old)
    @assert err <= 1e-10
    lazy=minimum((@elapsed A.ac2_prime(x,heff)) for _ in 1:repeats)
    cached=minimum((@elapsed action(x)) for _ in 1:repeats)
    println((D=D,d=d,wl=wl,wm=wm,relative_error=err,setup_seconds=setup,
        sequential_seconds=lazy,cached_seconds=cached,speedup=lazy/cached,
        mode=plan.mode,cache_bytes=plan.cache_bytes,estimated_workspace_bytes=plan.workspace_bytes,
        sequential_workspace_bytes=plan.sequential_workspace_bytes,
        cached_flops=plan.cached_flops_per_action,sequential_flops=plan.sequential_flops_per_action))
    GC.gc()
end
probe(2,3,2,4)
probe(16,16,46,154)
