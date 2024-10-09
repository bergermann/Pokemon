# types for npcs on map stuff

# abstract type NPC end

# abstract type NPCNormal <: NPC end

# abstract type NPCTrainer <:NPC end


# mutable struct NPCStatic <: NPCNormal
#     id::UInt16

#     pos::Position
#     chunk::Position
#     fg::Bool
#     dir::Int

#     sprite::Symbol

#     pattern::Int
#     parg::Int
#     c::Int

#     str::Vector{String}

#     function NPCStatic()
#         new(0,P(0,0),P(0,0),false,0,Symbol(),0,0,0,[])
#     end

#     function NPCStatic(id,pos,chunk,fg,dir,sprite,pattern,parg,c,str)
#         new(id,pos,chunk,fg,dir,sprite,pattern,parg,c,str)
#     end
# end

mutable struct NPC# <: NPCNormal
    id::UInt16

    pos1::Position
    pos2::Position
    mpos::Position
    homepos::Position
    height::Int
    chunk::Position
    mchunk::Position
    homechunk::Position
    fg::Bool
    dir::Int

    sprite::Symbol
    
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
        new(0,P(0,0),P(0,0),P(0,0),P(0,0),0,P(0,0),P(0,0),P(0,0),false,0,Symbol(),false,
            0,0,0,0,0,0,0,[])
    end

    function NPC(id,pos1,pos2,mpos,homepos,height,chunk,mchunk,homechunk,fg,dir,sprite,
                        dynamic,pattern,parg1,parg2,c1,c2,trainerid,range,str)
        
        new(id,pos1,pos2,mpos,homepos,height,chunk,mchunk,homechunk,fg,dir,sprite,
            dynamic,pattern,parg1,parg2,c1,c2,trainerid,range,str)
    end
end

# mutable struct TrainerStatic <: NPCTrainer
#     id::UInt16

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
#     id::UInt16

#     pos::Position
#     dir::Int
#     sprite::Symbol
#     dia::Int

#     pattern::Int
#     range::Int

#     reward::Int
# end