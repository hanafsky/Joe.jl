# This file was generated, do not modify it. # hide
t25_ = Vector{Real}(undef,1000)
for i in 1:1000
    x25 = randn(N); y25 = 0.1*x25 .+ randn(N)
    t25_[i],_ = collect(min_sq(x25,y25)) / Joe.RSE(x25,y25) ./ sqrt.(Joe.Bdiag(x25))
end
p25_2 = histogram(t25_,xlims=(-3,3),bins=20,normalize=true, xlabel="tの値",legend=false)
title!("帰無仮説が成立しない場合")
plot!(p25_2,x->pdf(TDist(98),x))
p25 = plot(p25_1,p25_2)
savefig(p25,joinpath(@OUTPUT,"fig1-6.svg")) # hide