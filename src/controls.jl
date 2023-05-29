#using MiniFB

# include("maps.jl")





dirs = Base.ImmutableDict(
    1 => Position(-1,0),    #up
    2 => Position(1,0),     #down
    3 => Position(0,-1),    #left
    4 => Position(0,1),     #right
    0 => Position(0,0)      #null
)

dirsinv = Base.ImmutableDict(
    1 => 2,     #up
    2 => 1,     #down
    3 => 4,     #left
    4 => 3,     #right
    0 => 0      #null
)

dirsturnright = Base.ImmutableDict(
    1 => 4,     #up
    2 => 3,     #down
    3 => 1,     #left
    4 => 2,     #right
    0 => 0      #null
)

dirsturnleft = Base.ImmutableDict(
    1 => 3,     #up
    2 => 4,     #down
    3 => 2,     #left
    4 => 1,     #right
    0 => 0      #null
)



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

function finddir(input::Input)::Int
    if input.up
        return 1
    elseif input.down
        return 2
    elseif input.left
        return 3
    else
        return 4
    end
end





walkable::Vector{UInt16} = [0x0000,0x0005,0x00006,0x00007]
bikeable::Vector{UInt16} = [0x0000,0x0005,0x00006]
swimmable::Vector{UInt16} = [0x0002,0x0003]

function checkWalkable(game::GameState,movepos::Position)
    for i in 1:game.npcstatic.idx
        if isequal(game.npcstatic[i].pos,movepos)
            return false
        end
    end

    for i in 1:game.npcmove.idx
        if isequal(game.npcmove[i].pos,movepos)
            return false
        end
    end

    return (game.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable ||
        (0x14 <= game.map.tilemap.collision[movepos.h,movepos.w] <= 0x3b) ||
        (0xc8 <= game.map.tilemap.collision[movepos.h,movepos.w] <= 0xdb))
end

function updateMovePos!(game::GameState,dir::Int)
    game.movepos.h = game.pos.h+dirs[dir].h
    game.movepos.w = game.pos.w+dirs[dir].w
end

function resetMovePos!(game::GameState)
    game.movepos = posAdd(game.pos,dirs[game.direction])
end

function checkEncounter!(game::GameState)
    if !(game.map.tilemap.collision[game.pos.h,game.pos.w] ∈ 0xc8:0xdb)
        return
    end

    if rand(0x00:0xff) > 0x80
        return
    end

    game.callbacks[:movemain].active = true
    game.callbacks[:movemain].args = (game.direction,-1)

    initBattleWild!(game)
end

function moveMain!(game::GameState,dir::Int,type::Int)
    if type == -1
        moveStop!(game,dir)
    elseif type == 0
        moveTurn!(game,dir)
    elseif type == 1
        moveWalk!(game,dir)
    elseif type == 2
        moveRun!(game,dir)
    elseif type == 3
        moveWalkWall!(game,dir)
    end
end





function inputManager!(game::GameState,input::Input)
    if game.input.inputlock
        return
    elseif game.input.dialogue
        inputDialogue!(game,input)
        return
    elseif game.input.map
        inputMap!(game,input)
        return
    elseif game.input.menu.main
        inputMenu!(game,input)
        return
    elseif game.input.menu.pdex
        return
    elseif game.input.menu.pkmn
        inputMenuPkmn!(game::GameState,input::Input)
        return
    elseif game.input.menu.bags
        inputMenuBags!(game::GameState,input::Input)
        return
    elseif game.input.menu.pnav
        return
    elseif game.input.menu.self
        return
    elseif game.input.menu.save
        return
    elseif game.input.menu.optn
        return
    elseif game.input.battle
        inputBattle!(game,input)
        return
    end
end

function inputMap!(game::GameState,input::Input)
    if game.input.move
        inputMove!(game,input)
    end

    if game.input.move && input._start
        game.input.move = false
        game.input.map = false
        game.input.menu.main = true

        game.draw.menu1 = true

        drawMenu!(game)
        return
    end

    if game.input.move && input._A
        mapAction!(game)
    end
end

function inputMove!(game::GameState,input::Input)
    if !(input.up || input.down || input.left || input.right)
        if game.n.c[:movemain].c != 0
            game.callbacks[:movemain].active = true
            game.callbacks[:movemain].args = (game.direction,-1)
        end

        return
    end

    dir = finddir(input)
    
    updateMovePos!(game,dir)

    if !checkWalkable(game,game.movepos)
        if game.n.c[:movemain].c == 0
            game.callbacks[:movemain].active = true
            game.callbacks[:movemain].args = (game.direction,3)
        end

        return
    end

    game.n.c[:movemain].c = 0

    game.callbacks[:movemain].active = true
    game.input.move = false

    if !input.B
        if game.direction == dir
            game.callbacks[:movemain].args = (game.direction,1)
        else
            game.direction = dir
            game.callbacks[:movemain].args = (game.direction,0)
        end
    else
        game.direction = dir
        game.callbacks[:movemain].args = (game.direction,2)
    end
end

function inputMenu!(game::GameState,input::Input)
    if !input._input
        return
    end

    if input._down
        game.input.menu.select = (game.input.menu.select+0x01)%0x08
        game.im.sprites[:cursor].pos = P(40+(game.input.menu.select)*17,185)
    elseif input._up
        if game.input.menu.select == 0x00
            game.input.menu.select = 0x07
        else
            game.input.menu.select -= 0x01
        end

        game.im.sprites[:cursor].pos = P(40+(game.input.menu.select)*17,185)
    elseif input._A
        inputMenuSelector!(game)
    elseif (input._start || input._B)
        flushLayer!(game,:layer5)
        killSprite!(game,:cursor)

        game.input.move = true
        game.input.map = true
        game.input.menu.main = false
        game.input.menu.select = 0x01

        game.draw.menu1 = false
    end
end

function inputMenuSelector!(game::GameState)
    if game.input.menu.select == 0x00
        game.input.menu.pdex = true
        game.input.map = false
    elseif game.input.menu.select == 0x01
        game.input.map = false
        game.input.menu.main = false
        game.input.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuPkmnOpen!,(),stateMenuPkmnCtrls!,()); active=true,n=1)
    elseif game.input.menu.select == 0x02
        game.input.map = false
        game.input.menu.main = false
        game.input.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuBagsOpen!,(),stateMenuBagsCtrls!,()); active=true,n=1)
    elseif game.input.menu.select == 0x03
        game.input.menu.pnav = true
        game.input.map = false
    elseif game.input.menu.select == 0x04
        game.input.menu.self = true
        game.input.map = false
    elseif game.input.menu.select == 0x05
        game.input.menu.save = true
        game.input.map = false
    elseif game.input.menu.select == 0x06
        game.input.menu.optn = true
        game.input.map = false
    else
        game.input.move = true
        game.input.map = true
        game.input.menu.main = false
        game.input.menu.select = 0x01

        game.draw.menu1 = false

        flushLayer!(game,:layer5)
        killSprite!(game,:cursor)
    end
end

function inputMenuPkmn!(game::GameState,input::Input)
    if input._A
        if game.input.menu.menupkmn.select == game.trainer.pokemon.idx+1
            game.input.inputlock = true
            game.input.menu.pkmn = false
            game.input.menu.menupkmn.select = 1

            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateMenuPkmnClose!,(),stateMenuMainOpen!,()); active=true,n=1)

            return
        end
    elseif input._B
        game.input.inputlock = true
        game.input.menu.pkmn = false
        game.input.menu.menupkmn.select = 1

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateMenuPkmnClose!,(),stateMenuMainOpen!,()); active=true,n=1)

        return
    elseif input._down
        if game.input.menu.menupkmn.select == game.trainer.pokemon.idx+1
            switchSlot!(game,game.input.menu.menupkmn.select,1)
        else
            switchSlot!(game,game.input.menu.menupkmn.select,
                game.input.menu.menupkmn.select+1)
        end
    elseif input._up
        if game.input.menu.menupkmn.select == 1
            switchSlot!(game,1,game.trainer.pokemon.idx+1)
        else
            switchSlot!(game,game.input.menu.menupkmn.select,
                game.input.menu.menupkmn.select-1)
        end
    elseif input._left || input._right
        if game.input.menu.menupkmn.select == 1
            switchSlot!(game,1,2)
        else
            switchSlot!(game,game.input.menu.menupkmn.select,1)
        end
    end
end

function inputMenuBags!(game::GameState,input::Input)
    if input._A
        return
    elseif input._B
        game.input.inputlock = true
        game.input.menu.bags = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateMenuBagsClose!,(),stateMenuMainOpen!,()); active=true,n=1)

        return
    elseif input._down
        if getSelect(game) == getAmountItems(game)+1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] = 1
            game.input.menu.menubags.slot = 1

            setVisibleItems!(game)

            flushLayer!(game,:layer2)
            drawInventoryText!(game)
        elseif game.input.menu.menubags.slot == 6 &&
                getSelect(game)+2 < getAmountItems(game)
            
            game.input.menu.menubags.select[game.input.menu.menubags.bag] += 1

            game.input.menu.menubags.vis[1:7,:] = game.input.menu.menubags.vis[2:8,:]
            game.input.menu.menubags.vis[8,:] = getSelect(game)+2 < getAmountItems(game) ?
                getInvSlot(game,game.input.menu.menubags.bag,getSelect(game)+2) : (-1,0)

            drawSlotSwitchDown!(game)
        else
            game.input.menu.menubags.slot += 1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] += 1
        end
        
        setPos!(game.im.sprites[:cursor].pos,24+22+15*game.input.menu.menubags.slot,16+114)
    elseif input._up
        if game.input.menu.menubags.select == 1
            game.input.menu.menubags.select = 8
        else
            game.input.menu.menubags.select -= 1
        end

        setPos!(game.im.sprites[:cursor].pos,24+24+12*game.input.menu.menubags.select,16+112)
    elseif input._left
        if game.input.menu.menubags.bag == 1
            game.input.menu.menubags.bag = 5
        else
            game.input.menu.menubags.bag -= 1
        end
        
        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    elseif input._right
        if game.input.menu.menubags.bag == 5
            game.input.menu.menubags.bag = 1
        else
            game.input.menu.menubags.bag += 1
        end
        
        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    end
end

function inputDialogue!(game::GameState,input::Input)
    if !(input._A || input._B || input._down)
        return
    end

    if game.dialogue.n < length(game.dialogue.str)
        game.dialogue.n += 1
        
        drawDialogueUpdate!(game)
    else
        game.dialogue.d = false
        game.dialogue.n = 1
        game.input.move = true
        game.input.map = true
        game.input.dialogue = false
        game.input.npclock = false
        
        flushLayer!(game,:textbox,P(24+112,16),P(48,240))
        # flushLayer!(game,:textbox)
    end
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
