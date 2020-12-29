using StatsBase
using LinearAlgebra

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
    Dict("β" => β, "β₀" => β₀) #vcatでつなげた方が良いかも
end

function ridge2(X::Matrix,y::Vector,λ=0)
    @assert λ ≥ 0
    n,p = size(X)
    X̄, σ = mean_and_std(X,1) #説明変数の平均と標準偏差を記録
    ȳ = mean(y) #目的変数については平均値を取得
    zscore!(X,X̄,σ) #標準化処理
    X = insert_ones(X)
    y .-= ȳ
    E = I(p+1); E[1]=false #単位行列の
    β = (X'X + n*λ*E)\ X'*y
    β ./= vcat(1.0,vec(σ)) #X'Xで割っているので、βをσで割っておく
end