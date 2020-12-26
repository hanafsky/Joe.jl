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

```julia:ex4
using Joe, Random, LinearAlgebra
using Plots
N=1000; p=2; Random.seed!(1)
X = expand_matrix(randn(N,p))
β = randn(p+1)
prob = @. 1/(1 + exp($*(X,β)))
threshold=0.5
y = ifelse.(rand(N) .> prob,1,-1) # ここまでデータ生成
@show y β;
```

せっかくなのでデータを可視化してみます。

```julia:ex5
data1 = X[y .== 1, 2:3]
data2 = X[y .== -1, 2:3]
p33=scatter(data1[:,1],data1[:,2],ylims=(-5,5),marker=:auto, label="y=1")
scatter!(p33,data2[:,1],data2[:,2],marker=:auto,label="y=-1")
plot!(p33,x-> -β[1]/β[3] - β[2]/β[3]*x, label="β")
savefig(p33,joinpath(@OUTPUT,"fig2-2.svg")) # hide
```

\fig{fig2-2}

```julia:ex6
γ = randn(2+1) #初期値
γ2 = copy(γ) #別解用にコピー
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
plot!(x-> -γ[1]/γ[3] - γ[2]/γ[3]*x, label="γ")
```

今度は横着をして、ヘシアンを使って計算してみます。

```julia:ex7
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
```

\fig{fig2-2-2}
\lineskip
だいたい同じような境界線が得られることが分かりました。
### 例34
データの半分を使ってロジスティック回帰で学習し、残りのデータで検証する練習。
まずデータを生成します。

```julia:ex8
using Joe, Random, Distributions, Plots, LinearAlgebra
Random.seed!(123)
n=100
x34 = vcat(randn(n).+1,randn(n).-1) |> expand_matrix
y34 = vcat(ones(n),-ones(n));
```

訓練データとテストデータを分けて可視化します。

```julia:ex9
index = sample(1:2n,2n,replace=false); #ランダムなインデックスを作り
train = index[begin:n];# 学習用とテスト用にインデックスを分ける。
test = index[n+1:end];
X_train = x34[train,:];y_train = y34[train]
X_test = x34[test,:];y_test = y34[test]
p34 = scatter(X_train[:,2],y_train,label="train")
scatter!(p34,X_test[:,2],y_test,label="test")
savefig(p34,joinpath(@OUTPUT,"fig2-2-3.svg")) # hide
```

\fig{fig2-2-3}
\lineskip
\note{
**訓練データとテストデータを分ける方法**

原著のpythonコードでは以下のようになっています。
```python
import numpy as np
train = np.random.choice(2*n, int(n), replace=false)
test = list(set(range(n))-set(train))
```
setを使った書き方は便利ですが、juliaでは重複を許さずにランダムに並べたインデックスを二つに分ける
方法を使いました。
```julia
using StatsBase
index = sample(1:n,n,replace=false);
train = index[begin:Int(n/2)];
test = index[Int(n/2)+1:end];
```
でもよく考えるとsetdiffを使えば十分でした。
```julia
train = sample(1:2n,n,replace=false); test = setdiff(1:2n,train)
```
}
ループは原著の方法に従いました。

```julia:ex10
β = [0,0] #初期値
γ = randn(2)
while sum(β-γ)^2 > 0.001
    global β, γ
    β = γ
    s = X_train*β
    v = @. exp(-s*y_train)
    u = @. y_train*v/(1+v)
    w = @. v/(1+v)^2
    local W = diagm(w)
    z = @. s + u/w
    γ = (X_train'*W*X_train)\(X_train'*W*z)
    @show γ;
end
```

次にこのγを使って、テストデータを予測してみます。 正誤をカウントする関数を次のように定義します。
```julia
function table_count(test,pred)
    @assert length(test) == length(pred)
    m = unique(test) |> length
    count = zeros(Int,m,m)
    for i in 1:length(test)
        count[test[i],pred[i]] += 1
    end
    return count
end
```

```julia:ex11
using Joe:table_count
y_pred = X_test*γ .|> x -> ifelse(x>0,2,1)
y_answer = y_test .|> x -> ifelse(x>0,2,1)
table = table_count(y_answer,y_pred)
@show table;
正答率 = sum(diag(table)) / sum(table)
```

## 2.3 線形判別と二次判別
### 例35
まずは与えられた平均と分散共分散行列から二次元正規分布のデータを2種類生成します。

```julia:ex12
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

```julia:ex13
μ̂₁ = mean(data1,dims=1)'; Σ̂₁ = cov(data1,dims=1);
μ̂₂ = mean(data2,dims=1)' ; Σ̂₂ = cov(data2,dims=1);
```

\warning{mean関数で行列の列方向の平均をとる時、得られるデータは二次元の横ベクトルになっている。
縦ベクトルとして扱いたいので、転置(正確には複素共役）をしている。}
それぞれの分布の情報を複合型にまとめておきます。
```julia
@with_kw struct QDA
    μ::Array # 平均
    Σ::Matrix # 分散共分散行列
    invΣ::Array = inv(Σ) # 分散共分散行列の逆行列
    detΣ = det(Σ) # 分散共分散行列の行列式
end
```
\note{しれっとパラメータを初期化した複合型を使っていますが、ここではParameters.jlとい
うサードパーティライブラリを使っています。}
また、多変量正規分布の対数尤度を取得する関数を以下のように定義します。
ここでは、juliaのfunction-like objectの機能を利用しています。
また、可変長引数(x...)を利用して、データが3次元以上の場合にも拡張しています。
キーワード付き引数に事前確率を加えています。
\note{function-like objectの機能を使うと、複合型のインスタンスを関数のように
使うことができ、再利用しやすくなります。}
```julia
function (qda::QDA)(x...,prior=1.0)
    data = collect(x)
    @unpack μ,invΣ,detΣ = qda
    a = 0.5*(data-μ)' * invΣ * (data-μ)
    a[1] - log(detΣ) - log(prior)
end
```

```julia:ex14
using Joe: QDA
param1=QDA(μ= μ̂₁,Σ = Σ̂₁);param2=QDA(μ = μ̂₂,Σ = Σ̂₂)

hanbetsu(x,y) = param1(x,y) - param2(x,y)
x35=-5:0.1:5;y35=-5:0.1:5;
scatter(data1[:,1],data1[:,2])
scatter!( data2[:,1],data2[:,2])
p35_2=contour!(x35,y35, hanbetsu.(x35,y35'), title="QDA")
savefig(p35_2,joinpath(@OUTPUT,"fig2-4.svg")) # hide
```

\fig{fig2-4}

線形判別を行う場合は、分散共分散行列が等しいことを仮定します。
data1とdata2を、それぞれ中心化後に統合したデータセットについて、
新たな分散共分散行列を求めることにします。

```julia:ex15
Σ_L =  vcat(data1 .- μ̂₁' , data2 .- μ̂₂') |> cov
param1_L=QDA(μ= μ̂₁,Σ =Σ_L );param2_L=QDA(μ = μ̂₂,Σ = Σ_L)
hanbetsu_L(x,y) = param1_L(x,y) - param2_L(x,y)
p35_3=contour!(p35,x35,y35, hanbetsu_L.(x35,y35'), title="LDA")
savefig(p35_3,joinpath(@OUTPUT,"fig2-5.svg")) # hide
```

\fig{fig2-5}

### 例36 (Fisherのあやめ)
まずRDatasetsからirisのデータセットを読み込みます。

```julia:ex16
using RDatasets, StatsBase, Random
using Joe:QDA
iris = dataset("datasets","iris")
x = iris[!,1:4] |> Matrix
targets=unique(iris.Species)
```

あやめの種類をIntに変換します。

```julia:ex17
label = Dict(target=>i for (i,target) in enumerate(targets))
y = [label[i] for i in iris.Species];
```

訓練データとテストデータを分けます。

```julia:ex18
Random.seed!(123)
n = length(y)
index = sample(1:n,n,replace=false); #ランダムなインデックスを作り
train = index[begin:Int(n/2)];# 学習用とテスト用にインデックスを分ける。
test = index[Int(n/2)+1:end];
X_train= x[train,:]; X_test = x[test,:];
y_train = y[train]; y_test = y[test];
```

それぞれのあやめの訓練データの平均と分散共分散行列を求めて保存する。

```julia:ex19
Params = QDA[]
for i in 1:3
    μ,Σ =  mean_and_cov(X_train[y_train .==i,:])
    push!(Params, QDA(μ=μ', Σ=Σ)) #μは行ベクトルであることに注意
end
```

テストデータで検証する。対数尤度を最大化するラベルを選択します。

```julia:ex20
y_pred = similar(y_test)
for i in 1:length(y_test)
    y_pred[i] = argmax([param(X_test[i,:]...) for param in Params])
end

using Joe:table_count
table_count(y_test,y_pred)
```

### 問29 事前確率が分かっている場合
あやめの事前確率が[0.5,0.25,0.25]だったときは、対数をとって足せば良いでしょう。
キーワード付き引数で事前確率を指定できるようにしたので、
少し書き換えるだけで対応可能です。今回の場合、予測結果に対して影響は少ないようです。

```julia:ex21
priors = [0.5,0.25,0.25]
y_pred2 = similar(y_test)
for i in 1:length(y_test)
    y_pred2[i] = argmax([Params[j](X_test[i,:]...;prior=priors[j]) for j in 1:3])
end
table_count(y_test,y_pred2)
```

## K近傍法
まず、K近傍法による関数を定義します。原著の記法をほぼ踏襲しています。
タイブレーキングが少し重複した書き方になっているのが残念。
```julia
using LinearAlgebra, StatsBase
function knn(X_train::Matrix,y_train::Vector,X_test::Vector, k)
    n = size(X_train)[1]
    distance = [norm(X_train[i,:]-X_test) for i in 1:n]
    S = sortperm(distance)[1:k]
    u = counts(y_train[S], 1:k)
    u_max = maximum(u)
    m = findall(c->c==u_max,u)
    while length(m)!==1 #タイブレーキング
        k -=1
        S = S[1:k]
        u = counts(S, 1:k)
        u_max = maximum(u)
        m = findall(c->c==u_max,u)
    end
    return m[1]
end
```
テストデータが複数の場合は多重ディスパッチで対応します。
```julia
function knn(X_train::Matrix,y_train::Vector,X_test::Matrix, k)
    l = size(X_test)[1]
    w = Array{Int}(undef,l)
    for i in 1:l
        w[i] = knn(X_train,y_train,X_test[i,:], k)
    end
    return w
end
```
### 例37 Fisherのあやめ returns
例36と同じデータを使ってK近傍法でやってみます。

```julia:ex22
using Joe:knn,table_count
y_pred_knn = knn(X_train,y_train,X_test,3)
table_count(y_test,y_pred_knn)
```

この乱数の種の場合だと、二次判別とそれほど精度は変わりません。
## ROC曲線
### 例38
x, y という表記はpositive, negativeに
添え字を陽性をp(positive), 陰性をn(negative)に変えています。
また、varはσに変更しています。

```julia:ex23
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
    global U,V
    U[i] = sum(@. pdf(Normal(μₚ,σₚ),negative) / pdf(Normal(μₙ,σₙ),negative) > θ[i]) / Nₙ
    V[i] = sum(@. pdf(Normal(μₚ,σₚ),positive) / pdf(Normal(μₙ,σₙ),positive) > θ[i]) / Nₚ
end

AUC = 0
for i in 1:length(θ)-1
    global AUC
    AUC += abs(U[i+1]-U[i])*V[i]
end
p38 = plot(U,V,xlabel="False Positive",ylabel="False Negative",
            title="ROC curve",legend=false,
            ann = (0.5,0.5,"AUC = $(round(AUC,digits=2))"))

savefig(p38,joinpath(@OUTPUT,"fig2-6.svg")) # hide
```

\fig{fig2-6}

