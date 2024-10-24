


function manageObjects(game::GameState)
    for object in game.objects
        manageObject(game,object)
    end

    return
end

function manageObject(game::GameState,object::Object)
    return
end