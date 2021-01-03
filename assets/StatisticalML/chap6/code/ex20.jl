# This file was generated, do not modify it. # hide
using Random,Joe
Random.seed!(123)
n=30; x = 2π*rand(n) .- π; y = sin.(x) .+ randn()
p61 = scatter(x,y,label=false)
m = 200;U = -π:π/m:π;