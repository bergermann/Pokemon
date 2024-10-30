





function loadStringsTeam!(game::GameState; reset::Bool=true)
    reset && (game.str = [])
    
    push!(game.str,readlines("str/ger/system_pkmn.txt"))

    return
end

function loadStringsInventory!(game::GameState; reset::Bool=true)
    reset && (game.str = [])
    
    push!(game.str,readlines("str/ger/system_bag.txt"))
    push!(game.str,readlines("str/ger/item_names.txt"))
    push!(game.str,readlines("str/ger/item_texts.txt"))

    return
end

function loadStringsMap!(game::GameState; reset::Bool=true)
    if reset
        empty!(game.str)

        push!(game.str,[])
        
        str = split(readlines("str/ger/system_main.txt")[],' ')
        push!(game.str,[str[1]*game.p.name*str[2]])
    else
        game.str[1] = []
    end

    return
end

function loadStringsBattle!(game::GameState)
    empty!(game.str)

    push!(game.str,readlines("str/ger/system_battle.txt"))

    return
end