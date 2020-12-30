# 第一章
"""
線形回帰分析の係数と切片
```julia
using Random,Distributions
Random.seed!(123)
#データの生成
N=100
a=rand(Normal(2,1),N)
b=randn(1)
x = randn(N)
y = a.*x .+ b + randn(N)
a1, b1 = min_sq(x,y)
```
"""
function min_sq(x::Vector{T},y::Vector{T}) where {T<:Number}
    x̄ = mean(x)
    ȳ = mean(y)
    β₁ = (x .- x̄)'*(y .- ȳ) / norm(x .- x̄)^2 #傾き
    β₀ = ȳ - β₁ * x̄ #切片
    return  β₁,β₀
end

function expand_matrix(X)
    N = typeof(X) <: Matrix  ?  size(X)[1] :  length(X)
    T = eltype(X)
    return hcat(ones(T,N),X)
end
function insert_ones(X)
    N = typeof(X) <: Matrix  ?  size(X)[1] :  length(X)
    T = eltype(X)
    return hcat(ones(T,N),X)
end

"""
重回帰分析の係数
```julia
n = 100; p =2
β = Float64[1,2,3]
x = randn(n,2)
y = @. β[1] + β[2] * x[:,1] + β[3]*x[:,2] + $randn(n)
MultipleRegression(x,y)

3-element Array{Float64,1}:
 0.8957078029816884
 1.904721221695989
 3.1212560196461494
```
"""
function multiple_regression(x::Matrix{T}, y::Vector{T}) where {T<:Number}
    N,_ = size(x)
    @assert N==length(y)
    X = insert_ones(x)
    return (X'X)\X'y
end
function multiple_regression(x::Vector{T}, y::Vector{T}) where {T<:Number}
    return multiple_regression(x[:,:],y)
end

"""
線形回帰分析でのRSS値
"""
function RSS(x::Vector,y)
    β̂ = min_sq(x,y)
    ŷ = β̂[1]*x .+ β̂[2]
    return (y-ŷ)'*(y-ŷ)
end
function RSS(x::Matrix,y)
    ŷ = insert_ones(x)*multiple_regression(x,y)
    return (y-ŷ)'*(y-ŷ)
end

function TSS(y)
    Y = y .- mean(y)
    return Y'*Y 
end

ESS(x,y) = TSS(y) - RSS(x,y)

R2(x,y) = ESS(x,y)/TSS(y)

function RSE(x::Matrix,y)
    n,p = size(x)
    RSS(x,y) / (n-p-1) 
end

function RSE(x::Vector,y)
    RSS(x,y) / (length(x)-2) 
end

function Bdiag(x)
    X = insert_ones(x)
    return X'X |> inv |> diag
end

"""
VIF(variance inflation factor)
"""
function VIF(x::Matrix)
    _,ncol= size(x)
    v = Vector{Float64}(undef,ncol)
    for j in 1:ncol
        # index = delete!(Set(1:ncol),j) |> collect
        index = setdiff(1:ncol,j)
        v[j] = 1/(1-R2(x[:,index],x[:,j]))
    end
    return v
end

"""
confident_interval(xp,x,y;α=0.01)

線形回帰における信頼区間(予測したい場所での標準偏差)を返す。
xp:説明変数の予測データ
x:説明変数の学習データ
y:目的変数の学習データ
α:0.01 は99%信頼区間
"""
function confident_interval(xp,x,y;α=0.01)
    N,p = size(x)
    X = insert_ones(x)
    XP = insert_ones(xp)
    typeof(xp) <:Number && (xp =[xp])
    yerror = quantile(TDist(N-p-1),1-α/2) * sqrt.(diag(XP * ((X'X) \ XP')))
end

function prediction_interval(xp,x,y;α=0.01)
    N,p = size(x)
    X = insert_ones(x)
    XP = insert_ones(xp)
    typeof(xp) <:Number && (xp =[xp])
    yerror = quantile(TDist(N-p-1),1-α/2) * sqrt.( 1 .+ diag(XP * ((X'X) \ XP')))
end
