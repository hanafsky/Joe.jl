# This file was generated, do not modify it. # hide
V = Joe.local_regression(x,y,Joe.epanechnikov;x_pred=U)
plot!(p61,U,V,label=false,title = "局所線形回帰(p=1, N=30)")
savefig(p61,joinpath(@OUTPUT,"fig6-11.svg")) # hide