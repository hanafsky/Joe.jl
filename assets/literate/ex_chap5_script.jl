# This file was generated, do not modify it.

using DelimitedFiles, Plots
using Joe:ridge
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

using Plots
x_seq = -2:0.05:2;
p49_1 = plot(x_seq, x -> x^2-3x+abs(x),title = "y=x^2-3x+|x|")
scatter!(p49_1,[1],[-1],color=:red,legend=false)
p49_2 = plot(x_seq,x -> x^2 + x +2abs(x),title="y=x^2+x+2|x|")
scatter!(p49_2,[0],[-0],color=:red, legend=false)
p49 = plot(p49_1,p49_2,layout=(1,2),size= (500,200))
savefig(p49,joinpath(@OUTPUT,"fig5-2.svg")) # hide

using Joe:lasso
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
λ = 0:0.5:200
_,p = size(X)
β = hcat([lasso(X,y,l)["β"] for l in λ]...)
p50 = plot(size=(500,500),xlims=(0,200),ylims=(-7.5,15),
           xlabel="λ",ylabel="β")
labels=["警察への年間資金                                                 ",
        "25歳以上で高校を卒業した人の割合",
        "16-19歳で高校に通っていない人の割合",
        "18-24歳で大学生の割合",
        "25歳以上で４年制大学を卒業した人の割合"]
for j in 1:p
    global p50, λ, β, labels # hide
    plot!(p50, λ,β[j,:],label=labels[j])
end
savefig(p50,joinpath(@OUTPUT,"fig5-3.svg")) # hide

using GLMNet
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1]
cv  = glmnetcv(X,y)

coef(cv)

p51 = plot(xlabel="log λ", ylabel="mean squared error")
plot!(p51,log.(cv.lambda),cv.meanloss,ribbon=cv.stdloss,legend=false)
savefig(p51,joinpath(@OUTPUT,"fig5-8.svg")) # hide

using ScikitLearn, DelimitedFiles

@sk_import linear_model: Lasso
@sk_import linear_model: LassoCV
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1];

Las = Lasso(alpha=20)

Las.fit(X,y);
Las.coef_

Lcv = LassoCV(alphas=0.1:0.1:30,cv=10)
Lcv.fit(X,y)
Lcv.alpha_

Lcv.coef_

using StatsBase, DelimitedFiles, ScikitLearn
@sk_import linear_model: LassoCV
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:7]; y =df[:,1];
X̄,σ = mean_and_std(X,1)
XX = zscore(X,X̄,σ)
ȳ = mean(y)
yy = y .- ȳ
Lcv2 = LassoCV(alphas=0.1:0.1:30,cv=10)
Lcv2.fit(XX,yy)
@show Lcv2.alpha_;
Lcv2.coef_

Lcv2.coef_ ./ σ'

