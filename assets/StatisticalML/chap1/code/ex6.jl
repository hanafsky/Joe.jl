# This file was generated, do not modify it. # hide
p15 = plot(x->pdf(Normal(0,1),x),label="正規分布")
for i in 1:10
    plot!(x->pdf(TDist(i),x), ls=:dash, label="dof: $(i)")
end
savefig(p15,joinpath(@OUTPUT,"fig1-5.svg")) # hide