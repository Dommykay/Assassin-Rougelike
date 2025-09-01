_G.playerID = 0
function ReturnPlayer(items, position)
    local player = {}
    player.id = playerID
    playerID = playerID + 1

    local state = {}
    local stats = {}
    local controls = {}
    local textures = {}

    controls.movement = {}

    controls.movement.up = function () return love.keyboard.isDown("w") end
    controls.movement.down = function () return love.keyboard.isDown("s") end
    controls.movement.left = function () return love.keyboard.isDown("a") end
    controls.movement.right = function () return love.keyboard.isDown("d") end
    controls.movement.sprint = function () return love.keyboard.isDown("lshift") end

    textures.body = love.graphics.newImage("Assets/Sprites/Player/Player.png")





    stats.acceleration = 800
    stats.maxspeed = 200
    stats.sprintboost = 100
    stats.sprinttime = 15
    stats.zoommult = 3

    state.position = vector.new(0,0)
    state.speed = vector.new(0,0)
    state.scopedin = false
    state.health = 1
    state.size = 1
    state.dead = function () return player.state.health <= 0 end
    state.isStill = function () return (player.state.speed == {0,0}) end
    state.fireconditionsmet = function () return love.mouse.isDown(1) end
    
    player.equips = {}
    local gunfile = require("Weapons.Guns.G19")
    player.equips.gun = ReturnGun()

    player.textures = textures
    player.controls = controls
    player.stats = stats
    player.state = state

    player.render = function ()
        parallaxcircle(player.state.position,1.1,5,player.state.size)
    end
    


    -- Not using rn but just in case i end up needing it for whatever reason
    player.desiredmovementvector = function()
        local desiredmovement = vector.new(0,0)


        if player.controls.up then 
            if player.controls.left or player.controls.right then
                desiredmovement[1] = desiredmovement[1] - SIN45
            else
                desiredmovement[1] = desiredmovement[1] - 1
            end
        end

        if player.controls.down then 
            if player.controls.left or player.controls.right then
                desiredmovement[1] = desiredmovement[1] + SIN45
            else
                desiredmovement[1] = desiredmovement[1] + 1
            end
        end

        if player.controls.left then 
            if player.controls.up or player.controls.down then
                desiredmovement[2] = desiredmovement[2] - SIN45
            else
                desiredmovement[2] = desiredmovement[2] - 1
            end
        end

        if player.controls.right then 
            if player.controls.up or player.controls.down then
                desiredmovement[2] = desiredmovement[2] + SIN45
            else
                desiredmovement[2] = desiredmovement[2] + 1
            end
        end

        return desiredmovement
    end



    

    player.acceleration = function (dt)
        local up,down,left,right,sprint = player.controls.movement.up(), player.controls.movement.down(), player.controls.movement.left(), player.controls.movement.right(), player.controls.movement.sprint()
        local maxspeed, acceleration, sprintboost = player.stats.maxspeed, player.stats.acceleration*dt, player.stats.sprintboost
        if sprint then
            maxspeed = maxspeed + sprintboost
        end
        if player.equips and player.equips.gun and player.equips.gun ~= nil then
            if player.state.scopedin then
                maxspeed = maxspeed - player.equips.gun.aimingwalkspeedpenalty
            end
        end
        
        if xor(up,down) and xor(left,right) then -- if (up xor down) and (left xor right) then cap the speed at the root of the original max speed, to prevent diagonal movement being faster than movement along one of the cardinals
            maxspeed = maxspeed / ROOT2
        elseif not xor(left,right) then
            maxspeed = 0
        end


        local newspeed_x, newspeed_y = player.state.speed:unpack()

        -- Determine movement direction
        if left and not right then
            if newspeed_x > -maxspeed then
                newspeed_x = newspeed_x - acceleration
                if newspeed_x < -maxspeed then
                    newspeed_x = -maxspeed
                end
            end
        end
        if right and not left then
            if newspeed_x < maxspeed then
                newspeed_x = newspeed_x + acceleration
                if newspeed_x > maxspeed then
                    newspeed_x = maxspeed
                end
            end
        end

        -- Limit left speed
        if newspeed_x < -maxspeed then
            newspeed_x = newspeed_x + acceleration
            if newspeed_x > -maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed_x = -maxspeed
            end
        end

        -- Limit right speed
        if newspeed_x > maxspeed then
            newspeed_x = newspeed_x - acceleration
            if newspeed_x < maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed_x = maxspeed
            end
        end
        
        maxspeed, acceleration, sprintboost = player.stats.maxspeed, player.stats.acceleration*dt, player.stats.sprintboost
        if sprint then
            maxspeed = maxspeed + sprintboost
        end
        if player.equips and player.equips.gun and player.equips.gun ~= nil then
            if player.state.scopedin then
                maxspeed = maxspeed - player.equips.gun.aimingwalkspeedpenalty
            end
        end

        if xor(up,down) and xor(left,right) then -- if (up xor down) and (left xor right) then cap the speed at the root of the original max speed, to prevent diagonal movement being faster than movement along one of the cardinals
            maxspeed = maxspeed / ROOT2
        elseif not xor(up,down) then
            maxspeed = 0
        end

        -- Determine movement direction
        if up and not down then
            if newspeed_y > -maxspeed then
                newspeed_y = newspeed_y - acceleration
                if newspeed_y < -maxspeed then
                    newspeed_y = -maxspeed
                end
            end
        end
        if down and not up then
            if newspeed_y < maxspeed then
                newspeed_y = newspeed_y + acceleration
                if newspeed_y > maxspeed then
                    newspeed_y = maxspeed
                end
            end
        end

        -- Limit up speed
        if newspeed_y < -maxspeed then
            newspeed_y = newspeed_y + acceleration
            if newspeed_y > -maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed_y = -maxspeed
            end
        end

        -- Limit down speed
        if newspeed_y > maxspeed then
            newspeed_y = newspeed_y - acceleration
            if newspeed_y < maxspeed then -- ease the speed to the intended range if not in the intended range
                newspeed_y = maxspeed
            end
        end

        player.state.speed = vector.new(newspeed_x, newspeed_y)
    end
    return player
end