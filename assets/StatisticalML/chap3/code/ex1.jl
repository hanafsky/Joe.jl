# This file was generated, do not modify it. # hide
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