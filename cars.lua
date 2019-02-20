function generateCars()

    for i = 0, (settings.maxCars or 100), 1 do
        cars[i] = DeepCopyTable(baseCar)
        cars[i]:init(i)
    end



end


baseCar = {
    ["location"] = {["x"]=0, ["y"]=0},
    ["velocity"] = {["x"]=0, ["y"]=0},
    ["size"] = {["width"]=0, ["height"]=0},
    ["colour"] = {{["r"]=1, ["g"]=1, ["b"]=1, ["a"]=1}},
    ["ID"] = -1,
    ["init"] = function (this, newID)
        this.ID = newID
        this.location = settings.carStartLocation[(settings.trackFileName or "default")]
        this.size = (settings.size or {["width"]=20, ["height"]=8})
        this.colour = (settings.carColour or {["r"]=1, ["g"]=1, ["b"]=1, ["a"]=1})
    end,
    ["move"] = function (this, dt) 
        this.location.x = this.location.x + (this.velocity.x * dt)
        this.location.y = this.location.y + (this.velocity.y * dt)
    end,
    ["decideDirection"] = function (this) -- test option before the genetic learning is implemented
        this.velocity.x = -5
    end,
    ["draw"] = function (this)
        love.graphics.setColor(this.colour.r, this.colour.g, this.colour.b, this.colour.a)
        love.graphics.rectangle("fill", this.location.x, this.location.y, this.size.width, this.size.height)
    end
}