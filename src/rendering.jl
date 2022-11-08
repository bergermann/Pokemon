#240x160
using MiniFB, Images, DelimitedFiles

include("parser.jl")

struct Settings
    width::UInt16
    height::UInt16
    fps::Float16

    Nh::UInt8
    Nw::UInt8
    tilesize::UInt8

    offseth::UInt16
    offsetw::UInt16

    function Settings()
        new(0x00f0,0x00a0,60.,0x0d,0x11,0x10,0x0000,0x0000)
    end

    function Settings(width::UInt16,height::UInt16,fps::Float16,
            Nh::UInt8,Nw::UInt8,tilesize::UInt8,offseth::UInt16,offsetw::UInt16)
        new(width,height,fps,Nh,Nw,tilesize,offseth,offsetw)
    end
end

mutable struct Layers
    water::Matrix{UInt32}
    background1::Matrix{UInt32}
    background2::Matrix{UInt32}
    spriteslow::Matrix{UInt32}
    spriteshigh::Matrix{UInt32}
    foreground1::Matrix{UInt32}
    foreground2::Matrix{UInt32}
    weather::Matrix{UInt32}

    textbox::Matrix{UInt32}

    menu::Matrix{UInt32}

    menu1::Matrix{UInt32}
    menu2::Matrix{UInt32}
    menu3::Matrix{UInt32}
    
    #text::Matrix{UInt32}
    

    function Layers(; s::Settings=Settings())
        new([zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
            UInt16(s.Nw)*UInt16(s.tilesize)) for _ in eachindex(fieldnames(Layers))]...)
    end
end



function drawLayers!(game::GameState,n_frame::UInt; s=Settings())
    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    for k in game.im.draw
        if !(k == :water || k == :background1 || k == :background2 ||
                k == :foreground1 || k == :foreground2)
            continue
        end

        for i in 1:s.Nh, j in 1:s.Nw
            getfield(game.im.layers,k)[1+(i-1)*s.tilesize:i*s.tilesize,
                1+(j-1)*s.tilesize:j*s.tilesize] = game.map.tiles[
                    getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                    game.pos.w+j-dw-1]]
        end
    end
end

function combineLayers!(game::GameState; s::Settings=Settings())
    for k in game.im.draw
        ind = getfield(game.im.layers,k) .!= 0x000000

        game.im.layer[ind] = getfield(game.im.layers,k)[ind]
    end
end










function getTiles(tileset::String; s=Settings())
    tileset = mfb_rgb.(load(string("maps/",tileset,".png")))

    height::UInt16,width::UInt16  = size(tileset)

    if height%0x0010 != 0x0000 || width%0x0010 != 0x0000
        return error("Wrong tileset format.")
    end

    
    h_tiles = div(height,s.tilesize)
    w_tiles = div(width,s.tilesize)
    n_tiles = h_tiles*w_tiles

    return Dict(zip(collect(0x0000:n_tiles),
                [tileset[0x0001+(h-1)*0x0010:h*0x0010,
                        0x001+(w-1)*0x0010:w*0x0010] for w in 0x0001:w_tiles,
                                                        h in 0x0001:h_tiles]))
end

function getTileMap(dir::String,key::Vector{Symbol}; s=Settings())
    tm = TileMap(; s=s)

    for k in key
        setfield!(tm,k,readdlm(string("maps/",dir,"/",k,".csv"),',',UInt16,'\n'))
    end

    return tm
end










function getSpriteMain(set::String; s=Settings())
    spriteset = mfb_rgb.(load("sprites/$set.png"))

    key::Vector{Tuple{Int,Int,Int,Int,Int,String}} = [
        (1,1,32,16,3,"walkdown"),
        (1,17,32,16,3,"walkup"),
        (1,33,32,16,3,"walkleft"),

        (97,1,32,16,3,"rundown"),
        (97,17,32,16,3,"runup"),
        (97,33,32,16,3,"runleft"),

        (1,49,32,32,9,"bikedown"),
        (1,81,32,32,9,"bikeup"),
        (1,113,32,32,9,"bikeleft"),

        (1,145,32,32,2,"sitdown"),
        (1,177,32,32,2,"situp"),
        (1,209,32,32,2,"sitleft"),

        (97,145,32,32,2,"waterdown"),
        (97,177,32,32,2,"waterup"),
        (97,209,32,32,2,"waterleft"),

        (1,241,32,32,5,"pokeball"),
    
        (1,273,32,32,4,"fishdown"),
        (1,305,32,32,4,"fishup"),
        (1,337,32,32,4,"fishleft"),

        (1,369,32,32,1,"surfdown"),
        (1,401,32,32,1,"surfup"),
        (1,433,32,32,1,"surfleft"),

        (33,369,32,32,1,"divedown"),
        (33,401,32,32,1,"diveup"),
        (33,433,32,32,1,"diveleft"),

        (1,465,32,32,1,"flypkmn"),
        (1,497,64,64,4,"battlesprites"),
        (97,401,64,64,1,"battler")
    ]

    d =  Dict{String,Vector{Matrix{UInt32}}}(zip([key[i][6] for i in eachindex(key)],
        [[spriteset[key[i][1]+(j-1)*key[i][3]:key[i][1]+j*key[i][3]-1,
            key[i][2]:key[i][2]+key[i][4]-1] for j in 1:key[i][5]] for i in eachindex(key)]))
    
    d["walkright"] = reverse.(d["walkleft"]; dims=2)
    d["runright"] = reverse.(d["runleft"]; dims=2)
    d["bikeright"] = reverse.(d["bikeleft"]; dims=2)
    d["sitright"] = reverse.(d["sitleft"]; dims=2)
    d["waterright"] = reverse.(d["waterleft"]; dims=2)
    d["fishright"] = reverse.(d["fishleft"]; dims=2)
    d["surfright"] = reverse.(d["surfleft"]; dims=2)
    d["diveright"] = reverse.(d["diveleft"]; dims=2)

    return d
end
    
function drawSpriteMain!(layers::Layers,game::GameState; s=Settings())
    #fix typestability
    S = game.trainer.sprite[string(game.transport,game.direction)][game.spritecycle]

    height,width = size(S)./s.tilesize
    dh,dw = Int((s.Nh-1)/2),Int((s.Nw-1)/2)

    layers.spriteshigh .*= 0x000000
    layers.spriteslow .*= 0x000000

    layers.spriteshigh[(dh-1)*s.tilesize+1+game.spriteoffset.h:dh*s.tilesize+game.spriteoffset.h,
        Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
        S[1:Int(s.tilesize*height/2),:]

    layers.spriteshigh[dh*s.tilesize+1+game.spriteoffset.h:(dh+1)*s.tilesize+game.spriteoffset.h,
        Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
        S[Int(s.tilesize*height/2+1):end,:]
end

function drawSpriteMain!(game::GameState; s=Settings())
    #fix typestability
    S = game.trainer.sprite[string(game.transport,game.direction)][game.spritecycle]

    height,width = size(S)./s.tilesize
    dh,dw = Int((s.Nh-1)/2),Int((s.Nw-1)/2)

    game.im.layers.spriteshigh .*= 0x000000
    game.im.layers.spriteslow .*= 0x000000

    game.im.layers.spriteshigh[(dh-1)*s.tilesize+1+game.spriteoffset.h:dh*s.tilesize+game.spriteoffset.h,
        Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
        S[1:Int(s.tilesize*height/2),:]

    game.im.layers.spriteshigh[dh*s.tilesize+1+game.spriteoffset.h:(dh+1)*s.tilesize+game.spriteoffset.h,
        Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
        S[Int(s.tilesize*height/2+1):end,:]
end







function getDialogueBox(set::String; s=Settings())
    boxes = mfb_rgb.(load("im/$set.png"))

    key::Vector{Tuple{Int,Int,UInt8}} = [
        (1,48,0x01),
        (49,48,0x02)
    ]

    return Dict{UInt8,Matrix{UInt32}}(
        zip([k[3] for k in key],[boxes[k[1]:k[1]+k[2]-1,:] for k in key])
    )
end

function drawDialogue!(game::GameState,str::String)
    game.im.layers.textbox[end-48-24+1:end-24,16+1:end-16] = game.im.diabox[game.options.diabox]
    drawText!(game,:textbox,str,UInt(2),Position(144,32))
end







function getFrames(set::String)
    frames = mfb_rgb.(load("im/$set.png"))

    return Dict{Int64,Vector{Matrix{UInt32}}}(zip(collect(1:30),[
        [frames[1+(i-1)*8+(rows-1)*8:i*8+(rows-1)*8,
        1+(j-1)*8+(cols-1)*8:j*8+(cols-1)*8] for j in 1:3, i in 1:3][:]
            for cols in 1:10, rows in 1:3
        ])
    )
end

function constructFrame(game::GameState,height::UInt,width::UInt)
    frame = ones(UInt32,height*8,width*8)*game.im.frames[1][5][1]

    if height == 1 || width == 1
        return error("Frame is too small.")
    end

    for i in 1:height, j in 1:width
        if i != 1 && i != height && j != 1 && j != width
            f = 5
        elseif i == 1 && j == 1
            f = 1
        elseif i == 1 && j != 1 && j != width
            f = 2
        elseif i == 1 && j == width
            f = 3
        elseif i != 1 && i != height && j == 1
            f = 4
        elseif i != 1 && i != height && j == width
            f = 6
        elseif i == height && j == 1
            f = 7
        elseif i == height && j != 1 && j != width
            f = 8
        else
            f = 9
        end

        frame[1+(i-1)*8:i*8,1+(j-1)*8:j*8] = game.im.frames[game.options.frame][f]
    end

    return frame
end

function drawFrame!(game::GameState,height::UInt,width::UInt,offset::Position)
    game.im.layers.menu[1+offset.h:height*8+offset.h,
        1+offset.w:width*8+offset.w] = constructFrame(game,height,width)
end

function drawMenu!(game::GameState)
    drawFrame!(game,UInt(20),UInt(10),Position(24,176))
    drawText!(game,:menu,"POKEDEX\nPOKEMON\nBEUTEL\nPOKENAV\
        \n$(game.trainer.name)\nSICHERN\nOPTION\nBEENDEN",
        UInt(2),Position(38,194); lineoffset=2)
        
    drawText!(game,:menu,"▷",UInt(2),Position(38+(game.menu.select)*17,186))
end






function startWindow(settings::Settings)
    window = mfb_open_ex("Pokemon Test",settings.width,settings.height,
                MiniFB.WF_RESIZABLE)
    mfb_set_target_fps(settings.fps)
    
    
    buffer = zeros(UInt32,settings.width,settings.height)

    return window, buffer
end



;