# This file was generated, do not modify it. # hide
using DelimitedFiles, StatsBase
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1];
X̄,σ = mean_and_std(X,1)
XX = zscore(X,X̄,σ)
ȳ = mean(y)
yy = y .- ȳ
Lcv2 = LassoCV(alphas=0.1:0.1:30,cv=10)
Lcv2.fit(XX,yy)
@show Lcv2.alpha_;
Lcv2.coef_