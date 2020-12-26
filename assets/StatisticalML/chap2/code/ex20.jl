# This file was generated, do not modify it. # hide
y_pred = similar(y_test)
for i in 1:length(y_test)
    y_pred[i] = argmax([param(X_test[i,:]...) for param in Params])
end

using Joe:table_count
table_count(y_test,y_pred)