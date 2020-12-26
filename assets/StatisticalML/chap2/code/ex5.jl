# This file was generated, do not modify it. # hide
data1 = X[y .== 1, 2:3]
data2 = X[y .== -1, 2:3]
p33=scatter(data1[:,1],data1[:,2],ylims=(-5,5),marker=:auto, label="y=1")
scatter!(p33,data2[:,1],data2[:,2],marker=:auto,label="y=-1")
plot!(p33,x-> -β[1]/β[3] - β[2]/β[3]*x, label="β")
savefig(p33,joinpath(@OUTPUT,"fig2-2.svg")) # hide