@def title = "機械学習の数理100問シリーズをJuliaでやる"
@def tags = ["syntax", "code"]
@def hascode = true 
@def showall = true

# Joe.jl
julia言語のパッケージ作りと静的サイト作成の練習のため、鈴木讓先生の[統計的機械学習の数理100問](https://www.kyoritsu-pub.co.jp/series/214/)にjuliaで取り組んでいます。
Joe.jlパッケージは原著内で定義した関数を再利用可能な形でまとめたものです。
原著では変数の名前やスコープが適当でしたが、じ
関数内からグローバル変数を参照しないように注意して翻訳しています。 
例題、問題はコーディングのお題だけ記載しています。 
もともとのコードは冗長なところがありますが（とくに可視化のコード）、juliaによってかなりシンプルに書けているところが伝われば良いと思います。

## パッケージのインストール方法
```julia
julia>]
pkg> add https://github.com/lethal8723/Joe.jl.git
```
使い方

```julia
using Joe
|>
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

# 統計的機械学習の数理

1. [第一章 線形回帰](/StatisticalML/chap1/index.html)
2. [第二章 ロジスティック回帰]()
3. [第三章 クロスバリデーション]()
4. [第四章 情報量基準](/StatisticalML/chap4/)
5. [第五章 正則化]()
6. [第六章 非線形回帰]()
7. [第七章 ブースティング]()
8. [第八章 サポートベクトルマシン]()
9. [第九章 教師なし学習]()