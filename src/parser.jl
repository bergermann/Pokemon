#
using Images: load
using MiniFB: mfb_rgb

function getFont()
    img = mfb_rgb.(load("im/font.png"))

    symbols1 = "0"
    symbols2 = "0123456789!?.-⋅~“”‘’♂♀€,×/®\
            ABCDEFGHIJKLMNOPQRSTUVWXYZ\
            abcdefghijklmnopqrstuvwxyz\
            ▷:ÄÖÜäöü↑↓←→+ⓁⒶⒾⓃ_ \
            ①②③④⑤⑥⑦⑧⑨()⊚△⨉\
            ÀÁÂÇÈÉËÌÍÏÒÓÔŒÙÚÛÑß\
            àáâçèéêëìíîïòóôœùúûñ\
            ᵒᵃᵉʳ&+🄻=;|¿¡%[]<>\
            ⓟ⒫Ⓑ"
    symbols3 = "0123456789!?.-⋅~“”‘’♂♀€,×/®\
            ABCDEFGHIJKLMNOPQRSTUVWXYZ\
            abcdefghijklmnopqrstuvwxyz\
            ▷:ÄÖÜäöüÀÁÂÇÈÉËÌÍÏÒÓÔŒÙÚÛÑß\
            àáâçèéêëìíîïòóôœùúûñ\
            ᵒᵃᵉʳ&+🄻=;|¿¡%[]<>\
            ⓟ⒫Ⓑ↑↓←→ "

    key1 = Vector{Vector{UInt16}}(
        [
            [5],
            [5]
        ]
    )
    key2 = Vector{Vector{UInt16}}(
        [
            [5,4,5,5,5,5,5,5,5,5,2,5,3,5,3,5,5,5,4,4,5,5,6,3,6,5,8],
            [5,5,5,5,5,5,5,5,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,4,5],
            [5,5,5,5,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,5,5,5,5],
            [6,3,5,5,5,5,5,5,10,10,9,9,6,8,10,7,10,9,3],
            [10,10,10,10,10,10,10,10,10,4,4,8,8,8],
            [5,5,5,5,5,5,5,5,4,4,4,4,5,5,5,8,5,5,5,5,6],
            [5,5,5,5,5,5,5,5,3,3,4,4,5,5,5,8,5,5,5,5],
            [5,6,5,9,6,6,8,6,3,5,5,2,6,3,3,6,6],
            [16,15,20]
        ]
    )
    key3 = Vector{Vector{UInt16}}(
        [
            [6,4,6,6,6,6,6,6,6,6,2,6,3,6,3,6,6,6,3,3,6,6,6,3,7,6,8],
            [6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6],
            [6,6,6,6,6,6,6,6,2,6,6,3,6,6,6,6,6,6,6,6,6,6,6,6,6],
            [6,3,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,8,6,6,6,6,6],
            [6,6,6,6,6,6,6,6,4,4,4,4,6,6,6,8,6,6,6,6],
            [6,6,5,9,6,6,10,6,3,3,6,6,2,8,3,3,6,6],
            [16,15,20,10,10,9,4]
        ]
    )

    f1 = Vector{Matrix{UInt32}}([])
    f2 = Vector{Matrix{UInt32}}([])
    f3 = Vector{Matrix{UInt32}}([])

    for i in eachindex(key1)
        k = key1[i]
        v = 0

        for j in eachindex(k)
            push!(f1,img[1+(i-1)*12:i*12,1+v:k[j]+v])
            v += k[j]+1
        end
    end

    for i in eachindex(key2)
        k = key2[i]
        v = 0

        for j in eachindex(k)
            push!(f2,img[1+(i-1)*15:i*15,176+1+v:176+k[j]+v])
            v += k[j]+1
        end
    end

    for i in eachindex(key3)
        k = key3[i]
        v = 0

        for j in eachindex(k)
            push!(f3,img[1+(i-1)*14:i*14,336+1+v:336+k[j]+v])
            v += k[j]+1
        end
    end
    
    return Dict(zip(symbols1,f1)),Dict(zip(symbols2,f2)),Dict(zip(symbols3,f3))
end

function drawText!(game::GameState,layer::Symbol,str::String,style::UInt,pos::Position;
        lineoffset=0)
    height = [12,15,14][style]

    S = split(str,"\n")

    for i in eachindex(S)
        vert = 0

        for c in collect(S[i])
            char = game.im.font[style][c]
            ind = char .!= 0x000000
            char[(!).(ind)] = getproperty(game.im.layers,layer)[
                1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
                vert+1+pos.w:vert+size(char)[2]+pos.w
            ][(!).(ind)]
            
            getproperty(game.im.layers,layer)[
                1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
                vert+1+pos.w:vert+size(char)[2]+pos.w
            ] = char
            
            vert += size(char)[2]
        end
    end
end

#=
function drawText!(game::GameState,layer::Symbol,str::String,style::UInt,pos::Position;
    lineoffset=0)
    height = [12,15,14][style]

    S = split(str,"\n")

    for i in eachindex(S)
        vert = 0

        for c in collect(S[i])
            char = game.im.font[style][c]
            ind = char .!= 0x000000
            #println(ind)
            
            getproperty(game.im.layers,layer)[
                1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
                vert+1+pos.w:vert+size(char)[2]+pos.w
            #] = char
            ][ind] .= char[ind]
            
            vert += size(char)[2]
        end
    end
end
=#

;