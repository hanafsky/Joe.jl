# This file was generated, do not modify it. # hide
priors = [0.5,0.25,0.25]
y_pred2 = similar(y_test)
for i in 1:length(y_test)
    y_pred2[i] = argmax([Params[j](X_test[i,:]...;prior=priors[j]) for j in 1:3])
end
table_count(y_test,y_pred2)