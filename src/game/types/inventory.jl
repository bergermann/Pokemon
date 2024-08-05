# types for item and inventory stuff

mutable struct Inventory
    nkeys::Int
    nberries::Int
    nmachines::Int
    nballs::Int
    nitems::Int

    cash::UInt32

    items::MMatrix{170,2,UInt16}
    balls::MMatrix{30,2,UInt16}
    machines::MMatrix{120,2,UInt16}
    berries::MMatrix{80,2,UInt16}
    keys::MMatrix{100,2,UInt16}

    function Inventory()
        items   = zeros(UInt16,170,2)
        balls   = zeros(UInt16, 30,2)
        tms     = zeros(UInt16,120,2)
        berries = zeros(UInt16, 80,2)
        keys    = zeros(UInt16,100,2)

        new(0,0,0,0,0,0,items,balls,tms,berries,keys)
    end
end

function Base.getindex(inv::Inventory,ind::Integer)
    @assert -5 <= ind <= 5 "Index needs to be within -5 and 5."

    return getfield(inv::Inventory,ind+6)
end

function setInventoryTest!(inv::Inventory)
    inv[1][1:20,1] = 31:50; inv[1][1:20,2] .= 1:20; inv[1][2,2] = 5
    inv.nitems = 20

    inv[2][1,1] = 1; inv[2][2,1] = 2; inv[2][3,1] = 3
    inv[2][1,2] = 20; inv[2][2,2] = 15; inv[2][3,2] = 10
    inv.nballs = 3

    inv[3][1,1] = 201; inv[3][2,1] = 202
    inv[3][1,2] = 10; inv[3][2,2] = 5
    inv.nmachines = 2

    inv[4][1,1] = 321
    inv[4][1,2] = 5
    inv.nberries = 1

    # inv[5][1,2] = 1
    inv.nkeys = 0

    inv.cash = 10000

    return
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




