

mutable struct ChunkData
    height::MMatrix{16,16,UInt8}
    collision::MArray{Tuple{16,16,2},UInt8}

    events::Vector{UInt8}
    npcs::Array{Base.RefValue{NPC}}
    objects::Array{Base.RefValue{Object}}
    items::Array{Base.RefValue{MapItem}}

    function ChunkData()
        new(
            MMatrix{16,16,UInt8}(undef),
            MArray{Tuple{16,16,2},UInt8}(undef),
            [],
            Array{Base.RefValue{NPC}}([]),
            Array{Base.RefValue{Object}}([]),
            Array{Base.RefValue{MapItem}}([]),
        )
    end
end

mutable struct Area
    id::UInt16

    px::Int; py::Int
    dx::Int; dy::Int
    cx::Int; cy::Int
    fg::Bool

    data::Matrix{UInt16}

    function Area(); new(0,0,0,0,0,0,0,false,zeros(Int,0,4)); end
    function Area(id,px,py,dx,dy,cx,cy,fg,data); new(id,px,py,dx,dy,cx,cy,fg,data); end
end

mutable struct MapData{R,R2}
    idxs::MMatrix{R,R,Int8}
    didxs::MMatrix{R,R,Int8}
    tilemap::MArray{Tuple{16,16,5,R2},UInt16}
    chunkdata::MVector{R2,ChunkData}

    npcids::Vector{UInt16}
    npcs::ArrayList{NPC}

    objectids::Vector{UInt16}
    objects::ArrayList{Object}

    itemids::Vector{UInt16}
    items::ArrayList{MapItem}

    areaids::Vector{UInt16}
    areas::ArrayList{Area}

    function MapData{R,R2}(idxs,didxs,tilemap,chunkdata,
            npcids,npcs,objectids,objects,itemids,items,areaids,areas) where {R,R2}

        new(idxs,didxs,tilemap,chunkdata,
            npcids,npcs,objectids,objects,itemids,items,areaids,areas)
    end

    function MapData(renderdistance)
        r = 2*renderdistance+1

        return MapData{r,r^2}(
            1:r^2,
            1:r^2,
            MArray{Tuple{16,16,5,r^2},UInt16}(undef),
            [ChunkData() for _ in 1:r^2],

            UInt16[],ArrayList(NPC,64),
            UInt16[],ArrayList(Object,64),
            UInt16[],ArrayList(MapItem,64),
            UInt16[],ArrayList(Area,16),
        )
    end
end

mutable struct Chunks
    renderdistance::UInt8
    r2::UInt8

    vao::UInt32
    vbo::UInt32
    tidxs::UInt32
    bidxs::UInt32
    tanimdata::UInt32
    banimdata::UInt32

    projection1::Mat4{Float32}
    projection2::Mat4{Float32}

    ulocp1::Int32
    ulocp2::Int32
    ulocframe::Int32

    function Chunks(renderdistance)
        vao = UInt32[0]; glGenVertexArrays(1,pointer(vao))
        vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))
        t = UInt32[0,0]; glGenTextures(2,pointer(t))
        b = UInt32[0,0]; glGenBuffers(2,pointer(b))

        new(renderdistance,
            2*renderdistance+1,
            vao[1],vbo[1],
            t[1],b[1],
            t[2],b[2],
            Matn(Float32,1.,1.,1.,1.),
            Matn(Float32,16/(240/2),-16/(160/2),1.,1.),#*Matn(Float32,1/8,1/8,1.,1.),
            0,0,0
        )
    end
end