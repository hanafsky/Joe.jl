# This file was generated, do not modify it.

using Joe, Random, Distributions, LinearAlgebra
Random.seed!(123) #乱数の種を固定
N = 100
a = rand(Normal(2,1),N) #傾き、平均2分散1の正規分布からサンプリング
b = randn() #切片
x = randn(N)
y = a .* x .+ b  + randn(N);

a1, b1 = min_sq(x,y)

xx = x .- mean(x); yy = y .- mean(y)
a2,b2 = min_sq(xx,yy)

using Plots; gr()
using Plots.PlotMeasures
Plots.reset_defaults()
default(
    titlefont  = font("JuliaMono", default(:titlefontsize),  ),
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ),
    tickfont   = font("JuliaMono", default(:tickfontsize),   ),
    legendfont = font("JuliaMono",  default(:legendfontsize), ),
    left_margin = 30px,
    bottom_margin = 30px,
)
p12 = scatter(x,y,label="original",legend=:topleft,xlabel="x", ylabel="y")
plot!(c->a1*c+b1 ,label="before centering")
plot!(c->a2*c+b2 , label="after centering")
savefig(p12,joinpath(@OUTPUT,"fig1-2.svg")) # hide

p13 = plot(xlims=(0,8),ylims=(0,1),title="DOF of chi",legend=:topright)
for i in 1:10
    plot!(p13,0.1:0.1:8,x->pdf(Chisq(i),x),label="dof = $(i)")
end
savefig(p13,joinpath(@OUTPUT,"fig1-3.svg")) # hide

p15 = plot(x->pdf(Normal(0,1),x),label="正規分布")
for i in 1:10
    plot!(x->pdf(TDist(i),x), ls=:dash, label="dof: $(i)")
end
savefig(p15,joinpath(@OUTPUT,"fig1-5.svg")) # hide

N=100;iter_num=100;
data23 = Matrix(undef,iter_num,2)
for i in 1:iter_num
    x23=randn(N)  .+2
    y23= x23 .+ 1 +  randn(N)
    data23[i,:] = min_sq(x23,y23) |> collect
end
p14 = scatter(data23[:,2],data23[:,1],xlabel="β₀",ylabel="β₁",title="test",legend=false)
savefig(p14,joinpath(@OUTPUT,"fig1-4.svg")) # hide

using Joe, Statistics
N = 100;Random.seed!(123)
x24 = randn(N); y24=randn(N);
β₁, β₀ = min_sq(x24,y24)
rse = Joe.RSE(x24,y24)
se₀, se₁ = rse*sqrt.(Joe.Bdiag(x24))
t₀ = β₀ / se₀
t₁ = β₁ / se₁
p₀ = 2*(ccdf(TDist(N-2),abs(t₀)))
p₁ = 2*(ccdf(TDist(N-2),abs(t₁)))
@show β₀, β₁;
@show t₀, t₁;
@show p₀, p₁;

using GLM, DataFrames
data = DataFrame(X=x24,Y=y24)
ols = lm(@formula(Y ~ X), data)

t25 = Vector{Real}(undef,1000)
for i in 1:1000
    x25 = randn(N); y25 = randn(N)
    t25[i],_ = collect(min_sq(x25,y25)) / Joe.RSE(x25,y25) ./ sqrt.(Joe.Bdiag(x25))
end
p25_1 = histogram(t25,xlims=(-3,3),bins=20,normalize=true,xlabel="tの値",legend=false)
title!("帰無仮説が成立する場合")
plot!(p25_1,x->pdf(TDist(98),x));

t25_ = Vector{Real}(undef,1000)
for i in 1:1000
    x25 = randn(N); y25 = 0.1*x25 .+ randn(N)
    t25_[i],_ = collect(min_sq(x25,y25)) / Joe.RSE(x25,y25) ./ sqrt.(Joe.Bdiag(x25))
end
p25_2 = histogram(t25_,xlims=(-3,3),bins=20,normalize=true, xlabel="tの値",legend=false)
title!("帰無仮説が成立しない場合")
plot!(p25_2,x->pdf(TDist(98),x))
p25 = plot(p25_1,p25_2)
savefig(p25,joinpath(@OUTPUT,"fig1-6.svg")) # hide

N = 100; Random.seed!(123)
x26_2 = randn(N,2); x26_1 = randn(N)
y26 = randn(N)
@show Joe.R2(x26_2,y26);

@show Joe.R2(x26_1,y26);
@show cor(x26_1,y26)^2 ; # Statistics.jl

using Joe, RDatasets,DataFrames
using Chain
df = dataset("MASS","BOSTON")
x27 = @chain df select(_,Not(:MedV)) Array #df[Not(:MedV)]がFranklinで動かん。
#TabularDisplayを使って綺麗に表示する。
using TabularDisplay, Formatting
foo = generate_formatter("%7.5f")
displaytable(Joe.VIF(x27);index=true,indexsep=" -> ",formatter=foo)

using Plots, Random, Joe
N = 100; Random.seed!(123)
x28 = randn(N,1)
y28 = x28 .+1 + randn(N)  |> vec # 真の切片と傾きはともに1
p28 = scatter(x28,y28,xlabel="x",ylabel="y",
                label="data     ",legend=:topleft)
β28 = multiple_regression(x28,y28)
x_seq = -10:0.1:10
ŷ = insert_ones(x_seq) * β28
yerror1 = Joe.confident_interval(x_seq,x28,y28)
yerror2 = Joe.prediction_interval(x_seq,x28,y28)
plot!(p28,x_seq,ŷ,ribbon=yerror2, label="予測区間")
plot!(p28,x_seq,ŷ,ribbon=yerror1, label="信頼区間")

savefig(p28,joinpath(@OUTPUT,"fig1-7.svg")) # hide

