function ReturnGun()
    local gun = {}

    gun.name = "G19" --Name of the gun
    gun.description = "Blah Blah Blah" --Description of the gun
    gun.firerate = 10 --Number of bullets per second, up to 1 bullet per frame bc im ahh at programming
    gun.loudness = 15 --How big the sound bubble the gun creates is
    gun.bulletspeed = 1000 --How fast the projectiles are leaving the weapon
    gun.bulletspeedpenalty = 1000 --How much does the speed of the projectiles deteriorate by per second after being shot
    gun.range = 500 --How far the projectiles will reach after being shots
    gun.spread = 10 --How inaccurate the gun is at it's maximum in degrees
    gun.stability = 200 --At what walkspeed the gun reaches maximum inaccuracy
    gun.walkspeedpenalty = 200 --How much walkspeed you lose when holding out the weapon
    gun.aimingvisionincrease = 2 --How much better can you see when scoping in
    gun.aimingspreadmult = 0.5 --How much spread is affected when aiming in
    gun.aimingwalkspeedpenalty = 100 --How much slower you walk when scoping in
    gun.damage = 1 --How much damage the gun does
    gun.headshotmult = 2 --How much the damage is multiplied by when getting a headshot AKA when standing still, 0 means no bonus
    gun.size = 0.15 --The size of the fired projectile
    gun.pierce = 1 --How many enemies can the fired projectile go through before being destroyed




    gun.lastfired = 0 --Stores when the gun was last fired to allow the firerate to know when the gun can next be fired
    gun.spread = math.rad(gun.spread) --Converting spread in degrees to radians
    gun.firerate = 1/gun.firerate --ignore this its just so that the firerate will be in bullets per second rather than seconds per bullet
    return gun
end