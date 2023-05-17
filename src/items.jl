# # item and inventory stuff

include("items/items.jl")
include("items/pokeballs.jl")
include("items/machines.jl")
include("items/berries.jl")
include("items/keys.jl")

function getPokeballs()
    return Dict(zip(1:12,getGridImage("im/menubag/items.png",24)))
end

function getItems()
    return Dict(zip(21:45,getGridImage("im/menubag/items.png",24)[1:25]))
end

function getMachines()
    return  Dict(zip(101:132,getGridImage("im/menubag/machines.png",24)[1:32]))
end

function getBerries()
    return  Dict(zip(201:243,getGridImage("im/menubag/berries.png",24)[1:43]))
end

function getKeys()
    return  Dict(zip(301:352,getGridImage("im/menubag/machines.png",24)[1:52]))
end

function getSlotItems(slot::Int)
    if slot == 1
        return getPokeballs()
    elseif slot == 2
        return getItems()
    elseif slot == 3
        return getMachines()
    elseif slot == 4
        return getBerries()
    else
        return getPokeballs()
    end
end