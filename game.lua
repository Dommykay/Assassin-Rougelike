love = require("love")
mathheader = require("mathheader")
function ReturnGameTable()

    -- Initialisation, getting some of the base stats ready
    local game = {}
    game.player = {}
    local stats = {}
    stats.acceleration = 800
    stats.maxspeed = 200
    stats.sprintboost = 100
    stats.sprinttime = 15
    game.player.stats = stats
    game.player.state = {}
    game.player.state.position = {0,0}
    game.player.state.speed = {0,0}

    -- Camera info and functions 
    game.player.camera = {}
    local camera = {}
    camera.framelag = 30 -- Number of frames the camera will average in order to lag behind, making the movement feel more "movementy"
    camera.storedpositions = {}
    camera.updatestoredpositions = function ()
        if camera.framelag > 0 then
            table.insert(camera.storedpositions, 1, game.player.state.position)
            if #camera.storedpositions > camera.framelag then
                table.remove(camera.storedpositions)
            end
        end
    end


    -- Calculate the camera offset
    camera.offset = function()
        if camera.framelag > 0 then
            local total = {0,0}
            for i,coordinate in ipairs(camera.storedpositions) do
                total[1] = total[1] + coordinate[1]
                total[2] = total[2] + coordinate[2]
            end
            total[1] = game.player.state.position[1] - total[1]/camera.framelag
            total[2] = game.player.state.position[2] - total[2]/camera.framelag
            return total
        end
        return game.player.state.position
    end

    game.player.camera = camera
    -- Controls, will have different sections for movement, shop ect just to simplify things for me lol
    local controls = {}
    controls.movement = {}

    controls.movement.up = function () return love.keyboard.isDown("w") end
    controls.movement.down = function () return love.keyboard.isDown("s") end
    controls.movement.left = function () return love.keyboard.isDown("a") end
    controls.movement.right = function () return love.keyboard.isDown("d") end
    controls.movement.sprint = function () return love.keyboard.isDown("lshift") end

    game.controls = controls


    --Where a ton of the calculations for the game will be stored, IE movement calculations and acceleration
    game.functions = {}

    local functions = {}

    functions.acceleration = function (dt)
        local up,down,left,right,sprint = controls.movement.up(), controls.movement.down(), controls.movement.left(), controls.movement.right(), controls.movement.sprint()
        local maxspeed, acceleration, sprintboost = game.player.stats.maxspeed, game.player.stats.acceleration*dt, game.player.stats.sprintboost
        if sprint then
            maxspeed = maxspeed + sprintboost
        end
        
        if xor(up,down) and xor(left,right) then -- if (up xor down) and (left xor right) then cap the speed at the root of the original max speed, to prevent diagonal movement being faster than movement along one of the cardinals
            maxspeed = maxspeed / ROOT2
        elseif not xor(left,right) then
            maxspeed = 0
        end


        local newspeed = game.player.state.speed[1]

        -- Determine movement direction
        if left and not right then
            if newspeed > -maxspeed then
                newspeed = newspeed - acceleration
                if newspeed < -maxspeed then
                    newspeed = -maxspeed
                end
            end
        end
        if right and not left then
            if newspeed < maxspeed then
                newspeed = newspeed + acceleration
                if newspeed > maxspeed then
                    newspeed = maxspeed
                end
            end
        end

        -- Limit left speed
        if newspeed < -maxspeed then
            newspeed = newspeed + acceleration
            if newspeed > -maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed = -maxspeed
            end
        end

        -- Limit right speed
        if newspeed > maxspeed then
            newspeed = newspeed - acceleration
            if newspeed < maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed = maxspeed
            end
        end

        game.player.state.speed[1] = newspeed
        
        maxspeed, acceleration, sprintboost = game.player.stats.maxspeed, game.player.stats.acceleration*dt, game.player.stats.sprintboost
        if sprint then
            maxspeed = maxspeed + sprintboost
        end

        if xor(up,down) and xor(left,right) then -- if (up xor down) and (left xor right) then cap the speed at the root of the original max speed, to prevent diagonal movement being faster than movement along one of the cardinals
            maxspeed = maxspeed / ROOT2
        elseif not xor(up,down) then
            maxspeed = 0
        end

        local newspeed = game.player.state.speed[2]
        -- Determine movement direction
        if up and not down then
            if newspeed > -maxspeed then
                newspeed = newspeed - acceleration
                if newspeed < -maxspeed then
                    newspeed = -maxspeed
                end
            end
        end
        if down and not up then
            if newspeed < maxspeed then
                newspeed = newspeed + acceleration
                if newspeed > maxspeed then
                    newspeed = maxspeed
                end
            end
        end

        -- Limit up speed
        if newspeed < -maxspeed then
            newspeed = newspeed + acceleration
            if newspeed > -maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed = -maxspeed
            end
        end

        -- Limit down speed
        if newspeed > maxspeed then
            newspeed = newspeed - acceleration
            if newspeed < maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed = maxspeed
            end
        end

        game.player.state.speed[2] = newspeed
    end
    
    functions.movement = function (dt)
        local position, speed = game.player.state.position, game.player.state.speed
        game.player.state.position = {position[1]+(speed[1]*dt), position[2]+(speed[2]*dt)}
    end

    game.functions = functions

    -- Proceed to next frame

    game.progress = function (dt)
        game.functions.acceleration(dt)
        game.functions.movement(dt)
        camera.updatestoredpositions()
    end


    -- Return everything
    return game
end