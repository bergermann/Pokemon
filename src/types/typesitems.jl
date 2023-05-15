# types for item and inventory stuff


mutable struct Inventory
    items::Matrix{UInt8}
    balls::Matrix{UInt8}
    tms::Matrix{UInt8}
    berries::Matrix{UInt8}
    keys::Matrix{UInt8}

    cash::UInt32

    function Inventory()
        items   = zeros(UInt8,10,2);   items[:,1] = 1:10
        balls   = zeros(UInt8,12,2);   balls[:,1] = 1:12
        tms     = zeros(UInt8,10,2);     tms[:,1] = 1:10
        berries = zeros(UInt8,10,2); berries[:,1] = 1:10
        keys    = zeros(UInt8,10,2);    keys[:,1] = 1:10

        new(items,balls,tms,berries,keys,0)
    end
end

abstract type ItemType end


# general items

abstract type Item <: ItemType end

struct MedicineHealth <: Item
    amount::Int
    fraction::Bool

    status::Int
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

# berries

abstract type Berries <: ItemType end



# pokeballs

struct Pokeball <: ItemType
    catchrate::Float64
    effect::Int
end

# key items

abstract type Keys <: ItemType end

struct Key <: Keys end

struct QuestItem <: Keys end

struct Fossil <: Keys end

abstract type Usable <: Keys end

struct Rod <: Usable end





