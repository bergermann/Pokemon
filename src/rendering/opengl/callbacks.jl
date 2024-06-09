


function resizeCallback(window::GLFW.Window,width::Int32,height::Int32)    
    println("Window resized to (width: $width, height: $height)")

    if width == height
        println("Square!")
    end

    # game.im.windowsize = (width=width,height=height)

    return
end