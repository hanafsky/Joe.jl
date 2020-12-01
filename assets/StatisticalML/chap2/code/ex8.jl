# This file was generated, do not modify it. # hide
let # hide
using Distributions
μ₁=[2,2];  Σ₁ = [2 0; 0 2]
μ₂=[-3,-3]; Σ₂ = [1 -0.8; -0.8 1]

N = 100;Random.seed!(123)
data1 = rand(MvNormal(μ₁,Σ₁),100) |> transpose
data2 = rand(MvNormal(μ₂,Σ₂),100) |> transpose
scatter(data1[:,1],data1[:,2])
scatter(data2[:,1],data2[:,2])


end # hide