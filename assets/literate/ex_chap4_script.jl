# This file was generated, do not modify it.

using Joe
using ScikitLearn, Plots
using Plots.PlotMeasures # hide
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ),  # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ), # hide
    left_margin = 30px, # hide
    bottom_margin = 30px # hide
) # hide
@sk_import datasets: load_boston
df = load_boston()
X = df["data"]
X2 =X[:,vcat([1,3,5:end]...)]
y = df["target"] #目的変数

aicmin, aicindex = Joe.AIC_min(X,y)
bicmin, bicindex = Joe.BIC_min(X,y)
aicmin2, aicindex2 = Joe.AIC_min(X2,y)
bicmin2, bicindex2 = Joe.BIC_min(X2,y)

p=plot(xlabel="number of variables",ylabel="AIC or BIC values")
scatter!(p,aicmin,label="AIC")
scatter!(p,bicmin,label="BIC")
savefig(p,joinpath(@OUTPUT,"p45.svg")) # hide

min_aic_boston,aicmin_index  = findmin(aicmin2)
println("Minimum AIC value:", min_aic_boston, ", set: ", aicindex2[aicmin_index])

#BIC
min_bic_boston,bicmin_index  = findmin(bicmin2)
println("Minimum BIC value: ", min_bic_boston, ", set: ", bicindex2[aicmin_index])
#AR2
ar2max2, ar2index2 = Joe.AR2_max(X2,y)
max_ar2_boston,ar2max_index  = findmax(ar2max2)
println("Maximum AR2 value: ", max_ar2_boston, ", set: ", ar2index2[aicmin_index])

