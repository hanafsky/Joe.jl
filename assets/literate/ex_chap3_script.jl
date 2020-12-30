# This file was generated, do not modify it.

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
X = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y = insert_ones(X)*β + randn(n)
@show cv_linear(X[:,[3,4,5]],y,10);
@show cv_linear(X,y,10);

using Joe # hide
U=Float64[]; V = Float64[]
for _ in 1:100
    global U, V, X, β, n # hide
    local y # hide
    y = insert_ones(X)*β + randn(n)
    push!(U,cv_linear(X[:,[3,4,5]],y,10))
    push!(V,cv_linear(X,y,10))
end

p39 = scatter(U,V,xlabel="変数4,5,6を選んだ時の二乗誤差",
                ylabel="全変数を選んだ時の二乗誤差",
                title="変数を多く選びすぎて過学習")
plot!(p39, x->x,xlims=(0.7,1.5),legend=false)
savefig(p39,joinpath(@OUTPUT,"fig3-1.svg")) # hide

n = 100; p = 5;
p40 = plot(ylims=(0.3,1.5),xlabel="k",ylabel="CVの値",
            title="k-foldのkとCVの値の関係",legend=false)
Random.seed!(1)
for _ in 1:10
    global p40 # hide
    local X, β, y, U, V # hide
    X = randn(n,p)
    β = randn(p+1)
    y = insert_ones(X) * β + randn(n)
    U = Int[]
    V = Float64[]
    for k in 2:n
        if n%k==0
            push!(U,k)
            push!(V, cv_linear(X,y,k))
        end
    end
    plot!(p40,U,V)
end
savefig(p40,joinpath(@OUTPUT,"fig3-2.svg")) # hide

using RDatasets, StatsBase, Random, Plots
using Joe:knn
iris = dataset("datasets","iris")
X = iris[!,1:4] |> Matrix
targets=unique(iris.Species);

label = Dict(target=>i for (i,target) in enumerate(targets))
y = [label[i] for i in iris.Species];
n = length(y);

Random.seed!(1)
order = sample(1:n,n,replace=false)
X = X[order,:]; y = y[order];

errorRate = Vector{Float64}(undef,10)
for k in 1:10
    global errorRate, X, y # hide
    S = 0
    for top in 1:15:150
        test = top:top+14
        train = setdiff(1:150,test)
        knn_ans = knn(X[train,:],y[train],X[test,:],k)
        S += sum(y[test] .!= knn_ans)
    end
    S /= n
    errorRate[k] = S
end
p41 = plot(errorRate,xlabel="K",ylabel="誤り率",
            legend=false, title="CVによる誤り率の評価")
savefig(p41,joinpath(@OUTPUT,"fig3-3.svg")) # hide

using Joe, Random, Plots
using Joe:cv_linear,cv_fast

n = 1000; p = 5
Random.seed!(1)
X = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y = insert_ones(X)*β + randn(n);

K = [i for i in 2:1000 if 1000%i ==0]
t_linear = Vector{Float64}(undef,length(K));
t_fast = similar(t_linear);

@show cv_linear(X,y,10)
@show cv_fast(X,y,10)

for i in eachindex(K)
    global X, y, t_fast, t_linear,K # hide
    start = time_ns();cv_fast(X,y,K[i]);stop = time_ns()
    t_fast[i] = (stop-start)/1e9
    start = time_ns();cv_linear(X,y,K[i]);stop = time_ns()
    t_linear[i] = (stop-start)/1e9
end
p42 = plot(ylims=(0.0,0.5), xlabel = "k" ,ylabel="実行時間",
           label="cv_linear",title="cv_fastとcv_linearの比較",
           legend=:topleft)
plot!(p42,K, t_linear, label="cv_linear")
plot!(p42,K, t_fast, label="cv_fast")
savefig(p42,joinpath(@OUTPUT,"fig3-4.svg")) # hide

using DelimitedFiles, Statistics
using Joe:bootstrap
function func_1(data,index)
    X=data[index,1]; Y= data[index,2]
    (var(Y) - var(X))/(var(X) + var(Y) -2cov(X,Y))
end
Portfolio = readdlm(joinpath("_assets","data","Portfolio.csv"),',', skipstart=1)
bootstrap(Portfolio,func_1,1000)

using Joe,DelimitedFiles
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:4]; y =df[:,1]
β = multiple_regression(X,y)

std_bt = ones(3)
for j in 1:3
    function func_2(data,index)
        X = data[index,3:4];y = data[index,1]
        β = multiple_regression(X,y)
        return β[j]
    end
    std_bt[j] = bootstrap(df,func_2,1000).stderr
end
std_bt

using GLM, DataFrames
data = DataFrame(df)
ols = lm(@formula(x1 ~ x3 + x4), data)

