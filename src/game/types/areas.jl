
struct Area
    id::UInt16

    px::Int; py::Int
    dx::Int; dy::Int
    cx::Int; cy::Int
    fg::Bool

    data::Matrix{UInt16}

    function Area(); new(0,0,0,0,0,0,0,false,zeros(Int,0,4)); end
    function Area(id,px,py,dx,dy,cx,cy,fg,data); new(id,px,py,dx,dy,cx,cy,fg,data); end
end
