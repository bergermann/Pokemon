



struct Event
    id::UInt32

    px::Int; py::Int
    dx::Int; dy::Int
    cx::Int; cy::Int
    fg::Bool

    onpress::Bool
    dir::Int
    flags::FlagSet
    callback::Callback

    function Event(); new(0,0,0,0,0,0,0,false,false,0,FlagSet(),F0); end
    function Event(id,px,py,dx,dy,cx,cy,fg,onpress,dir,flags,callback);
        new(id,px,py,dx,dy,cx,cy,fg,onpress,dir,flags,callback); end
end

struct EventQueue
    sheets::Vector{Symbol}
    npcs::Vector{Symbol}
    sprites::Vector{Symbol}

    flags::Pokemon.FlagSet

    queue::Matrix{Int}

    function EventQueue()
        new([],[],[],FlagSet(),zeros(Int,10,0))
    end

    function EventQueue(sheets,npcs,sprites,flags,queue)
        new(sheets,npcs,sprites,flags,queue)
    end
end

mutable struct Events
    active::Bool
    c::Int
    idx::Int
    queue::EventQueue

    function Events()
        new(false,0,1,EventQueue())
    end

    function Events(active,c,idx,queue)
        new(active,c,idx,queue)
    end
end