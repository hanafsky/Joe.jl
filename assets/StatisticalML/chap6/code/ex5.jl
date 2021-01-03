# This file was generated, do not modify it. # hide
X_cos = polynomial(x,3,cos)
β̂_cos = multiple_regression(X_cos,y)
ŷ_cos = insert_ones(polynomial(x_seq,3,cos))*β̂_cos;