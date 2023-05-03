



function loadMapStrings(mapid::Integer)
    return readlines("str/m$mapid.txt")
end

map0 = Map(0x00)
map0.exits = [
    (0x01,Position(112,28)),(0x01,Position(100,28)),(0x01,Position(60,28)),
    (0x01,Position(100,16))
]

map1 = Map(0x01)
map1.exits = [(0x00,Position(-112,-28))]
















