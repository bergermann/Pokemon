


function keyCallback(window::GLFW.Window,key,scancode,action,mods)
    println("Key pressed: ",key)
    # # println("Scancode:    ",scancode)
    println("Action:      ",action)
    # # println("Mods:        ",mods)
    # println()

    if action == GLFW.PRESS || action == GLFW.REPEAT
        if key == GLFW.KEY_ESCAPE
            GLFW.SetWindowShouldClose(window,true)
        else
            if haskey(keymap,key)
                keymap[key].press = true
                keymap[key].hold = true
            end
        end
    else
        if haskey(keymap,key)
            keymap[key].hold = false
        end
    end

    return
end