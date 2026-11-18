

@enum Gender::UInt8 G_NONE G_MALE G_FEMALE

@enum PType::UInt8 begin
    T_NONE = 0x00
    T_NORMAL
    T_GRASS
    T_FIRE
    T_WATER
    T_FIGHT
    T_FLYING
    T_POISON
    T_GROUND
    T_ROCK
    T_BUG
    T_GHOST
    T_ELECTRIC
    T_PSYCHO
    T_ICE
    T_DRAGON
    T_DARK
    T_STEEL
    T_FAIRY
end

@enum XPtype::UInt8 begin
    XP_NONE = 0x00
    XP_ERRATIC
    XP_FAST
    XP_SEMIFAST
    XP_SEMISLOW
    XP_SLOW
    XP_FLUCTUATE
end

@enum HealthStatus::UInt8 begin
    HS_NORMAL = 0x00
    HS_POISON
    HS_BURN
    HS_PARALYSE
    HS_SLEEP
    HS_FROZEN
    HS_FAINTED
    HS_ALL
end

# @enum Nature::UInt8 begin

# end

@enum EvolType::UInt16 begin
    EV_NONE = 0x0001
    EV_LEVEL
    EV_ITEM
    EV_ITEMHELD
    EV_ITEMTRADE
    EV_TRADE
    EV_LOVE
    EV_ATTACK
    EV_AREA
end

@enum AttackClass::UInt8 begin
    AC_NONE = 0x00
    AC_PHYS
    AC_SPEC
    AC_STAT
end