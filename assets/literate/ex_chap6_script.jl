# This file was generated, do not modify it.

using Plots, Joe, Random
using Plots.PlotMeasures # hide
Plots.reset_defaults() # hide
gr() # hide
default( # hide
    titlefont  = font("JuliaMono", default(:titlefontsize),  ), # hide
    guidefont  = font("JuliaMono",  default(:guidefontsize),  ), # hide
    tickfont   = font("JuliaMono", default(:tickfontsize),   ), # hide
    legendfont = font("JuliaMono",  default(:legendfontsize), ), # hide
    left_margin = 30px, # hide
    bottom_margin = 30px # hide
) # hide
Random.seed!(12)
n = 100; x = randn(n); y = sin.(x) + randn(n);
p52 = scatter(x,y,xlabel="x", ylabel="y", label=false, legend=:topleft);

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

using Plots, Random
Random.seed!(123)
n = 100; x = randn(n) * π
y = abs.(round.(x) .%2) * 2  .- 1+ randn(n)*0.2
p53 = scatter(x,y,label= false);

x_seq = -8:0.2:8

X_cos = polynomial(x,3,cos)
β̂_cos = multiple_regression(X_cos,y)
ŷ_cos = insert_ones(polynomial(x_seq,3,cos))*β̂_cos;

X_sin = polynomial(x,3,sin)
β̂_sin = multiple_regression(X_sin,y)
ŷ_sin = insert_ones(polynomial(x_seq,3,sin))*β̂_sin;

plot!(p53,x_seq,ŷ_cos,label="cos")
plot!(p53,x_seq,ŷ_sin,label="sin")
savefig(p53,joinpath(@OUTPUT,"fig6-2.svg")) # hide

using Plots, Random
using Joe: Spline
using Joe
Random.seed!(123)
n = 100; x = randn(n)*2π; y = sin.(x) + 0.2randn(n)
p54 = scatter(x,y,xlims=(-5,5),xlabel="x",ylabel="f(x)",label=false)
K_set = 5:2:9
for K in K_set
    spline = Spline(xmin=-2π, xmax=2π, K=K)
    u_seq = -5:0.2:5
    v_seq = spline(x,y,u_seq)
    plot!(p54, u_seq,v_seq, label="K = $K")
end
savefig(p54,joinpath(@OUTPUT,"fig6-5.svg")) # hide

using Plots, Random
using Joe: Spline
using Joe
Random.seed!(123)
n = 100; x = randn(n)*2π; y = sin.(x) + 0.2randn(n)
spline6 = Spline(xmin=-5, xmax=5, K=6);
spline11 = Spline(xmin=-5, xmax=5, K=11);

u_seq = -6:0.02:6;
v_seq6 = spline6(x,y,u_seq);
v_seq11 = spline11(x,y,u_seq);
w_seq6 = spline6(x,y,u_seq;splinematrix=Joe.natural_spline_matrix);
w_seq11 = spline11(x,y,u_seq;splinematrix=Joe.natural_spline_matrix);

p56_1 = scatter(x,y,xlims=(-7,7),xlabel="x",ylabel="f(x),g(x)",label=false,title="K=6")
p56_2 = scatter(x,y,xlims=(-7,7),xlabel="x",ylabel="f(x),g(x)",label=false,title="K=11")
plot!(p56_1,u_seq,v_seq6,label="spline")
plot!(p56_1,u_seq,w_seq6,label="natural spline")
vline!(p56_1,[-5,5];linewidth=1,label=false)
vline!(p56_1,range(-5,stop=5,length=6);linestyle=:dash,label=false)
plot!(p56_2,u_seq,v_seq11,label="spline")
plot!(p56_2,u_seq,w_seq11,label="natural spline")
vline!(p56_2,[-5,5];linewidth=1,label=false)
vline!(p56_2,range(-5,stop=5,length=11);linestyle=:dash,label=false)
p56 = plot(p56_1,p56_2,layout=(2,1))
savefig(p56,joinpath(@OUTPUT,"fig6-7.svg")) # hide

using Plots, Random, Distributions
using Joe: SmoothingSpline
using Joe
Random.seed!(11)
n = 100;
x = rand(Uniform(-5,5),n); y = x .+ 2sin.(x) + randn(n)
index = sortperm(x); x = x[index]; y = y[index]

p57 = scatter(x,y,label=false)

sspline = SmoothingSpline(x)
u_seq = -8:0.02:8
λ_set = [40,400,1000]
for λ in λ_set
    global u_seq, p57 # hide
    v_seq = sspline(y,u_seq,λ=λ)
    plot!(p57,u_seq,v_seq,label="λ = $λ")
end
p57
plot!(p57,u_seq,sspline(y,u_seq,λ=1),label="λ = 1")
savefig(p57,joinpath(@OUTPUT, "fig6-8.svg")) # hide

using Random, Distributions
Random.seed!(11)
n = 100; x = rand(Uniform(-5,5),n) ; y = x -0.02sin.(x)-0.1randn(n);
index = sortperm(x); x = x[index]; y = y[index];

X = Joe.smoothing_spline_matrix(x,x);
G = Joe.green_silverman(x);

result = hcat([collect(Joe.cv_ss_fast(X,y,G,n,λ=λ)) for λ in 1:50]...)
using Plots
p58 = plot(result[2,:], result[1,:],label= false,
            xlabel="有効自由度", ylabel="CVによる予測誤差",
            title = "有効自由度とCVによる予測誤差")
savefig(p58,joinpath(@OUTPUT,"fig6-9.svg"))

using Random
Random.seed!(123)
n=250;x = 2randn(n); y = sin.(2π*x) + randn(n)/4

using Plots
p58 = scatter(x,y,xlims=(-3,3),label=false)
xx = -3:0.1:3
using Joe:nadaraya_watson_estimator, epanechnikov
using LinearAlgebra

plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=0.05),
         label="λ = 0.05");
plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=0.25),
         label="λ = 0.25");

λ_seq = 0.05:0.01:1
SS_min = Inf
λ_best = λ_seq[1]
for λ in λ_seq
    global SS_min, λ_best,n,x,y # hide
    SS = 0
    m = Int(n/10)
    for k in 1:10
        test = k*m-m+1:k*m
        train = setdiff(1:n,test)
        y_pred = nadaraya_watson_estimator(x[train],y[train],epanechnikov,x[test];λ=λ)
        SS += dot(y[test]-y_pred,y[test]-y_pred)
    end
    if SS < SS_min
        SS_min = SS
        λ_best = λ
    end
end

plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=λ_best), label="λ = λ_best")
savefig(p58,joinpath(@OUTPUT,"fig6-10.svg")) # hide

@show λ_best;

using Random,Joe
Random.seed!(123)
n=30; x = 2π*rand(n) .- π; y = sin.(x) .+ randn()
p61 = scatter(x,y,label=false)
m = 200;U = -π:π/m:π;

V = Joe.local_regression(x,y,Joe.epanechnikov;x_pred=U)
plot!(p61,U,V,label=false,title = "局所線形回帰(p=1, N=30)")
savefig(p61,joinpath(@OUTPUT,"fig6-11.svg")) # hide

using Random,Joe
Random.seed!(123)
n=30; x = 2π*rand(n) .- π; sort!(x); y = sin.(x) .+ randn()
y₁ = zeros(n); y₂ = zeros(n)
for k in 1:10
    global x,y,y₁,y₂ # hide
    y₁ = Joe.polyfit(x,y-y₂)
    y₂ = Joe.local_regression(x,y-y₁,Joe.epanechnikov)
end
using Plots
p62_1 = plot(x,y₁,label=false,xlabel="x",ylabel="f(x)",title="多項式回帰(3次)")
p62_2 = plot(x,y₂,label=false,xlabel="x",ylabel="f(x)",title="局所線形回帰")
p62　= plot(p62_1,p62_2,layout=(1,2))
savefig(p62,joinpath(@OUTPUT,"fig6-12.svg")) # hide

using Random,Joe
Random.seed!(123)
n=30; x = 2π*rand(n) .- π; sort!(x); y = sin.(x) .+ randn()
y₁ = zeros(n); y₂ = zeros(n)
using Plots
for k in 1:10
    global x,y,y₁,y₂ # hide
    y₂ = Joe.local_regression(x,y-y₁,Joe.epanechnikov)
    y₁ = Joe.polyfit(x,y-y₂)
end
p62_3 = plot(x,y₁,label=false,xlabel="x",ylabel="f(x)",title="多項式回帰(3次)")
p62_4 = plot(x,y₂,label=false,xlabel="x",ylabel="f(x)",title="局所線形回帰")
p62_5　= plot(p62_3,p62_4,layout=(1,2))
savefig(p62_5,joinpath(@OUTPUT,"fig6-12-2.svg")) # hide

