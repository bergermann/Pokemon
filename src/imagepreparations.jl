using Images, ImageIO
using Serialization
using MiniFB

# include("types/typescore.jl")
# include("types/typesrendering.jl")

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


# for i in 1:151
#     im1 = getImage("images/battlers/front/normal/frame1/$i.png")
#     im2 = getImage("images/battlers/front/normal/frame2/$i.png")

#     p1 = Set(unique(im1))
#     p2 = Set(unique(im2))

#     p = union(p1,p2)

#     delete!(p,0x000000)

#     p = sort!(collect(p))
        

#     im1_ = transformImage(im1,Palette(p))
#     im2_ = transformImage(im2,Palette(p))

#     serialize("im/pkmn/$i/front_a.im",Image(im1_))
#     serialize("im/pkmn/$i/front_b.im",Image(im2_))
#     serialize("im/pkmn/$i/front_normal.p",Palette(p))

#     im3 = getImage("images/battlers/front/shiny/frame1/$i.png")
#     im4 = getImage("images/battlers/front/shiny/frame2/$i.png")

#     p_ = copy(p)

#     for i in eachindex(im3)
#         if im3[i] != 0x000000
#             p_[im1_[i]] = im3[i]
#         end
#     end

#     for i in eachindex(im4)
#         if im4[i] != 0x000000
#             p_[im2_[i]] = im4[i]
#         end
#     end

#     serialize("im/pkmn/$i/front_shiny.p",Palette(p))
# end



# for i in 1:151
#     im1 = getImage("images/battlers/back/normal/$i.png")

#     p = Set(unique(im1))
#     delete!(p,0x000000)

#     p = sort!(collect(p))

#     im1_ = transformImage(im1,Palette(p))

#     serialize("im/pkmn/$i/back.im",Image(im1_))
#     serialize("im/pkmn/$i/back_normal.p",Palette(p))

#     im3 = getImage("images/battlers/back/shiny/$i.png")

#     p_ = copy(p)

#     for i in eachindex(im3)
#         if im3[i] != 0x000000
#             p_[im1_[i]] = im3[i]
#         end
#     end

#     serialize("im/pkmn/$i/back_shiny.p",Palette(p))
# end

function replaceImage(dir::String)
    im = getImage(dir*".png")

    p = Set(unique(im)); delete!(p,0x000000); p = Palette(sort!(collect(p))); 

    im_ = transformImage(im,p)

    serialize(dir*".im",ImageP(im_,p))

    rm(dir*".png")
end

function replaceImages(dir::String)
    for file in readdir(dir)
        f = file[1:end-4]
        im = getImage(dir*"/"*f*".png")

        p = Set(unique(im)); delete!(p,0x000000); p = Palette(sort!(collect(p))); 

        im_ = transformImage(im,p)

        # serialize(dir*"/"*f*".im",Image(im_))
        # serialize(dir*"/"*f*".p",p)
        serialize(dir*"/"*f*".imp",ImageP(im_,p))

        rm(dir*"/"*f*".png")
    end
end

function replaceImage(dir::String,nh::Int,nw::Int,name::String,newname::String)
    im = getImage(dir*"/"*name*".png")

    dh,dw = size(im); dh = Int(dh/nh); dw = Int(dw/nw)

    for i in 1:nh
        for j in 1:nw
            imsub = im[dh*(i-1)+1:dh*i,dw*(j-1)+1:dw*j]

            psub = Set(unique(imsub)); delete!(psub,0x000000); psub = Palette(sort!(collect(psub))); 
        
            imsub_ = transformImage(imsub,psub)

            if all(isequal(0x00),imsub_)
                continue
            end

            serialize(dir*"/$newname"*"$(nw*(i-1)+j).imp",ImageP(imsub_,psub))
        end
    end

    rm(dir*"/"*name*".png")    
end

function replaceSprite(dir::String,nh::Int,nw::Int)
    im = getImage(dir*".png")

    dh,dw = size(im); dh = Int(dh/nh); dw = Int(dw/nw)

    p = Set(unique(im)); delete!(p,0x000000); p = Palette(sort!(collect(p))); 

    im_ = transformImage(im,p)

    for i in 1:nh
        for j in 1:nw
            imsub = im_[dh*(i-1)+1:dh*i,dw*(j-1)+1:dw*j]

            serialize(dir*"$(nw*(i-1)+j).im",imsub)
        end
    end

    serialize(dir*".p",p)

    rm(dir*".png")
end






# for i in 1:151
#     mkdir("im/pkmn/$i")
# end