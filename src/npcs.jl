# NPC related stuff

abstract type NPC end

abstract type NPCNormal <: NPC end

abstract type NPCTrainer <:NPC end

mutable struct NPCStatic <: NPCNormal
    id::UInt16

    pos::Position
    dir::Int
    sprite::Sprite
    dia::Int
    pattern::Int
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