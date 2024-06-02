# types for item and inventory stuff


mutable struct Inventory
    items::Matrix{UInt16}
    balls::Matrix{UInt16}
    machines::Matrix{UInt16}
    berries::Matrix{UInt16}
    keys::Matrix{UInt16}

    nitems::Int
    nballs::Int
    nmachines::Int
    nberries::Int
    nkeys::Int

    cash::UInt32

    function Inventory()
        items   = zeros(UInt16,25,2);   items[:,1] = 21:45
        balls   = zeros(UInt16,12,2);   balls[:,1] = 1:12
        tms     = zeros(UInt16,2,2);      tms[:,1] = 101:102
        berries = zeros(UInt16,2,2);  berries[:,1] = 201:202
        keys    = zeros(UInt16,2,2);     keys[:,1] = 301:302

        new(items,balls,tms,berries,keys,0,0,0,0,0,0)
    end
end

function Base.getindex(inv::Inventory,ind)
    if ind == -5
        return inv.nkeys
    elseif ind == -4
        return inv.nberries
    elseif ind == -3
        return inv.nmachines
    elseif ind == -2
        return inv.nballs
    elseif ind == -1
        return inv.nitems
    elseif ind == 0
        return inv.cash
    elseif ind == 1
        return inv.items
    elseif ind == 2
        return inv.balls
    elseif ind == 3
        return inv.machines
    elseif ind == 4
        return inv.berries
    elseif ind == 5
        return inv.keys
    end
end

function setInventoryTest!(inv::Inventory)
    inv[1][1:10,2] .= 1:10; inv[1][2,2] = 5
    inv.nitems = 10

    inv[2][1,2] = 20; inv[2][2,2] = 15; inv[2][3,2] = 10
    inv.nballs = 3

    inv[3][1,2] = 10; inv[3][2,2] = 5
    inv.nmachines = 2

    inv[4][1,2] = 5
    inv.nberries = 1

    # inv[5][1,2] = 1
    inv.nkeys = 0

    inv.cash = 10000
end



abstract type ItemType end



# general items

abstract type Item <: ItemType end

struct MedicineHealth <: Item
    amount::Int
    fraction::Bool

    status::UInt8
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

    status::Int
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




