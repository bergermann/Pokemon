#list of pokemons

p001 = Pkmn(
    UInt16(001),
    "Bisasam",
    UInt8(0),
    Vector{UInt8}([0,1,7]),

    "",
    UInt16(00000),
    "",
    pokeball,

    Stats(Vector{UInt8}([45,49,49,65,65,45]),   #bv
            Vector{UInt8}([0,0,0,0,0,0]),       #dv
            Vector{UInt8}([0,0,0,0,0,0]),       #ev
            UInt8(0),                           #level
            UInt8(0)),                          #nature
    UInt8(0),
    
    Vector{Attack}([]),
    Vector{Tuple{Attack,UInt8}}([]),
    Vector{UInt8}([]),
    Vector{Attack}([])
)
