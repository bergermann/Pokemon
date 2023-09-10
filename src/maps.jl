
function loadMap(game::GameState)

end

function getMap()
    
end

function getMaps(id::UInt8)
    map = maps[id]

    return Maps(map,[maps[n.id] for n in map.neighbours])
end

function enterMap!(game::GameState,exit::Exit)
    
end




map0 = Map(
    0x00,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x03,0x01,P(0,0),true,emptyCallback),
        Exit(0x03,0x01,P(0,0),true,emptyCallback),
        Exit(0x03,0x01,P(0,0),true,emptyCallback),
        Exit(0x01,0x00,P(100,16),false,emptyCallback)
    ],
    "tiles_exterior",
    getTileMap("$id",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x01,P(100,16))]
)


map1 = Map(
    0x01,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x00,0x00,P(-112,-28),false,emptyCallback),
        Exit(0x02,0x01,P(0,0),true,emptyCallback),
    ],
    "tiles_exterior",
    getTileMap("$id",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x00,P(-112,-28))]
)

maps = Base.ImmutableDict(
    0x00 => map0,
    0x01 => map1
)

















