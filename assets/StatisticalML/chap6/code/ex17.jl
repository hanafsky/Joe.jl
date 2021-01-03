# This file was generated, do not modify it. # hide
plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=0.05),
         label="λ = 0.05");
plot!(p58,xx,nadaraya_watson_estimator(x,y,epanechnikov,xx;λ=0.25),
         label="λ = 0.25");