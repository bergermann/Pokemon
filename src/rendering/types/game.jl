
mutable struct PlayerData

end

mutable struct Controls
    dir::Int            # 1,2,3,4 = N,E,S,W
    pos::Position
    chunk::Position

    moving::Bool
    counter::Int

    function Controls(h::Int,w::Int,ch::Int,cw::Int,dir::Int=2)
        new(dir,P(h,w),P(ch,cw),false,0)
    end
end

mutable struct GameState
    frame::UInt32

    p::PlayerData
    im::Im
    ctrl::Controls
    m::MapData
end