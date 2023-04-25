# types for npcs on map stuff

mutable struct NPCStatic <: NPCNormal
    id::UInt16

    pos::Position
    dir::Int
    spriteid::Int
    # dialogue::Vector{String}
    dialogue::Int
    pattern::Int

    # 0 up, down, left, right
    # 5 circ clockwise
    # 6 circ cclockwise
    # 7 rand

    function NPCStatic()
        new(0,P(0,0),1,0,0,0)
    end

    function NPCStatic(id,pos,dir,spriteid,dialogue,pattern)
        new(id,pos,dir,spriteid,dialogue,pattern)
    end
end

mutable struct NPCMove <: NPCNormal
    id::UInt16

    pos::Position
    dir::Int
    sprite::Sprite
    dia::Int
    pattern::Int
end

mutable struct TrainerStatic <: NPCTrainer
    id::UInt16

    pos::Position
    dir::Int
    sprite::Sprite
    dia::Int

    pattern::Int
    range::Int

    reward::Int
end

mutable struct TrainerMove <: NPCTrainer
    id::UInt16

    pos::Position
    dir::Int
    sprite::Sprite
    dia::Int

    pattern::Int
    range::Int

    reward::Int
end