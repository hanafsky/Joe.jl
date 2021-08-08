# This file was generated, do not modify it. # hide
using Joe, RDatasets,DataFrames
using Chain
df = dataset("MASS","BOSTON")
x27 = @chain df select(_,Not(:MedV)) Array #df[Not(:MedV)]がFranklinで動かん。
#TabularDisplayを使って綺麗に表示する。
using TabularDisplay, Formatting
foo = generate_formatter("%7.5f")
displaytable(Joe.VIF(x27);index=true,indexsep=" -> ",formatter=foo)