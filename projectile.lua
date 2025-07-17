love = require("love")
vector = require("libs.vector.vector")


function CreateProjectile(startpos, endpos, weapontype)
    
    startpos = vector.new(startpos[1], startpos[2])
    endpos = vector.new(endpos[1], endpos[2])
    local startendvector = endpos - startpos
    startendvector:norm()
    local projectile = {}
    projectile.position = startpos
    projectile.origin = startpos
    projectile.unitvec = startendvector
    local currentspeedvector = vector.new(GAME.player.state.speed[1],GAME.player.state.speed[2])
    local currentspeed = currentspeedvector:getmag()
    local maxspeed = GAME.player.stats.maxspeed + GAME.player.stats.sprintboost

    if weapontype == nil then
        -- Default/testing weapon type
        projectile.range = 5000
        projectile.damage = 1
        projectile.speed = 3000
        projectile.speedpenalty = 1000
        local stability = math.min((currentspeed/maxspeed)/0.5,1)
        projectile.spread = (math.random()-0.5) * 0.3 * stability
        print(projectile.spread)

        if projectile.spread ~= 0 then
            local heading = projectile.unitvec:heading()
            heading = heading + projectile.spread
            projectile.unitvec = vector.fromAngle(heading)
        end

        projectile.size = 0.15


    else
        -- Taking the equipped weapon type's projectiles
        projectile.range = weapontype.range
        projectile.damage = weapontype.damage
        projectile.speed = weapontype.bulletspeed
        projectile.speedpenalty = weapontype.bulletspeedpenalty
        local stability = math.min((currentspeed/maxspeed)/weapontype.stability,1)
        projectile.spread = (math.random()-0.5) * weapontype.spread * stability

        if projectile.spread ~= 0 then
            local heading = projectile.unitvec:heading()
            heading = heading + projectile.spread
            projectile.unitvec = vector.fromAngle(heading)
        end

        projectile.size = weapontype.size

    end


    projectile.dead = function () return (projectile.origin:dist(projectile.position)) >= projectile.range end

    projectile.progress = function (dt)
        projectile.position = projectile.position + ((projectile.unitvec*dt)*projectile.speed)
    end

    projectile.render = function ()
        local x,y = projectile.position:unpack()
        local x_pos = ((CAMERA_OFFSET[1]-GAME.player.state.position[1] + x) - RES_X/2)* ZOOM_MULT + RES_X/2
        local y_pos = ((CAMERA_OFFSET[2]-GAME.player.state.position[2] + y) - RES_Y/2)* ZOOM_MULT + RES_Y/2
        love.graphics.circle("fill",x_pos,y_pos, (ZOOM - fovsizecorrection())*projectile.size)
    end
    return projectile
end