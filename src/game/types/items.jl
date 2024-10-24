

mutable struct MapItem
    id::UInt16
    
    type::UInt16
    flag::UInt16
    pos::Position
    # height::Int
    chunk::Position
    fg::Bool

    vis::Bool

    sprite::Symbol

    function MapItem()
        new(0,0,0,P(0,0),P(0,0),false,false,Symbol())
    end

    function MapItem(id,type,flag,pos,chunk,fg,vis,sprite)
        new(id,type,flag,pos,chunk,fg,vis,sprite)
    end
end