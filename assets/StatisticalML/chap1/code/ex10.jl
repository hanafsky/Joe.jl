# This file was generated, do not modify it. # hide
t25 = Vector{Real}(undef,1000)
for i in 1:1000
    x25 = randn(N); y25 = randn(N)
    t25[i],_ = collect(min_sq(x25,y25)) / Joe.RSE(x25,y25) ./ sqrt.(Joe.Bdiag(x25))
end
p25_1 = histogram(t25,xlims=(-3,3),bins=20,normalize=true,xlabel="tの値",legend=false)
title!("帰無仮説が成立する場合")
plot!(p25_1,x->pdf(TDist(98),x));