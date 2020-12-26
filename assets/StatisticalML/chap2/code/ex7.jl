# This file was generated, do not modify it. # hide
using Zygote, LinearAlgebra
l(γ,X=X,y=y) = sum(@. log( 1 /(1+exp(*($*(X,γ),-y))))) #対数尤度関数

for i in 1:10
    global γ2
    δ =  Zygote.hessian(l,γ2) \ l'(γ2)
    γ2 -= δ
    @show γ2
end

plot!(p33,x-> -γ2[1]/γ2[3] - γ2[2]/γ2[3]*x, label="γ2")
savefig(p33,joinpath(@OUTPUT,"fig2-2-2.svg")) # hide