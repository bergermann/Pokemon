#
#using Images: load
#using MiniFB: mfb_rgb

function getFont()
    img = mfb_rgb.(load("im/font.png"))

    symbols1 = "0123456789!?.-⋅~“”‘’♂♀€,×/® \
            ABCDEFGHIJKLMNOPQRSTUVWXYZ\
            abcdefghijklmnopqrstuvwxyz\
            "
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
            [5,4,5,5,5,5,5,5,5,5,2,5,3,5,3,5,5,5,3,3,5,5,5,3,6,5,8,3],
            [5,5,5,5,5,5,5,5,4,5,5,5,5,5,5,5,5,5,5,4,5,5,5,5,4,5],
            [5,5,5,5,5,4,5,5,2,4,5,2,5,5,5,5,5,5,5,5,5,5,5,5,5,5]
        ]
    )
    key2 = Vector{Vector{UInt16}}(
        [
            [5,4,5,5,5,5,5,5,5,5,2,5,3,5,3,5,5,5,4,4,5,5,6,3,6,5,8],
            [5,5,5,5,5,5,5,5,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,4,5],
            [5,5,5,5,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,5,5,5,5],
            [6,3,5,5,5,5,5,5,10,10,9,9,6,8,10,7,10,9,3],
            [10,10,10,10,10,10,10,10,10,4,4,8,8,8],
            [5,5,5,5,5,5,5,4,4,4,5,5,5,8,5,5,5,5,6],
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
        lineoffset::Int=0, charoffset::Int=0)

    game.im.font.h_ = game.im.font.heights[style]
    game.im.font.h = 0
    game.im.font.w = 0

    @inbounds for c in str
        if c != '\\'
            game.im.font.char = game.im.font.fonts[style][c]
            game.im.font.w_ = size(game.im.font.char,2)
        else
            game.im.font.h += game.im.font.h_+lineoffset
            game.im.font.w = 0

            continue
        end

        @inbounds for i in eachindex(game.im.font.char)
            if game.im.font.char[i] == 0x000000
                continue
            else
                getproperty(game.im.layers,layer)[
                        pos.h+game.im.font.h+1+(i-1)%game.im.font.h_,
                        pos.w+game.im.font.w+1+div(i-1,game.im.font.h_)
                    ] = game.im.font.char[i]
            end
        end

        game.im.font.w += game.im.font.w_+charoffset
    end
end

;