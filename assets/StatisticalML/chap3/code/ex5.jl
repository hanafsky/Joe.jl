# This file was generated, do not modify it. # hide
Random.seed!(1)
order = StatsBase.sample(1:n,n,replace=false);
X_41 = X_41[order,:];
y_41 = y_41[order];