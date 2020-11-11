# ## ex 45
# ボストン不動産データセットでの線形回帰分析でのAIC・BICの例。
# 次のような関数をchap4.jl内で定義しています。
# ```julia
# function AIC(x,y)
#     N, k = size(x)
#     @assert N == length(y)
#     return N*log(RSS(x,y)/N) + 2k
# end
# function AIC_min(x,y)
#     _,p = size(x)
#     aic_min = Array{Float64}(undef,p)
#     aic_min_com = Array{Any}(undef,p)
#     for i in 1:p
#         combi = combinations(1:p,i) |> collect
#         aic_min[i],aic_index = [AIC(x[:,c],y) for c in combi] |> findmin
#         aic_min_com[i] = combi[aic_index]
#     end
#     return aic_min, aic_min_com
# end
# ```
using Joe
using RDatasets, Plots
df = dataset("MASS","BOSTON")

X = df[Not(:MedV)] |> Array #残りの全ての説明変数を利用
X2 = df[Not([:MedV, :Zn, :Chas])] |> Array #ZnとChasを除いた場合 教科書ではこうなっている。
y = df[:MedV]

aicmin, aicindex = Joe.AIC_min(X,y)
bicmin, bicindex = Joe.BIC_min(X,y)
aicmin2, aicindex2 = Joe.AIC_min(X2,y)
bicmin2, bicindex2 = Joe.BIC_min(X2,y)

p=plot(xlabel="number of variables",ylabel="AIC or BIC values")
scatter!(p,aicmin,label="AIC")
scatter!(p,bicmin,label="BIC")

# ## 問46
# ボストン不動産データでのAIC値を最小にする組み合わせを記述したもの。
findmin(aicmin)

# ## 問47

