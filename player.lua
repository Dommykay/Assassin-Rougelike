_G.playerID = 0
function ReturnPlayer(items, position)
    local player = {}
    player.id = playerID
    playerID = playerID + 1
    if type == nil then
        local state = {}
        local stats = {}
        local controls = {}

        controls.movement = {}

        controls.movement.up = function () return love.keyboard.isDown("w") end
        controls.movement.down = function () return love.keyboard.isDown("s") end
        controls.movement.left = function () return love.keyboard.isDown("a") end
        controls.movement.right = function () return love.keyboard.isDown("d") end
        controls.movement.sprint = function () return love.keyboard.isDown("lshift") end

        player.controls = controls

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


        player.equips = {}
        local gunfile = require("Weapons.Guns.G19")
        player.equips.gun = ReturnGun()

        state.isStill = function () return (player.state.speed == {0,0}) end

        player.stats = stats
        player.state = state

        player.render = function ()
            parallaxcircle(player.state.position[1],player.state.position[2],1.1,5,player.state.size)
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



        

        player.acceleration = function (dt, unitvector)
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


            local newspeed = player.state.speed[1]

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

            player.state.speed[1] = newspeed
            
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

            local newspeed = player.state.speed[2]
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

            player.state.speed[2] = newspeed
        end




    else
    end

    return player
end