# This file was generated, do not modify it. # hide
using Joe, Random, Distributions, LinearAlgebra
Random.seed!(123) #乱数の種を固定
N = 100
a = rand(Normal(2,1),N) #傾き、平均2分散1の正規分布からサンプリング
b = randn() #切片
x = randn(N)
y = a .* x .+ b  + randn(N);