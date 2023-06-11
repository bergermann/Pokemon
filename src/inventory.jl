# # item and inventory stuff

include("items/items.jl")
include("items/pokeballs.jl")
include("items/machines.jl")
include("items/berries.jl")
include("items/keys.jl")

function getItems()
    return Dict(zip(21:45,getGridImage("im/menubag/items.png",24)[1:25]))
end

function getPokeballs()
    return Dict(zip(1:12,getGridImage("im/menubag/balls.png",24)))
end

function getMachines()
    return  Dict(zip(101:132,getGridImage("im/menubag/machines.png",24)[1:32]))
end

function getBerries()
    return  Dict(zip(201:243,getGridImage("im/menubag/berries.png",24)[1:43]))
end

function getKeys()
    return  Dict(zip(301:352,getGridImage("im/menubag/keys.png",24)[1:52]))
end

function getItemIcons(bag::Int)
    if bag == 1
        return getItems()
    elseif bag == 2
        return getPokeballs()
    elseif bag == 3
        return getMachines()
    elseif bag == 4
        return getBerries()
    else
        return getKeys()
    end
end

function getItemIcons(game::GameState)
    if game.input.menu.menubags.bag == 1
        return getItems()
    elseif game.input.menu.menubags.bag == 2
        return getPokeballs()
    elseif game.input.menu.menubags.bag == 3
        return getMachines()
    elseif game.input.menu.menubags.bag == 4
        return getBerries()
    else
        return getKeys()
    end
end

function getSelect(game::GameState)
    return game.input.menu.menubags.select[game.input.menu.menubags.bag]
end

function getAmountItems(game::GameState)
    return game.trainer.inventory[-game.input.menu.menubags.bag]
end

function getInvSlot(game::GameState,bag::Int,select::Int)
    return game.trainer.inventory[bag][select,:]
end

function getInvSlot(game::GameState)
    return game.trainer.inventory[game.input.menu.menubags.bag][
        game.input.menu.menubags.select[game.input.menu.menubags.bag],:]
end

function getInvSlotID(game::GameState,bag::Int,select::Int)
    return game.trainer.inventory[bag][select,1]
end

function getInvSlotID(game::GameState)
    return game.trainer.inventory[game.input.menu.menubags.bag][
        game.input.menu.menubags.select[game.input.menu.menubags.bag],1]
end

function getInvSlotAmount(game::GameState,bag::Int,select::Int)
    return game.trainer.inventory[bag][select,2]
end

function getInvSlotAmount(game::GameState)
    return game.trainer.inventory[game.input.menu.menubags.bag][
        game.input.menu.menubags.select[game.input.menu.menubags.bag],2]
end

function loadInventoryStrings!(game::GameState)
    game.str = []
    
    push!(game.str,readlines("str/ger/system_bag.txt"))
    push!(game.str,readlines("str/ger/item_names.txt"))
    push!(game.str,readlines("str/ger/item_texts.txt"))
end

function getInvChoiceStr(game::GameState)
    if game.input.menu.menubags.bag == 1
        return game.str[1][[9,10,12]]
    elseif game.input.menu.menubags.bag == 2
        return game.str[1][[10,13,12]]
    elseif game.input.menu.menubags.bag == 3
        return game.str[1][[9,10,12]]
    elseif game.input.menu.menubags.bag == 4
        return game.str[1][[9,10,12]]
    else
        return game.str[1][[9,11,12]]
    end
end

function getItem(id::Int)
    if 1 <= id <= 20
        return pokeballs[id]
    elseif id <= 100
        return items[id]
    elseif id <= 200
        return machines[id]
    elseif id <= 300
        return berries[id]
    else
        return keys[id]
    end
end