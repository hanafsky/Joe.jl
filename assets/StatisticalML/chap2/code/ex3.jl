# This file was generated, do not modify it. # hide
using ForwardDiff

f(x,y) = [x^2+y^2-1, x+y]
let # hide
z = [3,4]
for i in 1:10
    z -= ForwardDiff.jacobian(x->f(x[1], x[2]),z) \ f(z[1],z[2])
    println(z)
end
end # hide