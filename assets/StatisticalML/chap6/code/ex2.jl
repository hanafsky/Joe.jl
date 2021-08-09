# This file was generated, do not modify it. # hide
using Joe:polynomial
p_set = [3,5,7]
x_seq = -3:0.1:3
for p in p_set
    global x, y, x_seq, p52 # hide
    X = polynomial(x,p)
    β̂ = multiple_regression(X,y)
    ŷ = insert_ones(polynomial(x_seq,p))*β̂
    plot!(p52, x_seq,ŷ,label="p = $p")
end
savefig(p52,joinpath(@OUTPUT,"fig6-1.svg")) # hide