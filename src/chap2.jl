using Parameters
using LinearAlgebra, StatsBase

sigmoid(x::Matrix, β::Vector) = @. 1 / (1 + exp(-$*(x,β)))

"""
    QDA(μ = μ, Σ = Σ)
Quadratic discrimination analysis

"""
@with_kw struct QDA
    μ::Array # 平均
    Σ::Matrix # 分散共分散行列
    invΣ::Matrix = inv(Σ) # 分散共分散行列の逆行列
    detΣ = det(Σ) # 分散共分散行列の行列式
end

"""
    function-like object of QDA

returns log likelihood of multivariate normal distribution

Example
```julia

```
"""
function (qda::QDA)(x...;prior=1.0)
    data = collect(x)
    @unpack μ,invΣ,detΣ = qda
    a = -0.5*(data-μ)' * invΣ * (data-μ) 
    a[1] - log(detΣ) + log(prior)
end

function table_count(test,pred)
    @assert length(test) == length(pred)
    m = unique(test) |> length
    count = zeros(Int,m,m)
    for i in 1:length(test)
        count[test[i],pred[i]] += 1
    end
    return count
end

function knn(X_train::Matrix,y_train::Vector,X_test::Vector, k)
    n = size(X_train)[1]
    distance = [norm(X_train[i,:]-X_test) for i in 1:n]
    S = sortperm(distance)[1:k]
    u = counts(y_train[S], 1:k)
    u_max = maximum(u)
    m = findall(c->c==u_max,u)
    while length(m)!==1
        k -=1
        S = S[1:k]
        u = counts(S, 1:k)
        u_max = maximum(u)
        m = findall(c->c==u_max,u)
    end
    return m[1]
end

function knn(X_train::Matrix,y_train::Vector,X_test::Matrix, k)
    l = size(X_test)[1]
    w = Array{Int}(undef,l)
    for i in 1:l
        w[i] = knn(X_train,y_train,X_test[i,:], k)
    end
    return w
end
