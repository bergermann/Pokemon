
include.(readdir("events/"))


function evalEvent(game::GameState,event::Event)
    if event.onpress != 0 && event.dir != game.direction
        return
    end

    for i in eachindex(event.flags)
        if event.flagvals[i] !=
                getfield(game.flags,event.flagtypes[i])[event.flags[i]]
            
            return
        end
    end

    for i in eachindex(event.counters)
        if event.countervals[i] > game.flags.counters[event.counters[i]]
            return
        end
    end

    events[event.id](game)

    return
end



const events = Base.ImmutableDict(
    :healcenter => (0xc8,F(eventHealCenter!)),
)