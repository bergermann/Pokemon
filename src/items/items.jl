# items (battleitems, medicine n such)

items = Dict{Int,Item}(
    21 => MedicineHealth(20,false,0),   # trank
    22 => MedicineHealth(50,false,0),   # supertrank
    23 => MedicineHealth(200,false,0),  # hypertrank
    24 => MedicineHealth(100,true,0),   # top trank
    25 => MedicineHealth(100,true,6),   # top genesung
    26 => MedicineHealth(50,false,0),   # tafelwasser
    27 => MedicineHealth(60,false,0),   # sprudel
    28 => MedicineHealth(80,false,0),   # limonade
    29 => MedicineHealth(100,false,0),  # kuh-muh milch
    30 => MedicineHealth(50,false,0),   # energiestaub
    31 => MedicineHealth(200,false,0),  # kraftwurzel

    32 => MedicineHealth(0,false,1),    # gegengift
    33 => MedicineHealth(0,false,2),    # feuerheiler
    34 => MedicineHealth(0,false,3),    # paraheiler
    35 => MedicineHealth(0,false,4),    # aufwecker
    36 => MedicineHealth(0,false,5),    # eisheiler
    37 => MedicineHealth(0,false,6),    # hyperheiler
    38 => MedicineHealth(0,false,6),    # heilpuder
    39 => MedicineHealth(0,false,6),    # lavakeks

    40 => MedicineHealth(50,true,7),    # beleber
    41 => MedicineHealth(100,true,7),   # top beleber
    42 => MedicineHealth(100,true,7),   # vitalkraut

    43 => MedicineAP(10,false),         # äther
    44 => MedicineAP(100,false),        # top äther
    45 => MedicineAP(10,true),          # elixier
    46 => MedicineAP(100,true),         # top-elixier
)


