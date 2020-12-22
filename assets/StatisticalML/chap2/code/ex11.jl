# This file was generated, do not modify it. # hide
hanbetsu(x,y) = logMvNormal(param1,x,y) - logMvNormal(param2,x,y)
x35=-5:0.1:5;
y35=-5:0.1:5;
scatter(data1[:,1],data1[:,2])
scatter!( data2[:,1],data2[:,2])
p35_2=contour!(x35,y35, hanbetsu.(x35,y35'), title="QDA")
savefig(p35_2,joinpath(@OUTPUT,"fig2-4.svg")) # hide