# # item and inventory stuff

include("items.jl")
include("pokeballs.jl")
include("machines.jl")
include("berries.jl")
include("keys.jl")



function getSelect(game::GameState)
    return game.ctrl.input.menu.menubags.select[game.ctrl.input.menu.menubags.bag]
end

function getSelect(m::MenuBags)
    return m.select[m.bag]
end

function getAmountItems(game::GameState)
    return game.p.inventory[-game.ctrl.input.menu.menubags.bag]
end

function getAmountItems(game::GameState,m::MenuBags)
    return game.p.inventory[-m.bag]
end

function getInvSlot(game::GameState,bag::Int,select::Int)
    return game.p.inventory[bag][select,:]
end

function getInvSlot(game::GameState)
    return game.p.inventory[game.ctrl.input.menu.menubags.bag][
        game.ctrl.input.menu.menubags.select[game.ctrl.input.menu.menubags.bag],:]
end

function getInvSlot(game::GameState,m::MenuBags)
    return game.p.inventory[m.bag][m.select[m.bag],:]
end

function getInvSlotID(game::GameState,bag::Int,select::Int)
    return game.p.inventory[bag][select,1]
end

function getInvSlotID(game::GameState)
    return game.p.inventory[game.ctrl.input.menu.menubags.bag][
        game.ctrl.input.menu.menubags.select[game.ctrl.input.menu.menubags.bag],1]
end

function getInvSlotID(game::GameState,m::MenuBags)
    return game.p.inventory[m.bag][m.select[m.bag],1]
end

function getInvSlotAmount(game::GameState,bag::Int,select::Int)
    return game.p.inventory[bag][select,2]
end

function getInvSlotAmount(game::GameState)
    return game.p.inventory[game.ctrl.input.menu.menubags.bag][
        game.ctrl.input.menu.menubags.select[game.ctrl.input.menu.menubags.bag],2]
end

function getInvChoiceStr(game::GameState)
    if !game.battle.active
        if game.ctrl.input.menu.menubags.bag == 1
            return game.str[1][[9,10,12]]
        elseif game.ctrl.input.menu.menubags.bag == 2
            return game.str[1][[10,13,12]]
        elseif game.ctrl.input.menu.menubags.bag == 3
            return game.str[1][[9,10,12]]
        elseif game.ctrl.input.menu.menubags.bag == 4
            return game.str[1][[9,10,12]]
        else
            return game.str[1][[9,11,12]]
        end
    else
        m = game.ctrl.input.battlebags

        if m.bag == 1
            t = getItem(game,m)
            if isa(t,MedicineHealth) ||
                    isa(t,MedicineAP)
                
                return game.str[1][[9,12]]
            else
                return game.str[1][12]
            end
        elseif m.bag == 2
            return game.str[1][[9,12]]
        elseif m.bag == 3
            return game.str[1][12]
        elseif m.bag == 4
            return game.str[1][[9,12]]
        else
            return game.str[1][12]
        end
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

function getItem(game::GameState,m::MenuBags)
    return getItem(Int(getInvSlotID(game,m)))
end
