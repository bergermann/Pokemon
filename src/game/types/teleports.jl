
struct Teleport
    id::UInt16

    px::Int; py::Int
    dx::Int; dy::Int
    cx::Int; cy::Int
    tx::Int; ty::Int
    tmapx::Int; tmapy::Int
    fg::Bool

    transition::UInt8

    function Teleport(); new(0,0,0,0,0,0,0,0,0,0,0,false,0); end
    function Teleport(id,px,py,dx,dy,cx,cy,tx,ty,tmapx,tmapy,fg,transition); 
        new(id,px,py,dx,dy,cx,cy,tx,ty,tmapx,tmapy,fg,transition); end
end
