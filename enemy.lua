_G.enemyID = 1
function ReturnEnemy(type, position)
    local enemy = {}
    enemy.id = enemyID
    enemyID = enemyID + 1
    if type == nil then
        local state = {}
        local stats = {}

        stats.acceleration = 200
        stats.maxspeed = 100

        state.position = vector.new(math.random(-500,500),math.random(-500,500))
        state.health = 1
        state.size = 1
        state.speed = vector.new(0,0)
        state.dead = function () return enemy.state.health <= 0 end
        enemy.equips = {}
        local gunfile = require("Weapons.Guns.G19")
        enemy.equips.gun = ReturnGun()

        state.isStill = function () return (enemy.state.speed == {0,0}) end

        enemy.stats = stats
        enemy.state = state

        enemy.render = function ()
            parallaxcircle(enemy.state.position[1],enemy.state.position[2],1.1,5,enemy.state.size)
        end

        enemy.desiredmovementvector = function (movetopoint)
            local desiredmovement = movetopoint - enemy.state.position
            if desiredmovement == vector.new(0,0) then
                return vector.new(0,0)
            end
            desiredmovement = desiredmovement:norm()
            return desiredmovement
        end


        enemy.acceleration = function (dt, point)
            local desiredmovement = enemy.desiredmovementvector(point)
            local maxspeed, acceleration = enemy.stats.maxspeed, enemy.stats.acceleration*dt
        
            if enemy.equips and enemy.equips.gun and enemy.equips.gun ~= nil then
                if enemy.state.scopedin then
                    maxspeed = maxspeed - enemy.equips.gun.aimingwalkspeedpenalty
                end
            end
            
            local maxspeed_x = maxspeed * desiredmovement[1]
            local maxspeed_y = maxspeed * desiredmovement[2]



            local newspeed = enemy.state.speed[1]
            newspeed = newspeed + (acceleration * desiredmovement[1])

            -- Limit left speed
            if newspeed < -maxspeed_x then
                newspeed = newspeed + acceleration
                if newspeed > -maxspeed_x then -- ease the speed to the intended range if not in the intended range
                    newspeed = -maxspeed_x
                end
            end

            -- Limit right speed
            if newspeed > maxspeed_x then
                newspeed = newspeed - acceleration
                if newspeed < maxspeed_x then -- ease the speed to the intended range if not in the intended range
                    newspeed = maxspeed_x
                end
            end

            enemy.state.speed[1] = newspeed
            
            maxspeed, acceleration, sprintboost = enemy.stats.maxspeed, enemy.stats.acceleration*dt, enemy.stats.sprintboost
            if sprint then
                maxspeed = maxspeed + sprintboost
            end
            if enemy.equips and enemy.equips.gun and enemy.equips.gun ~= nil then
                if enemy.state.scopedin then
                    maxspeed = maxspeed - enemy.equips.gun.aimingwalkspeedpenalty
                end
            end

            if xor(up,down) and xor(left,right) then -- if (up xor down) and (left xor right) then cap the speed at the root of the original max speed, to prevent diagonal movement being faster than movement along one of the cardinals
                maxspeed = maxspeed / ROOT2
            elseif not xor(up,down) then
                maxspeed = 0
            end

            local newspeed = enemy.state.speed[2]
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

            enemy.state.speed[2] = newspeed
        end


    else
    end

    return enemy
end