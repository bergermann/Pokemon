


mutable struct Event
    id::UInt8
    flags::NTuple
    flagvals::NTuple
    flagtypes::NTuple
    counters::NTuple
    countervals::NTuple
    onpress::Bool
    dir::Int

    function Event()
        new(0,(),(),(),(),(),false,0)
    end

    function Event(id)
        new(id,(),(),(),(),(),false,0)
    end

    function Event(id,flags,flagtype,flagvals,counters,countervals,onpress,dir)
        new(id,flags,flagtype,flagvals,counters,countervals,onpress,dir)
    end
end
