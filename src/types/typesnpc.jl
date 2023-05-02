# types for npcs on map stuff

mutable struct NPCStatic <: NPCNormal
    id::UInt16

    pos::Position
    dir::Int
    sprite::Int
    spriteid::Symbol
    pattern::Int
    parg::Int
    c::Int
    dialogue::Int
    dialoguelen::Int

    # patterns
    # 0 dont return
    # 1 2 3 4 return to
    # 5 circ clockwise
    # 6 circ cclockwise
    # 7 rand

    function NPCStatic()
        new(0,P(0,0),1,Symbol(),0,0,0,0,0)
    end

    function NPCStatic(id,pos,dir,sprite,spriteid,pattern,parg,c,dialogue,dialoguelen)
        new(id,pos,dir,sprite,spriteid,pattern,parg,c,dialogue,dialoguelen)
    end
end

mutable struct NPCMove <: NPCNormal
    id::UInt16

    pos::Position
    dir::Int
    sprite::Sprite
    dia::Int
    pattern::Int
    c::Int
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