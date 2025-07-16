love = require("love")
vector = require("libs.vector.vector")


function CreateProjectile(startpos, endpos, weapontype)
    startpos = vector.new(startpos[1], startpos[2])
    endpos = vector.new(endpos[1], endpos[2])
    local vector = endpos - startpos
    vector:norm()
    local projectile = {}

    if weapontype == nil then
        -- Default/testing weapon type
        projectile.range = 50
        projectile.firerate = 5
        projectile.damage = 1
        projectile.speed = 100
        projectile.position = startpos
        projectile.origin = startpos
        projectile.unitvec = vector
        projectile.size = 0.15

        projectile.dead = function () return (projectile.origin:dist(projectile.position)) >= projectile.range end

        projectile.progress = function (dt)
            projectile.position = projectile.position + ((projectile.unitvec*dt)*projectile.speed)
        end

        projectile.render = function ()
            local x,y = projectile.position:unpack()
            local x_pos = ((CAMERA_OFFSET[1]-GAME.player.state.position[1] + x) - RES_X/2)* ZOOM_MULT + RES_X/2
            local y_pos = ((CAMERA_OFFSET[2]-GAME.player.state.position[2] + y) - RES_Y/2)* ZOOM_MULT + RES_Y/2
            love.graphics.circle("fill",fovposcorrection(x_pos, RES_X),fovposcorrection(y_pos, RES_Y), (ZOOM - fovsizecorrection())*projectile.size)
        end


    end

    return projectile
end