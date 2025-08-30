love = require("love")
vector = require("libs.vector.vector")


function CreateProjectile(startpos, endpos, weapontype, shooter)

    local startendvector = endpos - startpos
    startendvector:norm()
    local projectile = {}
    projectile.position = startpos
    projectile.origin = startpos
    projectile.unitvec = startendvector
    projectile.hitlist = {} --List of things already hit, to prevent something being hit every frame
    projectile.shooterid = shooter.id
    local currentspeedvector = shooter.state.speed
    local currentspeed = currentspeedvector:getmag()

    if weapontype == nil then
        -- Default/testing weapon type
        projectile.range = 5000
        projectile.damage = 1
        projectile.speed = 3000
        projectile.speedpenalty = 1000
        local stability = math.min(currentspeed/0.5,1)
        projectile.spread = (math.random()-0.5) * 0.3 * stability
        print(projectile.spread)

        if projectile.spread ~= 0 then
            local heading = projectile.unitvec:heading()
            heading = heading + projectile.spread
            projectile.unitvec = vector.fromAngle(heading)
        end

        projectile.pierce = weapontype.pierce
        projectile.size = 0.15


    else
        -- Taking the equipped weapon type's projectiles
        projectile.range = weapontype.range
        projectile.damage = weapontype.damage
        if shooter.state.isStill() then
            projectile.damage = projectile.damage * weapontype.headshotmult --Normal damage if the player is standing still, headshot damage otherwise
        end

        projectile.speed = weapontype.bulletspeed
        projectile.speedpenalty = weapontype.bulletspeedpenalty
        local stability = math.min(currentspeed/weapontype.stability,1)
        projectile.spread = (math.random()-0.5) * weapontype.spread * stability
        print(projectile.spread)

        if projectile.spread ~= 0 then
            local heading = projectile.unitvec:heading()
            heading = heading + projectile.spread
            projectile.unitvec = vector.fromAngle(heading)
        end

        projectile.pierce = weapontype.pierce
        projectile.size = weapontype.size

    end


    projectile.dead = function () return ((projectile.origin:dist(projectile.position)) >= projectile.range) or projectile.pierce < 0 end

    projectile.progress = function (dt)
        projectile.position = projectile.position + ((projectile.unitvec*dt)*projectile.speed)
        projectile.speed = projectile.speed - (projectile.speedpenalty * dt)
    end

    projectile.render = function ()
        local x,y = projectile.position:unpack()
        local tmp = CAMERA_OFFSET-GAME.player.state.position
        local x_pos, y_pos = ((tmp + vector.new(x,y) - vector.new(RES_X/2,RES_Y/2))*ZOOM_MULT + vector.new(RES_X/2,RES_Y/2)):unpack()

        love.graphics.circle("fill",x_pos,y_pos, (ZOOM - fovsizecorrection())*projectile.size)
    end

    projectile.idinhitlist = function (id)
        for i, value in pairs(projectile.hitlist) do
            if id == value then
                return true
            end
        end
        return false
    end

    
    return projectile
end