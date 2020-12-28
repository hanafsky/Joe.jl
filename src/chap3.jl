using LinearAlgebra
using Parameters, StatsBase

function cv_linear(X::AbstractArray,y::Vector,K::Int)
    n = length(y); m = round(Int,n/K)
    S = 0
    for j in 1:K
        test = j*m-m+1:j*m
        train = setdiff(1:n,test)
        β̂ = multiple_regression(X[train,:],y[train])
        ŷ = insert_ones(X[test,:])*β̂
        S += dot(y[test]-ŷ,y[test]-ŷ)
    end
    return S/n
end

function cv_fast(X::AbstractArray,y::Vector,K::Int)
    n = length(y); m = round(Int,n/K)
    X = insert_ones(X)
    H = X*((X'X)\X')
    e = (I(n) - H)*y
    S = 0
    @views for j in 1:K
        test = j*m-m+1:j*m;
        err = (I(m)-H[test,test]) \ e[test]
        S += dot(err,err)
    end
    return S/n
end

@with_kw mutable struct bt{T<:Number}
    original::T = 0.0
    bias::T = 0.0
    stderr::T = 0.0
end

function bootstrap(df::AbstractArray{T}, F::Function, r::Int) where T <:Number
    m,_ = size(df)
    original = F(df,1:m)
    u = Vector{T}(undef, r)
    for i in 1:r
        index = sample(1:m,m,replace=true)
        u[i] = F(df,index)
    end
    bias = mean(u) - original; stderr = std(u)
    result = bt()
    @pack! result = original, bias, stderr 
    return result
end