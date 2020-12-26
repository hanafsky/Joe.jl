# This file was generated, do not modify it. # hide
γ = randn(2+1) #初期値
γ2 = copy(γ) #別解用にコピー
@show γ
W(v::Vector) = @.(v/(1+ v)^2) |> diagm
t = true
for i in 1:10
    global γ
    s=X*γ
    v = @. exp(-y*s)
    u = @. y*v/(1+v)
    γ += ((X'*W(v)*X) \ X') * u
    #δ'*δ < 0.001 && (t = false)
    @show γ
end
plot!(x-> -γ[1]/γ[3] - γ[2]/γ[3]*x, label="γ")