# # 第4章
# 情報量基準の問題。殆ど証明でコーディングの問題は少ないです。
# 説明変数の組み合わせを求めるにあたって、Combinatrics.jlパッケージ（pythonでいうitertools）がとても役立ちます。
# また、最小値とそのインデックスを返すfindmin関数も有用です。
# ## 例題45
# ボストン不動産データセットを用いた線形回帰分析でのAIC・BICの例。
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
y = df[:MedV] #目的変数

aicmin, aicindex = Joe.AIC_min(X,y)
bicmin, bicindex = Joe.BIC_min(X,y)
aicmin2, aicindex2 = Joe.AIC_min(X2,y)
bicmin2, bicindex2 = Joe.BIC_min(X2,y)

p=plot(xlabel="number of variables",ylabel="AIC or BIC values")
scatter!(p,aicmin,label="AIC")
scatter!(p,bicmin,label="BIC")
savefig(p,joinpath(@OUTPUT,"p45.svg"))
# \fig{p45}
# ## 問46
# ボストン不動産データでのAIC値を最小にする組み合わせを記述したもの。
min_aic_boston,aicmin_index  = findmin(aicmin2)
println("Minimum AIC value:", min_aic_boston, ", set: ", aicindex2[aicmin_index])
# ## 問47
# BIC関数とAR2関数を定義して利用します。変数の数毎の最小値を計算する関数は
# AIC_minと同じ方法で定義しています。ただしAR2の場合は最大化しなければならないので注意が必要です。
# ```julia
# function BIC(x,y)
#     N,k = size(x)
#     @assert N == length(y)
#     return N*log(RSS(x,y)/N) + k*log(N)    
# end
# 
# function AR2(x,y)
#     N,k = size(x)
#     @assert N == length(y)
#     return 1 - RSS(x,y)/(N-k-1)/TSS(y)*(N-1)    
# end
# ```
# どの基準で計算しても、今回の場合同じ変数の組み合わせが最適という結論になります。

#BIC
min_bic_boston,bicmin_index  = findmin(bicmin2)
println("Minimum BIC value: ", min_bic_boston, ", set: ", bicindex2[aicmin_index])
#AR2
ar2max2, ar2index2 = Joe.AR2_max(X2,y)
max_ar2_boston,ar2max_index  = findmax(ar2max2)
println("Maximum AR2 value: ", max_ar2_boston, ", set: ", ar2index2[aicmin_index])
# ## 問48
# 例題45でやったので、割愛します。