using Parameters
polynomial(x::Vector, P::Int) = hcat([x.^p for p in 1:P]...)
polynomial(x::AbstractRange, P::Int)= polynomial(collect(x),P)
polynomial(x::Vector, P::Int, f::Function) = hcat([f.(p*x) for p in 1:P]...)
polynomial(x::AbstractRange, P::Int, f::Function) = polynomial(collect(x), P, f)

function polyfit(x,y;x_pred=x, P::Int=3)
    X = polynomial(x,P)
    X_pred=polynomial(x_pred,P)
    β̂ = multiple_regression(X,y)
    y_pred = insert_ones(X_pred) * β̂
end

@with_kw mutable struct Spline{T<:Number}
    xmin::T = -1.0
    xmax::T = 1.0
    K::Int = 5
end 


function (s::Spline)(x::Vector, y::Vector, x_pred::Vector; 
          splinematrix::Function=spline_matrix)
    @unpack xmin, xmax, K = s
    X = splinematrix(x,K,xmin,xmax)
    β = (X'X)\X'y
    X_pred = splinematrix(x_pred,K,xmin,xmax)
    ypred = X_pred*β
end

(s::Spline)(x::Vector, y::Vector, x_pred::AbstractRange;kwargs...) = s(x,y,collect(x_pred);kwargs...)

function spline_matrix(x::Vector,K::Int,xmin,xmax;use_x=false)
    n = length(x)
    Knots = use_x ? x : range(xmin,stop=xmax,length=K)
    K = length(Knots)
    X = zeros(n,K+4)
    X[:,1] .= 1
    X[:,2] .= x
    X[:,3] .= x.^2
    X[:,4] .= x.^3
    for j in 1:K 
        X[:,j+4] = @. max(x - Knots[j], 0)^3
    end
    return X
end


function natural_spline_matrix(x::Vector,K::Int,xmin,xmax)
    n = length(x)
    Knots  = range(xmin,stop=xmax,length=K)
    X = zeros(n,K)
    X[:,1] .= 1
    X[:,2] .= x
    d(x::Vector,a::Number,b::Number) =  @. (max(x-a,0)^3 - max(x-b,0)^3) / (b-a)
    for j in 1:K-2
        X[:,j+2] = d(x,Knots[j],Knots[end]) - d(x,Knots[end-1],Knots[end])
    end
    return X
end

struct SmoothingSpline
    x::Vector
end

function (s::SmoothingSpline)(y::Vector,x_pred::Union{Vector,AbstractRange};λ=0)
    x = s.x
    X = smoothing_spline_matrix(x,x)
    G = green_silverman(x)
    γ = (X'X + λ*G)\X'y
    X_pred = smoothing_spline_matrix(x_pred,x)
    ypred = X_pred*γ
end

function smoothing_spline_matrix(x::Union{Vector,AbstractRange},Knots::Union{Vector, AbstractRange})
    n = length(x)
    K = length(Knots)
    X = zeros(n,K)
    X[:,1] .= 1
    X[:,2] .= x
    d(x::Union{Vector,AbstractRange},a::Number,b::Number) =  @. (max(x-a,0)^3 - max(x-b,0)^3) / (b-a)
    for j in 1:K-2
        X[:,j+2] = d(x,Knots[j],Knots[end]) - d(x,Knots[end-1],Knots[end])
    end
    return X
end

function green_silverman(x::Vector)
    n = length(x)
    g = zeros(n,n)
    for i in 3:n ,j in i:n
        g[j,i] =(12(x[end]-x[end-1])*(x[end-1]-x[j-2])*(x[end-1]-x[i-2])+
                (x[end-1]-x[j-2])^2*(12x[end-1]+6x[j-2]-18x[i-2]))/
                (x[end]-x[i-2])/(x[end]-x[j-2])
        g[i,j] = g[j,i]
    end
    return g
end

function cv_ss_fast(X::AbstractArray,y::Vector,G::AbstractArray,K::Int;λ=0)
    n = length(y); m = round(Int,n/K)
    H = X*((X'X + λ*G)\X')
    e = (I(n) - H)*y
    S = 0
    @views for j in 1:K
        test = j*m-m+1:j*m;
        err = (I(m)-H[test,test]) \ e[test]
        S += dot(err,err)
    end
    return S/n,tr(H)
end

#epanechnikovカーネル
epanechnikov(x,y,λ) = norm(x-y)/λ |> c -> max(0.75*(1-c^2),0)
#nadaraya-watson推定量
function nadaraya_watson_estimator(x_observed::Vector,y_observed::Vector,kk::Function,x_pred::TP;λ=1.0) where {TP<:Number}
    n = length(y_observed)
    S = 0; T = 0;
    for i in 1:n
        S += kk(x_observed[i],x_pred,λ)*y_observed[i]
        T += kk(x_observed[i],x_pred,λ)
    end
    result = T == 0 ? 0 : S/T
    return result
end

function nadaraya_watson_estimator(x_observed::Vector,y_observed::Vector,kk::Function,x_pred::Union{Vector,AbstractRange};λ=1.0) 
    y_pred = [nadaraya_watson_estimator(x_observed,y_observed,kk,xp; λ) for xp in x_pred]
end


function local_regression(x::Matrix{T}, 
                          y::Vector{T},
                          kernel::Function;
                          x_pred=x, λ=1) where {T<:Number}
    N,_ = size(x)
    @assert N==length(y)
    X = insert_ones(x)
    m,_ = size(x_pred) 
    y_pred = Vector{T}(undef,m)
    for j in 1:m
        W = [kernel(x[i,:],x_pred[j,:],λ) for i in 1:N] |> diagm
        β̂ = (X'*W*X)\X'*W*y
        y_pred[j] = dot(insert_ones(x_pred[j,:]),β̂)
    end
    return y_pred
end
function local_regression(x::Vector{T}, y::Vector{T},kernel::Function;x_pred=x,λ=1) where {T<:Number}
    return local_regression(x[:,:],y,kernel;x_pred=x_pred[:,:],λ=λ)
end