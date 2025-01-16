

mutable struct Object
    id::UInt32
    
    type::UInt8
    pos::Position
    # height::Int
    chunk::Position
    fg::Bool

    c::Int

    sprite::Symbol

    function Object()
        new(0,0,P(0,0),P(0,0),false,Symbol())
    end

    function Object(id,type,pos,chunk,fg,c,sprite)
        new(id,type,pos,chunk,fg,c,sprite)
    end
end