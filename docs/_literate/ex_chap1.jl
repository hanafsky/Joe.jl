# # 線形回帰
# ## 例 19
# 肩慣らしの単回帰分析。回帰係数と切片を返す関数を定義します。 
# ユニコードがtab補完で入力ので数式と関数との対応が非常に見やすくできるのがjuliaの特長の一つです。
# 
# \note{meanやnorm関数などを使うため、Distributions.jlとLinearAlgebra.jlをインポートしておきます。}
#　
# ---
# ```julia
# function min_sq(x::Vector{T},y::Vector{T}) where {T<:Number}
#     x̄ = mean(x)
#     ȳ = mean(y)
#     β₁ = (x .- x̄)'*(y .- ȳ) / norm(x .- x̄)^2 #傾き
#     β₀ = ȳ - β₁ * x̄ #切片
#     return  β₁,β₀
# end
# ```
# まずはトイデータの生成から。
using Joe, Random, Distributions, LinearAlgebra
Random.seed!(123) #乱数の種を固定
N = 100
a = rand(Normal(2,1),N) #傾き、平均2分散1の正規分布からサンプリング
b = randn() #切片
x = randn(N) 
y = a .* x .+ b  + randn(N);

# 普通に単回帰する場合。
a1, b1 = min_sq(x,y)

# データを中心化したあとに回帰分析すると切片が０になる（あたりまえ）。
xx = x .- mean(x); yy = y .- mean(y)
a2,b2 = min_sq(xx,yy)

using Plots, JSON
plotlyjs()

r = 2.0
N = 20

φ = range(0.0, 2π, length = N)
p = plot()
for θ in range(0, 2π, length = N)
    x = @. r * sin(θ) * cos(φ)
    y = @. r * sin(θ) * sin(φ)
    z = repeat([r * cos(θ)], N)
    scatter!(p, x, y, z, label = false, color = :blue)
end

fdplotly(JSON.json((
    layout = Plots.plotly_layout(p),
    data = Plots.plotly_series(p),
)); style = "width:400px;height:300x",
)