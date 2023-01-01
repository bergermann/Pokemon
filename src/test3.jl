using BenchmarkTools

include("core.jl")
include("rendering.jl")

function f()
    A = ArrayList(Sprite,128)
    #show(A)

    for i in 1:128
        push!(A,Sprite(Symbol("rand$i"),Position(rand(Int32,2)...),rand(UInt32,100,100)))
        #print(A.idx,", ")
    end

    sortHorizontal!(A)
    #println([x.id for x in A.data[1:A.idx]])

    @btime sortHorizontal!($A)

    #a = rand(100)

    #@btime quicksort!($a,1,90,sqrt)
    #show(a)
end

f()
;