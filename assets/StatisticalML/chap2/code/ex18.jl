# This file was generated, do not modify it. # hide
Random.seed!(123)
n = length(y)
index = sample(1:n,n,replace=false); #ランダムなインデックスを作り
train = index[begin:Int(n/2)];# 学習用とテスト用にインデックスを分ける。
test = index[Int(n/2)+1:end];
X_train= x[train,:]; X_test = x[test,:];
y_train = y[train]; y_test = y[test];