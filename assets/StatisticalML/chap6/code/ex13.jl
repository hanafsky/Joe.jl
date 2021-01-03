# This file was generated, do not modify it. # hide
using Random, Distributions
Random.seed!(11)
n = 100; x = rand(Uniform(-5,5),n) ; y = x -0.02sin.(x)-0.1randn(n);
index = sortperm(x); x = x[index]; y = y[index];