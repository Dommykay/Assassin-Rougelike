_G.enemyID = 1
function ReturnEnemy(type, position)
    local enemy = {}
    enemy.id = enemyID
    enemyID = enemyID + 1
    if type == nil then
        enemy.state = {}
        enemy.stats = {}
        enemy.state.position = {math.random(-500,500),math.random(-500,500)}
        enemy.state.health = 1
        enemy.state.size = 1
        enemy.state.speed = {0,0}
        enemy.state.dead = function () return enemy.state.health <= 0 end
        enemy.equips = {}
        local gunfile = require("Weapons.Guns.G19")
        enemy.equips.gun = ReturnGun()

        enemy.state.isStill = function () return (enemy.state.speed == {0,0}) end

        enemy.render = function ()
            parallaxcircle(enemy.state.position[1],enemy.state.position[2],1.1,5,enemy.state.size)
        end
    else
    end

    return enemy
end