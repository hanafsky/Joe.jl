# ##クロスバリデーション
# ### 例39
using Joe, Random, Plots
n = 100; p = 5
Random.seed!(123)
X = randn(n, p)
β = randn(p+1); β[2:3] .= 0
y = expand_matrix(X)*β + randn(n)
