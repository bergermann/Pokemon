using Images, ImageIO
using Serialization
using MiniFB

function fixBG!(img::Matrix{RGBA{N0f8}})
    bg = img[1]

    if bg == RGBA{N0f8}(0,0,0,0)
        return
    end

    for i in eachindex(img)
        if img[i] == RGBA{N0f8}(0,0,0,0) || img[i] == RGBA{N0f8}(0,0,0,1)
            img[i] == RGBA{N0f8}(0x01/0xff,0x01/0xff,0x01/0xff,0)
        elseif img[i] == bg
            img[i] = RGBA{N0f8}(0,0,0,0)
        end
    end
end

function fixBG!(img::Matrix{RGB{N0f8}})
    bg = img[1]

    if bg == RGB{N0f8}(0,0,0)
        return
    end

    for i in eachindex(img)
        if img[i] == RGB{N0f8}(0,0,0)
            img[i] == RGB{N0f8}(0x01/0xff,0x01/0xff,0x01/0xff)
        elseif img[i] == bg
            img[i] = RGB{N0f8}(0,0,0,0)
        end
    end
end

# key = """1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,\
#     28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,\
#     53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,\
#     78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,\
#     102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,\
#     121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,\
#     140,141,142,143,144,145,146,147,148,149,150,151"""

# for id in split(key,',')
#     println(id)
#     f1 = load("im/battlers/front/shiny/frame1/"*id*".png")
#     f2 = load("im/battlers/front/shiny/frame2/"*id*".png")

#     fc = hcat(f1,f2)

#     save("im/battlers/front/shiny/"*id*".png",fc)
# end

# for id in split(key,',')
#     print(id,",")

#     img = load("im/battlers/back/normal/"*id*".png")

#     fixBG!(img)
#     save("im/battlers/back/normal/"*id*".png",img)
# end


function transformImage(image::Matrix{UInt32})
    palette = unique(image)

    if 0x000000 in palette
        popat!(palette,findfirst(isequal(0x000000),palette))
    end

    bytemap = Matrix{UInt8}(undef,size(image))

    for i in eachindex(image)
        if image[i] == 0x000000
            bytemap[i] = 0x00

            continue
        end

        bytemap[i] = findfirst(isequal(image[i]),palette)
    end

    return Image(bytemap,palette)
end

function transformImage(image::Matrix{UInt32},palette::Palette)
    bytemap = Matrix{UInt8}(undef,size(image))

    for i in eachindex(image)
        if image[i] == 0x000000
            bytemap[i] = 0x00

            continue
        end

        bytemap[i] = findfirst(isequal(image[i]),palette)
    end

    return bytemap
end


for i in 1:151
    im1 = getImage("images/battlers/front/normal/frame1/$i.png")
    im2 = getImage("images/battlers/front/normal/frame2/$i.png")

    p1 = Set(unique(im1))
    p2 = Set(unique(im2))

    p = union(p1,p2)

    delete!(p,0x000000)

    p = sort!(collect(p))
        

    im1_ = transformImage(im1,Palette(p))
    im2_ = transformImage(im2,Palette(p))

    serialize("im/pkmn/$i/front_a.im",Image(im1_))
    serialize("im/pkmn/$i/front_b.im",Image(im2_))
    serialize("im/pkmn/$i/front_normal.p",Palette(p))

    im3 = getImage("images/battlers/front/shiny/frame1/$i.png")
    im4 = getImage("images/battlers/front/shiny/frame2/$i.png")

    p_ = copy(p)

    for i in eachindex(im3)
        if im3[i] != 0x000000
            p_[im1_[i]] = im3[i]
        end
    end

    for i in eachindex(im4)
        if im4[i] != 0x000000
            p_[im2_[i]] = im4[i]
        end
    end

    serialize("im/pkmn/$i/front_shiny.p",Palette(p))
end



for i in 1:151
    im1 = getImage("images/battlers/back/normal/$i.png")

    p = Set(unique(im1))

    delete!(p,0x000000)

    p = sort!(collect(p))

    im1_ = transformImage(im1,Palette(p))

    serialize("im/pkmn/$i/back.im",Image(im1_))
    serialize("im/pkmn/$i/back_normal.p",Palette(p))

    im3 = getImage("images/battlers/back/shiny/$i.png")

    p_ = copy(p)

    for i in eachindex(im3)
        if im3[i] != 0x000000
            p_[im1_[i]] = im3[i]
        end
    end

    serialize("im/pkmn/$i/back_shiny.p",Palette(p))
end










# for i in 1:151
#     mkdir("im/pkmn/$i")
# end