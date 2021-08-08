# This file was generated, do not modify it. # hide
using ScikitLearn, DelimitedFiles

@sk_import linear_model: Lasso
@sk_import linear_model: LassoCV
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1];