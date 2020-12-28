# This file was generated, do not modify it. # hide
β = [0,0] #初期値
γ = randn(2)
while sum(β-γ)^2 > 0.001
    global β, γ
    local W
    β = γ
    s = X_train*β
    v = @. exp(-s*y_train)
    u = @. y_train*v/(1+v)
    w = @. v/(1+v)^2
    W = diagm(w)
    z = @. s + u/w
    γ = (X_train'*W*X_train)\(X_train'*W*z)
    @show γ;
end