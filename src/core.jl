
# include("pokemons.jl")







function quicksort!(A::Vector,lo::Int,hi::Int)
    if lo >= hi || lo < 0
        return
    end

    p = partition!(A,lo,hi)

    quicksort!(A,lo,p-1)
    quicksort!(A,p+1,hi)
end

function quicksort!(A::Vector,lo::Int,hi::Int,mask::Function)
    if lo >= hi || lo < 0
        return
    end

    p = partition!(A,lo,hi,mask)

    quicksort!(A,lo,p-1,mask)
    quicksort!(A,p+1,hi,mask)
end

function partition!(A::Vector,lo::Int,hi::Int)
    pivot = A[hi]

    i = lo-1

    @inbounds for j in lo:hi-1
        if A[j] <= pivot
            i += 1
            
            A[i], A[j] = A[j], A[i]
        end
    end

    i += 1

    A[i], A[hi] = A[hi], A[i]

    return i
end

function partition!(A::Vector,lo::Int,hi::Int,mask::Function)
    pivot = mask(A[hi])

    i = lo-1

    @inbounds for j in lo:hi-1
        if mask(A[j]) <= pivot
            i += 1
            
            A[i], A[j] = A[j], A[i]
        end
    end

    i += 1

    A[i], A[hi] = A[hi], A[i]

    return i
end

function sortHorizontal!(A::ArrayList{Sprite})
    quicksort!(A.data,1,A.idx,a->a.pos.h)
end

function sortVertical!(A::ArrayList{Sprite})
    quicksort!(A.data,1,A.idx,a->a.pos.w)
end

function sortPriority!(A::ArrayList{BattleAction},t::Bool)
    quicksort!(A.data,1,A.idx,a->-(a.priority+(a.init*(-1*t+1*!t)+rand())/(0xffff+1)))
end






function emptyCallback(game::GameState)
    return
end

function createCounter!(game::GameState,id::Symbol)
    push!(game.n.c,Counter(id))
end

function createCounter!(game::GameState,id::Symbol,n::Int)
    push!(game.n.c,Counter(id,n))
end

function killCounter!(game::GameState,id::Symbol)
    popat!(game.n.c,id)
end

function createCallback!(game::GameState,id::Symbol,active::Bool,func::Function,args::Tuple)
    push!(game.callbacks,CallbackFunction(id,active,func,args))
end

function createCallback!(game::GameState,id::Symbol,func::Function,args::Tuple; active=false)
    push!(game.callbacks,CallbackFunction(id,active,func,args))
end

function killCallback!(game::GameState,id::Symbol)
    popat!(game.callbacks,id)
end

function createCC!(game::GameState,id::Symbol,func::Function,args::Tuple; active=false,n=0)
    createCounter!(game,id,n)
    createCallback!(game,id,active,func,args)
end

function createCC!(game::GameState,idc::Symbol,idcb::Symbol,func::Function,args::Tuple)
    createCounter!(game,idc::Symbol)
    createCallback!(game,idcb,func,args)
end

function killCC!(game::GameState,id::Symbol)
    killCounter!(game,id)
    killCallback!(game,id)
end

function killCC!(game::GameState,idc::Symbol,idcb::Symbol)
    killCounter!(game,idc)
    killCallback!(game,idcb)
end

function setDialogue!(game::GameState,str::String)
    game.dialogue.d = true
    game.dialogue.n = 1
    game.dialogue.str = str
end

function setBattleDialogue!(game::GameState,str::String)
    game.battle.dialogue.d = true
    game.battle.dialogue.n = 1
    game.battle.dialogue.str = str
end

function createSprite!(game::GameState,id::Symbol,layer::Symbol,
        dict::Dict{Int,Tuple{Matrix{UInt32},Position}},pos::Position,frame::Int;
        active=false,hreverse=false,vreverse=false)
    
    push!(game.im.sprites,Sprite(
        id,
        active,
        hreverse,
        vreverse,
        layer,
        pos,
        dict[frame][2],
        frame,
        dict,
        copy(dict[frame][1])
        )
    )
end

function killSprite!(game::GameState,id::Symbol)
    popat!(game.im.sprites,id)
end

function killSpriteAll!(game::GameState)
    popall!(game.im.sprites)
end



function setChoice!(game::GameState,exit::Bool,sel::Int)
    game.input.choice.active = true
    game.input.choice.exit = exit
    game.input.choice.sel = sel
    game.input.choice.callback = CallbackFunction()
end

function setChoice!(game::GameState,exit::Bool,sel::Int,callback::CallbackFunction)
    game.input.choice.active = true
    game.input.choice.exit = exit
    game.input.choice.sel = sel
    game.input.choice.callback = callback
end

function setChoice!(game::GameState,active::Bool,exit::Bool,sel::Int,
        callback::CallbackFunction)

    game.input.choice.active = active
    game.input.choice.exit = exit
    game.input.choice.sel = sel
    game.input.choice.callback = callback
end

function setChoice!(game::GameState,active::Bool,exit::Bool,sel::Int)
    game.input.choice.active = active
    game.input.choice.exit = exit
    game.input.choice.sel = sel
    game.input.choice.callback = CallbackFunction()
end

function resetChoice!(game::GameState)
    game.input.choice.active = false
    game.input.choice.exit = false
    game.input.choice.sel = 0
    game.input.choice.max = 0
    game.input.choice.callback = CallbackFunction()
end