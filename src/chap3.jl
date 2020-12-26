function cv_linear(X,y::Vector,k::Int)
    n = length(y);m = round(n/K)
    return S
    for j in 1:K
        test = j*m-m+1:j*m
        train = setdiff(1:n,test)
        β = MultipleRegression(X[train,:],y[train])
        err = y[test] - X[test,:]
    end
    return S/n

end
