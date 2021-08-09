# This file was generated, do not modify it. # hide
using Joe:knn,table_count
y_pred_knn = knn(X_train,y_train,X_test,3)
table_count(y_test,y_pred_knn)