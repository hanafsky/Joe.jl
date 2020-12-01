# This file was generated, do not modify it. # hide
using GLM, DataFrames
data = DataFrame(X=x24,Y=y24)
ols = lm(@formula(Y ~ X), data)