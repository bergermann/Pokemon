





function loadTeamStrings!(game::GameState; reset=true)
    reset && (game.str = [])
    
    push!(game.str,readlines("str/ger/system_pkmn.txt"))
end

function loadInventoryStrings!(game::GameState; reset::Bool=true)
    reset && (game.str = [])
    
    push!(game.str,readlines("str/ger/system_bag.txt"))
    push!(game.str,readlines("str/ger/item_names.txt"))
    push!(game.str,readlines("str/ger/item_texts.txt"))
end

function loadMapStrings!(game::GameState; reset=true)
    if reset
        game.str = []

        push!(game.str,readlines("str/ger/m$(game.maps.map.id).txt"))
        push!(game.str,readlines("str/ger/system_main.txt"))
    else
        game.str[1] = readlines("str/ger/m$(game.maps.map.id).txt")
    end
end