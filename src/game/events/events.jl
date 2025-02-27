
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

function playEventQueue!(game::GameState)
    while game.events.c == 0
        playEvent!(game)
    end

    return
end

function playEvent!(game)
    e = game.events.queue[:,game.events.idx]
    c = e[1]

    if c == 0
        game.events.active = false
        game.events.queue .= 0
    elseif c == 1
        game.events.branch = e[2]
    elseif c == 2
        stateSetDialogue!(game,str)
    elseif c == 3
        stateSetDialogue!(game,str)
        setChoice!(game,false,d,eventChoice)
        drawChoiceMenu!(game,6,strs,w,0,0)
    elseif c == 5
        # mc walk
    elseif c == 6
        # mc turn
    elseif c == 7
        # mc emote
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
    elseif c == 26
        # camera move
    elseif c == 27
        # camera zoom?
    elseif c == 28
        # teleport
    elseif c == 29
        # delay frames
    elseif c == 30
        # setflag
    elseif c == 31
        # setcounter
    elseif c == 33
        # gain item
    elseif c == 34
        # gain pkmn
    elseif c == 36
        # startbattle
    end

    return
end