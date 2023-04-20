# using BenchmarkTools, Plots

# using MiniFB, Images, DelimitedFiles

# include("types/typespkmn.jl")
# include("types/typescore.jl")
# include("types/typesbattle.jl")

# include("parser.jl")
# include("pokemons.jl")
# include("core.jl")
# include("battle.jl")
# include("statetransitions.jl")
# include("rendering.jl")
# include("npcs.jl")
# include("maps.jl")
# include("controls.jl")
# include("animations.jl")
# include("attackanimations.jl")
# include("battlenpc.jl")

function showIm(im)
    display(plot(reinterpret(RGB24,im)))
end

function testmain()
    
    settings = Settings()

    global input = Input()

    game = GameState(
        Im(),
        PkmnData(),

        Trainer("Void",0x0000,0x02,ArrayList(Pkmn,6),[],[],
            falses(151),getSpriteMain("sprite"; s=settings)),

        map1,
        Position(0x00006e,0x000013),
        Position(0x00006f,0x000013),
        2,

        Position(0,0),
        Position(0,0),

        Counters(128),
        ArrayList(CallbackFunction,128),

        Dialogue(),

        Battle(),

        InputState(),
        DrawState(),

        Options()
    )

    drawMap!(game)
    combineLayers!(game,[:layer1,:layer2,:layer3,:layer4,:layer5,:layer6])
    # showIm(game.im.layer)
    # shiftLayerUp!(game.im.layer)
    # showIm(game.im.layer)
    # shiftLayerLeft!(game.im.layer)
    # showIm(game.im.layer)
    # shiftLayerDown!(game.im.layer)
    # showIm(game.im.layer)
    # shiftLayerRight!(game.im.layer)
    # showIm(game.im.layer)
    # shiftMatrix1!(game.im.layer)
    
    # @btime shiftLayerLeft!($game.im.layer)
    # @btime shiftLayerRight!($game.im.layer)


    return game
end

g = testmain()

;

function shiftLayerUp!(l::Matrix{UInt32})
    @inbounds for j in 1:272, i in 1:208-16
        l[i,j] = l[i+16,j]
    end
end

function shiftLayerDown!(l::Matrix{UInt32})
    @inbounds for j in 1:272, i in 208:-1:17
        l[i,j] = l[i-16,j]
    end
end

function shiftLayerLeft!(l::Matrix{UInt32})
    @inbounds for j in 1:256, i in 1:208
        l[i,j] = l[i,j+16]
    end
end

function shiftLayerRight!(l::Matrix{UInt32})
    @inbounds for j in 272:-1:17, i in 1:208
        l[i,j] = l[i,j-16]
    end
end

function drawMap!(game::GameState; s=Settings())
    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    @inbounds for k in game.map.environment
        @inbounds for i in 1:s.Nh, j in 1:s.Nw
            tile = game.map.tiles[
                getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                game.pos.w+j-dw-1]]

            v = view(getfield(game.im.layers,k),
                1+(i-1)*s.tilesize:i*s.tilesize,
                1+(j-1)*s.tilesize:j*s.tilesize)
            
            @inbounds for t in eachindex(v)
                v[t] = tile[t]
            end
        end
    end
end


function drawMapUpdate!(game::GameState,dir::Int; s=Settings())
    if dir == 1
        for l in game.map.environment
            shiftLayerDown!(getfield(game.im.layers,l))
        end
    elseif dir == 2
        for l in game.map.environment
            shiftLayerUp!(getfield(game.im.layers,l))
        end
    elseif dir == 3
        for l in game.map.environment
            shiftLayerRight!(getfield(game.im.layers,l))
        end
    else
        for l in game.map.environment
            shiftLayerleft!(getfield(game.im.layers,l))
        end
    end

    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    @inbounds for k in game.map.environment
        @inbounds for i in 1:s.Nh, j in 1:s.Nw
            tile = game.map.tiles[
                getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                game.pos.w+j-dw-1]]

            v = view(getfield(game.im.layers,k),
                1+(i-1)*s.tilesize:i*s.tilesize,
                1+(j-1)*s.tilesize:j*s.tilesize)
            
            @inbounds for t in eachindex(v)
                v[t] = tile[t]
            end
        end
    end
end
