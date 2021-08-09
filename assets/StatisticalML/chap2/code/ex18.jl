# This file was generated, do not modify it. # hide
Params = QDA[]
for i in 1:3
    μ,Σ =  mean_and_cov(X_train[y_train .==i,:])
    push!(Params, QDA(μ=μ', Σ=Σ)) #μは行ベクトルであることに注意
end