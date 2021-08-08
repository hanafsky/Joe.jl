# This file was generated, do not modify it. # hide
using Joe,RDatasets
boston=dataset("MASS","boston") |> Matrix
X = boston[:,1:end-1];y=boston[:,end];
node = Joe.decisiontree(X,y;n_min=50);