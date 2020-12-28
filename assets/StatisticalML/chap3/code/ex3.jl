# This file was generated, do not modify it. # hide
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