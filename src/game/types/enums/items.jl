
@enum ItemID::UInt8 begin
    POT_POTION = 0x01
    POT_SUPER
    POT_HYPER
    POT_MAX
    POT_FULL
    POT_WATER
    POT_SODA
    POT_LIMO
    POT_MOO
    POT_ROOT
    POT_POWDER

    ST_POISON
    ST_BURN
    ST_PARA
    ST_SLEEP
    ST_ICE
    ST_ALL
    ST_COOKIE

    REV_REV
    REV_MAX
    REV_VITAL

    AP_ETHER
    AP_ETHERTOP
    AP_ELIX
    AP_ELIXTOP

    B_LIFEORB
    B_EXBELT
    B_LUCKYEGG
end

@enum BallID::UInt8 begin
    BALL_POKE = 0x01
    BALL_GREAT
    BALL_ULTRA
    BALL_MASTER
    BALL_DIVE
    BALL_LUXURY
    BALL_NEST
    BALL_NET
    BALL_PREMIER
    BALL_REPEAT
    BALL_SAFARI
    BALL_TIMER
end

@enum MachineID::UInt8 begin
    TM_001 = 0x01
    TM_002
end

@enum BerryID::UInt8 begin
    BERRY_ORAN = 0x01
    BERRY_PECHA
end

@enum KeyID::UInt8 begin
    KEY_BIKE = 0x01
    KEY_KEYS
end

const Items = Union{Nothing,ItemID,BallID,MachineID,BerryID,KeyID}
