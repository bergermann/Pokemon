# items (battleitems, medicine n such)

items = Dict{Int,Item}(
    31 => MedicineHealth(20,false,0),   # trank
    32 => MedicineHealth(50,false,0),   # supertrank
    33 => MedicineHealth(200,false,0),  # hypertrank
    34 => MedicineHealth(100,true,0),   # top trank
    35 => MedicineHealth(100,true,6),   # top genesung
    36 => MedicineHealth(50,false,0),   # tafelwasser
    37 => MedicineHealth(60,false,0),   # sprudel
    38 => MedicineHealth(80,false,0),   # limonade
    39 => MedicineHealth(100,false,0),  # kuh-muh milch
    40 => MedicineHealth(50,false,0),   # energiestaub
    41 => MedicineHealth(200,false,0),  # kraftwurzel

    42 => MedicineHealth(0,false,1),    # gegengift
    43 => MedicineHealth(0,false,2),    # feuerheiler
    44 => MedicineHealth(0,false,3),    # paraheiler
    45 => MedicineHealth(0,false,4),    # aufwecker
    46 => MedicineHealth(0,false,5),    # eisheiler
    47 => MedicineHealth(0,false,6),    # hyperheiler
    48 => MedicineHealth(0,false,6),    # heilpuder
    49 => MedicineHealth(0,false,6),    # lavakeks

    50 => MedicineHealth(50,true,7),    # beleber
    51 => MedicineHealth(100,true,7),   # top beleber
    52 => MedicineHealth(100,true,7),   # vitalkraut

    53 => MedicineAP(10,false),         # äther
    54 => MedicineAP(100,false),        # top äther
    55 => MedicineAP(10,true),          # elixier
    56 => MedicineAP(100,true),         # top-elixier
)


