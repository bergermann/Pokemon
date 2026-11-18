# items (battleitems, medicine n such)

items = Dict{ItemID,Item}(
    POT_POTION  => MedicineHealth( 20,false,HS_NORMAL),   # trank
    POT_SUPER   => MedicineHealth( 50,false,HS_NORMAL),   # supertrank
    POT_HYPER   => MedicineHealth(200,false,HS_NORMAL),   # hypertrank
    POT_MAX     => MedicineHealth(100, true,HS_NORMAL),   # top trank
    POT_FULL    => MedicineHealth(100, true,HS_ALL),      # top genesung
    POT_WATER   => MedicineHealth( 50,false,HS_NORMAL),   # tafelwasser
    POT_SODA    => MedicineHealth( 60,false,HS_NORMAL),   # sprudel
    POT_LIMO    => MedicineHealth( 80,false,HS_NORMAL),   # limonade
    POT_MOO     => MedicineHealth(100,false,HS_NORMAL),   # kuh-muh milch
    POT_ROOT    => MedicineHealth( 50,false,HS_NORMAL),   # energiestaub
    POT_POWDER  => MedicineHealth(200,false,HS_NORMAL),   # kraftwurzel

    ST_POISON   => MedicineHealth(  0,false,HS_POISON),   # gegengift
    ST_BURN     => MedicineHealth(  0,false,HS_BURN),     # feuerheiler
    ST_PARA     => MedicineHealth(  0,false,HS_PARALYSE), # paraheiler
    ST_SLEEP    => MedicineHealth(  0,false,HS_SLEEP),    # aufwecker
    ST_ICE      => MedicineHealth(  0,false,HS_FROZEN),   # eisheiler
    ST_ALL      => MedicineHealth(  0,false,HS_ALL),      # hyperheiler
    ST_COOKIE   => MedicineHealth(  0,false,HS_ALL),      # lavakeks

    REV_REV     => MedicineHealth( 50, true,HS_FAINTED),  # beleber
    REV_MAX     => MedicineHealth(100, true,HS_FAINTED),  # top beleber
    REV_VITAL   => MedicineHealth(100, true,HS_FAINTED),  # vitalkraut

    AP_ETHER    => MedicineAP( 10,false),                # äther
    AP_ETHERTOP => MedicineAP(100,false),                # top äther
    AP_ELIX     => MedicineAP( 10, true),                # elixier
    AP_ELIXTOP  => MedicineAP(100, true),                # top-elixier

    B_LIFEORB   => BattleCarry(),
    B_EXBELT    => BattleCarry(),
)
