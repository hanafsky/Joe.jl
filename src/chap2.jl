
sigmoid(x::Matrix, β::Vector) = @. 1 / (1 + exp(-$*(x,β)))
