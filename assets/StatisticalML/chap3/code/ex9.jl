# This file was generated, do not modify it. # hide
K = [i for i in 2:1000 if 1000%i ==0]
t_linear = Vector{Float64}(undef,length(K));
t_fast = similar(t_linear);