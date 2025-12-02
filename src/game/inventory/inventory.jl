# # item and inventory stuff

include("items.jl")
include("pokeballs.jl")
include("machines.jl")
include("berries.jl")
include("keys.jl")

function getInvChoiceStr(game::GameState,m::MenuBags)
    if game.battle.active
        if m.bag == 1
            t = getItem(game,m)
            if isa(t,MedicineHealth) || isa(t,MedicineAP)
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
    elseif game.ctrl.input.menu.menupkmn.sub

    else
        if m.bag == 1
            return game.str[1][[9,10,12]]
        elseif m.bag == 2
            return game.str[1][[10,13,12]]
        elseif m.bag == 3
            return game.str[1][[9,10,12]]
        elseif m.bag == 4
            return game.str[1][[9,10,12]]
        else
            return game.str[1][[9,11,12]]
        end
    end

    return String[]
end

function getBag(item::Items)
    if item isa ItemID
        return 1
    elseif item isa BallID
        return 2
    elseif item isa MachineID
        return 3
    elseif item isa BerryID
        return 4
    elseif item isa KeyID
        return 5
    end

    return -1
end

function itemIdx(x::Items)::Int
    if x isa ItemID
        return Integer(x)+1
    elseif x isa BallID
        return Integer(x)+160
    elseif x isa MachineID
        return Integer(x)+200
    elseif x isa BerryID
        return Integer(x)+320
    elseif x isa KeyID
        return Integer(x)+400
    else
        return 1
    end
end

function getItem(item::Items)::ItemType
    if item isa ItemID
        return items[item]
    elseif item isa BallID
        return pokeballs[item]
    elseif item isa MachineIDID
        return machines[item]
    elseif item isa BerryID
        return berries[item]
    elseif item isa KeyID
        return keys[item]
    end
end

function getItem(game::GameState,m::MenuBags)
    return getItem(getSelectedItem(game,m))
end

function getSelectedItem(game::GameState,m::MenuBags)::Items
    if m.select[m.bag] >= length(game.p.inventory[m.bag])+1
        return
    else
        return game.p.inventory[m.bag][m.select[m.bag]].id
    end
end

function hasitem(game::GameState,item::Items,amount::Int=1)
    b = getBag(item); idx = findfirst(item_->item_.id==item,game.p.inventory[b])

    return !isnothing(idx) && game.p.inventory[b][idx].amount >= amount
end

function addItem!(game::GameState,item::Items,amount::Int=1)
    b = getBag(item); idx = findfirst(item_->item_.id==item,game.p.inventory[b])

    if isnothing(idx)
        push!(game.p.inventory[b],ItemP(item,amount))
    else
        game.p.inventory[b][idx].amount += amount
    end
    
    return
end

function removeItem!(game::GameState,item::Items,amount::Int=1)
    b = getBag(item); idx = findfirst(item_->item_.id==item,game.p.inventory[b])

    @assert !isnothing(idx) "Item to be removed not found."
    @assert game.p.inventory[b].amount >= amount  "Not enough items to remove."

    if game.p.inventory[b].amount > amount
        game.p.inventory[b][idx].amount -= amount
    else
        popat!(game.p.inventory[b],idx)
    end

    return
end