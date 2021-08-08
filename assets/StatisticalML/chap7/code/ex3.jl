# This file was generated, do not modify it. # hide
using Joe,RDatasets
boston=dataset("MASS","boston") |> Matrix
X = boston[:,1:end-1];y=boston[:,end];
α_seq = 0:0.1:1.5
n = 100
X65 = X[begin:n,:]; y65 = y[begin:n];
s = Int(n/10)
out = zeros(length(α_seq))
for (i,α) in enumerate(α_seq)
    global n, X65, y65, out # hide
    local node # hide
    SS = 0
    for h in 0:9
        test = h*s+1:(h+1)*s
        train = setdiff(1:n,test)
        node = Joe.decisiontree(X65[train,:],y65[train];α=α)
        for t in test
            SS += (y[t] - Joe.dtvalue(X65[t,:],node))^2
        end
    end
    out[i] = SS/n
end
p65_1 = plot(α_seq,out,xlabel="α",ylabel="二乗誤差",
            title="CVで最適なα(N=100)",label=false);