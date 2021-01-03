# This file was generated, do not modify it. # hide
using Plots, Random, Distributions
using Joe: SmoothingSpline
using Joe
Random.seed!(11)
n = 100;
x = rand(Uniform(-5,5),n); y = x .+ 2sin.(x) + randn(n)
index = sortperm(x); x = x[index]; y = y[index]

p57 = scatter(x,y,label=false)

sspline = SmoothingSpline(x)
u_seq = -8:0.02:8
λ_set = [40,400,1000]
for λ in λ_set
    global u_seq, p57 # hide
    v_seq = sspline(y,u_seq,λ=λ)
    plot!(p57,u_seq,v_seq,label="λ = $λ")
end
p57
plot!(p57,u_seq,sspline(y,u_seq,λ=1),label="λ = 1")
savefig(p57,joinpath(@OUTPUT, "fig6-8.svg")) # hide