[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://hanafsky.github.io/Joe.jl/)
# Joe.jl
鈴木讓先生の[機械学習の数理100問シリーズ](https://www.kyoritsu-pub.co.jp/series/214/)をjuliaでやってみます。ソースファイルには、原著内で定義した関数を
なるべく再利用可能な形でまとめています。原著では変数の名やスコープが適当でしたが、
関数内からグローバル変数を参照しないように注意して翻訳しています。 
例題、問題はコーディングが必要なお題だけ記載しています。
[まとめはこちら](https://hanafsky.github.io/Joe.jl/)

## Installation
```julia
julia>]
pkg> add https://github.com/lethal8723/Joe.jl.git
```

```julia
using Joe

n = 100; p =2
β = Float64[1,2,3]
x = randn(n,2)
y = @. β[1] + β[2] * x[:,1] + β[3]*x[:,2] + $randn(n)
multiple_regression(x,y)

3-element Array{Float64,1}:
 0.8957078029816884
 1.904721221695989
 3.1212560196461494
```
