# This file was generated, do not modify it. # hide
using Plots, Random
using Joe: Spline
using Joe
Random.seed!(123)
n = 100; x = randn(n)*2π; y = sin.(x) + 0.2randn(n)
spline6 = Spline(xmin=-5, xmax=5, K=6);
spline11 = Spline(xmin=-5, xmax=5, K=11);