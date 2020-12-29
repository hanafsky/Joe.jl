<!--This file was generated, do not modify it.-->
## Ridge
Ridge回帰の関数は少し煩雑ですが、標準化処理(データの平均値をひいて、標準偏差で割る)
を行った後に、回帰分析を行っています。 全てが1の値を持つ列を説明変数に入れてしまうと
標準偏差(=0)で割るとエラーを吐くので、こういうことをしているのだと思います。
そう思って読むと原著のコードよりは分かりやすいでしょう。
```julia
using StatsBase
function ridge(X::Matrix,y::Vector,λ=0)
    @assert λ ≥ 0
    n,p = size(X)
    X̄, σ = mean_and_std(X,1) #説明変数の平均と標準偏差を記録
    ȳ = mean(y) #目的変数については平均値を取得
    zscore!(X,X̄,σ) #標準化処理
    y .-= ȳ
    β = (X'X + n*λ*I(p)) \ X'*y
    β ./= vec(σ) #X'Xで割っているので、βをσで割っておく
    β₀ = ȳ .- X̄*β
    Dict("β" => β, "β₀" => β₀)
end
```
### 例48
米国犯罪データをRidge回帰します。

```julia:ex1
using DelimitedFiles, Plots
using Joe:ridge
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ) # hide
) # hide
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
λ = 0:0.5:50
_,p = size(X)
β = hcat([ridge(X,y,l)["β"] for l in λ]...)
p48 = plot(size=(500,500),xlims=(0,50),ylims=(-7.5,15),xlabel="λ",ylabel="β")
labels=[" 警察への年間資金                                                 ",
        "25歳以上で高校を卒業した人の割合",
        "16-19歳で高校に通っていない人の割合",
        " 18-24歳で大学生の割合",
        "25歳以上で４年制大学を卒業した人の割合"]
for j in 1:p
    global p48, λ, β, labels # hide
    plot!(p48, λ,β[j,:],label=labels[j])
end
savefig(p48,joinpath(@OUTPUT,"fig5-1.svg"))
```

\fig{fig5-1}

