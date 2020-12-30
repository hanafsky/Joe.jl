# This file was generated, do not modify it. # hide
using Plots, Joe, Random
Random.seed!(12)
n = 100; x = randn(n); y = sin.(x) + randn(n);
p52 = scatter(x,y,xlabel="x", ylabel="y", label=false, legend=:topleft);