# This file was generated, do not modify it. # hide
using DelimitedFiles, Plots
using Joe:ridge
Plots.reset_defaults() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ) # hide
) # hide
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
λ = 0:0.5:50

_,p = size(X)
β = hcat([ridge(X,y,l)["β"] for l in λ]...)
p48 = plot(size=(500,500),xlims=(0,50),ylims=(-7.5,15),
           xlabel="λ",ylabel="β")
labels=["警察への年間資金                                                 ",
        "25歳以上で高校を卒業した人の割合",
        "16-19歳で高校に通っていない人の割合",
        "18-24歳で大学生の割合",
        "25歳以上で４年制大学を卒業した人の割合"]
for j in 1:p
    global p48, λ, β, labels # hide
    plot!(p48, λ,β[j,:],label=labels[j])
end
savefig(p48,joinpath(@OUTPUT,"fig5-1.svg")) # hide