# This file was generated, do not modify it. # hide
using Plots; gr()
using Plots.PlotMeasures
Plots.reset_defaults()
default(
    titlefont  = font("JuliaMono", default(:titlefontsize),  ),
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ),
    tickfont   = font("JuliaMono", default(:tickfontsize),   ),
    legendfont = font("JuliaMono",  default(:legendfontsize), ),
    left_margin = 10px,
    bottom_margin = 10px,
)
p12 = scatter(x,y,label="original",legend=:topleft,xlabel="x", ylabel="y")
plot!(c->a1*c+b1 ,label="before centering")
plot!(c->a2*c+b2 , label="after centering")
savefig(p12,joinpath(@OUTPUT,"fig1-2.svg")) # hide