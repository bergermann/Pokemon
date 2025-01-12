
struct Teleport
    id::UInt16

    px::Int; py::Int
    dx::Int; dy::Int
    cx::Int; cy::Int
    tx::Int; ty::Int
    tcx::Int; tcy::Int
    fg::Bool

    transition::UInt8

    function Teleport(); new(0,0,0,0,0,0,0,0,0,0,0,false,0); end
    function Teleport(id,px,py,dx,dy,cx,cy,tx,ty,tcx,tcy,fg,transition); 
        new(id,px,py,dx,dy,cx,cy,tx,ty,tcx,tcy,fg,transition); end
end
