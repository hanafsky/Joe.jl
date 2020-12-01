# This file was generated, do not modify it. # hide
using Joe
using RDatasets, Plots
using Pipe: @pipe
df = dataset("MASS","BOSTON")

X = @pipe df |> select(_, Not(:MedV)) |> Array #残りの全ての説明変数を利用
X2 =@pipe df |> select(_, Not([:MedV, :Zn, :Chas])) |> Array #ZnとChasを除いた場合 教科書ではこうなっている。
y = df[:MedV] #目的変数

aicmin, aicindex = Joe.AIC_min(X,y)
bicmin, bicindex = Joe.BIC_min(X,y)
aicmin2, aicindex2 = Joe.AIC_min(X2,y)
bicmin2, bicindex2 = Joe.BIC_min(X2,y)

p=plot(xlabel="number of variables",ylabel="AIC or BIC values")
scatter!(p,aicmin,label="AIC")
scatter!(p,bicmin,label="BIC")
savefig(p,joinpath(@OUTPUT,"p45.svg")) # hide