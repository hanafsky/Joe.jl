# ## Ridge
# Ridge回帰の関数は少し煩雑ですが、標準化処理(データの平均値をひいて、標準偏差で割る)
# を行った後に、回帰分析を行っています。 全てが1の値を持つ列を説明変数に入れてしまうと
# 標準偏差(=0)で割るとエラーを吐くので、こういうことをしているのだと思います。
# ```julia
# using StatsBase
# function ridge(X::Matrix,y::Vector,λ=0)
#     @assert λ ≥ 0
#     n,p = size(X)
#     X̄, σ = mean_and_std(X,1) #説明変数の平均と標準偏差を記録
#     ȳ = mean(y) #目的変数については平均値を取得
#     zscore!(X,X̄,σ) #標準化処理
#     y .-= ȳ
#     β = (X'X + n*λ*I(p)) \ X'*y
#     β ./= vec(σ) #X'Xで割っているので、βをσで割っておく
#     β₀ = ȳ .- X̄*β
#     Dict("β" => β, "β₀" => β₀)
# end
# ```
# ### 例48
# 米国犯罪データをRidge回帰します。

using DelimitedFiles, Plots
using Joe:ridge
using Plots.PlotMeasures # hide
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ),  # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ), # hide
    left_margin = 30px, # hide
    bottom_margin = 30px # hide
) # hide
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
λ = 0:0.5:50

_,p = size(X)
β = hcat([ridge(X,y,l)["β"] for l in λ]...)
p48 = plot(size=(500,500),xlims=(0,50),ylims=(-7.5,15),
           xlabel="λ",ylabel="β")
labels=["警察への年間資金                                                 ",
        "25歳以上で高校を卒業した人の割合",
        "16-19歳で高校に通っていない人の割合",
        "18-24歳で大学生の割合",
        "25歳以上で４年制大学を卒業した人の割合"]
for j in 1:p
    global p48, λ, β, labels # hide
    plot!(p48, λ,β[j,:],label=labels[j])
end
savefig(p48,joinpath(@OUTPUT,"fig5-1.svg")) # hide
# \fig{fig5-1}

# ### 例49
# 絶対値を含む関数のプロット
using Plots
x_seq = -2:0.05:2; 
p49_1 = plot(x_seq, x -> x^2-3x+abs(x),title = "y=x^2-3x+|x|")
scatter!(p49_1,[1],[-1],color=:red,legend=false)
p49_2 = plot(x_seq,x -> x^2 + x +2abs(x),title="y=x^2+x+2|x|")
scatter!(p49_2,[0],[-0],color=:red, legend=false)
p49 = plot(p49_1,p49_2,layout=(1,2),size= (500,200))
savefig(p49,joinpath(@OUTPUT,"fig5-2.svg")) # hide
# \fig{fig5-2}
# ## Lasso
# lassoのプログラムは標準化処理はridgeと共通しています。
# ### 例50
using Joe:lasso
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
λ = 0:0.5:200
_,p = size(X)
β = hcat([lasso(X,y,l)["β"] for l in λ]...)
p50 = plot(size=(500,500),xlims=(0,200),ylims=(-7.5,15),
           xlabel="λ",ylabel="β")
labels=["警察への年間資金                                                 ",
        "25歳以上で高校を卒業した人の割合",
        "16-19歳で高校に通っていない人の割合",
        "18-24歳で大学生の割合",
        "25歳以上で４年制大学を卒業した人の割合"]
for j in 1:p
    global p50, λ, β, labels # hide
    plot!(p50, λ,β[j,:],label=labels[j])
end
savefig(p50,joinpath(@OUTPUT,"fig5-3.svg")) # hide
# \fig{fig5-3}

# ### 例51
# CRANパッケージのglmnetはjuliaにも移植されています。
# ここでは[GLMNet.jl](https://github.com/JuliaStats/GLMNet.jl)を使って、クロスバリデーションによる
# λの最適化を検討します。
using GLMNet
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
cv  = glmnetcv(X,y)
# λは20くらいが最適のようです。その時の係数は以下のコードで求められます。
GLMNet.coef(cv)
# 後半の二つは係数が0になって、前半の三つの変数が選択されました。
# Python版の初版では係数の値が違うのですが、
# R版の原著ではこれらの値であまり問題はなさそうです。
# (これはPython版のScikitLearnのLassoCVでは0にされていないですね。
# ScikitLearnが悪いのか？)
# 横軸をlog λ, 縦軸を平均二乗誤差（リボンはσ）にして可視化します。
p51 = plot(xlabel="log λ", ylabel="mean squared error")
plot!(p51,log.(cv.lambda),cv.meanloss,ribbon=cv.stdloss,legend=false)
savefig(p51,joinpath(@OUTPUT,"fig5-8.svg")) # hide
# \fig{fig5-8}
# ### 問55
# 例48のcrime.txtで、今度はScikitLearnのLassoを利用してみることにします。
using ScikitLearn, DelimitedFiles
@sk_import linear_model: Lasso
@sk_import linear_model: LassoCV
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]; 
# まずはLassoのインスタンスを作ります。
Las = Lasso(alpha=20)
# キーワード引数のalphaは上の例でいう正則化パラメータλのことです。
# Lasにデータを入力して、$\lambda=20$の時の係数を求めます。
Las.fit(X,y);
Las.coef_
# LassoCVの場合は、複数の$\lambda$の値を与えることができます。
Lcv = LassoCV(alphas=0.1:0.1:30,cv=10)
Lcv.fit(X,y)
Lcv.alpha_
# なんと$\lambda = 30$が最適のようです。
# 係数はどうでしょうか？
Lcv.coef_
# こちらも係数が0に近づいて変数選択されているようには見えません。
# これではめでたしめでたしにはならないので、設定を見直すことにします。
# Lassoオブジェクトのインスタンスを生成する際の、キーワード引数はnormalize=falseとなっています。
# scikit-learnのドキュメントによれば、normalize=trueにすると、
# 平均値をひいたあとに、二乗ノルムで割ることになっているので標準化には使えません。
# StandardScalerを使えと書いてありますが、大した処理ではないので自前で標準化したデータを投げてみます。
using DelimitedFiles, StatsBase
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]; 
X̄,σ = mean_and_std(X,1)
XX = zscore(X,X̄,σ)
ȳ = mean(y)
yy = y .- ȳ
Lcv2 = LassoCV(alphas=0.1:0.1:30,cv=10)
Lcv2.fit(XX,yy)
@show Lcv2.alpha_;
Lcv2.coef_ 
# 正則化パラメータについては、それらしい値が得られました。
# 係数については、変数選択されていることは確認できましたが、値が大きいので$\sigma$で割って確かめることにします。
Lcv2.coef_ ./ σ'
# 混乱しましたが、[例50](#例50)と大体同じ係数になることを確認できました。