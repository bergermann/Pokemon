



struct Event
    id::UInt16

    px::Int; py::Int
    dx::Int; dy::Int
    cx::Int; cy::Int
    fg::Bool

    onpress::Bool
    dir::Int
    flags::FlagSet
    callback::Callback

    function Event(); new(0,0,0,0,0,0,0,false,0,false,F0); end
    function Event(id,px,py,dx,dy,cx,cy,fg,flag,onpress,callback);
        new(id,px,py,dx,dy,cx,cy,fg,flag,onpress,callback); end
end
