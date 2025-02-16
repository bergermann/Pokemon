

struct SpriteSheetData
    width::Int
    height::Int
    nframes::Int
    maxsprites::Int
    path::String
end

const SSD = SpriteSheetData

const spritesheets = Base.ImmutableDict(
    # general
    :health1    => SSD(  1,  3, 3,  6,"health1.png"),
    :health2    => SSD(  1,  2, 3,  6,"health2.png"),
    :xp         => SSD(  1,  1, 16, 2,"xp.png"),

    # map
    :mc1        => SSD( 32, 32, 9,  1,"main1.png"),
    :npcs_all   => SSD( 16, 32, 9,128,"npcs_all.png"),
    :objects    => SSD( 16, 16, 1, 64,"objects.png"),
    :healballs  => SSD(  8,  8, 5,  6,"healballs.png"),

    # menudex
    :dexwheel   => SSD(110,110, 1,  1,"menudex/wheel.png"),
    :dexslider  => SSD(  8,  8, 1,  1,"menudex/slider.png"),
    :dexarrow   => SSD( 16,  8, 1,  2,"menudex/arrow.png"),
    :dexball    => SSD(  8,  8, 1,649,"menudex/ball.png"),
    :footprints => SSD( 16, 16, 1,  1,"menudex/footprints.png"),

    # menupkmn
    :smain      => SSD( 78, 49, 2, 1,"menupkmn/slotmain.png"),
    :sside      => SSD(142, 22, 2, 5,"menupkmn/slotside.png"),
    :exit       => SSD( 52, 16, 2, 1,"menupkmn/exit.png"),
    :ballsm     => SSD( 20, 24, 2, 7,"menupkmn/pokeballs.png"),
    :status     => SSD( 20,  8, 1, 6,"menupkmn/status.png"),
    :item       => SSD(  8,  8, 1, 6,"menupkmn/item.png"),
    :gender     => SSD(  8,  8, 1, 6,"menupkmn/gender.png"),

    # menubags
    :arrows     => SSD( 16, 16, 5, 5,"menubag/arrows.png"),
    :bags       => SSD( 64, 64, 6, 1,"menubag/bags.png"),
    :items      => SSD( 24, 24, 1, 1,"menubag/items.png"),
    :markers    => SSD(  4,  4, 2, 1,"menubag/marker.png"),

    # battle
    :battlermc  => SSD( 64, 64, 4,  1,"battle/battlers/mc1.png"),
    :pads       => SSD(128, 32, 1,  2,"battle/pads/grass1.png"),
    :fol        => SSD(256, 80, 1,  2,"battle/intro/grass1.png"),
    :ballsb     => SSD( 16, 16, 2,  2,"battle/balls.png"),
    :ballicons  => SSD(  7,  7, 4, 12,"battle/ballicons.png"),
    :tagown     => SSD(104, 37, 1,  1,"battle/tagown.png"),
    :tagopp     => SSD(100, 29, 1,  1,"battle/tagopp.png"),
    :particles  => SSD(  8,  8, 1, 10,"battle/p1.png"),
)

