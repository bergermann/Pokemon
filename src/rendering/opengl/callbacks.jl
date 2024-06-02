

function keyCallback(window::GLFW.Window,key,scancode,action,mods)
    # println("Key pressed: ",key)
    # println("Scancode:    ",scancode)
    # println("Action:      ",action)
    # println("Mods:        ",mods)

    if key == GLFW.KEY_ESCAPE && action == GLFW.PRESS
        GLFW.SetWindowShouldClose(window,true)
    elseif key == GLFW.KEY_SPACE && action == GLFW.PRESS
        0
    elseif key == GLFW.KEY_W && (action == GLFW.PRESS || action == GLFW.REPEAT) && !game.ctrl.moving
        game.ctrl.dir = 1
        game.ctrl.moving = true
    elseif key == GLFW.KEY_D && (action == GLFW.PRESS || action == GLFW.REPEAT) && !game.ctrl.moving
        game.ctrl.dir = 2
        game.ctrl.moving = true
    elseif key == GLFW.KEY_S && (action == GLFW.PRESS || action == GLFW.REPEAT) && !game.ctrl.moving
        game.ctrl.dir = 3
        game.ctrl.moving = true
    elseif key == GLFW.KEY_A && (action == GLFW.PRESS || action == GLFW.REPEAT) && !game.ctrl.moving
        game.ctrl.dir = 4
        game.ctrl.moving = true
    end

    return
end

function resizeCallback(window::GLFW.Window,width::Int32,height::Int32)    
    println("Window resized to (width: $width, height: $height)")

    if width == height
        println("Square!")
    end

    game.im.windowsize = (width=width,height=height)

    return
end