# direct sampling of configuration amplitudes from a canonical MPS (Born distribution)

"""
    sample(rng::AbstractRNG, ψ::CanonicalMPS, N::Integer; atol=1e-12)
    sample(ψ::CanonicalMPS, N::Integer; atol=1e-12)

Draw Born samples with one-based local indices for arbitrary (also nonuniform)
physical dimensions. `ψ` may have any gauge and any finite nonzero normalization;
it is never canonicalized or modified. The method contracts normalized right norm
environments and rescales each sampled prefix. It does not use stored Schmidt
values, expand the state, or silently accept an all-zero conditional distribution.
The legacy overload uses `Random.default_rng()`.
"""
function sample(rng::AbstractRNG, ψ::CanonicalMPS, N::Integer; atol::Real=1e-12)
    N >= 0 || throw(ArgumentError("sample count must be nonnegative"))
    isfinite(atol) && atol >= 0 || throw(ArgumentError("atol must be finite and nonnegative"))
    isfinite(scaling(ψ)) && !iszero(scaling(ψ)) ||
        throw(ArgumentError("sampling requires a finite nonzero state scale"))
    R = sampling_right_environments(ψ)
    L = length(ψ)
    T = scalartype(ψ)
    samples = Vector{Vector{Int}}(undef, N)
    for n in 1:N
        x = Vector{Int}(undef, L)
        v = ones(T, 1)
        for s in 1:L
            A = ψ[s]
            d, Dr = size(A, 2), size(A, 3)
            candidates = Matrix{T}(undef, Dr, d)
            weights = Vector{Float64}(undef, d)
            for p in 1:d
                w = vec(transpose(v) * view(A, :, p, :))
                candidates[:, p] = w
            end
            candidate_scale = maximum(abs, candidates)
            isfinite(candidate_scale) && candidate_scale > 0 ||
                throw(ArgumentError("zero or non-finite prefix at site $s"))
            candidates ./= candidate_scale
            for p in 1:d
                w = view(candidates, :, p)
                z = dot(w, R[s+1] * w)
                abs(imag(z)) <= atol * max(1, abs(real(z))) ||
                    throw(ArgumentError("non-real Born weight; invalid right environment"))
                real(z) >= -atol || throw(ArgumentError("negative Born weight"))
                weights[p] = max(0.0, real(z))
            end
            total = sum(weights)
            isfinite(total) && total > 0 ||
                throw(ArgumentError("zero or non-finite conditional norm at site $s"))
            threshold = rand(rng) * total
            cumulative = 0.0
            selected = findlast(>(0), weights)
            for p in eachindex(weights)
                cumulative += weights[p]
                if threshold < cumulative
                    selected = p
                    break
                end
            end
            x[s] = selected
            v = candidates[:, selected]
            scale = maximum(abs, v)
            isfinite(scale) && scale > 0 || throw(ArgumentError("invalid sampled prefix"))
            v ./= scale
        end
        samples[n] = x
    end
    return samples
end
sample(ψ::CanonicalMPS, N::Integer; kwargs...) = sample(Random.default_rng(), ψ, N; kwargs...)

"""
    sampling_right_environments(ψ)

Right norm environments `R[s][bra,ket]` for sites `s:L`, individually rescaled
by a positive scalar to avoid long-chain underflow. Their scalar normalizations
cancel in conditional probabilities. Does not modify `ψ`.
"""
function sampling_right_environments(ψ::CanonicalMPS)
    T = scalartype(ψ)
    R = Vector{Matrix{T}}(undef, length(ψ)+1)
    R[end] = ones(T, 1, 1)
    for s in length(ψ):-1:1
        all(isfinite, ψ[s]) || throw(ArgumentError("non-finite MPS tensor"))
        tensor_scale = maximum(abs, ψ[s])
        tensor_scale > 0 || throw(ArgumentError("sampling requires nonzero tensors"))
        A = ψ[s] ./ tensor_scale
        R[s] = _updateright(R[s+1], A, A)
        scale = maximum(abs, R[s])
        isfinite(scale) && scale > 0 || throw(ArgumentError("sampling requires a nonzero finite state"))
        R[s] ./= scale
    end
    return R
end

"""
	amplitude(ψ::CanonicalMPS, 𝐱) -> Number

The amplitude `ψ(𝐱) = ⟨𝐱|ψ⟩` of the represented state at the configuration `𝐱`
(`𝐱[s] ∈ 1:ds[s]`, following the package's **1-based convention**; a `Vector{Int}` or
a tuple), including the per-site `scaling` factor (matching [`todense`](@ref)). The
scaling is applied **per site during the contraction** — no `scaling^L` power is ever
materialized, so the amplitude stays finite even for scalings whose `scaling(ψ)^L`
would overflow. The rows of the site tensors are contracted left to right.
"""
function amplitude(ψ::CanonicalMPS, 𝐱)
	L = length(ψ)
	(length(𝐱) == L) || throw(DimensionMismatch("configuration length must match the number of sites"))
	f = scaling(ψ)
	v = f * reshape(ψ[1][1, 𝐱[1], :], 1, :)
	for s in 2:L
		v = f * (v * reshape(ψ[s][:, 𝐱[s], :], size(ψ[s], 1), :))
	end
	return v[]
end
