#using MiniFB

include("input/inputgeneral.jl")
include("input/inputmap.jl")
include("input/inputmenu.jl")
include("input/inputpkmn.jl")
include("input/inputmenu.jl")



# FIX: move to somewhere sensible
mapid = Base.ImmutableDict(
    0x00 => map0,
    0x01 => map1
)


function onpress(window, button, mod, isPressed)::Cvoid
    global input

    if Bool(isPressed)
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,:input,true)
            setfield!(input,:_input,true)
            setfield!(input,c,true)
            setfield!(input,get(_ctrls,button,:null),true)
        end
    else
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,:input,false)
            setfield!(input,:input_,true)
            setfield!(input,c,false)
            setfield!(input,get(ctrls_,button,:null),true)
        end
    end

    return nothing
end

function resetInput!(input::Input)
    input._input    = false
    input.input_    = false
    input._A        = false
    input.A_        = false
    input._B        = false
    input.B_        = false
    input._L        = false
    input.L_        = false
    input._R        = false
    input.R_        = false
    input._up       = false
    input.up_       = false
    input._down     = false
    input.down_     = false
    input._left     = false
    input.left_     = false
    input._right    = false
    input.right_    = false
    input._start    = false
    input.start_    = false
    input._select   = false
    input.select_   = false
end







function inputBattle!(game::GameState,input::Input)
    if game.input.battled
        if input._A || input._B || input._down
            inputBattleDialogue!(game::GameState,input::Input)
        end

        return
    end

    if game.input.battle1
        if input._A
            inputBattleMenuSelector!(game::GameState)
            return
        end

        if input._B
            game.input.battle1menu.select = 3
            return
        end

        if input._up
            game.input.battle1menu.select -= 2
        elseif input._down
            game.input.battle1menu.select += 2
        elseif input._left
            if game.input.battle1menu.select%2 == 0
                game.input.battle1menu.select += 1
            else
                game.input.battle1menu.select -= 1
            end
        elseif input._right
            if game.input.battle1menu.select%2 == 1
                game.input.battle1menu.select -= 1
            else
                game.input.battle1menu.select += 1
            end
        end

        if game.input.battle1menu.select < 0
            game.input.battle1menu.select += 4
        end

        game.input.battle1menu.select %= 4

        game.im.sprites[:cursor1].pos.h = 146+div(game.input.battle1menu.select,2)*16
        game.im.sprites[:cursor1].pos.w = 136+(game.input.battle1menu.select%2)*58

        return
    end

    if game.input.battle2
        if game.input.battle1menu.select < 0
            game.input.battle1menu.select += 4
        end

        game.input.battle1menu.select %= 4

        if input._A
            inputBattleAttackSelector!(game::GameState)
            return
        end

        if input._B
            game.input.battle1 = true
            game.input.battle2 = false
    
            game.draw.battle1 = true
            game.draw.battle2 = false

            game.im.sprites[:cursor1].active = true
            game.im.sprites[:cursor2].active = false

            flushLayer!(game,:layer4,Position(24+1+112,16+1),Position(48,240))
            flushLayer!(game,:layer5,Position(24+1+112,16+1),Position(48,240))

            return
        end

        if input._up
            if div(game.input.battle2menu.select,2) == 0
                game.input.battle2menu.select += 2
            else
                game.input.battle2menu.select -= 2
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 2
            end
        elseif input._down
            if div(game.input.battle2menu.select,2) == 0
                game.input.battle2menu.select += 2
            else
                game.input.battle2menu.select -= 2
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 2
            end
        elseif input._left
            if game.input.battle2menu.select%2 == 0
                game.input.battle2menu.select += 1
            else
                game.input.battle2menu.select -= 1
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 1
            end
        elseif input._right
            if game.input.battle2menu.select%2 == 1
                game.input.battle2menu.select -= 1
            else
                game.input.battle2menu.select += 1
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 1
            end
        end

        if game.input.battle1menu.select < 0
            game.input.battle1menu.select += 4
        end

        game.input.battle1menu.select %= 4

        game.im.sprites[:cursor2].pos.h = 146+div(game.input.battle2menu.select,2)*16
        game.im.sprites[:cursor2].pos.w = 24+(game.input.battle2menu.select%2)*64

        return
    end
end

function inputBattleDialogue!(game::GameState,input::Input)
    if input._A || input._B || input._down
        if game.dialogue.n < length(game.dialogue.str)
            game.dialogue.n += 0x01
        else
            game.dialogue.d = false
            game.dialogue.n = 1
            game.input.battled = false
            
            game.draw.battled = false

            game.dialogue.callback.func(game,game.dialogue.callback.args...)
        end
        
        flushLayer!(game,:layer3,Position(24+1+120,24+1),Position(32,208),0x68a0a0)
    end
end

function inputBattleMenuSelector!(game::GameState)
    if game.input.battle1menu.select == 0
        game.input.battle1 = false
        game.input.battle2 = true

        game.draw.battle1 = false
        game.draw.battle2 = true

        game.im.sprites[:cursor1].active = false
        game.im.sprites[:cursor2].active = true    
                
        flushLayer!(game,:layer4,Position(24+1+112,16+1),Position(48,240),
            0x4a4252)
    elseif game.input.battle1menu.select == 1
        return
    elseif game.input.battle1menu.select == 2
        return
    else
        stateBattleFlee!(game)
    end
end

function inputBattleAttackSelector!(game::GameState)
    if !checkAttack!(game)
        return
    end

    stateBattleAttackSelected!(game)
end




function changeMap!(game::GameState,exit::Tuple{UInt8,Position})
    game.map = mapid[exit[1]]
    game.pos = posAdd(game.pos,exit[2])
    drawMap!(game)
    # popall!(game.sp)
    # loadSpritesNPCs!(game)
end

function checkMapChange!(game::GameState)
    if game.map.tilemap.collision[game.pos.h,game.pos.w] ∈ 0x14:0x3b
        changeMap!(game,
            game.map.exits[game.map.tilemap.collision[game.pos.h,game.pos.w]-19])
    end
end

function mapAction!(game::GameState)
    b, npc = checkTileNPC(game)

    if b
        if npc.dialogue == 0    # FIX
            return
        end

        game.input.npclock = true
        game.input.map = false
        game.input.move = false
        game.input.dialogue = true
        game.dialogue.n = 1
        game.dialogue.str = game.map.str[npc.dialogue:npc.dialogue+npc.dialoguelen-1]

        drawDialogue!(game)

        return
    end

    tile = game.map.tilemap.collision[game.movepos.h,game.movepos.w]

    if tile ∈ [0x0000,0x0001,0x0005,0x0006,0x0007]
        return
    elseif 0x003c <= tile <= 0x004f
        game.input.npclock = true
        game.input.map = false
        game.input.move = false
        game.input.dialogue = true
        game.dialogue.str = game.map.str[tile-59]

        drawDialogue!(game)
    end
end





function updateGame!(game::GameState,input::Input; s=Settings())
    inputManager!(game,input)

    if game.overworld
        checkProximityNPCs!(game)
        sortHorizontal!(game.im.sprites)

        manageNPCs!(game)

        checkMapChange!(game)
    end

    for i in 1:game.callbacks.idx
        if game.callbacks[i].active
            game.callbacks[i].func(game,game.callbacks[i].args...)
        end
    end

end
