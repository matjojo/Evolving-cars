io.stdout:setvbuf("no")
-- require('main_loop')
-- require("run") -- this makes sure that we can skip framedrawing and such
require("track") -- reads the track file and creates the collision tables
require("cars")
settings = require("settings")
require("util") -- some utilty functions

function love.load(arg)
	-- This canvas containts the current track as a background image.
	-- Drawing this before anything else means that we only have to draw this image to memory once
	backgroundCanvas = nil
	collisionTable = {}
    love.keyboard.setTextInput(true)
    parseTrack()
	love.window.setTitle("Running track: " .. trackFileName)
	
	cars = {}
	generateCars()

end

function love.update(dt)

end -- love.update

function love.draw(dt)
	love.graphics.setCanvas()
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(backgroundCanvas)
	-- this draws the trackimage to the background

	love.graphics.line(0, 0, 700, 700)
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.push('quit')
	end
	print(k)
end



function love.focus(f)
	if not f then
		Focus = false
	else
		Focus = true
	end
end