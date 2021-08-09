# This file was generated, do not modify it. # hide
using Joe, Random, Plots
using Plots.PlotMeasures # hide
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ), # hide
    left_margin = 30px, # hide
    bottom_margin = 30px # hide
) # hide
using Joe: cv_linear
n = 100; p = 5
Random.seed!(1)
X_39 = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y_39 = insert_ones(X_39)*β + randn(n)
@show cv_linear(X_39[:,[3,4,5]],y_39,10);
@show cv_linear(X_39,y_39,10);