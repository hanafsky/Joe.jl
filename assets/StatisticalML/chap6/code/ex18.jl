# This file was generated, do not modify it. # hide
λ_seq = 0.05:0.01:1
SS_min = Inf
λ_best = λ_seq[1]
for λ in λ_seq
    global SS_min, λ_best,n,x,y # hide
    SS = 0
    m = Int(n/10)
    for k in 1:10
        test = k*m-m+1:k*m
        train = setdiff(1:n,test)
        y_pred = nadaraya_watson_estimator(x[train],y[train],epanechnikov,x[test];λ=λ)
        SS += dot(y[test]-y_pred,y[test]-y_pred)
    end
    if SS < SS_min
        SS_min = SS
        λ_best = λ
    end
end

plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=λ_best), label="λ = λ_best")
savefig(p58,joinpath(@OUTPUT,"fig6-10.svg")) # hide