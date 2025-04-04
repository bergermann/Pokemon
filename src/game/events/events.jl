
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
events = Base.Dict{Symbol,Tuple{FlagSet,Union{Callback,EventQueue}}}(
    :healcenter => (FlagSet(; flags=[(0xc8,false,1)]),
        F(eventHealCenter!)),
)

function loadEvent!(game::GameState,name::Symbol)
    eq = deserialize(joinpath("events","$name.eq"))
    events[name] = (eq.flags,eq)

    return
end

function unloadEvent!(game::GameState,name::Symbol)
    if events[name][2] isa EventQueue; pop!(events,name); end

    return
end

function setupEvent!(game::GameState,name::Symbol)
    game.events.active = true
    game.events.c = 0
    game.events.idx = 1
    game.events.branch = 0
    # game.events.queue = deserialize(joinpath("events","$name.eq"))
    game.events.queue = events[name][2]
    loadStrings!(game,"events/$name")

    return
end

function playEventQueue!(game::GameState)
    while game.events.c <= 0 && game.events.active
        playEvent!(game)
        game.events.idx += 1
    end

    if game.events.c > 0
        # println("event delay: ",game.events.c)
        game.events.c -= 1
    end

    return
end

function playEvent!(game::GameState)
    if game.events.idx > game.events.queue.l; resetEvent!(game); return; end

    e = game.events.queue.queue[:,game.events.idx]
    c = e[2]

    println("\nbranch:        ",game.events.branch,", ",e[1])
    println("event command: ",e)

    if game.events.branch != e[1]; return; end

    if c == 0
        resetEvent!(game)
    elseif c == 1
        println("setting branch to ",e[3])
        game.events.branch = e[3]
    elseif c == 2
        str = game.str[end][e[3]]
        stateSetDialogue!(game,str,F((game,args)->game.events.active=true))
        game.events.active = false
    elseif c == 3
        str = game.str[end][e[4]]
        stateSetDialogue!(game,str); game.ctrl.input.dialogue = false
        setChoice!(game,false,e[3],F(eventChoice!))
        strc = game.str[end][e[4]+1:e[4]+e[5]]
        w = maximum(length.(strc)); h = length(strc)
        drawChoiceMenu!(game,6,strc,w,120-8*(w+2),32-16*(h+1))
        game.events.active = false
    elseif c == 5   # mcwalk
        game.ctrl.dir = e[3]
        setMovement!(game,1,e[4])
        game.events.c = 16*e[4]
    elseif c == 6   # mcturn
        game.ctrl.dir = e[3]
        setSpriteFrame!(game,:mc,1+3*(e[3]-1-2*(e[3] == 4)))
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

            Symbol()
        )

        push!(game.m.npcs,npc_)
        push!(game.m.chunkdata[target].npcs,Ref(npc_))

        createNPCSprite!(game,npc_)
    elseif c == 11  # npcadd 2
        rd = Int(game.im.c.renderdistance)+1
        
        cy = game.ctrl.chunk.x+e[6]
        cx = game.ctrl.chunk.y+e[5]
        
        target = game.m.idxs[e[6]+rd,e[5]+rd]
        # target = game.m.idxs[3,3]
        id = ID(cx,cy,length(game.m.chunkdata[target].npcs)+1)
        push!(game.m.npcids,id)

        sid = game.events.queue.npcs[e[3]]
        spriteid = e[4]; dir = e[9]
        # x = e[7]; y = e[8]
        x = 9; y = 9
        l = 1
        println("adding npc $id at cx=",cx,", cy=",cy,", x=",x,", y=",y)
        println("spriteid: ",sid)

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

            String[],
            Symbol(),
        )

        push!(game.m.npcs,npc_)
        push!(game.m.chunkdata[target].npcs,Ref(npc_))
        
        createNPCSprite!(game,npc_)
    elseif c == 12  # npc del
        rd = Int(game.im.c.renderdistance)+1

        id = game.events.queue.npcs[e[3]]

        idx = findfirst(x->x.sprite==id,game.m.npcs.data[1:game.m.npcs.idx])
        npc = game.m.npcs[idx]
        killSprite!(game,npc.sprite)
        popat!(game.m.npcids,idx)
        popat!(game.m.npcs,idx)

        dx = npc.chunk.x-game.ctrl.chunk.x; dy = npc.chunk.y-game.ctrl.chunk.y
        target = game.m.idxs[dy+rd,dx+rd]
        println(id)
        display([npc[].spriteid for npc in game.m.chunkdata[target].npcs])
        idx = findfirst(x->x[].spriteid==id,game.m.chunkdata[target].npcs)
        popat!(game.m.chunkdata[target].npcs,idx)
    elseif c == 13  # npc walk
        id = game.events.queue.npcs[e[3]]
        idx = findfirst(x->x.sprite==id,game.m.npcs.data[1:game.m.npcs.idx])
        npc = game.m.npcs[idx]
        println("walking npc $(npc.id) for $(e[5]) tiles in dir $(e[4])")
        npc.dir = e[4]; npc.c2 = 1; reverseSpriteW!(game,npc.sprite,npc.dir==4)
        @. npc.mpos = npc.pos1+dirs[npc.dir]
        @. npc.mchunk = modc(npc.mpos)+(game.im.c.renderdistance+1)+game.ctrl.chunk-npc.chunk
        @. npc.mpos = (npc.mpos+15)%16+1 
        cid = Symbol("move",id)
        createCC!(game,cid,walkNPC!,(Ref(npc),e[5],cid); active=true,n=1)
        
        game.events.c = 16*e[5]
    elseif c == 14  # npc turn
        id = game.events.queue.npcs[e[3]]
        idx = findfirst(x->x.sprite==id,game.m.npcs.data[1:game.m.npcs.idx])
        npc = game.m.npcs[idx]
        npc.dir = e[4]
        npc.dir = e[4]; reverseSpriteW!(game,npc.sprite,npc.dir==4)
        setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4)))
    elseif c == 15  # npc emote
        id = game.events.queue.npcs[e[3]]
        idx = findfirst(x->x.sprite==id,game.m.npcs.data[1:game.m.npcs.idx])
        npc = game.m.npcs[idx]
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
    elseif c == 37  # gainitem
        addItem!(game,e[3],e[4])
    elseif c == 38  # removeitem
        removeItem!(game,e[3],e[4])
    elseif c == 39  # addpokemon
        pkmn = generatePkmn(game,UInt16(e[3]),UInt8(e[4]))
        addPokemon!(game,pkmn)
    elseif c == 40  # removepkmn
        removePokemon!(game,)
    elseif c == 50  # startbattle
        startBattle!(game,command[3])
    end

    return
end

function resetEvent!(game::GameState)
    game.events.active = false
    # game.events.c = 0
    # game.events.idx = 1
    # game.events.branch = 0

    game.ctrl.input.npclock = false
    game.ctrl.input.map = true
    game.ctrl.input.move = true

    return
end


function walkNPC!(game::GameState,(npc,len,cid)::Tuple{Ref{NPC},Int,Symbol})
    npc = npc[]
    dir = npc.dir

    if npc.c2%16 == 1
        setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4))+1+sum(npc.pos1)%2)
        @. npc.pos2 = npc.mpos
    elseif npc.c2%16 == 9
        game.ctrl.pos1 += dirs[dir]
        @. npc.pos1 = npc.mpos; 
        setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4)))
    elseif npc.c2 >> 4 == len
        npc.c2 = -1
        killCC!(game,cid)

        # checkChunks!(game,npc)

        return
    end

    npc.c2 += 1
    moveSprite!(game,npc.sprite,dirs[npc.dir][2],dirs[npc.dir][1])

    return
end

function eventChoice!(game::GameState,args::Tuple{})
    println("setting branch to ",game.ctrl.input.choice.sel)
    game.events.branch = game.ctrl.input.choice.sel
    game.events.active = true
    
    deactivateBackground!(game,:textbox)
    deactivateText!(game,:dialogue)
    
    resetChoice!(game)

    return
end