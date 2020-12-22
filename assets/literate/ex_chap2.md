<!--This file was generated, do not modify it.-->
## ロジスティック回帰
### 例29
シグモイド関数を定義しておきます。
```julia
sigmoid(x::Matrix, β::Vector) = 1 / (1 + exp(-x*β))
```

```julia:ex1
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
```

\fig{fig2-1}

## ニュートン・ラフソン法
### 例31
$x^2-1=0$を4を初期値として数値計算で解く問題。10回でどの程度近づくか。
せっかくなので、 微分をあらわに書き下すのではなくて、自動微分パッケージを使ってみることにします。
見た目が$x \leftarrow x - \dfrac{f(x)}{f'(x)}$という公式のまんまですね。

```julia:ex2
using Zygote
f(x) = x^2 -1
let # hide
x=4
for i in 1:10
    x -= f(x)/f'(x)
    println(x)
end
end # hide
```

### 例31
2変数関数が2つある場合。 Zygote.jlにjacobianがなかったので、ForwardDiff.jlを使ってみます。

```julia:ex3
using ForwardDiff

f(x,y) = [x^2+y^2-1, x+y]
let # hide
z = [3,4]
for i in 1:10
    z -= ForwardDiff.jacobian(x->f(x[1], x[2]),z) \ f(z[1],z[2])
    println(z)
end
end # hide
```

### 例33
最尤推定によりロジスティック回帰を行う問題。
$\nabla l(\beta_0, \beta) = 0$を求める問題を解いてみる。
素直に``1 ./ (1 .+ exp.(X*β))``と書いたりfor文を回しても良いと思いますが。）

```julia:ex4
using Joe, Random, LinearAlgebra
N=1000; p=2; Random.seed!(12)
X = expand_matrix(randn(N,p))
β = randn(p+1)
prob = @. 1/(1 + exp($*(X,β)))
threshold=0.5
y = ifelse.(rand(N) .> prob,1,-1) # ここまでデータ生成
@show y β
```

せっかくなのでデータを可視化してみます。

```julia:ex5
data1 = X[y .== 1, 2:3]
data2 = X[y .== -1, 2:3]
p33=scatter(data1[:,1],data1[:,2],ylims=(-5,5),marker=:auto, label="y=1")
scatter!(data2[:,1],data2[:,2],marker=:auto,label="y=-1")
plot!(x-> -β[1]/β[3] - β[2]/β[3]*x, label="β")
savefig(p33,joinpath(@OUTPUT,"fig2-2.svg")) # hide
```

\fig{fig2-2}

```julia:ex6
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
```

横着をして、自動微分を使って計算してみます。

```julia:ex7
using Zygote, LinearAlgebra
l(γ,X=X,y=y) = sum(@. log( 1 /(1+exp(*($*(X,γ),-y))))) #対数尤度関数

for i in 1:10
    global γ,γ2
    δ =  Zygote.hessian(l,γ) \ l'(γ)
    @show norm(δ)^2
    γ2 -= δ
    @show γ2
end
```

## 2.3 線形判別と二次判別
### 例35
まずは与えられた平均と分散共分散行列から二次元正規分布のデータを2種類生成します。

```julia:ex8
using Distributions, Random,Plots, LinearAlgebra, Parameters
μ₁=[2,2];  Σ₁ = [2 0; 0 2]
μ₂=[-3,-3]; Σ₂ = [1 -0.8; -0.8 1]

N = 100;Random.seed!(123)
data1 = rand(MvNormal(μ₁,Σ₁),100) |> transpose
data2 = rand(MvNormal(μ₂,Σ₂),100) |> transpose
p35 = scatter(data1[:,1],data1[:,2])
scatter!(p35, data2[:,1],data2[:,2])

savefig(p35,joinpath(@OUTPUT,"fig2-3.svg")) # hide
```

\fig{fig2-3}

ここまでデータの生成。
生成したデータから平均と分散共分散行列を計算する。

```julia:ex9
μ̂₁ = mean(data1,dims=1)'; Σ̂₁ = cov(data1,dims=1);
μ̂₂ = mean(data2,dims=1)' ; Σ̂₂ = cov(data2,dims=1);
```

\warning{mean関数で行列の列方向の平均をとる時、得られるデータは二次元の横ベクトルになっている。\
縦ベクトルとして扱いたいので、転置している。}
それぞれの分布の情報を複合型にまとめておく。
```julia
@with_kw struct mvnormal
    μ::Array # 平均
    Σ::Matrix # 分散共分散行列
    invΣ::Array = inv(Σ) # 分散共分散行列の逆行列
    detΣ = det(Σ) # 分散共分散行列の行列式
end
```
また、多変量正規分布の対数尤度を取得する関数を以下のように定義する。
可変長引数を使うことで、データが3次元以上の場合にも拡張している。
```julia
function logMvNormal(parameter::mvnormal,x...)
    data = collect(x)
    @unpack μ,invΣ,detΣ = parameter
    a = 0.5*(data-μ)' * invΣ * (data-μ)
    a[1] - log(detΣ)
end
```

```julia:ex10
using Joe: mvnormal, logMvNormal
param1=mvnormal(μ= μ̂₁,Σ = Σ̂₁);param2=mvnormal(μ = μ̂₂,Σ = Σ̂₂)
```

それぞれの正規分布の平均と分散共分散行列のを与えたときの
対数尤度の差をとって、コンター図にする。(二次判別)

```julia:ex11
hanbetsu(x,y) = logMvNormal(param1,x,y) - logMvNormal(param2,x,y)
x35=-5:0.1:5;
y35=-5:0.1:5;
scatter(data1[:,1],data1[:,2])
scatter!( data2[:,1],data2[:,2])
p35_2=contour!(x35,y35, hanbetsu.(x35,y35'), title="QDA")
savefig(p35_2,joinpath(@OUTPUT,"fig2-4.svg")) # hide
```

\fig{fig2-4}
線形判別を行う場合は、分散共分散行列が等しいことを仮定する。
data1とdata2を、それぞれ中心化後に統合したデータセットについて、
新たな分散共分散行列を求めることにする。 後は

```julia:ex12
Σ_L =  vcat(data1 .- μ̂₁' , data2 .- μ̂₂') |> cov
param1_L=mvnormal(μ= μ̂₁,Σ =Σ_L );param2_L=mvnormal(μ = μ̂₂,Σ = Σ_L)
hanbetsu_L(x,y) = logMvNormal(param1_L,x,y) - logMvNormal(param2_L,x,y)
p35_3=contour!(p35,x35,y35, hanbetsu_L.(x35,y35'), title="LDA")
savefig(p35_3,joinpath(@OUTPUT,"fig2-5.svg")) # hide
```

\fig{fig2-5}
### 例36 (Fisherのあやめ)
まずRDatasetsからirisのデータセットを読み込む。

```julia:ex13
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
```

params = mvnormal[]
あやめの種類ごとに平均と分散共分散行列
for species in unique(y)
    xx = X[y==species,:]
    push!(μ, mean(xx,dims=1))
    push!(Σ, cov(xx,dims=1))
end

