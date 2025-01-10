
# mutable struct Event
#     id::UInt8
#     flags::NTuple
#     flagvals::NTuple
#     flagtypes::NTuple
#     counters::NTuple
#     countervals::NTuple
#     onpress::Bool
#     dir::Int

#     function Event()
#         new(0,(),(),(),(),(),false,0)
#     end

#     function Event(id)
#         new(id,(),(),(),(),(),false,0)
#     end

#     function Event(id,flags,flagtype,flagvals,counters,countervals,onpress,dir)
#         new(id,flags,flagtype,flagvals,counters,countervals,onpress,dir)
#     end
# end

struct Event
    id::UInt16

    px::Int; py::Int
    dx::Int; dy::Int
    cx::Int; cy::Int
    fg::Bool

    flag::UInt16
    onpress::Bool
    callback::Callback

    function Event(); new(0,0,0,0,0,0,0,false,0,false,F0); end
    function Event(id,px,py,dx,dy,cx,cy,fg,flag,onpress,callback);
        new(id,px,py,dx,dy,cx,cy,fg,flag,onpress,callback); end
end
