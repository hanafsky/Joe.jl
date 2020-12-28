# This file was generated, do not modify it. # hide
using RDatasets, StatsBase, Random, Plots
using Joe:knn
iris = dataset("datasets","iris")
X = iris[!,1:4] |> Matrix
targets=unique(iris.Species);