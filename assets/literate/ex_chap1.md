<!--This file was generated, do not modify it.-->
# 線形回帰
## 1.1最小二乗法
### 例19（問3に対応）
単回帰分析。回帰係数と切片を返す関数を定義します。
ユニコード使用可能なので数式と関数との対応が分かりやすくできるのがjuliaの特長の一つです。

\note{meanやnorm関数などを使うため、Distributions.jlとLinearAlgebra.jlをインポートしておきます。}

---
```julia
function min_sq(x::Vector{T},y::Vector{T}) where {T<:Number}
    x̄ = mean(x)
    ȳ = mean(y)
    β₁ = (x .- x̄)'*(y .- ȳ) / norm(x .- x̄)^2 #傾き
    β₀ = ȳ - β₁ * x̄ #切片
    return  β₁,β₀
end
```
まずはトイデータの生成から。

```julia:ex1
using Joe, Random, Distributions, LinearAlgebra
Random.seed!(123) #乱数の種を固定
N = 100
a = rand(Normal(2,1),N) #傾き、平均2分散1の正規分布からサンプリング
b = randn() #切片
x = randn(N)
y = a .* x .+ b  + randn(N);
```

普通に単回帰する場合。

```julia:ex2
a1, b1 = min_sq(x,y)
```

データを中心化したあとに回帰分析すると切片が０になる（あたりまえ）。

```julia:ex3
xx = x .- mean(x); yy = y .- mean(y)
a2,b2 = min_sq(xx,yy)
```

図1.2を可視化してみる。matplotlibに比べてコードが短いのがいいですね。
日本語扱うための設定は[GenKurokiさんのコード](https://gist.github.com/genkuroki/6c2b71f62504432bdf8a27d24106cad8)を参考にしました。

```julia:ex4
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
```

\fig{fig1-2}

## 1.2 重回帰
### 例20
$\hat{\beta} = (X^T X)^{-1} X^Ty$ を解くだけなので、もはや関数化する程でもないが、
後々のことを考えて、関数化します。
また、係数行列に定数項のために1の列を1列目に挿入しますが、
わざわざnumpyをimportしてnp.insert(x,0,1,axis=1)を呼び出すのが嫌なので、
以下のような関数を定義しました。(この行列、何かいい名前があるといいのですが。)
```julia
function expand_matrix(X)
    N = typeof(X) <: Matrix  ?  size(X)[1] :  length(X)
    T = eltype(X)
    return hcat(ones(T,N),X)
end
```
また、重回帰係数を最小二乗法で求める関数を次のように定義しました。
```julia
function MultipleRegression(x::Matrix{T}, y::Vector{T}) where {T<:Number}
    N,_ = size(x)
    @assert N==length(y)
    X = expand_matrix(x)
    return (X'X)\X'y
end
```

## 1.4 RSSの分布
### 例21
$\chi^2$分布のプロット。原著のプロット（図1.3）は間違っているらしい。
Plots.jlは無名関数のプロットができるので便利。

```julia:ex5
p13 = plot(xlims=(0,8),ylims=(0,1),title="DOF of chi",legend=:topright)
for i in 1:10
    plot!(p13,0.1:0.1:8,x->pdf(Chisq(i),x),label="dof = $(i)")
end
savefig(p13,joinpath(@OUTPUT,"fig1-3.svg")) # hide
```

\fig{fig1-3}
## 1.5 $\hat{\beta}_j \neq 0$の仮説検定
### 例22
t分布のプロット

```julia:ex6
p15 = plot(x->pdf(Normal(0,1),x),label="正規分布")
for i in 1:10
    plot!(x->pdf(TDist(i),x), ls=:dash, label="dof: $(i)")
end
savefig(p15,joinpath(@OUTPUT,"fig1-5.svg")) # hide
```

\fig{fig1-5}

### 例23

```julia:ex7
N=100;iter_num=100;
data23 = Matrix(undef,iter_num,2)
for i in 1:iter_num
    x23=randn(N)  .+2
    y23= x23 .+ 1 +  randn(N)
    data23[i,:] = min_sq(x23,y23) |> collect
end
p14 = scatter(data23[:,2],data23[:,1],xlabel="β₀",ylabel="β₁",title="test",legend=false)
savefig(p14,joinpath(@OUTPUT,"fig1-4.svg")) # hide
```

\fig{fig1-4}

### 例24(問12に対応)
後々のことを考えて、RSSやR２を定義しておきます。
```julia

function RSS(x::Vector,y)
    β̂ = min_sq(x,y)
    ŷ = β̂[1]*x .+ β̂[2]
    return (y-ŷ)'*(y-ŷ)
end
function RSS(x,y)
    ŷ = expand_matrix(x)*MultipleRegression(x,y)
    return (y-ŷ)'*(y-ŷ)
end


function RSE(x::Matrix,y)
    n,p = size(x)
    RSS(x,y) / (n-p-1) |> sqrt
end

function RSE(x::Vector,y)
    RSS(x,y) / (length(x)-2) |> sqrt
end

function Bdiag(x)
    X = expand_matrix(x)
    return X'X |> inv |> diag
end
```

```julia:ex8
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
```

GLM.jlを使った場合でも同じ値が得られることが確認できます。

```julia:ex9
using GLM, DataFrames
data = DataFrame(X=x24,Y=y24)
ols = lm(@formula(Y ~ X), data)
```

### 例25(問13に対応)
β̂₁/SE(β₁)を繰り返し推定してヒストグラムを作ります。 自由度N-2のt分布によく一致することが確認できます。

```julia:ex10
t25 = Vector{Real}(undef,1000)
for i in 1:1000
    x25 = randn(N); y25 = randn(N)
    t25[i],_ = collect(min_sq(x25,y25)) / Joe.RSE(x25,y25) ./ sqrt.(Joe.Bdiag(x25))
end
p25_1 = histogram(t25,xlims=(-3,3),bins=20,normalize=true,xlabel="tの値",legend=false)
title!("帰無仮説が成立する場合")
plot!(p25_1,x->pdf(TDist(98),x));
```

同じことをy=0.1x+ϵとしてデータをサンプリングしてみます。

```julia:ex11
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
```

\fig{fig1-6}
##　1.6 決定係数と共線形性の検出
$R^2 = 1 - \dfrac{RSS}{TSS} = \dfrac{ESS}{TSS}$にしたがって、次の関数を定義しておきます。
```julia
function TSS(y)
    Y = y .- mean(y)
    return Y'*Y
end

ESS(x,y) = TSS(y) - RSS(x,y)

R2(x,y) = ESS(x,y)/TSS(y)
```
### 例26
決定係数を計算してみます。

```julia:ex12
N = 100; Random.seed!(123)
x26_2 = randn(N,2); x26_1 = randn(N)
y26 = randn(N)
@show Joe.R2(x26_2,y26);
```

また、1変量なら相関係数の二乗になることを確認します。

```julia:ex13
@show Joe.R2(x26_1,y26);
@show cor(x26_1,y26)^2 ; # Statistics.jl
```

### 例27
VIFの計算は既存のパッケージになさそうです。
```julia
function VIF(x)
    _,ncol= size(x)
    v = Vector(undef, ncol)
    for j in 1:ncol
        index = delete!(Set(1:ncol),j) |> collect
        v[j] = 1/(1-R2(x[:,index],x[:,j]))
    end
    return v
end
```

```julia:ex14
using Joe, RDatasets,DataFrames
using Pipe: @pipe
df = dataset("MASS","BOSTON")
x27 = @pipe df |> select(_,Not(:MedV)) |> Array #df[Not(:MedV)]がFranklinで動かん。
#TabularDisplayを使って綺麗に表示する。
using TabularDisplay, Formatting
foo = generate_formatter("%7.5f")
displaytable(Joe.VIF(x27);index=true,indexsep=" -> ",formatter=foo)
```

## 1.7 信頼区間と予測区間
定義にしたがって、信頼区間と予測区間の定義をします。危険率はデフォルトでは0.01としています。
($x_{\star}(X^TX)^{-1}x_{\star}^T$ の計算に横着してdiagを使っているので、ちょっと勿体ないリソースの使い方をしている。)
```julia
function confident_interval(xp,x,y;α=0.01)
    N,p = size(x)
    X = expand_matrix(x)
    XP = expand_matrix(xp)
    typeof(xp) <:Number && (xp =[xp])
    yerror = quantile(TDist(N-p-1),1-α/2) * sqrt.(diag(XP * ((X'X) \ XP')))
end

function prediction_interval(xp,x,y;α=0.01)
    N,p = size(x)
    X = expand_matrix(x)
    XP = expand_matrix(xp)
    typeof(xp) <:Number && (xp =[xp])
    yerror = quantile(TDist(N-p-1),1-α/2) * sqrt.( 1 .+ diag(XP * ((X'X) \ XP')))
end
```
### 例28

```julia:ex15
using Random
N = 100; Random.seed!(123)
x28 = randn(N,1)
y28 = x28 .+1 + randn(N)  |> vec # 真の切片と傾きはともに1
p28 = scatter(x28,y28,xlabel="x",ylabel="y",label="data     ",legend=:topleft)

β28 = MultipleRegression(x28,y28)
x_seq = -10:0.1:10
ŷ = expand_matrix(x_seq) * β28
yerror1 = Joe.confident_interval(x_seq,x28,y28)
yerror2 = Joe.prediction_interval(x_seq,x28,y28)
plot!(p28,x_seq,ŷ,ribbon=yerror2, label="予測区間")
plot!(p28,x_seq,ŷ,ribbon=yerror1, label="信頼区間")
```

