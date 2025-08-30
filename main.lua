love = require("love")
gametable = require("game")

function love.load()
    _G.RES_X, _G.RES_Y, _ = love.window.getMode()

    FONT = love.graphics.setNewFont("Assets/Font/Exo/static/Exo-Thin.ttf", 60)
    _G.ORIGINAL_ZOOM = 20
    _G.ZOOM = 20
    _G.ZOOM_MULT = ZOOM/20
    _G.CAMERA_OFFSET = vector.new(0,0)
    _G.GAME = ReturnGameTable()
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
end

function love.resize(w, h)
    _G.RES_X = w
    _G.RES_Y = h
end

function love.update(dt)
    x_pos_screen, y_pos_screen= (CAMERA_OFFSET-GAME.player.state.position):unpack() -- X and Y positions of the screen according to where it is on the map
    
    local tmp_pos_player = (CAMERA_OFFSET*ZOOM_MULT) + vector.new(RES_X/2, RES_Y/2)
    x_pos_player, y_pos_player = tmp_pos_player:unpack() -- X and Y positions of the camera when compared to the position of the player AKA the camera offset

    ZOOM = ORIGINAL_ZOOM -- I know its a bit confusing but original zoom is copied to zoom so that the original value of 20 is not lost when changing zoom - i programmed it as i went along, okay?
    ZOOM_MULT = ZOOM/20

    while #GAME.enemies < 1 do
        GAME.functions.spawnenemy()
    end



    if love.keyboard.isDown("down") then
        ORIGINAL_ZOOM = ORIGINAL_ZOOM - 25*dt*ZOOM_MULT
    end

    if love.keyboard.isDown("up") then
        ORIGINAL_ZOOM = ORIGINAL_ZOOM + 25*dt*ZOOM_MULT
    end

    

    GAME.progress(dt)
    CAMERA_OFFSET = GAME.player.camera.offset()
    ZOOM_MULT = ZOOM/20

    if love.mouse.isDown(2) then
        local mouse_x, mouse_y = love.mouse.getPosition()
        local mouse_dist = (math.abs(mouse_x - RES_X/2) + math.abs(mouse_y - RES_Y/2)) / (RES_X/2 + RES_Y/2)

        ZOOM_MULT = ZOOM_MULT - mouse_dist/3
        ZOOM = ORIGINAL_ZOOM * ZOOM_MULT
        GAME.player.state.scopedin = true
    else
        GAME.player.state.scopedin = false
    end


    mouse_x, mouse_y = love.mouse.getPosition()
    mouse_x = ((mouse_x - RES_X/2) / ZOOM_MULT - x_pos_screen + RES_X/2)
    mouse_y = ((mouse_y - RES_Y/2) / ZOOM_MULT - y_pos_screen + RES_Y/2)
    if love.mouse.isDown(1) then

        GAME.functions.fire(GAME.player.state.position+vector.new(RES_X/2,RES_Y/2),vector.new(mouse_x, mouse_y), GAME.player.equips.gun, GAME.player)
    end



    --position_text = string.format("%s\n%s\n%s\n%s\n%s", GAME.player.state.position:floor(), GAME.player.state.speed:floor(), CAMERA_OFFSET:floor(), ZOOM_MULT, ZOOM)
end

function love.draw()
    GAME.functions.renderprojectiles()
    GAME.functions.renderenemies()
    love.graphics.setColor(0,1,0)
    parallaxplayer(1.05,15)
    love.graphics.setColor(1,1,1)
    love.graphics.line(x_pos_player, y_pos_player, love.mouse.getX(), love.mouse.getY())
    love.graphics.setColor(1,0,0)
    love.graphics.line(x_pos_player, y_pos_player,(GAME.player.state.speed + vector.new(x_pos_player,y_pos_player)):unpack())
    love.graphics.setColor(1,1,1)
    parallaxcircle(vector.new(0,0),1.1,5,0.5)
    --love.graphics.printf(position_text, 0, 0, RES_X, "left", 0, 1, 1, 0, 0, 0, 0)
end

function fovsizecorrection()
    return (pythagorean(GAME.player.state.speed) / (100/ZOOM_MULT))
end

function fovposcorrection(orgvalue, resolution)
    local modifier = ( ZOOM - (pythagorean(GAME.player.state.speed)) / (100/ZOOM_MULT))/ ZOOM
    return ((orgvalue - resolution/2) * modifier) + resolution/2
end

function parallaxcircle(pos,range,density,size)
    local x_pos, y_pos = (CAMERA_OFFSET-GAME.player.state.position):unpack()
    local x, y = pos:unpack()
    x_pos = x_pos + x - RES_X/2
    y_pos = y_pos + y - RES_Y/2

    
    for i=1,range, (range-1)/density do
        local tmp_x = (x_pos * i * ZOOM_MULT) + RES_X/2
        local tmp_y = (y_pos * i * ZOOM_MULT) + RES_Y/2
        love.graphics.setColor(1-(i-1),0,0)
        if size == nil then
            love.graphics.circle("fill",fovposcorrection(tmp_x, RES_X), fovposcorrection(tmp_y, RES_Y), (ZOOM - fovsizecorrection())*i)
        else
            love.graphics.circle("fill",fovposcorrection(tmp_x, RES_X), fovposcorrection(tmp_y, RES_Y), (ZOOM - fovsizecorrection())*i*size)
        end
        
    end
    love.graphics.setColor(1, 1, 1)
end

function parallaxplayer(range,density)
    local x_pos, y_pos = (CAMERA_OFFSET-GAME.player.state.position+CAMERA_OFFSET):unpack()
    local x_pos = x_pos - x_pos_screen
    local y_pos = y_pos - y_pos_screen
    for i=1,range, (range-1)/density do
        local tmp_x = (x_pos * i * ZOOM_MULT) + RES_X/2
        local tmp_y = (y_pos * i * ZOOM_MULT) + RES_Y/2
        love.graphics.setColor(0,0.75+(i-1),0)
        love.graphics.circle("fill", tmp_x, tmp_y, (ZOOM - fovsizecorrection())*i)
    end
    love.graphics.setColor(1, 1, 1)
end