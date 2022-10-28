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
    text::Matrix{UInt32}
    
    menu::Matrix{UInt32}

    function Layers(; s::Settings=Settings())
        new([zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
            UInt16(s.Nw)*UInt16(s.tilesize)) for _ in eachindex(fieldnames(Layers))]...)
    end
end

function combineLayers(layers::Layers,key::Vector{Symbol};
        s::Settings=Settings())
    L = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
        UInt16(s.Nw)*UInt16(s.tilesize))

    for k in key
        ind = getfield(layers,k) .!= 0x000000
        L[ind] = getfield(layers,k)[ind]
    end

    return L
end

function drawLayers!(layers::Layers,key::Vector{Symbol},game::GameState;
    s=Settings())

    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    for k in key
        for i in 1:s.Nh, j in 1:s.Nw
            getfield(layers,k)[1+(i-1)*s.tilesize:i*s.tilesize,
                1+(j-1)*s.tilesize:j*s.tilesize] = game.map.tiles[
                    getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                    game.pos.w+j-dw-1]]
        end
    end
end

function updateLayers!(layers::Layers,key::Vector{Symbol},game::GameState,
        direction::NamedTuple{(:h,:w),Tuple{Int8,Int8}}; s=Settings())

    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    for k in key
        if direction.h == 1
            getfield(layers,k)[1:end-s.tilesize,:] = getfield(layers,k)[1+s.tilesize:end,:]

            for i in 1:s.Nw
                getfield(layers,k)[end-s.tilesize+1:end,1+(i-1)*s.tilesize:i*s.tilesize] = 
                    game.map.tiles[getfield(game.map.tilemap,k)[game.pos.h+dh,
                    game.pos.w+i-dw-1]]
            end
        elseif direction.h == -1
            getfield(layers,k)[1+s.tilesize:end,:] = getfield(layers,k)[1:end-s.tilesize,:]
            
            for i in 1:s.Nw
                getfield(layers,k)[1:s.tilesize,1+(i-1)*s.tilesize:i*s.tilesize] = 
                    game.map.tiles[getfield(game.map.tilemap,k)[game.pos.h-dh,
                    game.pos.w+i-dw-1]]
            end
        end

        if direction.w == 1
            return
        elseif direction.w == -1
            return
        end
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

    layers.spriteshigh .*= 0x00000
    layers.spriteslow .*= 0x00000

    layers.spriteshigh[(dh-1)*s.tilesize+1+game.spriteoffset.h:dh*s.tilesize+game.spriteoffset.h,
        Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
        S[1:Int(s.tilesize*height/2),:]

    layers.spriteshigh[dh*s.tilesize+1+game.spriteoffset.h:(dh+1)*s.tilesize+game.spriteoffset.h,
        Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
        S[Int(s.tilesize*height/2+1):end,:]
end







function startWindow(settings::Settings)
    window = mfb_open_ex("Pokemon Test",settings.width,settings.height,
                MiniFB.WF_RESIZABLE)
    mfb_set_target_fps(settings.fps)
    
    
    buffer = zeros(UInt32,settings.width,settings.height)

    return window, buffer
end



;