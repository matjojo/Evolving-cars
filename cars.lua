function generateCars()

    for i = 0, (settings.maxCars or 100), 1 do
        cars[i] = deepCopyTable(baseCar)
        cars[i]:new(i)
    end



end


baseCar = {
    ["location"] = {["x"]=0, ["y"]=0},
    ["velocity"] = {["x"]=0, ["y"]=0},
    ["ID"] = -1,
    ["new"] = function (this, newID)
        this.ID = newID
    end,
    ["move"] = function (this) 
        this.location.x = this.location.x + this.velocity.x
        this.location.y = this.location.y + this.velocity.y
    end,
    ["decideDirection"] = function (this)
        this.velocity.y = -5
    end,
    ["draw"] = function (this)

    end
}