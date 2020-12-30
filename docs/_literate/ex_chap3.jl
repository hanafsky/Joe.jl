# ## クロスバリデーション
# まず線形回帰の場合のクロスバリデーションの関数を定義します。
# ```julia
# function cv_linear(X::AbstractArray,y::Vector,K::Int)
#     n = length(y); m = round(Int,n/K)
#     S = 0
#     for j in 1:K
#         test = j*m-m+1:j*m
#         train = setdiff(1:n,test)
#         β̂ = multiple_regression(X[train,:],y[train])
#         ŷ = insert_ones(X[test,:])*β̂
#         S += dot(y[test]-ŷ,y[test]-ŷ)
#     end
#     return S/n
# end
# ```
# ### 例39
using Joe, Random, Plots
using Plots.PlotMeasures # hide
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ), # hide
    left_margin = 30px, # hide
    bottom_margin = 30px # hide
) # hide
using Joe: cv_linear
n = 100; p = 5
Random.seed!(1)
X = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y = insert_ones(X)*β + randn(n)
@show cv_linear(X[:,[3,4,5]],y,10);
@show cv_linear(X,y,10);
# あれ？変数選択した方が誤差でかいぞ？試行回数を増やして全変数を用いた場合のCV値と
# 変数選択を行った場合のCV値を可視化します。
using Joe # hide
U=Float64[]; V = Float64[] 
for _ in 1:100
    global U, V, X, β, n # hide
    local y # hide
    y = insert_ones(X)*β + randn(n)
    push!(U,cv_linear(X[:,[3,4,5]],y,10))
    push!(V,cv_linear(X,y,10))
end

p39 = scatter(U,V,xlabel="変数4,5,6を選んだ時の二乗誤差",
                ylabel="全変数を選んだ時の二乗誤差",
                title="変数を多く選びすぎて過学習")
plot!(p39, x->x,xlims=(0.7,1.5),legend=false)
savefig(p39,joinpath(@OUTPUT,"fig3-1.svg")) # hide
# \fig{fig3-1}
# \lineskip
# $y=x$ の直線の上側に大多数の点がプロットされているので、
# 変数選択をした方が誤差が少ないことが分かりました。
# ただ、あまり二乗誤差の違いは大きくないです。
# ### 例40
# kの値を変えたときのCVの予測誤差の変化
n = 100; p = 5;
p40 = plot(ylims=(0.3,1.5),xlabel="k",ylabel="CVの値",
            title="k-foldのkとCVの値の関係",legend=false)
Random.seed!(1)
for _ in 1:10
    global p40 # hide
    local X, β, y, U, V # hide
    X = randn(n,p)
    β = randn(p+1)
    y = insert_ones(X) * β + randn(n)
    U = Int[]
    V = Float64[]
    for k in 2:n
        if n%k==0 
            push!(U,k)
            push!(V, cv_linear(X,y,k))
        end
    end
    plot!(p40,U,V)
end
savefig(p40,joinpath(@OUTPUT,"fig3-2.svg")) # hide
# \fig{fig3-2}
# ### 例41 (FInsherのあやめ)
# あやめのデータセットでK近傍法のｋ毎に誤り率を評価します。

using RDatasets, StatsBase, Random, Plots
using Joe:knn
iris = dataset("datasets","iris")
X = iris[!,1:4] |> Matrix
targets=unique(iris.Species);
# あやめの種類をIntに変換します。
label = Dict(target=>i for (i,target) in enumerate(targets))
y = [label[i] for i in iris.Species];
n = length(y);
# データセットをランダムに並べ替えておきます。
Random.seed!(1)
order = sample(1:n,n,replace=false)
X = X[order,:]; y = y[order];
# 10-foldクロスバリデーションなので、テストデータを15毎に交代させることになります。
errorRate = Vector{Float64}(undef,10) 
for k in 1:10
    global errorRate, X, y # hide
    S = 0
    for top in 1:15:150
        test = top:top+14
        train = setdiff(1:150,test)
        knn_ans = knn(X[train,:],y[train],X[test,:],k)
        S += sum(y[test] .!= knn_ans)
    end
    S /= n
    errorRate[k] = S
end
p41 = plot(errorRate,xlabel="K",ylabel="誤り率",
            legend=false, title="CVによる誤り率の評価")
savefig(p41,joinpath(@OUTPUT,"fig3-3.svg")) # hide
# \fig{fig3-3}
# \lineskip
# $K \ge 3$で大きく誤り率が低下することが分かりました。
# pythonでは実行に10分程度かかったとありますが、いくらなんでも遅すぎでは？(juliaは瞬殺)
# ## 線形回帰の場合の公式(CVの公式)
# クロスバリデーションでの誤差の分析は、訓練データ毎に重回帰分析を行う必要があるので、
# 処理に時間がかかります。$\hat{\beta}_{-S}$をあらわに求めることなく、CVを
# 楽して評価できるのがこの公式です。($S$はテストデータの集合、$-S$は訓練データの集合)
# \lineskip
# $$\sum_{S} || (I - H_S)^{-1}e_S||^2$$
# ただし、$H_S = X_S(X^\mathsf{T}X)^{-1}X_S^\mathsf{T}$、
# $e_S = y_S - X_S\hat{\beta}$ です。プログラムを実装して、ベンチマークをしてみます。
# cv_fast関数は次のように実装しました。
# ```julia
# function cv_fast(X::AbstractArray,y::Vector,K::Int)
#     n = length(y); m = round(Int,n/K)
#     X = insert_ones(X)
#     H = X*((X'X)\X')
#     e = (I(n) - H)*y
#     S = 0
#     @views for j in 1:K
#         test = j*m-m+1:j*m;
#         err = (I(m)-H[test,test]) \ e[test]
#         S += dot(err,err)
#     end
#     return S/n
# end
# ```
using Joe, Random, Plots
using Joe:cv_linear,cv_fast

n = 1000; p = 5
Random.seed!(1)
X = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y = insert_ones(X)*β + randn(n);
# ループのネストを浅くしたいので、K-foldのkのリストを作って、ループすることにします。
K = [i for i in 2:1000 if 1000%i ==0]
t_linear = Vector{Float64}(undef,length(K));
t_fast = similar(t_linear);
# まずは関数の慣らし運転を
@show cv_linear(X,y,10)
@show cv_fast(X,y,10)
# 値が一致することは確認できました。それでは、いざ本番!
for i in eachindex(K)
    global X, y, t_fast, t_linear,K # hide
    start = time_ns();cv_fast(X,y,K[i]);stop = time_ns()
    t_fast[i] = (stop-start)/1e9
    start = time_ns();cv_linear(X,y,K[i]);stop = time_ns()
    t_linear[i] = (stop-start)/1e9
end
p42 = plot(ylims=(0.0,0.5), xlabel = "k" ,ylabel="実行時間",
           label="cv_linear",title="cv_fastとcv_linearの比較",
           legend=:topleft)
plot!(p42,K, t_linear, label="cv_linear")
plot!(p42,K, t_fast, label="cv_fast")
savefig(p42,joinpath(@OUTPUT,"fig3-4.svg")) # hide
# \fig{fig3-4}
# \lineskip
# $n\ge100$ではcv_fastの方が実行時間が短いことが分かります。
# 原著と比べると、マシンの違いがあるとはいえ、juliaは速いということもよくわかります。
# ## ブートストラップ
# 以下のような複合型とbootstrap関数を定義しました。
# 原著のコードよりは可読性が向上したかなぁ。
# ```julia
# using Parameters
# @with_kw mutable struct bt{T<:Number}
#     original::T = 0
#     bias::T = 0
#     stderr::T = 0
# end
# function bootstrap(df::AbstractArray{T}, F::Function, r::Int) where T <:Number
#     m,_ = size(df)
#     original = F(df,1:m)
#     u = Vector{T}(undef, r)
#     for i in 1:r
#         index = sample(1:m,m,replace=true)
#         u[i] = F(df,index)
#     end
#     bias = mean(u) - original; stderr = std(u)
#     result = bt()
#     @pack! result = original, bias, stderr 
# end
# ```
# ### 例43
# データは[ここ](https://bitbucket.org/prof-joe/statistical_learning_with_python/src/master/)からダウンロードできます。
using DelimitedFiles, Statistics
using Joe:bootstrap
function func_1(data,index)
    X=data[index,1]; Y= data[index,2]
    (var(Y) - var(X))/(var(X) + var(Y) -2cov(X,Y))
end
Portfolio = readdlm(joinpath("_assets","data","Portfolio.csv"),',', skipstart=1)
bootstrap(Portfolio,func_1,1000)

# ### 例44
# データの読み込み
using Joe,DelimitedFiles
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:4]; y =df[:,1]
β = multiple_regression(X,y)

# 回帰係数のそれぞれについて、ブートストラップ法を適用します。ここでは標準偏差だけを出力します。
std_bt = ones(3) 
for j in 1:3
    function func_2(data,index)
        X = data[index,3:4];y = data[index,1]
        β = multiple_regression(X,y)
        return β[j]
    end
    std_bt[j] = bootstrap(df,func_2,1000).stderr
end
std_bt
# GLM.jlで回帰係数を推定したときの標準偏差と比較してみます。
using GLM, DataFrames
data = DataFrame(df)
ols = lm(@formula(x1 ~ x3 + x4), data)
# 標準偏差がほぼ一致することが分かりました。