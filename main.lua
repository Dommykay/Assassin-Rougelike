love = require("love")
gametable = require("game")

function love.load()
    _G.RES_X = love.graphics.getWidth()
    _G.RES_Y = love.graphics.getHeight()
    FONT = love.graphics.setNewFont("Assets/Font/Exo/static/Exo-Thin.ttf", 60)
    _G.GAME = ReturnGameTable()
    _G.ZOOM = 20
    _G.ZOOM_MULT = ZOOM/20
    _G.CAMERA_OFFSET = {0,0}
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
end

function love.resize(w, h)
    _G.RES_X = w
    _G.RES_Y = h
end

function love.update(dt)
    if love.keyboard.isDown("down") then
        ZOOM = ZOOM - 25*dt*ZOOM_MULT
        ZOOM_MULT = ZOOM/20
    end

    if love.keyboard.isDown("up") then
        ZOOM = ZOOM + 25*dt*ZOOM_MULT
        ZOOM_MULT = ZOOM/20
    end
    position_text = string.format("%s,%s\n%s,%s\n%s,%s", math.floor(GAME.player.state.position[1]), math.floor(GAME.player.state.position[2]), math.floor(GAME.player.state.speed[1]), math.floor(GAME.player.state.speed[2]), math.floor(CAMERA_OFFSET[1]), math.floor(CAMERA_OFFSET[2]))

    GAME.progress(dt)
    CAMERA_OFFSET = GAME.player.camera.offset()
end

function love.draw()
    x_pos_screen = (CAMERA_OFFSET[1]-GAME.player.state.position[1])
    y_pos_screen = (CAMERA_OFFSET[2]-GAME.player.state.position[2])
    x_pos_player = (CAMERA_OFFSET[1]*ZOOM_MULT) + RES_X/2
    y_pos_player = (CAMERA_OFFSET[2]*ZOOM_MULT) + RES_Y/2
    love.graphics.setColor(0,1,0)
    love.graphics.circle("fill", x_pos_player, y_pos_player, ZOOM - fovsizecorrection())
    parallaxplayer(1.2,3)
    love.graphics.setColor(1,1,1)
    parallaxcircle(-250,-250,1.1,5)
    parallaxcircle(250,-250,1.1,5)
    parallaxcircle(-250,250,1.1,5)
    parallaxcircle(250,250,1.1,5)
    love.graphics.line(x_pos_player, y_pos_player, love.mouse.getX(), love.mouse.getY())
    love.graphics.setColor(1,0,0)
    love.graphics.line(x_pos_player, y_pos_player, GAME.player.state.speed[1]+RES_X/2,GAME.player.state.speed[2]+RES_Y/2)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(position_text, 0, 0, RES_X, "left", 0, 1, 1, 0, 0, 0, 0)
end

function fovsizecorrection()
    return (pythagorean(GAME.player.state.speed[1],GAME.player.state.speed[2]) / (100/ZOOM_MULT))
end

function fovposcorrection(orgvalue, resolution)
    local modifier = ( ZOOM - (pythagorean(GAME.player.state.speed[1],GAME.player.state.speed[2])) / (100/ZOOM_MULT))/ ZOOM
    return ((orgvalue - resolution/2) * modifier) + resolution/2
end

function parallaxcircle(x,y,range,density)
    local x_pos = (CAMERA_OFFSET[1]-GAME.player.state.position[1] + x) - RES_X/2
    local y_pos = (CAMERA_OFFSET[2]-GAME.player.state.position[2] + y) - RES_Y/2
    for i=1,range, (range-1)/density do
        local tmp_x = (x_pos * i * ZOOM_MULT) + RES_X/2
        local tmp_y = (y_pos * i * ZOOM_MULT) + RES_Y/2
        love.graphics.setColor(1-(i-1),0,0)
        love.graphics.circle("fill",fovposcorrection(tmp_x, RES_X), fovposcorrection(tmp_y, RES_Y), (ZOOM - fovsizecorrection())*i)
    end
    love.graphics.setColor(1, 1, 1)
end

function parallaxplayer(range,density)
    local x_pos = (CAMERA_OFFSET[1]-GAME.player.state.position[1]+RES_X/2-x_pos_screen+CAMERA_OFFSET[1]) - RES_X/2
    local y_pos = (CAMERA_OFFSET[2]-GAME.player.state.position[2]+RES_Y/2-y_pos_screen+CAMERA_OFFSET[2]) - RES_Y/2
    for i=1,range, (range-1)/density do
        local tmp_x = (x_pos * i * ZOOM_MULT) + RES_X/2
        local tmp_y = (y_pos * i * ZOOM_MULT) + RES_Y/2
        love.graphics.setColor(0,0.75+(i-1),0)
        love.graphics.circle("fill", tmp_x, tmp_y, (ZOOM - fovsizecorrection())*i)
    end
    love.graphics.setColor(1, 1, 1)
end