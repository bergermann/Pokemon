
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

    (T_NONE,T_NONE),
    Stats(zeros(0),zeros(6),0x00,XPtype(1),0,0),
    HS_NORMAL,
    nothing,

    Atk[],
    A_NONE,

    0x00,
)

const PB0 = PkmnBattle(P0)