using LinearAlgebra

function cv_linear(X,y::Vector,K::Int)
    n = length(y); m = round(Int,n/K)
    S = 0
    for j in 1:K
        test = j*m-m+1:j*m
        train = setdiff(1:n,test)
        β̂ = multiple_regression(X[train,:],y[train])
        ŷ = insert_ones(X[test,:])*β̂
        S += (y[test]-ŷ)'*(y[test]-ŷ)
    end
    return S/n
end
