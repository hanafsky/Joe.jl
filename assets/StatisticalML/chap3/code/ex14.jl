# This file was generated, do not modify it. # hide
std_bt = ones(3)
for j in 1:3
    function func_2(data,index)
        X = data[index,3:4];y = data[index,1]
        β = multiple_regression(X,y)
        return β[j]
    end
    std_bt[j] = bootstrap(df,func_2,1000).stderr
end
std_bt