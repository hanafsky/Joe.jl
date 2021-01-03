# This file was generated, do not modify it. # hide
using Plots, Random
using Joe: Spline
using Joe
Random.seed!(123)
n = 100; x = randn(n)*2π; y = sin.(x) + 0.2randn(n)
p54 = scatter(x,y,xlims=(-5,5),xlabel="x",ylabel="f(x)",label=false)
K_set = 5:2:9
for K in K_set
    spline = Spline(xmin=-2π, xmax=2π, K=K)
    u_seq = -5:0.2:5
    v_seq = spline(x,y,u_seq)
    plot!(p54, u_seq,v_seq, label="K = $K")
end
savefig(p54,joinpath(@OUTPUT,"fig6-5.svg")) # hide