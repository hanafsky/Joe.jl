# This file was generated, do not modify it. # hide
using RDatasets, StatsBase
using Joe:mvnormal, logMvNormal
iris = dataset("datasets","iris")
x = iris[!,1:4]
y = iris.Species
n = length(y)
index = sample(1:n,n,replace=false); #ランダムなインデックスを作り
train=index[begin:Int(n/2)];# 学習用とテスト用にインデックスを分ける。
text = index[Int(n/2)+1:end];
X = x[train,:] |> Matrix
Y = y[train];