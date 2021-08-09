# This file was generated, do not modify it. # hide
using Distributions, Plots
μₚ = 1; μₙ = -1
σₚ=1; σₙ =1
Nₚ = 1000; Nₙ = 10000
positive = rand(Normal(μₚ,σₚ),Nₚ)
negative = rand(Normal(μₙ,σₙ),Nₙ)
θ = exp.(-10:0.1:100);
U = Vector{Float64}(undef,length(θ))
V = Vector{Float64}(undef,length(θ))
for i in 1:length(θ)
    global U,V # hide
    U[i] = sum(@. pdf(Normal(μₚ,σₚ),negative) / pdf(Normal(μₙ,σₙ),negative) > θ[i]) / Nₙ
    V[i] = sum(@. pdf(Normal(μₚ,σₚ),positive) / pdf(Normal(μₙ,σₙ),positive) > θ[i]) / Nₚ
end

AUC = 0
for i in 1:length(θ)-1
    global AUC # hide
    AUC += abs(U[i+1]-U[i])*V[i]
end
p38 = plot(U,V,xlabel="False Positive",ylabel="False Negative",
            title="ROC curve",legend=false,
            ann = (0.5,0.5,"AUC = $(round(AUC,digits=2))"))

savefig(p38,joinpath(@OUTPUT,"fig2-6.svg")) # hide