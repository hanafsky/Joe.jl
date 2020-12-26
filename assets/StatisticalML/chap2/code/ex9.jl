# This file was generated, do not modify it. # hide
index = sample(1:2n,2n,replace=false); #ランダムなインデックスを作り
train = index[begin:n];# 学習用とテスト用にインデックスを分ける。
test = index[n+1:end];
X_train = x34[train,:];y_train = y34[train]
X_test = x34[test,:];y_test = y34[test]
p34 = scatter(X_train[:,2],y_train,label="train")
scatter!(p34,X_test[:,2],y_test,label="test")
savefig(p34,joinpath(@OUTPUT,"fig2-2-3.svg")) # hide