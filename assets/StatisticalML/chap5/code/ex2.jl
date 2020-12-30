# This file was generated, do not modify it. # hide
using Plots
x_seq = -2:0.05:2;
p49_1 = plot(x_seq, x -> x^2-3x+abs(x),title = "y=x^2-3x+|x|")
scatter!(p49_1,[1],[-1],color=:red,legend=false)
p49_2 = plot(x_seq,x -> x^2 + x +2abs(x),title="y=x^2+x+2|x|")
scatter!(p49_2,[0],[-0],color=:red, legend=false)
p49 = plot(p49_1,p49_2,layout=(1,2),size= (500,200))
savefig(p49,joinpath(@OUTPUT,"fig5-2.svg")) # hide