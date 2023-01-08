using BenchmarkTools

include("core.jl")
include("rendering.jl")

function getBattler(id::Int)
    img = mfb_rgb.(load("im/gen1/$id.png"))

    return Dict{UInt,Matrix{UInt32}}(1=>img[:,1:64],2=>img[:,65:128])
end

function getBattler_(id::Int)
    img = mfb_rgb.(load("im/gen1/$id.png"))

    d = Dict{UInt,Matrix{UInt32}}(
        1=>mfb_rgb.(load("im/gen1/$(id)a.png")),
        2=>mfb_rgb.(load("im/gen1/$(id)b.png"))
    )

    return d
end

function f()
    id = 1

    str = "im/gen1/$id.bmp"
    
    @btime getBattler($id)
end

f()
;