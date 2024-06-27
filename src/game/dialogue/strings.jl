





function loadTeamStrings!(game::GameState; reset::Bool=true)
    reset && (game.str = [])
    
    push!(game.str,readlines("str/ger/system_pkmn.txt"))

    return
end

function loadInventoryStrings!(game::GameState; reset::Bool=true)
    reset && (game.str = [])
    
    push!(game.str,readlines("str/ger/system_bag.txt"))
    push!(game.str,readlines("str/ger/item_names.txt"))
    push!(game.str,readlines("str/ger/item_texts.txt"))

    return
end

function loadMapStrings!(game::GameState; reset::Bool=true)
    if reset
        game.str = []

        push!(game.str,[])
        
        str = split(readlines("str/ger/system_main.txt")[],' ')
        push!(game.str,[str[1]*game.p.name*str[2]])
    else
        game.str[1] = []
    end

    return
end