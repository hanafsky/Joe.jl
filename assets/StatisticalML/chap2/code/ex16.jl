# This file was generated, do not modify it. # hide
using ScikitLearn, StatsBase, Random
using Joe:QDA
@sk_import datasets: load_iris
iris = load_iris()
x = iris["data"]
y = iris["target"]