# This file was generated, do not modify it. # hide
using Plots, Random, Joe
N = 100; Random.seed!(123)
x28 = randn(N,1)
y28 = x28 .+1 + randn(N)  |> vec # 真の切片と傾きはともに1
p28 = scatter(x28,y28,xlabel="x",ylabel="y",label="data     ",legend=:topleft)

β28 = MultipleRegression(x28,y28)
x_seq = -10:0.1:10
ŷ = expand_matrix(x_seq) * β28
yerror1 = Joe.confident_interval(x_seq,x28,y28)
yerror2 = Joe.prediction_interval(x_seq,x28,y28)
plot!(p28,x_seq,ŷ,ribbon=yerror2, label="予測区間")
plot!(p28,x_seq,ŷ,ribbon=yerror1, label="信頼区間")

savefig(p28,joinpath(@OUTPUT,"fig1-7.svg")) # hide