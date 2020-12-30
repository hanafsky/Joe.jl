using StatsBase
using LinearAlgebra

function ridge(x::Matrix,y::Vector,λ=0)
    @assert λ ≥ 0
    X = copy(x)
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

soft_th(λ::Number,x::Number) = sign(x) * max(abs(x)-λ,0)

function lasso(x::Matrix,y::Vector,λ=0)
    @assert λ ≥ 0
    X = copy(x)
    n,p = size(X)
    X̄, σ = mean_and_std(X,1) #説明変数の平均と標準偏差を記録
    ȳ = mean(y) #目的変数については平均値を取得
    zscore!(X,X̄,σ) #標準化処理
    y .-= ȳ

    #ここまでridgeと同じ
    ϵ = 1.0
    β = zeros(p); β_old = zeros(p)
    while ϵ > 0.001
        for j in 1:p
            index = setdiff(1:p,j)
            r = y - X[:,index]*β[index]
            β[j] = soft_th(λ,r'*X[:,j]/n)
        end
        ϵ = abs.(β-β_old) |> maximum
        β_old = β
    end
    β ./= vec(σ) #X'Xで割っているので、βをσで割っておく
    β₀ = ȳ .- X̄*β
    Dict("β" => β, "β₀" => β₀) #vcatでつなげた方が良いかも
end