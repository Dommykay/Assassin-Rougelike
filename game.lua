love = require("love")
mathheader = require("mathheader")
projectile = require("projectile")
enemy = require("enemy")
vector = require("libs.vector.vector")
player = require("player")

function ReturnGameTable()

    -- Initialisation, getting some of the base stats ready
    local _,_,flags = love.window.getMode()


    gunequippedfilepath = "Weapons.Guns.G19"

    _G.REFRESH_RATE = flags.refreshrate
    local game = {}
    game.player = ReturnPlayer(nil, vector.new(0,0))
    game.player.id = 0
    game.projectiles = {}
    game.enemies = {}
    

    -- Camera info and functions 
    game.player.camera = {}
    local camera = {}
    camera.framelag = math.floor(REFRESH_RATE/2) -- Number of frames the camera will average in order to lag behind, making the movement feel more "movementy"

    camera.storedpositions = {}

    camera.storedpositions.player = {}
    print(game.player.state.position)
    for i=1,camera.framelag do camera.storedpositions.player[i] = game.player.state.position end

    camera.storedpositions.mouse = {}
    for i=1,camera.framelag do camera.storedpositions.mouse[i] = vector.new(0,0) end

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


                        table.insert(camera.storedpositions.mouse, 1, vector.new((mouse_x/10)*game.player.equips.gun.aimingvisionincrease,(mouse_y/10)*game.player.equips.gun.aimingvisionincrease))
                    end
                end
            else
                table.insert(camera.storedpositions.mouse, 1, vector.new(0,0))
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
            local total = vector.new(0,0)
            local zoomtotal = 0

            for i,coordinate in ipairs(camera.storedpositions.player) do
                total = total + coordinate
            end

            for i,mouseoffset in ipairs(camera.storedpositions.mouse) do
                total = total + mouseoffset
            end

            for i,zoom in ipairs(camera.storedpositions.zoom) do
                zoomtotal = zoomtotal + zoom
            end


            total = game.player.state.position - total/camera.framelag
            ZOOM = zoomtotal/camera.framelag


            return total
        end

        if love.mouse.isDown(2) then
            local mouse_x, mouse_y = love.mouse.getPosition()

            mouse_x = mouse_x - RES_X/2
            mouse_y = mouse_y - RES_Y/2

            return game.player.state.position - vector.new(mouse_x,mouse_y)
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
        game.player.acceleration(dt)
        for i,enemy in ipairs(game.enemies) do
            game.enemies[i].acceleration(dt, enemy.desiredmovementvector(game.player.state.position))
            print("enemy speed:", game.enemies[i].state.speed)
        end 
    end

    --Movement
    functions.movement = function (dt)
        -- player movement
        game.player.state.position = game.player.state.position + (game.player.state.speed * dt)
        print("player pos:", game.player.state.position)

        -- enemy movement
        for i,enemy in ipairs(game.enemies) do
            game.enemies[i].movement(dt)
            print("enemy position:", enemy.state.position)
        end
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
        local thingposition = thing.state.position
        local distance = thingposition:dist(projectile.position)

        --If the distance between the two objects is less than their radii added together, they are colliding
        return (thing.state.size + projectile.size)*20 > distance
    end

    functions.spawnrequestedprojectiles = function ()
        if game.player.state.fireconditionsmet() then
            local mouse_x, mouse_y = love.mouse.getPosition()
            mouse_x = ((mouse_x - RES_X/2) / ZOOM_MULT - x_pos_screen + RES_X/2)
            mouse_y = ((mouse_y - RES_Y/2) / ZOOM_MULT - y_pos_screen + RES_Y/2)
            game.functions.fire(game.player.state.position+vector.new(RES_X/2,RES_Y/2),vector.new(mouse_x, mouse_y), game.player.equips.gun, game.player)
        end

        for i, enemy in pairs(game.enemies) do
            if enemy.state.fireconditionsmet() then
                game.functions.fire(enemy.state.position,game.player.state.position+vector.new(RES_X/2,RES_Y/2), enemy.equips.gun, enemy)
            end
        end 
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
        functions.spawnrequestedprojectiles()
        game.functions.killenemies()
        camera.updatestoredpositions()
    end


    -- Return everything
    return game
end