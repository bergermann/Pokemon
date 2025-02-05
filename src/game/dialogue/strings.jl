





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
        
        str = readlines("str/ger/system_main.txt")
        str_ = split(str[1],' '); str[1] = str_[1]*game.p.name*str_[2]
        push!(game.str,str)
    else
        game.str[1] = []
    end

    return
end

function loadStringsBattle!(game::GameState)
    empty!(game.str)

    push!(game.str,readlines("str/ger/system_battle.txt"))
    push!(game.str,readlines("str/ger/system_types.txt"))

    return
end

function loadStringsDex!(game::GameState)
    empty!(game.str)

    push!(game.str,readlines("str/ger/system_dex.txt"))
    push!(game.str,readlines("str/ger/pkmn_names.txt"))
    
    return
end