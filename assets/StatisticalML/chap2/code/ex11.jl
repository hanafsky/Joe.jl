# This file was generated, do not modify it. # hide
using Joe:table_count
y_pred = X_test*γ .|> x -> ifelse(x>0,2,1)
y_answer = y_test .|> x -> ifelse(x>0,2,1)
table = table_count(y_answer,y_pred)
@show table;
正答率 = sum(diag(table)) / sum(table)