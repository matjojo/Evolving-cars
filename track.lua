function parseTrack()
    trackFileName = settings.trackFilename or "default"
    local trackFileExtension = settings.extension or ".png"
    local trackPath = (settings.subfolder or "/track/") .. trackFileName .. trackFileExtension
    local trackImage = love.graphics.newImage(trackPath)
    local imageData = love.image.newImageData(trackPath) -- we generate the image collision table from this

    repeat
        local success = love.window.setMode(trackImage:getWidth(), trackImage:getHeight());
    until success

    backgroundCanvas = love.graphics.newCanvas() -- default is screen size, which we have just set above

    love.graphics.setCanvas(backgroundCanvas)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(trackImage, 0, 0)
    love.graphics.setCanvas()

    local collisionColour = settings.trackWallColour or {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1}
    local cc = collisionColour
    for width = 0, imageData:getWidth()-1, 1 do
        collisionTable[width] = {}
        for height = 0, imageData:getHeight()-1, 1 do
            local r, g, b, a = imageData:getPixel(width, height)
            -- if the pixel is anything but white we assume we can ride on it
            -- this allows us to style the tracks should we want to later
            -- print(r, g, b, a)
            if r == cc.r and g == cc.g and b == cc.b and a == cc.a then
                collisionTable[width][height] = true
            else
                collisionTable[width][height] = false
            end

        end
    end

    -- this piece of code can be used to verify the imagedata
    -- testImageData = love.image.newImageData( imageData:getWidth(), imageData:getHeight())
    -- local r, g, b, a
    -- for i, d in ipairs(collisionTable) do
    --     for i2, d2 in ipairs(d) do
    --         if d2 then
    --             r, g, b, a = cc.r, cc.g, cc.b, cc.a -- the colliding parts of the track are still printed in the given colour
    --         else
    --             r, g, b, a = 0, 0, 0, 1 // per default we draw all but the walls in black
    --         end
    --         testImageData:setPixel(i, i2, r, g, b, a)
    --             -- print("collisionTable[" .. i .. "][" .. i2 .. "] = " .. tostring(d2) .. " " .. r .. " " .. g .. " " .. b .. " " .. a)
    --     end
    -- end
    -- -- this image can be printed to the screen to check the validity of the the collision table
    -- testImage = love.graphics.newImage(testImageData)




end