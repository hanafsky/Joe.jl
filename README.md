# Joe.jl
[統計的機械学習の数理100問](https://www.kyoritsu-pub.co.jp/series/214/)をjuliaでやってみる。 

## Installation
```julia
julia>]
pkg> add https://github.com/lethal8723/Joe.jl.git
```
## Example

```julia
using Joe

n = 100; p =2
β = Float64[1,2,3]
x = randn(n,2)
y = @. β[1] + β[2] * x[:,1] + β[3]*x[:,2] + $randn(n)
MultipleRegression(x,y)

3-element Array{Float64,1}:
 0.8957078029816884
 1.904721221695989
 3.1212560196461494
```
