# This file was generated, do not modify it. # hide
using Zygote, LinearAlgebra
l(γ,X=X,y=y) = sum(@. log( 1 /(1+exp(*($*(X,γ),-y))))) #対数尤度関数

for i in 1:10
    δ =  Zygote.hessian(l,γ) \ l'(γ)
    @show norm(δ)^2
    γ2 -= δ
    @show γ2
end