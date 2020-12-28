# This file was generated, do not modify it. # hide
using Joe, Random, Distributions, Plots, LinearAlgebra
Random.seed!(123)
n=100
x34 = vcat(randn(n).+1,randn(n).-1) |> insert_ones
y34 = vcat(ones(n),-ones(n));