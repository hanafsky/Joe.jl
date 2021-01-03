# This file was generated, do not modify it. # hide
using Plots, Random
Random.seed!(123)
n = 100; x = randn(n) * π
y = abs.(round.(x) .%2) * 2  .- 1+ randn(n)*0.2
p53 = scatter(x,y,label= false);