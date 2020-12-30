# This file was generated, do not modify it. # hide
Lcv = LassoCV(alphas=0.1:0.1:30,cv=10)
Lcv.fit(X,y)
Lcv.alpha_