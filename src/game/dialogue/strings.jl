


# function loadStrings!(game::GameState,path::String; reset::Bool=false)
#     reset && empty!(game.str)

#     push!(game.str,readlines(joinpath(PATH,"str/ger",path)))

#     return
# end


function loadStringsTeam!(game::GameState; reset::Bool=true)
    reset && empty!(game.str)
    
    push!(game.str,readlines("str/ger/system_pkmn.txt"))

    return
end

function loadStringsInventory!(game::GameState; reset::Bool=true)
    reset && empty!(game.str)
    
    push!(game.str,readlines(joinpath(PATH,"str/ger/system_bag.txt")))

    push!(game.str,readlines(joinpath(PATH,"str/ger/items/items.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/balls.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/machines.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/berries.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/keys.txt")))
    
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/items_text.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/balls_text.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/machines_text.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/berries_text.txt")))
    push!(game.str,readlines(joinpath(PATH,"str/ger/items/keys_text.txt")))

    # push!.(game.str[(1+1):(1+5)],game.str[1][6])
    push!.(game.str[(1+5):end],game.str[1][7])

    return
end

function loadStringsMap!(game::GameState; reset::Bool=true)
    if reset
        empty!(game.str)

        push!(game.str,[])
        
        str = readlines(joinpath(PATH,"str/ger/system_main.txt"))
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

    push!(game.str,readlines("str/ger/items/items.txt"))
    push!(game.str,readlines("str/ger/items/balls.txt"))
    push!(game.str,readlines("str/ger/items/berries.txt"))
    push!(game.str,readlines("str/ger/items/machines.txt"))
    push!(game.str,readlines("str/ger/items/keys.txt"))

    return
end

function loadStringsDex!(game::GameState)
    empty!(game.str)

    push!(game.str,readlines("str/ger/system_dex.txt"))
    # push!(game.str,readlines("str/ger/pkmn_names.txt"))
    
    return
end

function loadStringsEvolve!(game::GameState)
    empty!(game.str)
    
    push!(game.str,readlines("str/ger/system_evolve.txt"))

    return
end