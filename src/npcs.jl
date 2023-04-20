# NPC related stuff

abstract type NPC end

abstract type NPCNormal <: NPC end

abstract type NPCTrainer <:NPC end

mutable struct NPCStatic <: NPCNormal
    id::UInt16

    pos::Position
    dir::Int
    spriteid::Int
    dialogue::Vector{String}
    pattern::Int

    # 0 up, down, left, right
    # 5 circ clockwise
    # 6 circ cclockwise
    # 7 rand
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

npctest = NPCStatic(
    1,
    P(110,30),
    2,
    1,
    ["Test 123","Ich bin eine hohle Nuss."],
    0
)