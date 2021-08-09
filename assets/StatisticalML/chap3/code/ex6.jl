# This file was generated, do not modify it. # hide
errorRate = Vector{Float64}(undef,10)
for k in 1:10
    global errorRate, X_41, y_41 # hide
    S = 0
    for top in 1:15:150
        test = top:top+14
        train = setdiff(1:150,test)
        knn_ans = knn(X_41[train,:],y_41[train],X_41[test,:],k)
        S += sum(y[test] .!= knn_ans)
    end
    S /= n
    errorRate[k] = S
end
p41 = plot(errorRate,xlabel="K",ylabel="誤り率",
            legend=false, title="CVによる誤り率の評価")
savefig(p41,joinpath(@OUTPUT,"fig3-3.svg")) # hide