# This file was generated, do not modify it.

using Joe, Plots
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ),  # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ) # hide
) # hide
p29 = plot(xlims=(-10,10), xlabel="x",ylabel="P(Y=1|x)",
            legend=:topleft, title="ロジスティック曲線")
x29 = expand_matrix(-10:0.1:10)
for i in [0, 0.2, 0.5, 1, 2, 10]
    plot!(p29, x29[:,2], Joe.sigmoid(x29,[0,i]),label="$i")
end

savefig(p29,joinpath(@OUTPUT,"fig2-1.svg")) # hide

using Zygote
f(x) = x^2 -1
let # hide
x=4
for i in 1:10
    x -= f(x)/f'(x)
    println(x)
end
end # hide

using ForwardDiff

f(x,y) = [x^2+y^2-1, x+y]
let # hide
z = [3,4]
for i in 1:10
    z -= ForwardDiff.jacobian(x->f(x[1], x[2]),z) \ f(z[1],z[2])
    println(z)
end
end # hide

using Joe, Random, LinearAlgebra
N=1000; p=2; Random.seed!(12)
X = expand_matrix(randn(N,p))
β = randn(p+1)
prob = @. 1/(1 + exp($*(X,β)))
threshold=0.5
y = ifelse.(rand(N) .> prob,1,-1) # ここまでデータ生成
@show y β

data1 = X[y .== 1, 2:3]
data2 = X[y .== -1, 2:3]
p33=scatter(data1[:,1],data1[:,2],ylims=(-5,5),marker=:auto, label="y=1")
scatter!(data2[:,1],data2[:,2],marker=:auto,label="y=-1")
plot!(x-> -β[1]/β[3] - β[2]/β[3]*x, label="β")
savefig(p33,joinpath(@OUTPUT,"fig2-2.svg")) # hide

γ = randn(p+1)
γ2=copy(γ)
@show γ

W(v::Vector) = @.(v/(1+ v)^2) |> diagm
t = true
for i in 1:10
    global γ
    s=X*γ
    v = @. exp(-y*s)
    u = @. y*v/(1+v)
    γ += ((X'*W(v)*X) \ X') * u
    #δ'*δ < 0.001 && (t = false)
    @show γ
end

using Zygote, LinearAlgebra
l(γ,X=X,y=y) = sum(@. log( 1 /(1+exp(*($*(X,γ),-y))))) #対数尤度関数

for i in 1:10
    global γ,γ2
    δ =  Zygote.hessian(l,γ) \ l'(γ)
    @show norm(δ)^2
    γ2 -= δ
    @show γ2
end

using Distributions, Random,Plots, LinearAlgebra, Parameters
μ₁=[2,2];  Σ₁ = [2 0; 0 2]
μ₂=[-3,-3]; Σ₂ = [1 -0.8; -0.8 1]

N = 100;Random.seed!(123)
data1 = rand(MvNormal(μ₁,Σ₁),100) |> transpose
data2 = rand(MvNormal(μ₂,Σ₂),100) |> transpose
p35 = scatter(data1[:,1],data1[:,2])
scatter!(p35, data2[:,1],data2[:,2])

savefig(p35,joinpath(@OUTPUT,"fig2-3.svg")) # hide

μ̂₁ = mean(data1,dims=1)'; Σ̂₁ = cov(data1,dims=1);
μ̂₂ = mean(data2,dims=1)' ; Σ̂₂ = cov(data2,dims=1);

using Joe: mvnormal, logMvNormal
param1=mvnormal(μ= μ̂₁,Σ = Σ̂₁);param2=mvnormal(μ = μ̂₂,Σ = Σ̂₂)

hanbetsu(x,y) = logMvNormal(param1,x,y) - logMvNormal(param2,x,y)
x35=-5:0.1:5;
y35=-5:0.1:5;
scatter(data1[:,1],data1[:,2])
scatter!( data2[:,1],data2[:,2])
p35_2=contour!(x35,y35, hanbetsu.(x35,y35'), title="QDA")
savefig(p35_2,joinpath(@OUTPUT,"fig2-4.svg")) # hide

Σ_L =  vcat(data1 .- μ̂₁' , data2 .- μ̂₂') |> cov
param1_L=mvnormal(μ= μ̂₁,Σ =Σ_L );param2_L=mvnormal(μ = μ̂₂,Σ = Σ_L)
hanbetsu_L(x,y) = logMvNormal(param1_L,x,y) - logMvNormal(param2_L,x,y)
p35_3=contour!(p35,x35,y35, hanbetsu_L.(x35,y35'), title="LDA")
savefig(p35_3,joinpath(@OUTPUT,"fig2-5.svg")) # hide

using RDatasets, StatsBase
using Joe:mvnormal, logMvNormal
iris = dataset("datasets","iris")
x = iris[!,1:4]
y = iris.Species
n = length(y)
index = sample(1:n,n,replace=false); #ランダムなインデックスを作り
train=index[begin:Int(n/2)];# 学習用とテスト用にインデックスを分ける。
text = index[Int(n/2)+1:end];
X = x[train,:] |> Matrix
Y = y[train];

