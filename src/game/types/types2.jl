
include("inventory.jl")
include("pkmn.jl")
include("battle.jl")
include("game.jl")



const P0 = Pkmn(
    0x0000,
    "",
    Gnone,
    false,
    0x00,
    0x00,

    "",
    0x0000,
    "",
    Bpoke,

    (Tnone,Tnone),
    Stats(zeros(0),zeros(6),0,0,0),
    HSnormal,
    Inone,

    Atk[],
    Anone,

    0x00,
)

const PB0 = PkmnBattle(P0)