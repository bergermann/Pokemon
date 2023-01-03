using BenchmarkTools

include("core.jl")
include("rendering.jl")

function test(s::Symbol)
    Symbol(s,"1")
end

function f()
    S = Sprites(128)

    ss = getSpriteMain("sprite")

    for i in 1:100
        m = Sprite(Symbol(i),:background2,Position(104,72),Position(32,16),1,
            ss,ss[1])

        push!(S,m)
    end

    print(S[Symbol(50)].id)
end

f()
;