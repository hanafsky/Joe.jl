# This file was generated, do not modify it. # hide
p51 = plot(xlabel="log λ", ylabel="mean squared error")
plot!(p51,log.(cv.lambda),cv.meanloss,ribbon=cv.stdloss,legend=false)
savefig(p51,joinpath(@OUTPUT,"fig5-8.svg")) # hide