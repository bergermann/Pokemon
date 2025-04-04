
function evalFlagSet(game::GameState,flags::FlagSet)::Bool
    if isempty(flags); return true; end

    N1, N2, N3, N4, N5 = size(flags)

    f = true
    for i in 1:N1
        f &= getfield(game.flags,flags.flagtypes[i])[flags.flags[i]] == flags.flagvals[i]
    end

    c = true
    for i in 1:N2
        c_ = game.counters[flags.counters[i]]
        cv = flags.countervals[i]
        ct = flags.countertypes[i]
        c &= (c_<=cv && ct==-1) || (c_==cv && ct==0) || (c_>=cv && ct==1)
    end

    seen = true
    for i in 1:N3
        seen &= game.p.dex[flags.hasseen[i],1]
    end

    caught = true
    for i in 1:N4
        caught &= game.p.dex[flags.hascaught[i],2]
    end

    t = true
    for i in 1:N5
        t_ = false
        for j in eachindex(game.p.pokemon)
            if game.p.pokemon[j].id == flags.inteam[i]; t_ = true; break; end
        end

        t &= t_
    end

    return *(f,c,seen,caught,t)
end
