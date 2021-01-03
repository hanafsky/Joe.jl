<!--This file was generated, do not modify it.-->
## 多項式回帰
### 例52
sin関数に乱数を足した観測データを多項式で回帰します。
\lineskip
データの生成

```julia:ex1
using Plots, Joe, Random
using Plots.PlotMeasures # hide
Plots.reset_defaults() # hide
gr() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ), # hide
    left_margin = 30px, # hide
    bottom_margin = 30px # hide
) # hide
Random.seed!(12)
n = 100; x = randn(n); y = sin.(x) + randn(n);
p52 = scatter(x,y,xlabel="x", ylabel="y", label=false, legend=:topleft);
```

3、5、7次の多項式で回帰します。
多項式回帰用にデータセットを作る関数を定義したので、これを使ってみます。
```julia
polynomial(x::Vector, P::Int) = hcat([x.^p for p in 1:P]...)
polynomial(x::AbstractRange, P::Int)= polynomial(collect(x),P)
```

```julia:ex2
using Joe:polynomial
p_set = [3,5,7]
x_seq = -3:0.1:3
for p in p_set
    global x, y, x_seq, p52 # hide
    X = polynomial(x,p)
    β̂ = multiple_regression(X,y)
    ŷ = insert_ones(polynomial(x_seq,p))*β̂
    plot!(p52, x_seq,ŷ,label="p = $p")
end
savefig(p52,joinpath(@OUTPUT,"fig6-1.svg")) # hide
```

\fig{fig6-1}
### 例53
矩形波に雑音をノイズをのせたデータを作って、フィッティングします。
まずはデータを生成します。

```julia:ex3
using Plots, Random
Random.seed!(123)
n = 100; x = randn(n) * π
y = abs.(round.(x) .%2) * 2  .- 1+ randn(n)*0.2
p53 = scatter(x,y,label= false);
```

基底関数が、$f_1(x) = 1$、 $f_2(x) = \cos(x) $、 $f_3(x) = \cos(2x)$、
$f_4(x) = \cos(3x)$の場合と、$f_1(x) = 1$、 $f_2(x) = \sin(x) $、 $f_3(x) = \sin(2x)$、
$f_4(x) = \sin(4x)$の場合とでそれぞれ回帰分析します。
準備として先ほどのpolynomial関数をべき乗以外にも対応できるように多重ディスパッチで拡張します。
```julia
polynomial(x::Vector, P::Int, f::Function) = hcat([f.(p*x) for p in 1:P]...)
polynomial(x::AbstractRange, P::Int, f::Function) = polynomial(collect(x), P, f)
```
$(-8,8)$の区間でフィッティングします。

```julia:ex4
x_seq = -8:0.2:8
```

cosの場合

```julia:ex5
X_cos = polynomial(x,3,cos)
β̂_cos = multiple_regression(X_cos,y)
ŷ_cos = insert_ones(polynomial(x_seq,3,cos))*β̂_cos;
```

sinの場合

```julia:ex6
X_sin = polynomial(x,3,sin)
β̂_sin = multiple_regression(X_sin,y)
ŷ_sin = insert_ones(polynomial(x_seq,3,sin))*β̂_sin;
```

可視化します。

```julia:ex7
plot!(p53,x_seq,ŷ_cos,label="cos")
plot!(p53,x_seq,ŷ_sin,label="sin")
savefig(p53,joinpath(@OUTPUT,"fig6-2.svg")) # hide
```

\fig{fig6-2}
\lineskip
cosを基底にとったほうが、上手くフィッティングできることが確認できました。
## スプライン回帰
スプライン回帰については、まずスプラインに関する複合型を作って、
function-like objectを実装しました。
spline_matrix関数は、あとで変更できるようにキーワード引数にしました。

```julia
using Parameters
@with_kw mutable struct Spline{T<:Number}
    xmin::T = -1.0
    xmax::T = 1.0
    K::Int = 5
end
function spline_matrix(x::Vector,K::Int,xmin,xmax)
    n = length(x)
    Knots = range(xmin,stop=xmax,length=K)
    X = zeros(n,K+4)
    X[:,1] .= 1
    X[:,2] .= x
    X[:,3] .= x.^2
    X[:,4] .= x.^3
    for j in 1:K
        X[:,j+4] = @. max(x - Knots[j], 0)^3
    end
    return X
end
function (s::Spline)(x::Vector, y::Vector, x_pred::Vector;
          spline_matrix::Function=spline_matrix)
    @unpack xmin, xmax, K = s
    Knots = range(xmin,stop=xmax,length=K)
    X = spline_matrix(x,K,xmin,xmax)
    X_pred = spline_matrix(x_pred,K,xmin,xmax)
    β = (X'X)\X'y
    ypred = X_pred*β
end
(s::Spline)(x::Vector, y::Vector, x_pred::AbstractRange;kwargs...) = s(x,y,collect(x_pred);kwargs...)
```
### 例54
sinカーブに乱数を加えたデータにスプライン回帰でフィッティングします。
分割点数が7以上でデータに追随していることがわかります。

```julia:ex8
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
```

\fig{fig6-5}
### 例56 自然なスプライン曲線
スプライン曲線の両端が直線になっているものです。
原著では、関数dとか関数hを定義して使っていました。
そんなことはしたくないけど、いい名前もないので、関数内で定義して使うことにしました。
```julia
function natural_spline_matrix(x::Vector, K::Int, xmin, xmax)
    n = length(x)
    Knots = range(xmin,stop=xmax,length=K)
    X = zeros(n,K)
    X[:,1] .= 1
    X[:,2] .= x
    d(x::Vector,a::Number,b::Number) =  @. (max(x-a,0)^3 - max(x-b,0)^3) / (b-a)
    for j in 1:K-2
        X[:,j+2] = d(x,Knots[j],Knots[end]) - d(x,Knots[end-1],Knots[end])
    end
    return X
end
```
例54と同じデータに、ただのスプラインと自然なスプラインの回帰を適用し、
結果を可視化します。まずデータの生成とスプライン型を定義します。

```julia:ex9
using Plots, Random
using Joe: Spline
using Joe
Random.seed!(123)
n = 100; x = randn(n)*2π; y = sin.(x) + 0.2randn(n)
spline6 = Spline(xmin=-5, xmax=5, K=6);
spline11 = Spline(xmin=-5, xmax=5, K=11);
```

次に回帰を行います。自然なスプラインで回帰を行う場合には、キーワード引数を指定します。

```julia:ex10
u_seq = -6:0.02:6;
v_seq6 = spline6(x,y,u_seq);
v_seq11 = spline11(x,y,u_seq);
w_seq6 = spline6(x,y,u_seq;splinematrix=Joe.natural_spline_matrix);
w_seq11 = spline11(x,y,u_seq;splinematrix=Joe.natural_spline_matrix);
```

可視化します。

```julia:ex11
p56_1 = scatter(x,y,xlims=(-7,7),xlabel="x",ylabel="f(x),g(x)",label=false,title="K=6")
p56_2 = scatter(x,y,xlims=(-7,7),xlabel="x",ylabel="f(x),g(x)",label=false,title="K=11")
plot!(p56_1,u_seq,v_seq6,label="spline")
plot!(p56_1,u_seq,w_seq6,label="natural spline")
vline!(p56_1,[-5,5];linewidth=1,label=false)
vline!(p56_1,range(-5,stop=5,length=6);linestyle=:dash,label=false)
plot!(p56_2,u_seq,v_seq11,label="spline")
plot!(p56_2,u_seq,w_seq11,label="natural spline")
vline!(p56_2,[-5,5];linewidth=1,label=false)
vline!(p56_2,range(-5,stop=5,length=11);linestyle=:dash,label=false)
p56 = plot(p56_1,p56_2,layout=(2,1))
savefig(p56,joinpath(@OUTPUT,"fig6-7.svg")) # hide
```

\fig{fig6-7}
## 平滑化スプライン
平滑化スプラインは区切り点を指定するときにデータ点自身を使っていたので、
以下のように書き直しました。(function-like objectにするまでもなかった。)
```julia
struct SmoothingSpline
    x::Vector
end
function (s::SmoothingSpline)(y::Vector,x_pred::Union{Vector,AbstractRange};λ=0)
    x = s.x
    X = smoothing_spline_matrix(x,x)
    G = green_silverman(x)
    γ = (X'X + λ*G)\X'y
    X_pred = smoothing_spline_matrix(x_pred,x)
    ypred = X_pred*γ
end
```
ただし、smoothing_spline_matrixとgreen_silverman関数は以下の通りです。
```julia
function smoothing_spline_matrix(x::Vector,Knots::Union{Vector, AbstractRange})
    n = length(x)
    K = length(Vector)
    X = zeros(n,K)
    X[:,1] .= 1
    X[:,2] .= x
    d(x::Vector,a::Number,b::Number) =  @. (max(x-a,0)^3 - max(x-b,0)^3) / (b-a)
    for j in 1:K-2
        X[:,j+2] = d(x,Knots[j],Knots[end]) - d(x,Knots[end-1],Knots[end])
    end
    return X
end

function green_silverman(x::Vector)
    n = length(x)
    g = zeros(n,n)
    for i in 3:n ,j in i:n
        g[j,i] =(12(x[end]-x[end-1])*(x[end-1]-x[j-2])*(x[end-1]-x[i-2])+
                (x[end-1]-x[j-2])^2*(12x[end-1]+6x[j-2]-18x[i-2]))/
                (x[end]-x[i-2])/(x[end]-x[j-2])
        g[i,j] = g[j,i]
    end
    return g
end
```
### 例57
$x\in(-5,5)$の一様分布からサンプルを生成します。
原著では、サンプル生成コードが間違っているようなので、ipynbの記述を参照しました。

```julia:ex12
using Plots, Random, Distributions
using Joe: SmoothingSpline
using Joe
Random.seed!(11)
n = 100;
x = rand(Uniform(-5,5),n); y = x .+ 2sin.(x) + randn(n)
index = sortperm(x); x = x[index]; y = y[index]

p57 = scatter(x,y,label=false)

sspline = SmoothingSpline(x)
u_seq = -8:0.02:8
λ_set = [40,400,1000]
for λ in λ_set
    global u_seq, p57 # hide
    v_seq = sspline(y,u_seq,λ=λ)
    plot!(p57,u_seq,v_seq,label="λ = $λ")
end
p57
plot!(p57,u_seq,sspline(y,u_seq,λ=1),label="λ = 1")
savefig(p57,joinpath(@OUTPUT, "fig6-8.svg")) # hide
```

\fig{fig6-8}
\lineskip
$\lambda$が大きくなると、直線に近くなっていくようです。
### 例58 クロスバリデーションによる平滑化スプラインの正則化乗数の最適化
3章で使った線形回帰の場合の高速なクロスバリデーションの公式
$$CV[\lambda] \coloneqq \sum_{S}||(I - H_S[\lambda])^{-1}e_S ||^2$$
$$H_S[\lambda] \coloneqq X_s(X^\mathsf{T}X+\lambda G)^{-1}X^\mathsf{T}_S$$
を利用して、$\lambda$の最適化を行います。
以下のcv_ss_fast関数を定義して利用します。
```julia
function cv_ss_fast(X::AbstractArray,y::Vector,G::AbstractArray,K::Int;λ=0)
    n = length(y); m = round(Int,n/K)
    H = X*((X'X + λ*G)\X')
    e = (I(n) - H)*y
    S = 0
    @views for j in 1:K
        test = j*m-m+1:j*m;
        err = (I(m)-H[test,test]) \ e[test]
        S += dot(err,err)
    end
    return S/n,tr(H)
end
```
3章の使ったcv_fast関数とほぼ同様ですが、定数項の列を付けないことと、
正則化乗数が引数になっていること、クロスバリデーション誤差だけでなく、
Hのトレースも返していることなどが異なります。
まずはデータを生成します。

```julia:ex13
using Random, Distributions
Random.seed!(11)
n = 100; x = rand(Uniform(-5,5),n) ; y = x -0.02sin.(x)-0.1randn(n);
index = sortperm(x); x = x[index]; y = y[index];
```

XとGを計算します。

```julia:ex14
X = Joe.smoothing_spline_matrix(x,x);
G = Joe.green_silverman(x);
```

クロスバリデーション誤差とHのトレース(有効自由度)を求めます。

```julia:ex15
result = hcat([collect(Joe.cv_ss_fast(X,y,G,n,λ=λ)) for λ in 1:50]...)
using Plots
p58 = plot(result[2,:], result[1,:],label= false,
            xlabel="有効自由度", ylabel="CVによる予測誤差",
            title = "有効自由度とCVによる予測誤差")
savefig(p58,joinpath(@OUTPUT,"fig6-9.svg"))
```

\fig{fig6-9}
\lineskip
(注)ちなみに生成するデータによって、グラフの形はかなり変わります。
## 局所回帰
### 例60 nadaraya-watson推定量
nadaraya-watson推定量の計算の実装です。
カーネルは関数の引数にして、別のものに変更できるようにしました。(ここでは他のカーネルは出てきませんが。)
```julia
epanechnikov(x,y,λ) = norm(x-y)/λ |> c -> max(0.75*(1-c^2),0)

function nadaraya_watson_estimator(x_observed::Vector,y_observed::Vector,kk::Function,x_pred::TP;λ=1.0) where {TP<:Number}
    n = length(y_observed)
    S = 0; T = 0;
    for i in 1:n
        S += kk(x_observed[i],x_pred,λ)*y_observed[i]
        T += kk(x_observed[i],x_pred,λ)
    end
    result = T == 0 ? 0 : S/T
    return result
end
ベクトル化にも対応しています。
function nadaraya_watson_estimator(x_observed::Vector,y_observed::Vector,kk::Function,x_pred::Union{Vector,AbstractRange};λ=1.0)
    y_pred = [nadaraya_watson_estimator(x_observed,y_observed,kk,xp; λ) for xp in x_pred]
end
```
\note{epanechnikoc関数に絶対値の処理は必要になりますが、abs関数を使うよりもLinearAlgebra.jlのnormを使った方が、多次元化に対応できて良いと思います。}
トイデータとしてsin関数にノイズをのせたデータを作成します。

```julia:ex16
using Random
Random.seed!(123)
n=250;x = 2randn(n); y = sin.(2π*x) + randn(n)/4

using Plots
p58 = scatter(x,y,xlims=(-3,3),label=false)
xx = -3:0.1:3
using Joe:nadaraya_watson_estimator, epanechnikov
using LinearAlgebra
```

$\lambda=0.05,0.25$の場合にプロットしてみます。

```julia:ex17
plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=0.05),
         label="λ = 0.05");
plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=0.25),
         label="λ = 0.25");
```

クロスバリデーションで$\lambda$を最適化してプロットしてみます。

```julia:ex18
λ_seq = 0.05:0.01:1
SS_min = Inf
λ_best = λ_seq[1]
for λ in λ_seq
    global SS_min, λ_best,n,x,y # hide
    SS = 0
    m = Int(n/10)
    for k in 1:10
        test = k*m-m+1:k*m
        train = setdiff(1:n,test)
        y_pred = nadaraya_watson_estimator(x[train],y[train],epanechnikov,x[test];λ=λ)
        SS += dot(y[test]-y_pred,y[test]-y_pred)
    end
    if SS < SS_min
        SS_min = SS
        λ_best = λ
    end
end

plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=λ_best), label="λ = λ_best")
savefig(p58,joinpath(@OUTPUT,"fig6-10.svg")) # hide
```

\fig{fig6-10}
\lineskip
$\lambda_{best}$はこの程度の値になるようです。

```julia:ex19
@show λ_best;
```

### 例61 局所線形回帰
カーネル関数$k$を成分に持った対角行列$\bm{W}$を
$$\bm{W} = \begin{bmatrix}
 k(x,x_1) & \cdots & 0 \\
 \vdots & \ddots & \vdots \\
 0 & \cdots & k(x,x_n) \end{bmatrix} $$
とした時、
$$ L \coloneqq (\bm{y} - \bm{Xβ}(x))^\mathsf{T}\bm{W}(\bm{y} - \bm{Xβ}(x)) $$
を最小化する$\bm{\beta}(x)$を求めます。
$$ \dfrac{\partial L}{\partial \bm{\beta}} =
-2\bm{X}^\mathsf{T}\bm{W}(\bm{y} - \bm{Xβ}(x))=0$$とおくと、
$$ \bm{\beta}(x) = (\bm{X}^\mathsf{T}\bm{WX})^{-1}\bm{X}^\mathsf{T}\bm{Wy}$$
で係数を求めることができます。この処理を関数で実装するわけですが、原著のlocalという関数名は良くないので、
local_regressionという名前で実装しました。例では1次元に限定していましたが、
多次元データにも対応させています。
```julia
function local_regression(x::Matrix{T},
                          y::Vector{T},
                          kernel::Function;
                          x_pred=x, λ=1) where {T<:Number}
    N,_ = size(x)
    @assert N==length(y)
    X = insert_ones(x)
    m,_ = size(x_pred)
    y_pred = Vector{T}(undef,m)
    for j in 1:m
        W = [kernel(x[i,:],x_pred[j,:],λ) for i in 1:N] |> diagm
        β̂ = (X'*W*X)\X'*W*y
        y_pred[j] = dot(insert_ones(x_pred[j,:]),β̂)
    end
    return y_pred
end
function local_regression(x::Vector{T}, y::Vector{T},kernel::Function;x_pred=x,λ=1) where {T<:Number}
    return local_regression(x[:,:],y,kernel;x_pred=x_pred[:,:],λ=λ)
end
```
トイデータとしてsin関数にノイズをのせたデータを作成します。

```julia:ex20
using Random,Joe
Random.seed!(123)
n=30; x = 2π*rand(n) .- π; y = sin.(x) .+ randn()
p61 = scatter(x,y,label=false)
m = 200;U = -π:π/m:π;
```

正則化パラメータ$\lambda=1$の条件で回帰分析を行ってプロットします。

```julia:ex21
V = Joe.local_regression(x,y,Joe.epanechnikov;x_pred=U)
plot!(p61,U,V,label=false,title = "局所線形回帰(p=1, N=30)")
savefig(p61,joinpath(@OUTPUT,"fig6-11.svg")) # hide
```

\fig{fig6-11}
\lineskip
予測したい場所の数だけ回帰分析の計算を行わないといけないので、元データの数が多い時は
計算が大変そうです。
## 一般化加法モデル
### 例62
基底関数の数が有限個なら線形回帰の手法で係数を求められるけど、
数が多すぎると逆行列を解くのが大変でどうしましょうとい３う話。
バックフィッティングは例63で実装します。
### 例63
以下のようなpolyfit関数を実装しました。
```julia
function polyfit(x,y;x_pred=x, P::Int=3)
    X = polynomial(x,P)
    X_pred=polynomial(x_pred,P)
    β̂ = multiple_regression(X,y)
    y_pred = insert_ones(X_pred) * β̂
end
```
[例６１](#例61)のデータに一般加法モデルを適用します。
先に多項式でフィッティングして残りを局所線形回帰で求めていきます。

```julia:ex22
using Random,Joe
Random.seed!(123)
n=30; x = 2π*rand(n) .- π; sort!(x); y = sin.(x) .+ randn()
y₁ = zeros(n); y₂ = zeros(n)
for k in 1:10
    global x,y,y₁,y₂ # hide
    y₁ = Joe.polyfit(x,y-y₂)
    y₂ = Joe.local_regression(x,y-y₁,Joe.epanechnikov)
end
using Plots
p62_1 = plot(x,y₁,label=false,xlabel="x",ylabel="f(x)",title="多項式回帰(3次)")
p62_2 = plot(x,y₂,label=false,xlabel="x",ylabel="f(x)",title="局所線形回帰")
p62　= plot(p62_1,p62_2,layout=(1,2))
savefig(p62,joinpath(@OUTPUT,"fig6-12.svg")) # hide
```

\fig{fig6-12}
\lineskip
大体３次多項式で回帰されていて、残りが局所線形回帰されていることが分かります。
先に3次多項式で回帰したためでしょうか。 確認してみることにします。

```julia:ex23
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
```

\fig{fig6-12-2}
\lineskip
多項式回帰の影響が減って、局所線形回帰の成分が大きくなることが確認できました。

