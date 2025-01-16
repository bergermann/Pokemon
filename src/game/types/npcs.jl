# types for npcs on map stuff

mutable struct NPC
    id::UInt32

    pos1::Position
    pos2::Position
    mpos::Position
    hpos::Position
    height::Int
    chunk::Position
    mchunk::Position
    hchunk::Position
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

    function NPC()
        new(0,P(0,0),P(0,0),P(0,0),P(0,0),0,P(0,0),P(0,0),P(0,0),false,0,Symbol(),0,false,
            0,0,0,0,0,0,0,[])
    end

    function NPC(id,pos1,pos2,mpos,hpos,height,chunk,mchunk,hchunk,fg,dir,sprite,spriteid,
                        dynamic,pattern,parg1,parg2,c1,c2,trainerid,range,str)
        
        new(id,pos1,pos2,mpos,hpos,height,chunk,mchunk,hchunk,fg,dir,sprite,spriteid,
            dynamic,pattern,parg1,parg2,c1,c2,trainerid,range,str)
    end
end

# mutable struct TrainerStatic <: NPCTrainer
#     id::UInt32

#     pos1::Position
#     pos2::Position
#     mpos::Position
#     height::Int
#     chunk::Position
#     dir::Int

#     sprite::Symbol

#     pattern::Int
#     parg::Int
#     c::Int
#     range::Int

#     str::Vector{String}
# end

# mutable struct TrainerMove <: NPCTrainer
#     id::UInt32

#     pos::Position
#     dir::Int
#     sprite::Symbol
#     dia::Int

#     pattern::Int
#     range::Int

#     reward::Int
# end