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

function getBag(id::Int)
    if 1 <= id <= 30            # 30
        return 2
    elseif 31 <= id <= 200      # 170
        return 1
    elseif 201 <= id <= 320     # 120
        return 3
    elseif 321 <= id <= 400     # 80
        return 4
    else                        # 100
        return 5 
    end
end

function getItem(id::Int)
    if 1 <= id <= 30            # 30
        return pokeballs[id]
    elseif 31 <= id <= 200      # 170
        return items[id]
    elseif 201 <= id <= 320
        return machines[id]     # 120
    elseif 321 <= id <= 400
        return berries[id]      # 80
    else
        return keyitems[id]         # 100
    end
end

function getItem(game::GameState,m::MenuBags)
    return getItem(Int(getInvSlotID(game,m)))
end

function getSelectedItem(game::GameState,m::MenuBags)
    if m.select[m.bag] >= game.p.inventory[-m.bag]+1
        return 500
    else
        return Int(game.p.inventory[m.bag][m.select[m.bag],1])
    end
end

function addItem!(game::GameState,id::Int,amount::Int)
    b = getBag(id)
    idx = findfirst(isequal(id),game.p.inventory[b][:,1])
    if isnothing(idx); idx = game.p.inventory[-b]+1; game.p.inventory[-b][idx,1] = id; end
    game.p.inventory[b][idx,2] += amount
    
    return
end

function removeItem!(game::GameState,id::Int,amount::Int)
    
    return
end