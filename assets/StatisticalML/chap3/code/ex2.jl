# This file was generated, do not modify it. # hide
using Joe # hide
U=Float64[]; V = Float64[]
for _ in 1:100
    global U, V, X, β, n
    local y
    y = expand_matrix(X)*β + randn(n)
    push!(U,cv_linear(X[:,[3,4,5]],y,10))
    push!(V,cv_linear(X,y,10))
end

p39 = scatter(U,V,xlabel="with variable 3,4,5",ylabel="all variable",title="overlearning")
plot!(p39, x->x,xlims=(0.7,1.5),legend=false)
savefig(p39,joinpath(@OUTPUT,"fig3-1.svg")) # hide