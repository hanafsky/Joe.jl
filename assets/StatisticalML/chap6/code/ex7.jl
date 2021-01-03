# This file was generated, do not modify it. # hide
plot!(p53,x_seq,ŷ_cos,label="cos")
plot!(p53,x_seq,ŷ_sin,label="sin")
savefig(p53,joinpath(@OUTPUT,"fig6-2.svg")) # hide