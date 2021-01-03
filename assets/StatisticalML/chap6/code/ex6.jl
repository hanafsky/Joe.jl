# This file was generated, do not modify it. # hide
X_sin = polynomial(x,3,sin)
β̂_sin = multiple_regression(X_sin,y)
ŷ_sin = insert_ones(polynomial(x_seq,3,sin))*β̂_sin;