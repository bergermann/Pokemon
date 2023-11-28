

abstract type Event end

mutable struct FlagEvent <: Event
    id::UInt8
    flag::UInt8
    flagtype::UInt8
    onpress::Bool
end

mutable struct CounterEvent
    id::UInt8
    counter::UInt8
    threshold::UInt16
    onpress::Bool
end

