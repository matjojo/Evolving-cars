io.stdout:setvbuf("no")
-- require('main_loop')
-- require("run") -- this makes sure that we can skip framedrawing and such
require("track") -- reads the track file and creates the collision tables
require("cars")
settings = require("settings")
require("util") -- some utilty functions



--[[
TODO:
Add the driver logic, for a Lua implementation of this take a look at MarIOCart from sethbling

we need to set the DT to some default value if we ever want to do a high speed background simulation
--]]



function love.load(arg)
	-- This canvas containts the current track as a background image.
	-- Drawing this before anything else means that we only have to draw this image to memory once
	backgroundCanvas = nil
	collisionTable = {} -- [x][y]
    love.keyboard.setTextInput(true)
    parseTrack()
	love.window.setTitle("Running track: " .. trackFileName)
	
	cars = {}
	generateCars()

	debug = {
	["showCheckPoints"] = false,
	["showCarCorner"] = false,
	["showMouseCoordsWhenPressed"] = false,
	}

end

function love.update(dt)
	for _, d in pairs(cars) do
		d:update(dt)
	end

end -- love.update

function love.draw(dt)
	love.graphics.setCanvas()
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(backgroundCanvas)
	-- ^^^^ this draws the trackimage to the background

	for _, d in pairs(cars) do
		d:draw()
	end
	if debug.showCheckPoints then
		love.graphics.setColor(1,0,0,1)
		for _, d in ipairs(settings.trackInfo.default.checkpoints) do
			love.graphics.polygon("line", verticesFromSquareAsTwoPoints(d))
		end
	end
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.push('quit')
	end
	print(k)
end

function love.mousepressed( x, y, button, istouch, presses)
	if debug.showMouseCoordsWhenPressed then
		print(x, y)
	end
end