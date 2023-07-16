#240x160

include("layers.jl")
include("sprites.jl")
include("map.jl")
include("menu.jl")
include("dialogue.jl")
include("battle.jl")



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

function getImage(dir::String; attachsize::Bool=false)
    im = mfb_rgb.(load(dir))

    if attachsize
        return im, P(size(im)...)
    else
        return im
    end
end

function getGridImage(dir::String,rows::Int,columns::Int; attachsize::Bool=true)
    im = mfb_rgb.(load(dir))
    height, width = size(im)

    dh = div(height,rows); dw = div(width,columns)

    if attachsize
        return [(im[1+(h-1)*dh:h*dh,1+(w-1)*dw:w*dw],P(dh,dw)) 
            for w in 1:columns, h in 1:rows]
    else
        return [im[1+(h-1)*dh:h*dh,1+(w-1)*dw:w*dw] 
            for w in 1:columns, h in 1:rows]
    end
end

function getGridImage(dir::String,tilesize::Int; attachsize::Bool=true)
    im = mfb_rgb.(load(dir))
    height, width = size(im)

    nh = div(height,tilesize); nw = div(width,tilesize)

    if attachsize
        return [(im[1+(h-1)*tilesize:h*tilesize,1+(w-1)*tilesize:w*tilesize],
            P(tilesize,tilesize)) for w in 1:nw, h in 1:nh]
    else
        return [im[1+(h-1)*tilesize:h*tilesize,1+(w-1)*tilesize:w*tilesize] 
            for w in 1:nw, h in 1:nh]
    end
end













function drawGame!(game::GameState; s=Settings())
    if game.draw.battleintro
        drawBattleIntro!(game; s=s)
    end

    if game.draw.battle
        drawBattle!(game; s=s)
    end

    combineLayers!(game,game.im.L; s=s)

    if game.im.weather.active
        game.im.weather.func(game.im.layer,game.im.weather.args...)
    end

    if game.im.postprocess.active
        game.im.postprocess.func(game.im.layer,game.im.postprocess.args...)
    end
end





function startWindow(settings::Settings)
    window = mfb_open_ex("Pokemon Test",settings.width,settings.height,
                MiniFB.WF_RESIZABLE)
    mfb_set_target_fps(settings.fps)
    
    
    buffer = zeros(UInt32,settings.width,settings.height)

    return window, buffer
end

function resizer(window,w,h)
    s = round(minimum([w/240,h/160]); sigdigits=2)
    mfb_set_viewport(window,0,0,round(Int,240*s),round(Int,160*s))

    return nothing
end

function writeToBuffer!(buffer::Matrix{UInt32},game::GameState; s=Settings())
    @inbounds for i in eachindex(buffer)
        buffer[i] = game.im.layer[
            24+1+div(i-1,s.width)+game.screenoffset.h,
            16+1+(i-1)%s.width+game.screenoffset.w
        ]
    end
end
;