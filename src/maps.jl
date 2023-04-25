


map0 = Map(0x00,[:layer1,:layer2,:layer3,:layer4],"0",[],[
        (0x01,Position(112,28)),(0x01,Position(100,28)),(0x01,Position(60,28)),
        (0x01,Position(100,16))
    ],
    getTiles("tiles_exterior"),
    getTileMap("0",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [
        ["Wer das liest\\ist doof.","Aaron ist ein Eierkopf."],["Test 1 2 3...","Test 4 5 6"],
        ["Labor oder so\\Bitch nugget"],["▷:ÄÖÜäöü↑↓←→\\+ⓁⒶⒾⓃ_ "]
    ],[],[],[])

map1 = Map(0x01,[:layer1,:layer2,:layer3,:layer4],"1",[],[
    (0x00,Position(-112,-28))],getTiles("tiles_exterior"),
    getTileMap("1",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [["test"]],[],[],[])
















