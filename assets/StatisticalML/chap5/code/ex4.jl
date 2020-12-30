# This file was generated, do not modify it. # hide
using GLMNet
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
cv  = glmnetcv(X,y)