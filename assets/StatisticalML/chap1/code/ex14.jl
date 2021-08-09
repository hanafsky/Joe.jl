# This file was generated, do not modify it. # hide
using Joe, DataFrames
using ScikitLearn
@sk_import datasets: load_boston
df = load_boston()
x27 = df["data"] # RDatasetsがGithub actions で使えなくなってた。
#TabularDisplayを使って綺麗に表示する。
using TabularDisplay, Formatting
foo = generate_formatter("%7.5f")
displaytable(Joe.VIF(x27);index=true,indexsep=" -> ",formatter=foo)