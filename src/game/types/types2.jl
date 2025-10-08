
include("inventory.jl")
include("pkmn.jl")
include("battle.jl")
include("game.jl")



const P0 = Pkmn(
    0x0000,
    "",
    0x00,
    false,
    0x00,
    0x00,

    "",
    0x0000,
    "",
    0x00,

    (0x00,0x00),
    Stats(zeros(0),zeros(6),0,0,0),
    0x00,
    0,

    Atk[],
    0x00,

    0x00,
)

const PB0 = PkmnBattle(P0)