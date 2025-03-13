
# include.(joinpath.("events",readdir("src/game/events/events")))
include("events/heal.jl")

function evalEvent(game::GameState,event::Event)
    if (event.dir != 0 && event.dir != game.ctrl.dir) && !evalFlagSet(game,event.flags)
        return
    end

    evalCallback(game,event.callback)

    return
end


const E0 = Event()
const events = Base.ImmutableDict(
    :healcenter => (FlagSet(; flags=[(0xc8,false,1)]),
        F(eventHealCenter!)),
)

function setupEvent!(game::GameState,name::String)
    game.events.active = true
    game.events.c = 0
    game.events.idx = 1
    game.events.queue = deserialize(joinpath("events","$name.eq"))

    return
end

function playEventQueue!(game::GameState)
    while game.events.c <= 0
        playEvent!(game)
        game.events.idx += 1
    end

    if game.events.c > 0
        game.events.c -= 1
    end

    return
end

function playEvent!(game::GameState)
    # if game.events.idx > size(game.events.queue.queue,2); resetEvent!(game); end
    if game.events.idx > size(game.events.queue.queue,2); game.events.active = false; end

    e = game.events.queue.queue[:,game.events.idx]
    c = e[1]

    println("event command: ",e)

    if c == 0
        game.events.active = false
        game.events.queue .= 0
    elseif c == 1
        game.events.branch = e[2]
    elseif c == 2
        str = game.str[end][e[3]]
        stateSetDialogue!(game,str)
    elseif c == 3
        str = game.str[end][e[4]]
        stateSetDialogue!(game,str)
        setChoice!(game,false,e[3],eventChoice!)
        strc = game.str[end][e[4]+1:e[4]+e[5]]
        w = maximum(length.(strc)); h = length(strc)
        drawChoiceMenu!(game,6,strc,w,120-8*(w+2),56-8*(h+2))
    elseif c == 5   # mcwalk
        game.ctrl.dir = e[3]
        setMovement!(game,1,e[4])
        game.events.c = 16*e[4]
    elseif c == 6   # mcturn
        game.ctrl.dir = e[3]
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    elseif c == 7   # mcemote
        game.events.c = 32
    elseif c == 10
        # npc add 1
    elseif c == 11
        # npc add 2
    elseif c == 12
        # npc del
    elseif c == 13
        # npc walk
    elseif c == 14
        # npc turn
    elseif c == 15
        # npc emote
    elseif c == 20
        # sprite add
    elseif c == 21
        # sprite del
    elseif c == 22
        # sprite move
    elseif c == 23
        # sprite frame
    elseif c == 24
        # sprite del
    elseif c == 30
        # camera move
    elseif c == 31
        # camera zoom?
    elseif c == 32
        # teleport
    elseif c == 33  # delay frames
        game.events.c = e[3]
    elseif c == 34  # setflag
        game.flags
    elseif c == 35  # setcounter
    elseif c == 37
        # gain item
    elseif c == 38
        # gain pkmn
    elseif c == 40
        # startbattle
    end

    return
end

function resetEvent(game::GameState)
    game.events.active = false
    game.events.c = 0
    game.events.idx = 0

    return
end