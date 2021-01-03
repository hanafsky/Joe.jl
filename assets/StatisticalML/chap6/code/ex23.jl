# This file was generated, do not modify it. # hide
using Random,Joe
Random.seed!(123)
n=30; x = 2π*rand(n) .- π; sort!(x); y = sin.(x) .+ randn()
y₁ = zeros(n); y₂ = zeros(n)
using Plots
for k in 1:10
    global x,y,y₁,y₂ # hide
    y₂ = Joe.local_regression(x,y-y₁,Joe.epanechnikov)
    y₁ = Joe.polyfit(x,y-y₂)
end
p62_3 = plot(x,y₁,label=false,xlabel="x",ylabel="f(x)",title="多項式回帰(3次)")
p62_4 = plot(x,y₂,label=false,xlabel="x",ylabel="f(x)",title="局所線形回帰")
p62_5　= plot(p62_3,p62_4,layout=(1,2))
savefig(p62_5,joinpath(@OUTPUT,"fig6-12-2.svg")) # hide