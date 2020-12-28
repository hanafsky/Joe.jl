# This file was generated, do not modify it. # hide
Random.seed!(1)
order = sample(1:n,n,replace=false)
X = X[order,:]; y = y[order];