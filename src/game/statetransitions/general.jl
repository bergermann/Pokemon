


include("battle.jl")
include("map.jl")
include("input.jl")
include("menu.jl")



function stateSetInput!(game::GameState,args::Tuple{Symbol,Bool}...)
    for arg in args
        setfield!(game.input,arg[1],arg[2])
    end
end



