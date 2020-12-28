# This file was generated, do not modify it. # hide
using DelimitedFiles, Statistics
using Joe:bootstrap
function func_1(data,index)
    X=data[index,1]; Y= data[index,2]
    (var(Y) - var(X))/(var(X) + var(Y) -2cov(X,Y))
end
Portfolio = readdlm(joinpath("_assets","data","Portfolio.csv"),',', skipstart=1)
bootstrap(Portfolio,func_1,1000)