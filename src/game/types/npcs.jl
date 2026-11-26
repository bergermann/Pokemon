# types for npcs on map stuff

mutable struct NPC
    id::UInt32

    pos1::Position      # current position
    chunk1::Position

    pos2::Position      # next position
    chunk2::Position

    mpos::Position      # planned position
    mchunk::Position

    hpos::Position      # home position
    hchunk::Position

    height::Int
    fg::Bool
    dir::Int

    sprite::Symbol
    spriteid::Int
    
    dynamic::Bool
    pattern::Int
    parg1::Int
    parg2::Int
    c1::Int
    c2::Int

    trainerid::UInt16
    range::Int

    str::Vector{String}
    event::Symbol

    function NPC()
        new(
            0,              # id
            P(0,0),P(0,0),  # start position
            P(0,0),P(0,0),  # end position
            P(0,0),P(0,0),  # planned position
            P(0,0),P(0,0),  # home position
            0,false,0,
            Symbol(),0,false,
            0,0,0,0,0,
            0,0,
            [],Symbol())
    end

    function NPC(
            id,
            pos1,chunk1,
            pos2,chunk2,
            mpos,mchunk,
            hpos,hchunk,
            height,fg,dir,
            sprite,spriteid,
            dynamic,pattern,parg1,parg2,c1,c2,
            trainerid,range,
            str,event
        )
        
        new(
            id,
            pos1,chunk1,
            pos2,chunk2,
            mpos,mchunk,
            hpos,hchunk,
            height,fg,dir,
            sprite,spriteid,
            dynamic,pattern,parg1,parg2,c1,c2,
            trainerid,range,
            str,event
        )
    end
end
