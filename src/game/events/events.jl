
# include.(joinpath.("events",readdir("src/game/events/events")))
include("events/heal.jl")

function evalEvent(game::GameState,event::Event)
    if (event.dir != 0 && event.dir != game.ctrl.dir) && !evalFlagSet(game,event.flags)
        return
    end

    evalCallback(game,event.callback)

    return
end


const E0 = Event()
const events = Base.ImmutableDict(
    :healcenter => (FlagSet(; flags=[(0xc8,false,1)]),
        F(eventHealCenter!)),
)