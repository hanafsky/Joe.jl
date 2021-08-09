# This file was generated, do not modify it. # hide
using ScikitLearn, StatsBase, Random, Plots
using Joe:knn
@sk_import datasets: load_iris
iris = load_iris()
X_41 = iris["data"]
y_41 = iris["target"]
n = length(y_41);