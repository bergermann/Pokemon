#using MiniFB

include("maps.jl")





mutable struct Input
    input::Bool
    _input::Bool
    input_::Bool

    A::Bool
    _A::Bool
    A_::Bool
    B::Bool
    _B::Bool
    B_::Bool

    L::Bool
    _L::Bool
    L_::Bool
    R::Bool
    _R::Bool
    R_::Bool

    up::Bool
    _up::Bool
    up_::Bool
    down::Bool
    _down::Bool
    down_::Bool
    left::Bool
    _left::Bool
    left_::Bool
    right::Bool
    _right::Bool
    right_::Bool

    start::Bool
    _start::Bool
    start_::Bool
    select::Bool
    _select::Bool
    select_::Bool

    function Input()
        new([false for _ in fieldnames(Input)]...)
    end
end

ctrls = Base.ImmutableDict(
    MiniFB.KB_KEY_SPACE => :A,
    MiniFB.KB_KEY_ENTER => :A,

    MiniFB.KB_KEY_LEFT_CONTROL => :B,
    MiniFB.KB_KEY_LEFT_SHIFT => :B,
    MiniFB.KB_KEY_BACKSPACE => :B,

    MiniFB.KB_KEY_Q => :L,

    MiniFB.KB_KEY_E => :R,

    MiniFB.KB_KEY_W => :up,
    MiniFB.KB_KEY_UP => :up,

    MiniFB.KB_KEY_S => :down,
    MiniFB.KB_KEY_DOWN => :down,

    MiniFB.KB_KEY_A => :left,
    MiniFB.KB_KEY_LEFT => :left,

    MiniFB.KB_KEY_D => :right,
    MiniFB.KB_KEY_RIGHT => :right,

    MiniFB.KB_KEY_X => :start,

    MiniFB.KB_KEY_Y => :select,
)

_ctrls = Base.ImmutableDict(
    MiniFB.KB_KEY_SPACE => :_A,
    MiniFB.KB_KEY_ENTER => :_A,

    MiniFB.KB_KEY_LEFT_CONTROL => :_B,
    MiniFB.KB_KEY_LEFT_SHIFT => :_B,
    MiniFB.KB_KEY_BACKSPACE => :_B,

    MiniFB.KB_KEY_Q => :_L,

    MiniFB.KB_KEY_E => :_R,

    MiniFB.KB_KEY_W => :_up,
    MiniFB.KB_KEY_UP => :_up,

    MiniFB.KB_KEY_S => :_down,
    MiniFB.KB_KEY_DOWN => :_down,

    MiniFB.KB_KEY_A => :_left,
    MiniFB.KB_KEY_LEFT => :_left,

    MiniFB.KB_KEY_D => :_right,
    MiniFB.KB_KEY_RIGHT => :_right,

    MiniFB.KB_KEY_X => :_start,

    MiniFB.KB_KEY_Y => :_select,
)

ctrls_ = Base.ImmutableDict(
    MiniFB.KB_KEY_SPACE => :A_,
    MiniFB.KB_KEY_ENTER => :A_,

    MiniFB.KB_KEY_LEFT_CONTROL => :B_,
    MiniFB.KB_KEY_LEFT_SHIFT => :B_,
    MiniFB.KB_KEY_BACKSPACE => :B_,

    MiniFB.KB_KEY_Q => :L_,

    MiniFB.KB_KEY_E => :R_,

    MiniFB.KB_KEY_W => :up_,
    MiniFB.KB_KEY_UP => :up_,

    MiniFB.KB_KEY_S => :down_,
    MiniFB.KB_KEY_DOWN => :down_,

    MiniFB.KB_KEY_A => :left_,
    MiniFB.KB_KEY_LEFT => :left_,

    MiniFB.KB_KEY_D => :right_,
    MiniFB.KB_KEY_RIGHT => :right_,

    MiniFB.KB_KEY_X => :start_,

    MiniFB.KB_KEY_Y => :select_,
)

dirs = Base.ImmutableDict(
    1 => Position(-1,0),    #up
    2 => Position(1,0),     #down
    3 => Position(0,-1),    #left
    4 => Position(0,1),     #right
    0 => Position(0,0)      #null
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

function resetInput!()
    global input

    for i in eachindex(fieldnames(Input))
        if i%3 == 1
            continue
        end
        
        setfield!(input,i,false)
    end
end





walkable::Vector{UInt16} = [0x0000,0x0005,0x00006,0x00007]
bikeable::Vector{UInt16} = [0x0000,0x0005,0x00006]
swimmable::Vector{UInt16} = [0x0002,0x0003]

function checkWalkable(game::GameState,movepos::Position)
    return game.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable ||
        (game.map.tilemap.collision[movepos.h,movepos.w] >= 0x14 &&
        game.map.tilemap.collision[movepos.h,movepos.w] <= 0x3b) ||
        (game.map.tilemap.collision[movepos.h,movepos.w] >= 0xc8 &&
        game.map.tilemap.collision[movepos.h,movepos.w] <= 0xdb)
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
    end

    if game.input.map
        inputMap!(game,input)
        return
    end

    if game.input.dialogue
        inputDialogue!(game,input)
        return
    end

    if game.input.menu.main
        inputMenu!(game,input)
        return
    end

    if game.input.menu.pdex
        return
    end

    if game.input.menu.pkmn
        inputMenuPkmn!(game::GameState,input::Input)
        return
    end

    if game.input.menu.bags
        inputMenuBags!(game::GameState,input::Input)
        return
    end

    if game.input.menu.pnav
        return
    end

    if game.input.menu.self
        return
    end

    if game.input.menu.save
        return
    end

    if game.input.menu.optn
        return
    end

    if game.input.battle
        inputBattle!(game,input)
        return
    end
end

function inputMap!(game::GameState,input::Input)
    if game.input.move
        inputMove!(game::GameState,input::Input)
    end

    if game.input.move && input._start
        game.input.move = false
        game.input.map = false
        game.input.menu.main = true

        game.draw.menu1 = true

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

    dir = findfirst([input.up,input.down,input.left,input.right])
    #game.movepos = game.pos
    #posAdd!(game.movepos,dirs[dir])
    #resetMovePos!(game)
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
    elseif input._up
        game.input.menu.select = (game.input.menu.select-0x01)%0x08
    elseif input._A
        inputMenuSelector!(game)
    elseif (input._start || input._B)
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
        game.input.menu.pkmn = true
        game.input.map = false
    elseif game.input.menu.select == 0x02
        game.input.menu.bags = true
        game.input.map = false
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
    end
end

function inputMenuPkmn!(game::GameState,input::Input)
    if input._A
        if game.input.menu.pkmn.select == length(game.trainer.pokemon)
            game.input.menu.pkmn = false
            game.input.menu.menupkmn.select = 0x00
            game.input.map = true
        end
    elseif input._B
        game.input.menu.pkmn = false
        game.input.menu.menupkmn.select = 0x00
        game.input.map = true
    elseif input._down
        if game.menu.pkmn.select == length(game.trainer.pokemon)
            game.input.menu.menupkmn.select = 0x00
        else
            game.input.menu.menupkmn.select += 0x01
        end
    elseif input._up
        if game.input.menu.pkmn.select == 0x00
            game.input.menu.pkmn.select = length(game.trainer.pokemon)
        else
            game.input.menu.pkmn.select -= 0x01
        end
    elseif input._left || input._right
        if game.input.menu.pkmn.select == 0x00
            game.input.menu.pkmn.select = 0x01
        else
            game.input.menu.pkmn.select = 0x00
        end
    end
end

function inputMenuBags!(game::GameState,input::Input)
    if input._A
        return
    elseif input._B
        game.input.menu.menubags = false
        game.input.menu.menubags.select = 0x00
        game.input.map = true
    elseif input._down
        if game.input.menu.menubags.select == 0x06
            game.input.menu.menubags.select = 0x00
        else
            game.input.menu.menubags.select += 0x01
        end
    elseif input._up
        if game.input.menu.menubags.select == 0x00
            game.input.menu.menubags.select = 0x06
        else
            game.input.menu.menubags.select -= 0x01
        end
    elseif input._left
        if game.input.menu.menubags.slot == 0x00
            game.input.menu.menubags.slot = 0x04
        else
            game.input.menu.menubags.slot -= 0x01
        end
    elseif input._right
        if game.input.menu.menubags.slot == 0x04
            game.input.menu.menubags.slot = 0x00
        else
            game.input.menu.menubags.slot += 0x01
        end
    end
end

function inputDialogue!(game::GameState,input::Input)
    if input._A || input._B || input._down
        if game.dialogue.n < length(game.dialogue.str)
            game.dialogue.n += 0x01
        else
            game.dialogue.d = false
            game.dialogue.n = 0x01
            game.input.move = true
            game.input.dialogue = true
        end
    end
end

function inputBattle!(game::GameState,input::Input)
    if game.input.battled
        if input._A || input._B || input._down
            inputBattleDialogue!(game::GameState,input::Input)

            return
        end
    end

    if game.input.battle1
        if game.input.battle1menu.select < 0
            game.input.battle1menu.select += 4
        end

        game.input.battle1menu.select %= 4

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
            game.input.battle1menu.select -= 1
        elseif input._right
            game.input.battle1menu.select += 1
        end

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
            return
        end

        if input._up
            game.input.battle1menu.select -= 2
        elseif input._down
            game.input.battle1menu.select += 2
        elseif input._left
            game.input.battle1menu.select -= 1
        elseif input._right
            game.input.battle1menu.select += 1
        end

        return
    end
end

function inputBattleDialogue!(game::GameState,input::Input)
    if game.dialogue.n < length(game.dialogue.str)
        game.dialogue.n += 0x01
    else
        game.dialogue.d = false
        game.dialogue.n = 0x01
        game.input.move = true
    end
end

function inputBattleMenuSelector(game::GameState)
    if game.input.battle1menu.select == 0
        game.input.battle1 = false
        game.input.battle2 = true
    elseif game.input.battle1menu.select == 1
        return
    elseif game.input.battle1menu.select == 2
        return
    else
        game.input.battle.active = false
        game.input.move = true
        game.input.inputlock = false
    end
end

function inputBattleAttackSelector(game::GameState)
    if game.input.battle1menu.select == 0
        return
    elseif game.input.battle1menu.select == 1
        return
    elseif game.input.battle1menu.select == 2
        return
    else
        return
    end
end




function changeMap!(game::GameState,exit::Tuple{UInt8,Position})
    game.map = mapid[exit[1]]
    game.pos = posAdd(game.pos,exit[2])
end

function mapAction!(game::GameState)
    tile = game.map.tilemap.collision[game.movepos.h,game.movepos.w]

    if tile ∈ [0x0000,0x0001,0x0005,0x0006,0x0007]
        return
    elseif tile >= 0x003c && tile <= 0x004f
        game.input.move
        game.dialogue.d = true
        game.dialogue.str = game.map.signs[tile-0x003b]
    end
end





function updateGame!(game::GameState,input::Input; s=Settings())
    #@time
    inputManager!(game,input)

    for i in 1:game.callbacks.idx
        if game.callbacks[i].active
            game.callbacks[i].func(game,game.callbacks[i].args...)
        end
    end

    if game.map.tilemap.collision[game.pos.h,game.pos.w] ∈ 0x14:0x3b
        changeMap!(game,game.map.exits[game.map.tilemap.collision[game.pos.h,game.pos.w]-19])
    end
end
