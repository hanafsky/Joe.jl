using Parameters

sigmoid(x::Matrix, β::Vector) = @. 1 / (1 + exp(-$*(x,β)))

@with_kw struct mvnormal
    μ::Array # 平均
    Σ::Matrix # 分散共分散行列
    invΣ::Array = inv(Σ) # 分散共分散行列の逆行列
    detΣ = det(Σ) # 分散共分散行列の行列式
end

function logMvNormal(parameter::mvnormal,x...)
    data = collect(x)
    @unpack μ,invΣ,detΣ = parameter
    a = 0.5*(data-μ)' * invΣ * (data-μ) 
    a[1] - log(detΣ)
end