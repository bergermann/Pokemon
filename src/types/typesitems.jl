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
end



struct Pokeball <: ItemType
    catchrate::Float64
    effect::Int
end