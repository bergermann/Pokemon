#240x160

include("transformations.jl")
include("layers.jl")
include("sprites.jl")
include("map.jl")
include("menu.jl")
include("dialogue.jl")
include("battle.jl")
include("parser.jl")



function getTiles(tileset::String; s=Settings())
    tileset = mfb_rgb.(load(string("maps/",tileset,".png")))

    height::UInt16,width::UInt16  = size(tileset)

    if height%0x0010 != 0x0000 || width%0x0010 != 0x0000
        return error("Wrong tileset format.")
    end
    
    h_tiles = div(height,s.tilesize)
    w_tiles = div(width,s.tilesize)
    n_tiles = h_tiles*w_tiles

    d = Dict(zip(collect(0x0000:n_tiles),
                [tileset[0x0001+(h-1)*0x0010:h*0x0010,
                        0x001+(w-1)*0x0010:w*0x0010] for w in 0x0001:w_tiles,
                                                        h in 0x0001:h_tiles]))
    
    d[0xffff] = fill(0x010101,16,16)

    return d
end

function getTileMap(id::UInt8)
    tm = TileMap()

    for k in 1:5
        tm.map[k] = readdlm(joinpath("maps","$id","$(id)_$i.csv"),',',UInt16,'\n')
    end

    tm.collision = readdlm(joinpath("maps","$id","$(id)_$collision.csv"),
        ',',UInt16,'\n')
    tm.height =readdlm(joinpath("maps","$id","$(id)_$height.csv"),
        ',',UInt16,'\n')

    return tm
end










function drawGame!(game::GameState; s=Settings())
    if game.draw.battleintro
        drawBattleIntro!(game; s=s)
    end

    if game.draw.battle
        drawBattle!(game; s=s)
    end

    combineLayers!(game,game.im.L)

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