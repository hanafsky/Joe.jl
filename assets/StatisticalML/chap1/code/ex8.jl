# This file was generated, do not modify it. # hide
using Joe, Statistics
N = 100;Random.seed!(123)
x24 = randn(N); y24=randn(N);
β₁, β₀ = min_sq(x24,y24)
rse = Joe.RSE(x24,y24)
se₀, se₁ = rse*sqrt.(Joe.Bdiag(x24))
t₀ = β₀ / se₀
t₁ = β₁ / se₁
p₀ = 2*(ccdf(TDist(N-2),abs(t₀)))
p₁ = 2*(ccdf(TDist(N-2),abs(t₁)))
@show β₀, β₁;
@show t₀, t₁;
@show p₀, p₁;