

mutable struct Sign
    id::UInt32
    
    pos::Position
    chunk::Position
    # height::Int
    fg::Bool

    str::Vector{String}

    function Sign()
        new(0,P(0,0),P(0,0),false,[])
    end

    function Sign(id,pos,chunk,fg,str)
        new(id,pos,chunk,fg,str)
    end
end