
function loadMap(game::GameState)
    # replace the map dict with these two functions
end

function getMap()
    # replace the map dict with these two functions
end

function getMaps(id::UInt8)
    map = maps[id]

    return Maps(map,[(map=maps[n.id],offset=n.offset) for n in map.neighbours])
end



function setNeighbours!(game)
        
end



function checkMapExit!(game::GameState,movepos::Position)
    col = game.maps.map.tilemap.collision[movepos.h,movepos.w]

    if col ∈ 0x14:0x3b
        return game.maps.map.exits[col-0x13]
    end
end



function enterMap!(game::GameState,exit::Exit)
    game.maps.map = game.maps.neighbours[
        findfirst(x->x.id==exit.targetid,game.maps.neighbours)]

    setNeighbours!(game)
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
    getTileMap("0",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x01,P(-120,-28))]
)


map1 = Map(
    0x01,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x00,0x00,P(-112,-28),false,emptyCallback),
        Exit(0x02,0x01,P(0,0),true,emptyCallback),
    ],
    "tiles_exterior",
    getTileMap("1",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x00,P(120,28))]
)

maps = Base.ImmutableDict(
    0x00 => map0,
    0x01 => map1
)

















