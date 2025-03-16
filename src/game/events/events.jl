
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

    e = game.events.queue.queue[:,game.events.idx]
    c = e[1]

    println("event command: ",e)

    if c == 0 || game.events.idx > game.events.queue.queue.l
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
    elseif c == 10  # npcadd 1
        id = game.events.queue.npcs[e[3]]
        push!(game.m.npcids,id)

        sid = Symbol(:npc,id)
        spriteid = e[4]; dir = e[7]
        x = e[5]-game.ctrl.pos1.x; y = e[6]-game.ctrl.pos1.y
        cx = 0  # FIX
        cy = 0  # FIX

        npc_ = NPC(
            id,

            P(x,y),P(x,y),P(x,y),P(x,y),
            game.m.chunkdata[target].height[y,x]*(l==1),
            P(cy,cx),P(cy,cx),P(cy,cx),
            l==2,
            dir,

            sid,
            spriteid,
            
            false,
            0,
            0,
            0,
            0,
            0,

            0,
            0,

            game.str[end][e[8]],
        )

        push!(game.m.npcs,npc_)
        push!(game.m.chunkdata[target].npcs,Ref(npc_))

        createNPCSprite!(game,npc_)
    elseif c == 11  # npcadd 2
        id = game.events.queue.npcs[e[3]]
        push!(game.m.npcids,id)

        sid = Symbol(:npc,id)
        spriteid = e[4]; dir = e[7]
        x = e[5]-game.ctrl.pos1.x; y = e[6]-game.ctrl.pos1.y
        cx = 0  # FIX
        cy = 0  # FIX

        npc_ = NPC(
            id,

            P(x,y),P(x,y),P(x,y),P(x,y),
            game.m.chunkdata[target].height[y,x]*(l==1),
            P(cy,cx),P(cy,cx),P(cy,cx),
            l==2,
            dir,

            sid,
            spriteid,
            
            false,
            0,
            0,
            0,
            0,
            0,

            0,
            0,

            game.str[end][e[8]],
        )

        push!(game.m.npcs,npc_)
        push!(game.m.chunkdata[target].npcs,Ref(npc_))
        
        createNPCSprite!(game,npc_)
    elseif c == 12  # npc del
        id = game.events.queue.npcs[e[3]]
        idx = findfirst(x->x.id==id,game.m.npcs)
        npc = game.m.npcs[idx]

        killSprite!(game,npc.sprite)
        popat!(game.m.npcids,idx)
        popat!(game.m.npcs,idx)
    
        c = game.m.chunkdata[target].npcs[1][].chunk    # FIX
        idx = findfirst(x->x[].id==id,game.m.chunkdata[c])
        popat!(game.m.chunkdata[c].npcs,idx)
    elseif c == 13  # npc walk
        id = game.events.queue.npcs[e[3]]
        idx = findfirst(x->x.id==id,game.m.npcs)
        npc = game.m.npcs[idx]
        npc.dir = e[4]
        createCC!(game,Symbol("move",id),walkNPC!,(Ref(NPC),e[5]))
    elseif c == 14  # npc turn
    elseif c == 15  # npc emote
        npc = game.im.c
    elseif c == 20  # sprite add
        sheet = game.events.queue.sheets[e[3]]
        id = game.events.queue.sprites[e[4]]
        createSprite!(game,id,sheet,e[5],e[6],e[7],e[8],0,e[9]; active=true)
    elseif c == 21  # sprite del
        id = game.events.queue.sprites[e[3]]
        killSprite!(game,id)
    elseif c == 22  # sprite move 1
        id = game.events.queue.sprites[e[3]]
        moveSprite!(game,id,e[4],e[5],Bool(e[6]))
    elseif c == 23  # sprite move 1
        id = game.events.queue.sprites[e[3]]
        createCC!(game,Symbol("move",id),moveSpriteT!,(e[4],e[5],Bool(e[6])))
    elseif c == 24  # sprite idx
        id = game.events.queue.sprites[e[3]]
        setSpriteIdx!(game,id,e[4])
    elseif c == 25  # sprite frame
        id = game.events.queue.sprites[e[3]]
        setSpriteFrame!(game,id,e[4])
    elseif c == 26  # sprite reverse
        id = game.events.queue.sprites[e[3]]
        reverseSprite!(game,id,e[4],e[5])
    elseif c == 27  # sprite rotate
        id = game.events.queue.sprites[e[3]]
        rotateSprite!(game,id,e[4],Bool(e[5]))
    elseif c == 28  # sprite scale
        id = game.events.queue.sprites[e[3]]
        scaleSprite!(game,id,e[4],e[5],Bool(e[6]))
    elseif c == 30  # camera move
        createCC!(game,:movecamera,moveCamera!,(e[3],e[4],e[5]))
    elseif c == 31  # camera zoom?
        # zoomCamera!(game,e[3]/100)
        # createCC!(game,:zoomcamera,zoomCamera!,())
    elseif c == 32  # teleport
        teleport!(game,e[5],e[6],e[3],e[4],) # e[7],e[8]
    elseif c == 33  # delay frames
        game.events.c = e[3]
    elseif c == 34  # setflag
        getfield(game.flags,e[4])[e[3]] = Bool(e[5])
    elseif c == 35  # setcounter
        game.flags.counters[e[3]] = UInt32(e[4])
    elseif c == 37
        addItem!(game,e[3],e[4])
    elseif c == 38
        pkmn = generatePkmn(game,UInt16(e[3]),UInt8(e[4]))
        addPokemon!(game,pkmn)
    elseif c == 40
        startBattle!(game)
        # startbattle
    end

    return
end

function resetEvent!(game::GameState)
    game.events.active = false
    game.events.c = 0
    game.events.idx = 0

    return
end