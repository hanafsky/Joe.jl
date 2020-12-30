# ## 多項式回帰
# ### 例52
# sin関数に乱数を足した観測データを多項式で回帰します。
# データの生成
using Plots, Joe, Random
using Plots.PlotMeasures # hide
Plots.reset_defaults() # hide
gr() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ), # hide
    left_margin = 10px, # hide
    bottom_margin = 10px # hide
) # hide
Random.seed!(12)
n = 100; x = randn(n); y = sin.(x) + randn(n);
p52 = scatter(x,y,xlabel="x", ylabel="y", label=false, legend=:topleft);
# 3、5、7次の多項式で回帰します。
# 多項式回帰用にデータセットを作る関数を定義したので、これを使ってみます。
# ```julia
# polynomial(x::Vector, P::Int) = hcat([x.^p for p in 1:P]...)
# polynomial(x::AbstractRange, P::Int)= polynomial(collect(x),P)
# ```
using Joe:polynomial
p_set = [3,5,7]
x_seq = -3:0.1:3 
for p in p_set
    global x, y, x_seq, p52 # hide
    X = polynomial(x,p)
    β̂ = multiple_regression(X,y)
    ŷ = insert_ones(polynomial(x_seq,p))*β̂
    plot!(p52, x_seq,ŷ,label="p = $p")
end
savefig(p52,joinpath(@OUTPUT,"fig6-1.svg")) # hide
# \fig{fig6-1}
