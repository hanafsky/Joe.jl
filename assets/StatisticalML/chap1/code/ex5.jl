# This file was generated, do not modify it. # hide
p13 = plot(xlims=(0,8),ylims=(0,1),title="DOF of chi",legend=:topright)
for i in 1:10
    plot!(p13,0.1:0.1:8,x->pdf(Chisq(i),x),label="dof = $(i)")
end
savefig(p13,joinpath(@OUTPUT,"fig1-3.svg")) # hide