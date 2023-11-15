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
    # 5 line 
    # 6 angle
    # 7 T
    # 8 T clockwise
    # 9 T cclockwise
    # 10 circ clockwise
    # 11 circ cclockwise
    # 12 rand

    function NPCStatic()
        new(0,P(0,0),1,0,Symbol(),0,0,0,0,0)
    end

    function NPCStatic(id,pos,dir,sprite,spriteid,pattern,parg,c,dialogue,dialoguelen)
        new(id,pos,dir,sprite,spriteid,pattern,parg,c,dialogue,dialoguelen)
    end
end

mutable struct NPCMove <: NPCNormal
    id::UInt16

    pos::Position
    homepos::Position
    dir::Int
    sprite::Int
    spriteid::Symbol
    
    pattern::Int
    parg1::Int
    parg2::Int
    c1::Int
    c2::Int

    dialogue::Int
    dialoguelen::Int

    # patterns
    # 1         linear      dirneg  dirpos
    # 2         l shape     arm1    arm2
    # 3         rect cw     ax1     ax2
    # 4         rect ccw    ax1     ax2
    # 5         rand        freq    max

    
    function NPCMove()
        
        new(0,P(0,0),P(0,0),1,0,Symbol(),0,0,0,0,0,0,0)
    end

    function NPCMove(id,pos,homepos,dir,sprite,spriteid,pattern,parg1,parg2,
            c1,c2,dialogue,dialoguelen)
        
        new(id,pos,homepos,dir,sprite,spriteid,pattern,parg1,parg2,
            c1,c2,dialogue,dialoguelen)
    end
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