# ## クロスバリデーション
# ### 例39
using Joe, Random, Plots
using Joe: cv_linear
n = 100; p = 5
Random.seed!(1)
X = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y = expand_matrix(X)*β + randn(n)
@show cv_linear(X[:,[3,4,5]],y,10);
@show cv_linear(X,y,10);
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ) # hide
) # hide
# あれ？変数選択した方が誤差でかいぞ？回数を増やしてグラフにしてみよ。
using Joe # hide
U=Float64[]; V = Float64[] 
for _ in 1:100
    global U, V, X, β, n
    local y 
    y = expand_matrix(X)*β + randn(n)
    push!(U,cv_linear(X[:,[3,4,5]],y,10))
    push!(V,cv_linear(X,y,10))
end

p39 = scatter(U,V,xlabel="with variable 3,4,5",ylabel="all variable",title="overlearning")
plot!(p39, x->x,xlims=(0.7,1.5),legend=false)
savefig(p39,joinpath(@OUTPUT,"fig3-1.svg")) # hide
# \fig{fig3-1}
# \lineskip
# $y=x$ の直線の上側に大多数の点がプロットされているので、
# 変数選択をした方が誤差が少ないことが分かりました。