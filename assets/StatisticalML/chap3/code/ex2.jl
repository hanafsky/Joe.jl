# This file was generated, do not modify it. # hide
using Joe # hide
U=Float64[]; V = Float64[]
for _ in 1:100
    global U, V, X_39, β, n # hide
    local y # hide
    y = insert_ones(X_39)*β + randn(n)
    push!(U,cv_linear(X_39[:,[3,4,5]],y,10))
    push!(V,cv_linear(X_39,y,10))
end

p39 = scatter(U,V,xlabel="変数4,5,6を選んだ時の二乗誤差",
                ylabel="全変数を選んだ時の二乗誤差",
                title="変数を多く選びすぎて過学習")
plot!(p39, x->x,xlims=(0.7,1.5),legend=false)
savefig(p39,joinpath(@OUTPUT,"fig3-1.svg")) # hide