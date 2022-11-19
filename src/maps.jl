#include("core.jl")
#include("rendering.jl")




map0 = Map(0x00,[:background1,:background2,:foreground1,:foreground2],"0",[],[
        (0x01,Position(112,28)),(0x01,Position(100,28)),(0x01,Position(60,28)),
        (0x01,Position(100,16))
    ],
    getTiles("tiles_exterior"),
    getTileMap("0",[:background1,:background2,:foreground1,:foreground2,:collision]),
    [
        ["Wer das liest\\ist doof."],["Test 1 2 3...","Test 4 5 6"],
        ["Labor oder so\\Bitch nugget"],["▷:ÄÖÜäöü↑↓←→","+ⓁⒶⒾⓃ_ "]
    ],[],[])

map1 = Map(0x01,[:background1,:background2,:foreground1,:foreground2],"1",[],[
    (0x00,Position(-112,-28))],getTiles("tiles_exterior"),
    getTileMap("1",[:background1,:background2,:foreground1,:foreground2,:collision]),
    [["test"]],[],[])
















