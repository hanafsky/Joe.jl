# # 線形回帰
# ## 1.1最小二乗法 
# ### 例19
# 肩慣らしの単回帰分析。回帰係数と切片を返す関数を定義します。 
# ユニコードがtab補完で入力ので数式と関数との対応が非常に見やすくできるのがjuliaの特長の一つです。
# 
# \note{meanやnorm関数などを使うため、Distributions.jlとLinearAlgebra.jlをインポートしておきます。}
#　
# ---
# ```julia
# function min_sq(x::Vector{T},y::Vector{T}) where {T<:Number}
#     x̄ = mean(x)
#     ȳ = mean(y)
#     β₁ = (x .- x̄)'*(y .- ȳ) / norm(x .- x̄)^2 #傾き
#     β₀ = ȳ - β₁ * x̄ #切片
#     return  β₁,β₀
# end
# ```
# まずはトイデータの生成から。
using Joe, Random, Distributions, LinearAlgebra
Random.seed!(123) #乱数の種を固定
N = 100
a = rand(Normal(2,1),N) #傾き、平均2分散1の正規分布からサンプリング
b = randn() #切片
x = randn(N) 
y = a .* x .+ b  + randn(N);

# 普通に単回帰する場合。
a1, b1 = min_sq(x,y)

# データを中心化したあとに回帰分析すると切片が０になる（あたりまえ）。
xx = x .- mean(x); yy = y .- mean(y)
a2,b2 = min_sq(xx,yy)


# 図1.2を可視化してみる。matplotlibに比べてコードが短いのがいいですね。
# 日本語扱うための設定は[GenKurokiさんのコード](https://gist.github.com/genkuroki/6c2b71f62504432bdf8a27d24106cad8)を参考にしました。
using Plots; gr()
Plots.reset_defaults()
default(
    titlefont  = font("JuliaMono", default(:titlefontsize),  ),
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ),
    tickfont   = font("JuliaMono", default(:tickfontsize),   ),
    legendfont = font("JuliaMono",  default(:legendfontsize), )
)
p12 = scatter(x,y,label="original",legend=:topleft,xlabel="x", ylabel="y")
plot!(c->a1*c+b1 ,label="before centering")
plot!(c->a2*c+b2 , label="after centering")
savefig(p12,joinpath(@OUTPUT,"fig1-2.svg")) # hide
# \fig{fig1-2}

# ## 1.2 重回帰 
# ### 例20
# $\hat{\beta} = (X^T X)^{-1} X^Ty$ を解くだけなので、もはや関数化する程でもないが、
# 後々のことを考えて、関数化します。
# また、係数行列に定数項のために1の列を1列目に挿入しますが、
# わざわざnumpyをimportしてnp.insert(x,0,1,axis=1)を呼び出すのが嫌なので、
# 以下のような関数を定義しました。(この行列、何かいい名前があるといいのですが。)
# ```julia
# function expand_matrix(X)
#     N = typeof(X) <: Matrix  ?  size(X)[1] :  length(X)
#     T = eltype(X)
#     return hcat(ones(T,N),X)
# end
# ```
# また、重回帰係数を最小二乗法で求める関数を次のように定義しました。
# ```julia
# function MultipleRegression(x::Matrix{T}, y::Vector{T}) where {T<:Number}
#     N,_ = size(x)
#     @assert N==length(y)
#     X = expand_matrix(x)
#     return (X'X)\X'y
# end
# ```

# ## 1.4 RSSの分布 
# ### 例21
# $\chi^2$分布のプロット。原著のプロット（図1.3）は間違っているらしい。
# Plots.jlは無名関数のプロットができるので便利。
p13 = plot(xlims=(0,8),ylims=(0,1),title="DOF of chi",legend=:topright)
for i in 1:10
    plot!(0.1:0.1:8,x->pdf(Chisq(i),x),ls:auto,label="dof = $(i)")
end
savefig(p13,joinpath(@OUTPUT,"fig1-3.svg")) # hide
# \fig{fig1-3}
# ## 1.5 $\hat{\beta}_j \neq 0$の仮説検定 
# ### 例22
# t分布のプロット
p15 = plot(x->pdf(Normal(0,1),x),label="正規分布")
for i in 1:10
    plot!(x->pdf(TDist(i),x), ls=:dash, label="dof: $(i)")
end
savefig(p15,joinpath(@OUTPUT,"fig1-5.svg")) # hide
# \fig{fig1-5}

# ### 例23 
N=100;iter_num=100;
data23 = Matrix(undef,iter_num,2)
for i in 1:iter_num
    x23=randn(N)  .+2
    y23= x23 .+ 1 +  randn(N)
    data23[i,:] = min_sq(x23,y23) |> collect
end
p14 = scatter(data23[:,2],data23[:,1],xlabel="β₀",ylabel="β₁",title="test")
savefig(p14,joinpath(@OUTPUT,"fig1-4.svg")) # hide
# \fig{fig1-4}
# 
# ### 例24
# 
# ```julia
# function RSS(x,y)
#     ŷ = expand_matrix(x)*MultipleRegression(x,y)
#     return (y-ŷ)'*(y-ŷ)
# end
# 
# function TSS(y)
#     Y = y .- mean(y)
#     return Y'*Y
# end
# 
# ESS(x,y) = TSS(y) - RSS(x,y)
# 
# R2(x,y) = ESS(x,y)/TSS(y)
# ```

x25 = randn(N); y25=randn(N);
β₁, β₀ = min_sq(x25,y25)
Joe.RSS(x,y)
