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
        state.scopedin = false
        enemy.equips = {}
        local gunfile = require("Weapons.Guns.G19")
        enemy.equips.gun = ReturnGun()

        state.isStill = function () return (enemy.state.speed == vector.new(0,0)) end

        enemy.stats = stats
        enemy.state = state

        enemy.render = function ()
            parallaxcircle(enemy.state.position,1.1,5,enemy.state.size)
        end

        enemy.desiredmovementvector = function (movetopoint)
            local desiredmovement = movetopoint - enemy.state.position
            print("movetopoint: ", movetopoint)
            return desiredmovement:norm()
        end


        enemy.acceleration = function (dt, point)
            local desiredmovement = enemy.desiredmovementvector(point)
            local maxspeed, acceleration = enemy.stats.maxspeed, enemy.stats.acceleration*dt
        
            if enemy.equips and enemy.equips.gun and enemy.equips.gun ~= nil then
                if enemy.state.scopedin then
                    maxspeed = maxspeed - enemy.equips.gun.aimingwalkspeedpenalty
                end
            end
            
            local maxspeed_x, maxspeed_y = (desiredmovement * maxspeed):unpack()
            local newspeed_x, newspeed_y = (enemy.state.speed + (acceleration * desiredmovement)):unpack()



            -- Limit left speed
            if newspeed_x < -maxspeed_x then
                newspeed_x = newspeed_x + acceleration
                if newspeed_x > -maxspeed_x then -- ease the speed to the intended range if not in the intended range
                    newspeed_x = -maxspeed_x
                end
            end

            -- Limit right speed
            if newspeed_x > maxspeed_x then
                newspeed_x = newspeed_x - acceleration
                if newspeed_x < maxspeed_x then -- ease the speed to the intended range if not in the intended range
                    newspeed_x = maxspeed_x
                end
            end
            
            if enemy.equips and enemy.equips.gun and enemy.equips.gun ~= nil then
                if enemy.state.scopedin then
                    maxspeed_y = maxspeed_y - enemy.equips.gun.aimingwalkspeedpenalty
                end
            end

            -- Limit up speed
            if newspeed_y < -maxspeed_y then
                newspeed_y = newspeed_y + acceleration
                if newspeed_y > -maxspeed_y then -- ease the speed to the intended range if not in the intended range
                    newspeed_y = -maxspeed_y
                end
            end

            -- Limit down speed
            if newspeed_y > maxspeed_y then
                newspeed_y = newspeed_y - acceleration
                if newspeed_y < maxspeed_y then -- ease the speed to the intended range if not in the intended range
                    newspeed_y = maxspeed_y
                end
            end

            enemy.state.speed = vector.new(newspeed_x, newspeed_y)
        end

        enemy.movement = function (dt)
            enemy.state.position = enemy.state.position+(enemy.state.speed*dt)
        end


    else
    end

    return enemy
end