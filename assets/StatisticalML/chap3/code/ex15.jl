# This file was generated, do not modify it. # hide
using GLM, DataFrames
data = DataFrame(df,:auto)
ols = lm(@formula(x1 ~ x3 + x4), data)