# This file was generated, do not modify it. # hide
@with_kw struct mvnormal
    μ::Array
    Σ::Matrix
    invΣ::Array = inv(Σ)
    detΣ = det(Σ)
end

param1=mvnormal(μ= μ̂₁,Σ = Σ̂₁);param2=mvnormal(μ = μ̂₂,Σ = Σ̂₂)