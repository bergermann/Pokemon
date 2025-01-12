
function evalFlagSet(game::GameState,flags::FlagSet)::Bool
    if isempty(flags); return true; end

    N1, N2 = size(f)

    f = true
    for i in 1:N1
        f &= getfield(game.flags,flags.flagtypes)[flags.flags[i]] == flags.flagvals[i]
    end

    c = true
    for i in 1:N2
        c_ = game.counters[flags.counters[i]]
        cv = flags.countervals[i]
        ct = flags.countertypes[i]
        c &= (c_<=cv && ct==-1) || (c_==cv && ct==0) || (c_>=cv && ct==1)
    end

    return f && c
end
