# This file was generated, do not modify it. # hide
using Joe, Random, LinearAlgebra
using Plots
N=1000; p=2; Random.seed!(1)
X = insert_ones(randn(N,p))
β = randn(p+1)
prob = @. 1/(1 + exp($*(X,β)))
threshold=0.5
y = ifelse.(rand(N) .> prob,1,-1) # ここまでデータ生成
@show y β;