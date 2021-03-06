function generateCars()
    for i = 1, (settings.maxCars or 100), 1 do
        cars[i] = baseCar:new(i)
    end
end

baseCar = {
    ["location"] = {["x"] = 550, ["y"] = 252, rotation = 0}, -- default for the default track
    ["velocity"] = {["forward"] = 0, ["rotational"] = 0},
    ["size"] = {["length"]=20, ["width"]=8},
    ["colour"] = {{["r"]=1, ["g"]=1, ["b"]=1, ["a"]=1}},
    ["maxCheckPoint"] = 0,
    -- you start with the checkpoint at -1, every checkpoint is a box you have to go through,
    -- only if the number is n AND you go through checkpoint n+1 your score goes to n+1.
    -- Making sure that none of the bots will go over a single checkpoint again and again
    ["dead"] = false,
    ["ID"] = -1,
    ["specifications"] = {
        maxSpeed = 120, -- this should probably never rise above say 5 times UPS, since the collisionlogic relies on the car not moving too much
        accelleration = 50, -- it should take some time to speed up
        decelleration = 70,
        maxSpeedReverse = -30, -- really there should be no reason to drive backwards but hey what can ya do?
        maxSteeringAngle = 33, -- this is some sort of assume/reasonable real amount
        steeringAccelleration = 50, -- the steering should be able to lock within a second
    },
    ["new"] = function (this, newID)
        newCar = DeepCopyTable(baseCar)
        newCar.ID = newID
        newCar.location = settings.trackInfo[(settings.trackFileName or "default")].carStartLocation or this.location
        -- settings.trackInfo[trackname].carStartLocation gives you the location of the cars at the start
        newCar.size = (settings.size or this.size)
        newCar.colour = (settings.carColour or this.colour)
        return newCar
    end,
    ["move"] = function (this, dt)
        this.location.rotation = this.location.rotation + this.velocity.rotational * dt

        local veloy = math.sin(math.rad(this.location.rotation)) * this.velocity.forward
        local velox = math.cos(math.rad(this.location.rotation)) * this.velocity.forward

        this.location.x = this.location.x + (velox * dt)
        this.location.y = this.location.y - (veloy * dt)
    end,
    ["decideDirection"] = function (this, dt) -- test option before the genetic learning is implemented
        local w, a, s, d = false, false, false, false -- default is off

        -- w, a, s, d = this:getNet():getInputsFromNet()
        if w then
            this.velocity.forward = math.min(   this.velocity.forward + (this.specifications.accelleration * dt),
                                                this.specifications.maxSpeed)
        end
        if s then
            this.velocity.forward = math.max(   this.velocity.forward - (this.specifications.decelleration * dt),
                                                this.specifications.maxSpeedReverse)
        end
        if a then
            this.velocity.rotational = math.min(this.velocity.rotational + (this.specifications.steeringAccelleration * dt),
                                                this.specifications.maxSteeringAngle)
        end
        if d then
            this.velocity.rotational = math.max( this.velocity.rotational - (this.specifications.steeringAccelleration * dt),
                                                -this.specifications.maxSteeringAngle)
        end
    end,
    ["draw"] = function (this)
        local colour 
        if this.dead then
            colour = settings.carColourDead or {["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1}
        else
            colour = this.colour
        end
        love.graphics.setColor(colour.r, colour.g, colour.b, colour.a)
        local vertices = this:getVertices() -- tl-tr-br-bl
        love.graphics.polygon("fill", vertices)
        if debug.showCarCorner then
            love.graphics.setColor(1,0,0,1) -- show where the top left is (RED)
            love.graphics.circle("fill", vertices[1], vertices[2], 5)
            love.graphics.setColor(0,1,0,1) -- show where the top right is (GREEN)
            love.graphics.circle("fill", vertices[3], vertices[4], 5)
            love.graphics.setColor(0,0,1,1) -- show where the bottom right is (BLUE)
            love.graphics.circle("fill", vertices[5], vertices[6], 5)
            love.graphics.setColor(1,1,1,1) -- show where the bottom left is (WHITE)
            love.graphics.circle("fill", vertices[7], vertices[8], 5)
        end
    end,
    ["checkDeath"] = function (this)
        for _, d in pairs(this:cornersFromVertices(this:getVertices())) do
            -- so basically for every corner, which is: {x and y}
            if collisionTable[math.floor(d.x)][math.floor(d.y)] then
                this.dead = true
            end
        end
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
    ["update"] = function (this, dt)
        if not this.dead then
            this:checkDeath()
            this:decideDirection(dt)
            this:move(dt)
            this:checkCheckpoint(dt)
        end
    end,
    ["cornersFromVertices"] = function (this, vertices)
        -- these are the vertices as gotten from this:getVertices()
        local corners = {}
        corners[1] = {["x"] = vertices[1], ["y"] = vertices[2]}
        corners[2] = {["x"] = vertices[3], ["y"] = vertices[4]}
        corners[3] = {["x"] = vertices[5], ["y"] = vertices[6]}
        corners[4] = {["x"] = vertices[7], ["y"] = vertices[8]}
        return corners
    end,
    ["checkCheckpoint"] = function (this, dt)
        local checkpoints = settings.trackInfo[settings.trackFilename or "default"].checkpoints
        local checkNum = this.maxCheckPoint
        while checkNum > #checkpoints do
            checkNum = checkNum - #checkpoints
        end

        local nextCheckpoint = checkpoints[checkNum + 1]
        
        local cp = nextCheckpoint
        if pointIsInRectangle(this.location.x, this.location.y, cp.tl.x, cp.tl.y, cp.br.x, cp.br.y) then
            this.maxCheckPoint = this.maxCheckPoint + 1
        end
    end,
}