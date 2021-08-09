# This file was generated, do not modify it. # hide
using Joe, Random, Plots
using Joe:cv_linear,cv_fast

n = 1000; p = 5
Random.seed!(1)
X = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y = insert_ones(X)*β + randn(n);