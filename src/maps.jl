include("core.jl")
include("rendering.jl")



map0 = Map(0x00,0x00,"0",[],[(0x01,Position(112,28))],getTiles("tiles_exterior"),
    getTileMap("0",[:background1,:background2,:foreground1,:foreground2,:collision]),[],[])

map1 = Map(0x01,0x00,"1",[],[(0x00,Position(-112,-28))],getTiles("tiles_exterior"),
    getTileMap("1",[:background1,:background2,:foreground1,:foreground2,:collision]),[],[])
















