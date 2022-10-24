#
using Images: load
using MiniFB: mfb_rgb

function getFont()
    fontimg = load("im/Font.png")

    symbols1 = ""
    symbols2 = "0123456789!?.-⋅~“”‘’♂♀€,×/®\
            ABCDEFGHIJKLMNOPQRSTUVWXYZ\
            abcdefghijklmnopqrstuvwxyz\
            ▷:ÄÖÜäöü↑↓←→+ⓁⒶⒾⓃ_ "#=\
            ①②③④⑤⑥⑦⑧⑨()⊚△⨉\
            ÀÁÂÇÈÉËÌÍÏÒÓÔŒÙÚÛÑß\
            àáâçèéêëìíîïòóôœùúûñ\
            ᵒᵃᵉʳ&+🄻=;|¿¡%[]<>\
            ⓟ⒫Ⓑ"=#
    symbols3 = ""

    key1 = Vector{Matrix{UInt16}}([])
    key2 = Vector{Matrix{UInt16}}([
        Matrix{UInt16}([
            180 5;  #0
            187 4;  #1
            192 5;  #2
            198 5;  #3
            204 5;  #4
            210 5;  #5
            216 5;  #6
            222 5;  #7
            228 5;  #8
            234 5;  #9
            241 2;  #!
            245 4;  #?
            251 3;  #.
            255 5;  #-
            261 3;  #*
            265 5;  #..
            271 5;  #"l
            277 5;  #"r
            283 3;  #'l
            287 3;  #'r
            291 5;  #male
            297 5;  #female
            303 6;  #poke
            310 3;  #,
            314 6;  #x
            321 5;  #/
            327 8]),#re
        Matrix{UInt16}([
            180 5;  #A
            186 5;  #B
            192 5;  #C
            198 5;  #D
            204 5;  #E
            210 5;  #F
            216 5;  #G
            222 5;  #H
            228 4;  #I
            233 5;  #J
            239 5;  #K
            245 5;  #L
            251 5;  #M
            257 5;  #N
            263 5;  #O
            269 5;  #P
            275 5;  #Q
            281 5;  #R
            287 5;  #S
            293 5;  #T
            299 5;  #U
            305 5;  #V
            311 5;  #W
            317 5;  #X
            323 4;  #Y
            328 5]),#Z
        Matrix{UInt16}([
            180 5;  #a
            186 5;  #b
            192 5;  #c
            198 5;  #d
            204 5;  #e
            210 5;  #f
            216 5;  #g
            222 5;  #h
            229 2;  #i
            233 5;  #j
            239 5;  #k
            246 2;  #l
            250 5;  #m
            256 5;  #n
            262 5;  #o
            268 5;  #p
            274 5;  #q
            280 5;  #r
            286 5;  #s
            292 5;  #t
            298 5;  #u
            304 5;  #v
            310 5;  #w
            316 5;  #x
            322 5;  #y
            328 5]),#z
        Matrix{UInt16}([
            181 6;  #triangle right
            189 3;  #:
            193 5;  #Ä
            199 5;  #Ö
            205 5;  #Ü
            211 5;  #ä
            217 5;  #ö
            223 5;  #ü
            229 10; #arrow up
            240 10; #arrow down
            251 9;  #arrow left
            263 9;  #arrow right
            274 6;  #+
            282 8;  #lv
            291 10; #ap
            302 8;  #id
            311 10; #no
            323 9;  #_
            333 3]),
    ])
    key3 = Vector{Matrix{UInt16}}([])

    f1 = Vector{Matrix{UInt32}}([])
    f2 = Vector{Matrix{UInt32}}([])
    f3 = Vector{Matrix{UInt32}}([])

    for i in eachindex(key1)
        k = key1[i]

        for j in Array{UInt16}(1:size(k)[1])
            push!(f1,permutedims(
                    mfb_rgb.(fontimg)[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
                    k[j,1]+0x01:k[j,1]+k[j,2]+0x01],(2,1)))
        end
    end

    for i in eachindex(key2)
        k = key2[i]

        for j in Array{UInt16}(1:size(k)[1])
            push!(f2,permutedims(
                    mfb_rgb.(fontimg)[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
                    k[j,1]+0x01:k[j,1]+k[j,2]+0x01],(2,1)))
        end
    end

    for i in eachindex(key3)
        k = key3[i]

        for j in Array{UInt16}(1:size(k)[1])
            push!(f3,permutedims(
                    mfb_rgb.(fontimg)[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
                    k[j,1]+0x01:k[j,1]+k[j,2]+0x01],(2,1)))
        end
    end
    
    return Dict(zip(symbols1,f1)),Dict(zip(symbols2,f2)),Dict(zip(symbols3,f3))
end

function textBuffer(str::String,area::Tuple{UInt16,UInt16},dict::Dict)
    height = size(dict[str[1]])[2]

    S = split(str,"\n")

    tb = permutedims(zeros(UInt32,area),(2,1))
    for i in eachindex(S)
        vert::UInt16 = 0x0001
        for c in collect(S[i])
            char = dict[c]
            width = UInt16(size(char)[1])
            
            tb[vert:vert+width-0x01,
                        UInt16(1+height*(i-1)):UInt16(height*i)] = char
            vert += width - 0x01
        end
    end
    
    return tb
end

;