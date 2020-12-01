# This file was generated, do not modify it. # hide
using Zygote
f(x) = x^2 -1
let # hide
x=4
for i in 1:10
    x -= f(x)/f'(x)
    println(x)
end
end # hide