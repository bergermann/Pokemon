
include("battle.jl")
include("movement.jl")
include("menu.jl")

function animEmpty!(game::GameState)
    return
end





function fadeIn!(game::GameState,len::Int)
    if game.n[:fadein].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),UInt8(len),)
    elseif game.n[:fadein].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(len-game.n[:fadein].c),)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        
        killCC!(game,:fadein)

        return
    end

    game.n[:fadein].c += 1

    return
end

function fadeOut!(game::GameState,len::Int)
    if game.n[:fadeout].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),0x00,)
    elseif game.n[:fadeout].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(game.n[:fadeout].c),)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        
        killCC!(game,:fadeout)

        return
    end

    game.n[:fadeout].c += 1

    return
end

function sceneTransition!(game::GameState, # pause >= 1!
        (len,pause,state1,state2)::Tuple{Int,Int,Callback,Callback})
    
    if game.n[:scenet].c <= len
        game.im.l.color[4] = 1.0 - game.n[:scenet].c/len
    elseif game.n[:scenet].c == len+1
        Base.GC.gc()

        # evalCallback(game,state1)
        state1.func(game,state1.args...)
    elseif len+pause+1 <= game.n[:scenet].c <= 2*len+pause
        game.im.l.color[4] = 1.0 - (2*len+pause-game.n[:scenet].c)/len
    elseif game.n[:scenet].c == 2*len+pause+1
        game.im.l.color[4] = 1.0

        # evalCallback(game,state2)
        state2.func(game,state2.args...)

        killCC!(game,:scenet)

        return
    end
   
    game.n[:scenet].c += 1

    return
end

# function sceneTransition!(game::GameState,len::Int,pause::Int,  # pause >= 1!
#         (len,pause,state1,state2,fade1,fade2)::Tuple{Int,Int,Callback,Callback,Function,Function})
    
#     if game.n[:scenet].c == 1
#         game.im.postprocess.args = (UInt8(len),0x01,)
#     elseif game.n[:scenet].c <= len
#         game.im.postprocess.args = (UInt8(len),UInt8(game.n[:scenet].c),)
#     elseif game.n[:scenet].c == len+1
#         Base.GC.gc()

#         state1(game,state1args...)
#     elseif len+pause+1 <= game.n[:scenet].c <= 2*len+pause
#         game.im.postprocess.args = (UInt8(len),UInt8(2*len+pause-game.n[:scenet].c),)
#     elseif game.n[:scenet].c == 2*len+pause+1
#         state2(game,state2args...)

#         killCC!(game,:scenet)

#         return
#     end
   
#     game.n[:scenet].c += 1

#     return
# end


