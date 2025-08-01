love = require("love")
mathheader = require("mathheader")
projectile = require("projectile")
enemy = require("enemy")
vector = require("libs.vector.vector")

function ReturnGameTable()

    -- Initialisation, getting some of the base stats ready
    local _,_,flags = love.window.getMode()


    gunequippedfilepath = "Weapons.Guns.G19"

    _G.REFRESH_RATE = flags.refreshrate
    local game = {}
    game.player = {}
    game.player.id = 0
    game.projectiles = {}
    game.enemies = {}
    local stats = {}
    stats.acceleration = 800
    stats.maxspeed = 200
    stats.sprintboost = 100
    stats.sprinttime = 15
    stats.zoommult = 3
    game.player.stats = stats
    game.player.state = {}
    game.player.state.position = {0,0}
    game.player.state.speed = {0,0}
    game.player.state.scopedin = false

    -- Some functions to do with the player to make things easier
    game.player.state.isStill = function () return game.player.state.speed == {0,0} end --Check the player is standing still
    

    -- Camera info and functions 
    game.player.camera = {}
    local camera = {}
    camera.framelag = math.floor(REFRESH_RATE/2) -- Number of frames the camera will average in order to lag behind, making the movement feel more "movementy"

    camera.storedpositions = {}

    camera.storedpositions.player = {}
    for i=1,camera.framelag do camera.storedpositions.player[i] = game.player.state.position end

    camera.storedpositions.mouse = {}
    for i=1,camera.framelag do camera.storedpositions.mouse[i] = {0,0} end

    camera.storedpositions.zoom = {}
    for i=1,camera.framelag do camera.storedpositions.zoom[i] = ZOOM end
    

    camera.updatestoredpositions = function ()
        if camera.framelag > 0 then
            if love.mouse.isDown(2) then
                if game.player.equips and game.player.equips.gun and game.player.equips.gun ~= nil then
                    if game.player.equips.gun.aimingvisionincrease then
                        local mouse_x, mouse_y = love.mouse.getPosition()

                        mouse_x = mouse_x - RES_X/2
                        mouse_y = mouse_y - RES_Y/2


                        table.insert(camera.storedpositions.mouse, 1, {(mouse_x/10)*game.player.equips.gun.aimingvisionincrease,(mouse_y/10)*game.player.equips.gun.aimingvisionincrease})
                    end
                end
            else
                table.insert(camera.storedpositions.mouse, 1, {0,0})
            end
            
            table.insert(camera.storedpositions.player, 1, game.player.state.position)
            table.insert(camera.storedpositions.zoom, 1, ZOOM)

            if #camera.storedpositions.player > camera.framelag then
                table.remove(camera.storedpositions.player)
            end

            if #camera.storedpositions.mouse > camera.framelag then
                table.remove(camera.storedpositions.mouse)
            end

            if #camera.storedpositions.zoom > camera.framelag then
                table.remove(camera.storedpositions.zoom)
            end
        end
    end


    -- Calculate the camera offset
    camera.offset = function()
        if camera.framelag > 0 then
            local total = {0,0}
            local zoomtotal = 0

            for i,coordinate in ipairs(camera.storedpositions.player) do
                total[1] = total[1] + coordinate[1]
                total[2] = total[2] + coordinate[2]
            end

            for i,mouseoffset in ipairs(camera.storedpositions.mouse) do
                total[1] = total[1] + mouseoffset[1]
                total[2] = total[2] + mouseoffset[2]
            end

            for i,zoom in ipairs(camera.storedpositions.zoom) do
                zoomtotal = zoomtotal + zoom
            end


            total[1] = game.player.state.position[1] - total[1]/camera.framelag
            total[2] = game.player.state.position[2] - total[2]/camera.framelag
            ZOOM = zoomtotal/camera.framelag


            return total
        end

        if love.mouse.isDown(2) then
            local mouse_x, mouse_y = love.mouse.getPosition()

            mouse_x = mouse_x - RES_X/2
            mouse_y = mouse_y - RES_Y/2

            return {game.player.state.position[1] - mouse_x, game.player.state.position[2] - mouse_y}
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





    --Code for equipping items

    local equips = {}
    local gunequipped = require(gunequippedfilepath)
    equips.gun = ReturnGun()

    game.player.equips = equips




    --Where a ton of the calculations for the game will be stored, IE movement calculations and acceleration
    game.functions = {}

    local functions = {}

    functions.acceleration = function (dt)
        local up,down,left,right,sprint = controls.movement.up(), controls.movement.down(), controls.movement.left(), controls.movement.right(), controls.movement.sprint()
        local maxspeed, acceleration, sprintboost = game.player.stats.maxspeed, game.player.stats.acceleration*dt, game.player.stats.sprintboost
        if sprint then
            maxspeed = maxspeed + sprintboost
        end
        if game.player.equips and game.player.equips.gun and game.player.equips.gun ~= nil then
            if game.player.state.scopedin then
                maxspeed = maxspeed - game.player.equips.gun.aimingwalkspeedpenalty
            end
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
        if game.player.equips and game.player.equips.gun and game.player.equips.gun ~= nil then
            if game.player.state.scopedin then
                maxspeed = maxspeed - game.player.equips.gun.aimingwalkspeedpenalty
            end
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

    --Player movement
    functions.movement = function (dt)
        local position, speed = game.player.state.position, game.player.state.speed
        game.player.state.position = {position[1]+(speed[1]*dt), position[2]+(speed[2]*dt)}
    end




    --Projectile based functions
    functions.fire = function (startpos,endpos,weapontype,thing)
        if (love.timer.getTime() - weapontype.lastfired) > weapontype.firerate then
            weapontype.lastfired = love.timer.getTime()
            local projectile = CreateProjectile(startpos,endpos,weapontype,thing)
            if projectile ~= nil then
                table.insert(game.projectiles, projectile)
            end
        end
    end

    functions.killexpiredprojectiles = function ()
        for pos,projectile in pairs(game.projectiles) do
            if projectile.dead() then
                table.remove(game.projectiles, pos)
            end
        end
    end

    functions.checkcirclecollision = function(thing, projectile)
        local thingposition = vector.new(thing.state.position[1],thing.state.position[2])
        local distance = thingposition:dist(projectile.position)

        print(thingposition, projectile.position)

        --If the distance between the two objects is less than their radii added together, they are colliding
        return (thing.state.size + projectile.size)*20 > distance
    end

    functions.progressprojectiles = function (dt)
        for _,projectile in pairs(game.projectiles) do
            projectile.progress(dt)
        end
        functions.killexpiredprojectiles()
    end

    functions.renderprojectiles = function ()
        for _,projectile in pairs(game.projectiles) do
            projectile.render()
        end
    end


    functions.spawnenemy = function ()
        local enemy = ReturnEnemy()
        table.insert(game.enemies, enemy)
    end

    functions.progressenemies = function (dt)
        for i,enemy in pairs(game.enemies) do
            local position, speed = enemy.state.position, enemy.state.speed
            enemy.state.position = {position[1]+(speed[1]*dt), position[2]+(speed[2]*dt)}
            print(enemy.state.position[1],enemy.state.position[2])
        end
    end

    functions.killenemies = function ()
        for enemypos, enemy in pairs(game.enemies) do
            for projpos, projectile in pairs(game.projectiles) do
                if not projectile.idinhitlist(enemy.id) then
                    if not enemy.state.dead() and not projectile.dead() and projectile.shooterid ~= enemy.id then
                        if functions.checkcirclecollision(enemy, projectile) then
                            print("hit")
                            game.enemies[enemypos].state.health = enemy.state.health - game.projectiles[projpos].damage
                            game.projectiles[projpos].pierce = game.projectiles[projpos].pierce - 1
                            table.insert(game.projectiles[projpos].hitlist, enemy.id)
                        end
                    end
                end
            end
        end
        for pos, enemy in pairs(game.enemies) do
            if enemy.state.dead() then
                table.remove(game.enemies, pos)
            end
        end
    end

    functions.renderenemies= function ()
        for i, enemy in pairs(game.enemies) do
            enemy.render()
        end
    end


    game.functions = functions

    -- Proceed to next frame

    game.progress = function (dt)
        game.functions.acceleration(dt)
        game.functions.movement(dt)
        game.functions.progressprojectiles(dt)
        game.functions.progressenemies(dt)
        game.functions.killenemies()
        camera.updatestoredpositions()
    end


    -- Return everything
    return game
end