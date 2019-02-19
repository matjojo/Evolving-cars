io.stdout:setvbuf("no")
-- require('main_loop')
require("run") -- this makes sure that we can skip framedrawing and such


function love.load(arg)
	love.keyboard.setTextInput(true)				-- NEED TO UNDERSTAND this AND HOWTO USE IT
end

function love.update(dt)

end -- love.update

function love.draw(dt)
	if inMainMenu then drawMainMenu() end
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