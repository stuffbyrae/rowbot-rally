-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

local boatimage = gfx.imagetable.new('images/race/boat')

class('boat').extends(gfx.sprite)
function boat:init(x, y)
    boat.super.init(self)
    self.turning = true
    self.moving = true
    self.movingspeed = 5
    self.currentspeed = gfx.animator.new(1500, 0, self.movingspeed, pd.easingFunctions.inOutSine)
    self.turningspeed = 7
    self.lerp = 0.1
    self.crashed = false
    self.boosting = false
    self.leaping = false
    self.reversed = false
    self.rotation = 0
    self.radtation = 0
    self.crankage = 0
    self.camera_x = gfx.animator.new(1500, 0, 40, pd.easingFunctions.inOutSine)
    self.camera_y = gfx.animator.new(1500, 0, 20, pd.easingFunctions.inOutSine)
    self:moveTo(x, y)
    self:setImage(boatimage[1])
    self:add()
end

function boat:start()
end

function boat:stop()
end

function boat:collision_check()
end

function boat:crash()
end

function boat:boost()
    if not self.boosting then
    end
end

function boat:leap()
end

function boat:update()
    if self.turning then
        self.crankage += ((pd.getCrankChange() / 1.5) - self.crankage) * self.lerp
        self.rotation -= self.crankage
        self.rotation += self.turningspeed
        self.rotation = self.rotation % 360
        self.radtation = math.rad(self.rotation)
        self:setRotation(self.rotation)
    end
    if self.moving then
        self:moveBy(math.sin(self.radtation) * self.currentspeed:currentValue(), math.cos(self.radtation) * -self.currentspeed:currentValue())
        gfx.setDrawOffset(-self.x + 200 - (math.sin(self.radtation) * self.camera_x:currentValue()), -self.y + 120 + (math.cos(self.radtation) * self.camera_x:currentValue()))
    end
end