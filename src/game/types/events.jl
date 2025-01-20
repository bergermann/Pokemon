



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

const E0 = Event()