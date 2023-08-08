# # item and inventory stuff

include("items/items.jl")
include("items/pokeballs.jl")
include("items/machines.jl")
include("items/berries.jl")
include("items/keys.jl")



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