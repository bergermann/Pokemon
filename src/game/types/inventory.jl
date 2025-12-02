# types for item and inventory stuff

mutable struct ItemP{T<:Enum{UInt8}}
    id::T
    amount::UInt16

    function ItemP(id::T,amount::Integer) where T<:Enum{UInt8}
        new{T}(id,amount)
    end
end

mutable struct Inventory
    cash::UInt32

       items::Vector{ItemP{ItemID}}
       balls::Vector{ItemP{BallID}}
    machines::Vector{ItemP{MachineID}}
     berries::Vector{ItemP{BerryID}}
    keyitems::Vector{ItemP{KeyID}}

    function Inventory()
        new(0,[],[],[],[],[])
    end
end

function Base.getindex(inv::Inventory,ind::Integer)
    @assert 0 <= ind <= 5 "Index needs to be within -5 and 5."

    return getfield(inv::Inventory,ind+1)
end

function setInventoryTest!(inv::Inventory)
    addItem!(game,POT_POTION,5)
    addItem!(game,POT_SUPER,5)
    addItem!(game,POT_SUPER,5)
    addItem!(game,POT_POTION,1) 
    addItem!(game,POT_SUPER,1)
    addItem!(game,POT_HYPER,1)
    addItem!(game,POT_MAX,1)
    addItem!(game,POT_FULL,1)
    addItem!(game,POT_WATER,1)
    addItem!(game,POT_SODA,1)
    addItem!(game,POT_LIMO,1)
    addItem!(game,POT_MOO,1)
    addItem!(game,POT_ROOT,1)
    addItem!(game,POT_POWDER,1)
    
    addItem!(game,BALL_POKE,10)
    addItem!(game,BALL_GREAT,20)
    addItem!(game,BALL_ULTRA,100)

    addItem!(game,TM_001,5)
    addItem!(game,TM_002,5)

    addItem!(game,BERRY_ORAN,1)
    addItem!(game,BERRY_PECHA,5)

    addItem!(game,KEY_BIKE)
    addItem!(game,KEY_KEYS)

    inv.cash = 10000

    return
end



abstract type ItemType end



# general items

abstract type Item <: ItemType end

struct MedicineHealth <: Item
    amount::Int
    fraction::Bool

    status::HealthStatus
end

struct MedicineAP <: Item
    amount::Int
    all::Bool
end



struct Vitamin <: Item
    stat::Int
    amount::Int
end

struct BattleItem <: Item
    stat::Int
    amount::Int
end

struct BattleCarry <: Item end



struct Valuable <: Item end

struct Tradable <: Item end

struct EvolveApply <: Item end

struct EvolveCarry <: Item end



struct Repel <: Item
    duration::Int
end

# pokeballs

struct Pokeball <: ItemType
    catchrate::Float64
    effect::Int
    id::Int
end



# tms

abstract type Machine <: ItemType end

mutable struct TM <: Machine end

mutable struct HM <: Machine end



# berries

abstract type Berry <: ItemType end



struct BerryHealth <: Berry
    amount::Int
    fraction::Bool

    status::HealthStatus
end

struct BerryAP <: Berry
    amount::Int
    all::Bool
end


# key items

abstract type KeyItem <: ItemType end

struct Key <: KeyItem end

struct QuestItem <: KeyItem end

struct Fossil <: KeyItem end

abstract type Usable <: KeyItem end

struct Rod <: Usable end

struct Bike <: Usable end




