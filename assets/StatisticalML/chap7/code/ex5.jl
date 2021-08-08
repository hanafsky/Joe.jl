# This file was generated, do not modify it. # hide
using RDatasets, Joe
iris = dataset("datasets","iris")
x = iris[!,1:4] |> Matrix
targets=unique(iris.Species)