polynomial(x::Vector, P::Int) = hcat([x.^p for p in 1:P]...)
polynomial(x::AbstractRange, P::Int)= polynomial(collect(x),P)
polynomial(x::Vector, P::Int, f::Function) = hcat([f.(p*x) for p in 1:P]...)
polynomial(x::AbstractRange, P::Int, f::Function) = polynomial(collect(x), P, f)