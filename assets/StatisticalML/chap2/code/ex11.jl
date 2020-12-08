# This file was generated, do not modify it. # hide
function logMvNormal(parameter::mvnormal,x...)
    data = collect(x)
    @unpack μ,invΣ,detΣ = parameter
    a = 0.5*(data-μ)' * invΣ * (data-μ)
    a[1] - log(detΣ)
end

x35=-5:0.1:5;
y35=-5:0.1:5;
contour(x35,y35, hanbetsu.([x35,y35']))