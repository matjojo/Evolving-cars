function generateCars()

    for i = 0, (settings.maxCars or 100), 1 do
        cars[i] = DeepCopyTable(baseCar)
        cars[i]:init(i)
    end



end


baseCar = {
    ["location"] = {["x"] = 550, ["y"] = 252, rotation = 0}, -- default for the default track
    ["velocity"] = {["forward"] = 0, ["rotational"] = 0},
    ["size"] = {["length"]=20, ["width"]=8},
    ["colour"] = {{["r"]=1, ["g"]=1, ["b"]=1, ["a"]=1}},
    ["dead"] = false,
    ["ID"] = -1,
    ["init"] = function (this, newID)
        this.ID = newID
        this.location = settings.carStartLocation[(settings.trackFileName or "default")] or this.location
        this.size = (settings.size or this.size)
        this.colour = (settings.carColour or this.colour)
    end,
    ["move"] = function (this, dt)
        this.location.rotation = this.location.rotation + this.velocity.rotational * dt

        local veloy = math.sin(math.rad(this.location.rotation)) * this.velocity.forward
        local velox = math.cos(math.rad(this.location.rotation)) * this.velocity.forward

        this.location.x = this.location.x + (velox * dt)
        this.location.y = this.location.y - (veloy * dt)
    end,
    ["decideDirection"] = function (this) -- test option before the genetic learning is implemented
        this.velocity.forward = 25
        this.velocity.rotational = -10
    end,
    ["draw"] = function (this)
        love.graphics.setColor(this.colour.r, this.colour.g, this.colour.b, this.colour.a)
        local vertices = this:getVertices() -- tl-tr-br-bl
        love.graphics.polygon("fill", vertices)
        -- love.graphics.setColor(1,0,0,1) -- show where the top left is (RED)
        -- love.graphics.circle("fill", vertices[1], vertices[2], 5)
        -- love.graphics.setColor(0,1,0,1) -- show where the top right is (GREEN)
        -- love.graphics.circle("fill", vertices[3], vertices[4], 5)
        -- love.graphics.setColor(0,0,1,1) -- show where the bottom right is (BLUE)
        -- love.graphics.circle("fill", vertices[5], vertices[6], 5)
        -- love.graphics.setColor(1,1,1,1) -- show where the bottom left is (WHITE)
        -- love.graphics.circle("fill", vertices[7], vertices[8], 5)
    end,
    ["collisionLogic"] = function (this)
        -- make list of pixel locations that this car is in
        -- we will probably jsut check on the corners, as dt should be small and thus no real problems should occur,
        -- maybe we can widen the track limits to three pixels to alliviate this problem
        -- check for collisions
        -- make the car red, it has collided
    end,
    ["getVertices"] = function (this)
        local sinOfRotation = math.sin(math.rad(this.location.rotation))
        local cosOfRotation = math.cos(math.rad(this.location.rotation))
        local tr = {
                    ["y"] = this.location.y - (sinOfRotation * this.size.length),
                    ["x"] = this.location.x + (cosOfRotation * this.size.length)
                }

        local tl = {
                    ["x"] = this.location.x,
                    ["y"] = this.location.y
                }

        local bl = {
                    ["y"] = this.location.y + (math.sin(math.rad(90-this.location.rotation)) * this.size.width),
                    ["x"] = this.location.x + (math.cos(math.rad(90-this.location.rotation)) * this.size.width)
                }

        local br = {
                    ["y"] = bl.y - (sinOfRotation * this.size.length),
                    ["x"] = bl.x + (cosOfRotation * this.size.length)
                }
        return {tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y}
    end,
}