using BenchmarkTools

using Images, Plots

include("transformations.jl")

function showIm(im)
    display(plot(reinterpret(RGB24,im)))
end

function testShearX(im,θ,n)
    for i in -n:n
        showIm(xShear(im,θ*i*2pi/360))
    end
end

function testShearY(im,θ,n)
    for i in -n:n
        showIm(yShear(im,θ*i*2pi/360))
    end
end

function testRot(im,θ,n)
    for i in -n:n
        showIm(rotate(im,θ*i))
    end
end

function testRot!(im,θ,n)
    for i in 1:n
        rotate!(im,θ)
        showIm(im)
    end
end



function f()
    a = 512; A = zeros(UInt32,a,a)

    for i in 1:a, j in 1:a
        if (i > a/3)*(i < 2a/3)*(j > a/3)*(j < 2a/3)
            A[i,j] = 0x101010
        end
    end

    B = zeros(UInt32,a,a)
    B[:,floor(Int,a/2):end] .= 0xffffff

    
    showIm(A)
    showIm(B)

    C = combine(A,B,0x0a,0x01)
    combine!(A,B,0x0a,0x01)

    showIm(A)
    showIm(C)
    

    #@btime combine!($A,$B,0x0a,0x01)
    #@btime combine($A,$B,0x0a,0x01)

    return
end

f()
