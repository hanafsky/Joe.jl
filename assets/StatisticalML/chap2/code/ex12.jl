# This file was generated, do not modify it. # hide
Σ_L =  vcat(data1 .- μ̂₁' , data2 .- μ̂₂') |> cov
param1_L=mvnormal(μ= μ̂₁,Σ =Σ_L );param2_L=mvnormal(μ = μ̂₂,Σ = Σ_L)
hanbetsu_L(x,y) = logMvNormal(param1_L,x,y) - logMvNormal(param2_L,x,y)
p35_3=contour!(p35,x35,y35, hanbetsu_L.(x35,y35'), title="LDA")
savefig(p35_3,joinpath(@OUTPUT,"fig2-5.svg")) # hide