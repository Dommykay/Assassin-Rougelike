function ReturnGun()
    local gun = {}

    gun.name = "G19" --Name of the gun
    gun.description = "Blah Blah Blah" --Description of the gun
    gun.firerate = 1 --Number of bullets per second, up to 1 bullet per frame bc im ahh at programming
    gun.firerate = 1/gun.firerate
    gun.loudness = 15 --How big the sound bubble the gun creates is
    gun.bulletspeed = 1000 --How fast the projectiles are leaving the weapon
    gun.bulletspeedpenalty = 100 --How much does the speed of the projectiles deteriorate by per second after being shot
    gun.range = 500 --How far the projectiles will reach after being shots
    gun.spread = 0.05 --How inaccurate the gun is at it's maximum
    gun.stability = 0.5 --How much walking affects inaccuracy
    gun.walkspeedpenalty = 200 --How much walkspeed you lose when holding out the weapon
    gun.aimingvisionincrease = 2 --How much better can you see when scoping in
    gun.aimingwalkspeedpenalty = 100 --How much slower you walk when scoping in
    gun.lastfired = 0 --Stores when the gun was last fired to allow the firerate to know when the gun can next be fired
    gun.damage = 1 --How much damage the gun does
    gun.size = 0.15 --The size of the fired projectile

    return gun
end