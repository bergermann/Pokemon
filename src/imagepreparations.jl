using Images, ImageIO

function fixBG!(img::Matrix{RGBA{N0f8}})
    bg = img[1]

    if bg == RGBA{N0f8}(0,0,0,0)
        return
    end

    for i in eachindex(img)
        if img[i] == RGBA{N0f8}(0,0,0,0) || img[i] == RGBA{N0f8}(0,0,0,1)
            img[i] == RGBA{N0f8}(0x01/0xff,0x01/0xff,0x01/0xff,0)
        elseif img[i] == bg
            img[i] = RGBA{N0f8}(0,0,0,0)
        end
    end
end

function fixBG!(img::Matrix{RGB{N0f8}})
    bg = img[1]

    if bg == RGB{N0f8}(0,0,0)
        return
    end

    for i in eachindex(img)
        if img[i] == RGB{N0f8}(0,0,0)
            img[i] == RGB{N0f8}(0x01/0xff,0x01/0xff,0x01/0xff)
        elseif img[i] == bg
            img[i] = RGB{N0f8}(0,0,0,0)
        end
    end
end

key = """1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,\
    28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,\
    53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,\
    78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,\
    102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,\
    121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,\
    140,141,142,143,144,145,146,147,148,149,150,151"""

# for id in split(key,',')
#     println(id)
#     f1 = load("im/battlers/front/shiny/frame1/"*id*".png")
#     f2 = load("im/battlers/front/shiny/frame2/"*id*".png")

#     fc = hcat(f1,f2)

#     save("im/battlers/front/shiny/"*id*".png",fc)
# end

for id in split(key,',')
    print(id,",")

    img = load("im/battlers/back/normal/"*id*".png")

    fixBG!(img)
    save("im/battlers/back/normal/"*id*".png",img)
end
