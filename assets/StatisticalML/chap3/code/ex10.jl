# This file was generated, do not modify it. # hide
for i in eachindex(K)
    global X, y, t_fast, t_linear,K # hide
    start = time_ns();cv_fast(X,y,K[i]);stop = time_ns()
    t_fast[i] = (stop-start)/1e9
    start = time_ns();cv_linear(X,y,K[i]);stop = time_ns()
    t_linear[i] = (stop-start)/1e9
end
p42 = plot(ylims=(0.0,0.5), xlabel = "k" ,ylabel="実行時間",
           label="cv_linear",title="cv_fastとcv_linearの比較",
           legend=:topleft)
plot!(p42,K, t_linear, label="cv_linear")
plot!(p42,K, t_fast, label="cv_fast")
savefig(p42,joinpath(@OUTPUT,"fig3-4.svg")) # hide