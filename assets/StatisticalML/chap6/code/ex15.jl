# This file was generated, do not modify it. # hide
result = hcat([collect(Joe.cv_ss_fast(X,y,G,n,λ=λ)) for λ in 1:50]...)
using Plots
p58 = plot(result[2,:], result[1,:],label= false,
            xlabel="有効自由度", ylabel="CVによる予測誤差",
            title = "有効自由度とCVによる予測誤差")
savefig(p58,joinpath(@OUTPUT,"fig6-9.svg"))