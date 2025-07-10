love = require("love")

function love.load()
    _G.RES_X = love.graphics.getWidth()
    _G.RES_Y = love.graphics.getHeight()
end

function love.resize(w, h)
    _G.RES_X = w
    _G.RES_Y = h
end

function love.update(dt)
    
end

function love.draw()
    love.graphics.circle("fill", RES_X/2, RES_Y/2, 20)
    love.graphics.line(RES_X/2, RES_Y/2, love.mouse.getX(), love.mouse.getY())
end