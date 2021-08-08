# This file was generated, do not modify it.

#hideall
using Plots, Joe, Random
using Plots.PlotMeasures
Plots.reset_defaults()
gr()
default(
    titlefont  = font("JuliaMono", default(:titlefontsize),  ),
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ),
    tickfont   = font("JuliaMono", default(:tickfontsize),   ),
    legendfont = font("JuliaMono",  default(:legendfontsize), ),
    left_margin = 30px,
    right_margin = 30px,
    bottom_margin = 30px
)

using Joe,RDatasets
boston=dataset("MASS","boston") |> Matrix
X = boston[:,1:end-1];y=boston[:,end];
node = Joe.decisiontree(X,y;n_min=50);

using Joe,RDatasets
boston=dataset("MASS","boston") |> Matrix
X = boston[:,1:end-1];y=boston[:,end];
α_seq = 0:0.1:1.5
n = 100
X65 = X[begin:n,:]; y65 = y[begin:n];
s = Int(n/10)
out = zeros(length(α_seq))
for (i,α) in enumerate(α_seq)
    global n, X65, y65, out # hide
    local node # hide
    SS = 0
    for h in 0:9
        test = h*s+1:(h+1)*s
        train = setdiff(1:n,test)
        node = Joe.decisiontree(X65[train,:],y65[train];α=α)
        for t in test
            SS += (y[t] - Joe.dtvalue(X65[t,:],node))^2
        end
    end
    out[i] = SS/n
end
p65_1 = plot(α_seq,out,xlabel="α",ylabel="二乗誤差",
            title="CVで最適なα(N=100)",label=false);

n_min_seq = 1:15
out2 = zeros(length(n_min_seq))
for (i,n_min) in enumerate(n_min_seq)
    global n, X65, y65, out2 # hide
    local node # hide
    SS = 0
    for h in 0:9
        test = h*s+1:(h+1)*s
        train = setdiff(1:n,test)
        node = Joe.decisiontree(X65[train,:],y65[train];n_min=n_min)
        for t in test
            SS += (y[t] - Joe.dtvalue(X65[t,:],node))^2
        end
    end
    out2[i] = SS/n
end
p65_2 = plot(n_min_seq,out2,xlabel="n_min",ylabel="二乗誤差",
            title="CVで最適なn_min(N=100)",label=false);

p65 = plot(p65_1,p65_2,layout=(1,2))
savefig(p65,joinpath(@OUTPUT,"fig7-5.svg")) # hide

using RDatasets, Joe
iris = dataset("datasets","iris")
x = iris[!,1:4] |> Matrix
targets=unique(iris.Species)

label = Dict(target=>i for (i,target) in enumerate(targets))
y = [label[i] for i in iris.Species];

