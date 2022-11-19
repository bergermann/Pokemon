using BenchmarkTools

function combLayers!(l::Matrix{UInt32},ls::Array{UInt32})
    @inbounds for k in 1:size(ls,3)
        @inbounds for i in eachindex(l)
            @views if ls[:,:,k][i] != 0x000000
                l[i] = ls[:,:,k][i]
            end
        end
    end

    return
end

function test2()
    layers = rand(UInt32,204,272,7)
    layer = zeros(UInt32,204,272)

    @btime combLayers!($layer,$layers)

    println(all(layer .== 0x000000))

    return
end

test2()
