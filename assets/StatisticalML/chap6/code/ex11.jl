# This file was generated, do not modify it. # hide
p56_1 = scatter(x,y,xlims=(-7,7),xlabel="x",ylabel="f(x),g(x)",label=false,title="K=6")
p56_2 = scatter(x,y,xlims=(-7,7),xlabel="x",ylabel="f(x),g(x)",label=false,title="K=11")
plot!(p56_1,u_seq,v_seq6,label="spline")
plot!(p56_1,u_seq,w_seq6,label="natural spline")
vline!(p56_1,[-5,5];linewidth=1,label=false)
vline!(p56_1,range(-5,stop=5,length=6);linestyle=:dash,label=false)
plot!(p56_2,u_seq,v_seq11,label="spline")
plot!(p56_2,u_seq,w_seq11,label="natural spline")
vline!(p56_2,[-5,5];linewidth=1,label=false)
vline!(p56_2,range(-5,stop=5,length=11);linestyle=:dash,label=false)
p56 = plot(p56_1,p56_2,layout=(2,1))
savefig(p56,joinpath(@OUTPUT,"fig6-7.svg")) # hide