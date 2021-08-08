# This file was generated, do not modify it. # hide
n_min_seq = 1:15
out2 = zeros(length(n_min_seq))
for (i,n_min) in enumerate(n_min_seq)
    global n, X65, y65, out2 # hide
    local node # hide
    SS = 0
    for h in 0:9
        test = h*s+1:(h+1)*s
        train = setdiff(1:n,test)
        node = Joe.decisiontree(X65[train,:],y65[train];n_min=n_min)
        for t in test
            SS += (y[t] - Joe.dtvalue(X65[t,:],node))^2
        end
    end
    out2[i] = SS/n
end
p65_2 = plot(n_min_seq,out2,xlabel="n_min",ylabel="二乗誤差",
            title="CVで最適なn_min(N=100)",label=false);

p65 = plot(p65_1,p65_2,layout=(1,2))
savefig(p65,joinpath(@OUTPUT,"fig7-5.svg")) # hide