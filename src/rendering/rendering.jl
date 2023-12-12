#240x160

include("transformations.jl")
include("layers.jl")
include("sprites.jl")
include("tiles.jl")
include("map.jl")
include("menu.jl")
include("dialogue.jl")
include("battle.jl")
include("parser.jl")









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