


const dirs = Base.ImmutableDict(
    1 => Position(-1,0),    #up
    2 => Position(1,0),     #down
    3 => Position(0,-1),    #left
    4 => Position(0,1),     #right
    0 => Position(0,0)      #null
)

const dirsinv = Base.ImmutableDict(
    1 => 2,     #up
    2 => 1,     #down
    3 => 4,     #left
    4 => 3,     #right
    0 => 0      #null
)

const dirsturnright = Base.ImmutableDict(
    1 => 4,     #up
    2 => 3,     #down
    3 => 1,     #left
    4 => 2,     #right
    0 => 0      #null
)

const dirsturnleft = Base.ImmutableDict(
    1 => 3,     #up
    2 => 4,     #down
    3 => 2,     #left
    4 => 1,     #right
    0 => 0      #null
)

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





const walkable::Vector{UInt16} = [0x0000,0x0005,0x00006,0x00007]
const bikeable::Vector{UInt16} = [0x0000,0x0005,0x00006]
const swimmable::Vector{UInt16} = [0x0002,0x0003]

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

    return |(game.maps.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable,
        (0x14 <= game.maps.map.tilemap.collision[movepos.h,movepos.w] <= 0x3b),
        (0xa0 <= game.maps.map.tilemap.collision[movepos.h,movepos.w] <= 0xb3),
        (0xc8 <= game.maps.map.tilemap.collision[movepos.h,movepos.w] <= 0xdb))
end

function updateMovePos!(game::GameState,dir::Int)
    game.movepos.h = game.pos.h+dirs[dir].h
    game.movepos.w = game.pos.w+dirs[dir].w

    return
end

function resetMovePos!(game::GameState)
    game.movepos = posAdd(game.pos,dirs[game.direction])

    return
end

function checkEncounter!(game::GameState)
    if !(game.maps.map.tilemap.collision[game.pos.h,game.pos.w] == 0x06)
        return
    end

    if rand(0x00:0xff) > 0x80
        return
    end

    game.callbacks[:movemain].active = true
    game.callbacks[:movemain].args = (game.direction,-1)

    initBattleWild!(game)

    return
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

    return
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

    return
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

    checkMapExit!(game,game.movepos)

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

    return
end
