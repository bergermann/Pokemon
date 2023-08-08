using Images, ImageIO
using Serialization
using MiniFB

# const Image = Matrix{UInt8}

# const Palette{N} = NTuple{N,UInt32}

# mutable struct ImageP
#     im::Image
#     palette::Palette
# end


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

function transformImage(image::Matrix{UInt32},palette::Pokemon.Palette)
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
    im = Pokemon.getImage(dir*".png")

    p = Set(unique(im)); delete!(p,0x000000); p = Pokemon.Palette(sort!(collect(p))); 

    im_ = transformImage(im,p)

    serialize(dir*".imp",Pokemon.ImageP(im_,p))

    rm(dir*".png")
end

function replaceImages(dir::String)
    for file in readdir(dir)
        f = file[1:end-4]
        im = Pokemon.getImage(dir*"/"*f*".png")

        p = Set(unique(im)); delete!(p,0x000000);
        p = Pokemon.Palette(sort!(collect(p))); 

        im_ = transformImage(im,p)

        # serialize(dir*"/"*f*".im",Image(im_))
        # serialize(dir*"/"*f*".p",p)
        serialize(dir*"/"*f*".imp",Pokemon.ImageP(im_,p))

        rm(dir*"/"*f*".png")
    end
end

function replaceImage(dir::String,nh::Int,nw::Int,name::String,newname::String)
    im = Pokemon.getImage(dir*"/"*name*".png")

    dh,dw = size(im); dh = Int(dh/nh); dw = Int(dw/nw)

    for i in 1:nh
        for j in 1:nw
            imsub = im[dh*(i-1)+1:dh*i,dw*(j-1)+1:dw*j]

            psub = Set(unique(imsub)); delete!(psub,0x000000); 
            psub = Pokemon.Palette(sort!(collect(psub))); 
        
            imsub_ = transformImage(imsub,psub)

            if all(isequal(0x00),imsub_)
                continue
            end

            serialize(dir*"/$newname"*"$(nw*(i-1)+j).imp",Pokemon.ImageP(imsub_,psub))
        end
    end

    rm(dir*"/"*name*".png")    
end

function replaceSprite(dir::String,nh::Int,nw::Int)
    im = Pokemon.getImage(dir*".png")

    dh,dw = size(im); dh = Int(dh/nh); dw = Int(dw/nw)

    p = Set(unique(im)); delete!(p,0x000000); p = Pokemon.Palette(sort!(collect(p))); 

    im_ = transformImage(im,p)

    for i in 1:nh
        for j in 1:nw
            imsub = im_[dh*(i-1)+1:dh*i,dw*(j-1)+1:dw*j]

            serialize(dir*"$(nw*(i-1)+j).im",Pokemon.Image(imsub))
        end
    end

    serialize(dir*".p",p)

    rm(dir*".png")
end

function replaceSprites(dir::String,nh::Int,nw::Int)
    for file in readdir(dir)
        d = joinpath(dir,file)

        f = mkdir(joinpath(dir,file[1:end-3]))

        im = getImage(d)

        dh,dw = size(im); dh = Int(dh/nh); dw = Int(dw/nw)

        p = Set(unique(im)); delete!(p,0x000000);
        p = Pokemon.Palette(sort!(collect(p))); 

        im_ = transformImage(im,p)

        for i in 1:nh
            for j in 1:nw
                imsub = im_[dh*(i-1)+1:dh*i,dw*(j-1)+1:dw*j]

                serialize(joinpath(f,"$(nw*(i-1)+j).im"),Pokemon.Image(imsub))
            end
        end

        serialize(joinpath(f,"palette.p"),p)

        rm(d)
    end
end







# for i in 1:151
#     mkdir("im/pkmn/$i")
# end
# for dir in readdir("im/sprites/npcs")
#     path = joinpath("im/sprites/npcs",dir)

#     for file in readdir(path)
#         if occursin(".im",file)
#             im = deserialize(joinpath(path,file))
#             im_ = Pokemon.Image(im)
        
#             serialize(joinpath(path,file), im)
#         else
#             p = deserialize(joinpath(path,file))
#             p_ = Pokemon.Palette(p)
#         end
#     end 
# end

# for dir in readdir("im/sprites/npcs")
#     path = joinpath("im/sprites/npcs",dir)

#     for file in readdir(path)
#         if occursin(".p",file)
#             continue
#         end

#         mv(joinpath(path,file),joinpath(path,"_"*file))
#     end

#     for file in readdir(path)
#         if occursin(".p",file)
#             continue
#         end

#         if occursin('1',file)
#             mv(joinpath(path,file),joinpath(path,"2.im"))
#         elseif occursin('2',file)
#             mv(joinpath(path,file),joinpath(path,"1.im"))
#         elseif occursin('3',file)
#             mv(joinpath(path,file),joinpath(path,"3.im"))
#         elseif occursin('4',file)
#             mv(joinpath(path,file),joinpath(path,"5.im"))
#         elseif occursin('5',file)
#             mv(joinpath(path,file),joinpath(path,"8.im"))
#         elseif occursin('6',file)
#             mv(joinpath(path,file),joinpath(path,"4.im"))
#         elseif occursin('7',file)
#             mv(joinpath(path,file),joinpath(path,"7.im"))
#         elseif occursin('8',file)
#             mv(joinpath(path,file),joinpath(path,"6.im"))
#         elseif occursin('9',file)
#             mv(joinpath(path,file),joinpath(path,"9.im"))
#         end
#     end
# end

# for dir in readdir("im/sprites/npcs")
#     p = deserialize(joinpath("im/sprites/npcs",dir,"palette.p"))
#     p_ = collect(UInt32,p)

#     serialize(joinpath("im/sprites/npcs",dir,"palette.p"),Pokemon.Palette(p_))
# end