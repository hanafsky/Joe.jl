# This file was generated, do not modify it. # hide
using Joe,DelimitedFiles
df = readdlm(joinpath("_assets","data","crime.txt"))
X = df[:,3:4]; y =df[:,1]
β = multiple_regression(X,y)