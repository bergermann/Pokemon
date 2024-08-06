
# include("pokemons.jl")


function Base.getindex(a::MMatrix,idx::MVector{2,<:Integer})
    return a[idx[1],idx[2]]
end

function modc(x::Integer)
    return div(x-1+16,16)-1
end


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



function discreteGaussian(type::Type,dims; μ::Real=0.,σ::Real=1.)
    return round.(type,σ*randn(Float64,dims).+μ)
end





function evalCallback(game::GameState,f::Callback)
    f.func(game,f.args)  # FIX

    return
end

function emptyCallback(game::GameState)
    return
end

function createCounter!(game::GameState,id::Symbol)
    push!(game.n,Counter(id))
end

function createCounter!(game::GameState,id::Symbol,n::Int)
    push!(game.n,Counter(id,n))
end

function killCounter!(game::GameState,id::Symbol)
    popat!(game.n,id)
end

function createCallback!(game::GameState,id::Symbol,active::Bool,func::Function,args::Tuple)
    push!(game.callbacks,Callback(id,active,func,args))
end

function createCallback!(game::GameState,id::Symbol,func::Function,args::Tuple; active=false)
    push!(game.callbacks,Callback(id,active,func,args))

    return
end

function killCallback!(game::GameState,id::Symbol)
    popat!(game.callbacks,id)

    return
end

function createCC!(game::GameState,id::Symbol,func::Function,args::Tuple; active=false,n=0)
    createCounter!(game,id,n)
    createCallback!(game,id,active,func,args)

    return
end

function createCC!(game::GameState,idc::Symbol,idcb::Symbol,func::Function,args::Tuple)
    createCounter!(game,idc::Symbol)
    createCallback!(game,idcb,func,args)

    return
end

function killCC!(game::GameState,id::Symbol)
    killCounter!(game,id)
    killCallback!(game,id)

    return
end

function killCC!(game::GameState,idc::Symbol,idcb::Symbol)
    killCounter!(game,idc)
    killCallback!(game,idcb)

    return
end


## remove if works!
# function setDialogue!(game::GameState,str::String)
#     game.dialogue.d = true
#     game.dialogue.n = 1
#     game.dialogue.str = str
# end

function setBattleDialogue!(game::GameState,str::String)
    game.battle.dialogue.d = true
    game.battle.dialogue.n = 1
    game.battle.dialogue.str = str

    return
end



function setChoice!(game::GameState,exit::Bool,sel::Int; active=true)
    game.ctrl.input.choice.active = active
    game.ctrl.input.choice.exit = exit
    game.ctrl.input.choice.sel = sel
    game.ctrl.input.choice.func = Callback()

    return
end

function setChoice!(game::GameState,exit::Bool,sel::Int,func::Callback; active=true)
    game.ctrl.input.choice.active = active
    game.ctrl.input.choice.exit = exit
    game.ctrl.input.choice.sel = sel
    game.ctrl.input.choice.func = func

    return
end

function resetChoice!(game::GameState)
    game.ctrl.input.choice.active = false
    game.ctrl.input.choice.exit = false
    game.ctrl.input.choice.sel = -1
    game.ctrl.input.choice.max = 0
    game.ctrl.input.choice.func = Callback()

    return
end

lang = Base.ImmutableDict(
    0x01 => "ger",
    0x02 => "eng",
    0x03 => "fre",
    0x04 => "esp",
)

function loadStrings!(game::GameState,paths::String...; reset::Bool=false)
    reset && (game.str = [])

    for p in paths
        push!(game.str,readlines(joinpath("str",lang[game.options.lang],p*".txt")))
    end
end





