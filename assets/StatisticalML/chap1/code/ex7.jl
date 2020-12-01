# This file was generated, do not modify it. # hide
N=100;iter_num=100;
data23 = Matrix(undef,iter_num,2)
for i in 1:iter_num
    x23=randn(N)  .+2
    y23= x23 .+ 1 +  randn(N)
    data23[i,:] = min_sq(x23,y23) |> collect
end
p14 = scatter(data23[:,2],data23[:,1],xlabel="β₀",ylabel="β₁",title="test",legend=false)
savefig(p14,joinpath(@OUTPUT,"fig1-4.svg")) # hide