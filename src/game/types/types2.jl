
include("inventory.jl")
include("pkmn.jl")
include("battle.jl")
include("game.jl")



const P0 = Pkmn(
    0x0000,
    "",
    G_NONE,
    false,
    0x00,

    "",
    0x0000,
    "",
    BALL_POKE,

    (Tnone,Tnone),
    Stats(zeros(0),zeros(6),0,XPtype(0),0,0),
    HSnormal,
    nothing,

    Atk[],
    Anone,

    0x00,
)

const PB0 = PkmnBattle(P0)