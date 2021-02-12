using Parameters, StatsBase

"""
決定木関連
"""

function branch(x::Matrix,y::Vector,S,rf=0;loss_f=TSS)
    rf==0 && (m=size(x)[2])
    size(x)[2]==0 && return [0,0,0,0,0,0,0]
    best_score = Inf; i_1=1; j_1=1;
    left_1=[];right_1=[]
    left_score_1=Inf; right_score_1=Inf
    for j in 1:m
        for i in S
            left=[k for k in S if x[k,j]<x[i,j]]
            right=setdiff(S,left)
            left_score=loss_f(y[left]); right_score=loss_f(y[right])
            score=left_score + right_score
            if score<best_score
                best_score = score
                i_1=i; j_1=j
                left_1=left;right_1=right
                left_score_1=left_score;right_score_1=right_score
            end
        end        
    end 
    return i_1,j_1,left_1,right_1,best_score,left_score_1,right_score_1
end

mutable struct Stack
    parent::Union{Int,Vector,AbstractRange} #親ノード番号
    set::Union{Vector,AbstractRange} #教師データの行
    score::Number # 損失関数の値
end

mutable struct Node
    parent::Union{Int,Vector,AbstractRange} #親ノード番号
    j::Int #列番号
    th::Number #閾値
    set::Union{Vector,AbstractRange} #そのノードでの教師データの集合
    left::Int # 分岐後の列番号(左)
    right::Int # 分岐後の列番号(右)
    center::Number # yの平均値
end

function decisiontree(x::Matrix,y::Vector;α=0.0,n_min=1,rf=0,loss_f=TSS)
    rf==0 && (m=size(x)[2])
    stack = [Stack(0,1:size(x)[1],loss_f(y))]
    node=Node[]
    k=0 #Node番号
    while length(stack)>0
        popped=pop!(stack)
        k+=1　#Node番号を増やす。
        i,j,left,right,score,left_score,right_score = branch(x,y,popped.set,rf,;loss_f=loss_f)
        if popped.score-score<α || length(popped.set)<n_min || length(left)==0 || length(right)==0
            push!(node,Node(popped.parent,-1,0,popped.set,0,0,0))
        else
            push!(node,Node(popped.parent,j,x[i,j],popped.set,0,0,0))
            push!(stack,Stack(k,right,right_score))
            push!(stack,Stack(k,left,left_score))
        end
    end
    for h in k:-1:2
        pa=node[h].parent
        if node[pa].right==0 
            node[pa].right=h
        else
            node[pa].left = h
        end
    end

    g = loss_f==TSS ? mean : mode_max

    for h in 1:k
        node[h].center =  node[h].j==-1 ? g(y[node[h].set]) : 0
    end
    return node
end

function dtvalue(u,node)
    r=1
    while node[r].j !=-1
        if u[node[r].j] < node[r].th
            r = node[r].left
        else
            r = node[r].right
        end
    end
    return node[r].center
end

function freq(y)
    S = Set(y) |> collect |> sort
    [count(==(i),y) for i in S]
end

mode(y) = length(y)==0 ? 0 : maximum(freq(y))

mis_match(y) = length(y) - mode(y)

function gini(y)
    n = length(y)
    n==0 && (return 0)
    fr = freq(y)
    sum(x->x*(n-x), fr)
end

function entropy(y)
    n = length(y)
    n==0 && (return 0)
    fr = freq(y)
    sum(x->-x*log(x/n), fr)
end

function mode_max(y)
    length(y)==0 && (return -Inf)
    counts(y) |> argmax
end