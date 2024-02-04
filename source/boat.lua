-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('boat').extends(gfx.sprite)
function boat:init(x, y)
    boat.super.init(self)
    self.boat_size = 90
    self.poly_body = pd.geometry.polygon.new(0,-38, 11,-29, 17,-19, 20,-6, 18,20, 15,30, 12,33, -12,33, -15,30, -18,20, -20,6, -20,-6, -17,-19, -11,-29, 0,-38)
    self.poly_inside = pd.geometry.polygon.new(12,-20, 0,-23, -12,-20, -16,-7, 16,-7, 16,5, -16,5, -14,20, 14,20, 16,5, 16,-7, 12,-20)
    self.poly_rowbot = pd.geometry.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11, 6,-8, 6,6, 20,6, 20,-8, 6,-8, 3,-11)
    self.poly_rowbot_fill = pd.geometry.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11)
    self.transform = pd.geometry.affineTransform.new()
    self.transform_shadow = pd.geometry.affineTransform.new()
    self.scale_x = gfx.animator.new(0, 1, 1)
    self.scale_y = gfx.animator.new(0, 1, 1)
    self.boost_scale_x = gfx.animator.new(0, 1, 1)
    self.boost_scale_y = gfx.animator.new(0, 1, 1)
    self.turning = true
    self.moving = true
    self.movingspeed = 5
    self.currentspeed = gfx.animator.new(1500, 0, self.movingspeed, pd.easingFunctions.inOutSine)
    self.turningspeed = 7
    self.lerp = 0.2
    self.crashed = false
    self.boosting = false
    self.leaping = false
    self.reversed = false
    self.old_rotation = 0
    self.rotation = 0
    self.rotation_difference = 0
    self.radtation = 0
    self.crankage = 0
    self.camera_x = gfx.animator.new(1500, 0, 20, pd.easingFunctions.inOutSine)
    self.camera_y = gfx.animator.new(1500, 0, 20, pd.easingFunctions.inOutSine)
    self:moveTo(x, y)
    self:setImage(boatimage)
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
        self.boosting = true
        -- shakies()
        self.camera_x = gfx.animator.new(500, self.camera_x:currentValue(), -20, pd.easingFunctions.outBack)
        self.camera_y = gfx.animator.new(500, self.camera_y:currentValue(), -20, pd.easingFunctions.outBack)
        self.boost_scale_x = gfx.animator.new(500, 0.8, 1)
        self.boost_scale_y = gfx.animator.new(500, 1.2, 1)
        self.currentspeed = gfx.animator.new(500, self.currentspeed:currentValue(), self.movingspeed * 1.5, pd.easingFunctions.inOutSine)
        self.lerp = 0.1
        pd.timer.performAfterDelay(2500, function()
            self.boosting = false
            self.lerp = 0.2
            self.currentspeed = gfx.animator.new(500, self.currentspeed:currentValue(), self.movingspeed, pd.easingFunctions.inOutSine, 500)
            self.camera_x = gfx.animator.new(1500, self.camera_x:currentValue(), 20, pd.easingFunctions.inOutSine)
            self.camera_y = gfx.animator.new(1500, self.camera_y:currentValue(), 20, pd.easingFunctions.inOutSine)
        end)
    end
end

function boat:leap()
    if not self.leaping then
        self.leaping = true
        self.turning = false
        self.boat_size = 220
        self.scale_x = gfx.animator.new(650, 1, 1.75, pd.easingFunctions.outQuad)
        self.scale_y = gfx.animator.new(650, 1, 1.75, pd.easingFunctions.outQuad)
        self.scale_x.reverses = true
        self.scale_y.reverses = true
        pd.timer.performAfterDelay(1300, function()
            self.leaping = false
            self.turning = true
            self.scale_x = gfx.animator.new(1500, 0.9, 1, pd.easingFunctions.outElastic)
            self.scale_y = gfx.animator.new(1500, 0.9, 1, pd.easingFunctions.outElastic)
            self.boat_size = 90
        end)
    end
end

function boat:update()
    self.transform:reset()
    self.transform_shadow:reset()
    if self.turning then
        if pd.getCrankChange() >= 0 then
            if pd.isSimulator == 1 then
                self.crankage += ((pd.getCrankChange() / 1.5) - self.crankage) * self.lerp
            else
                self.crankage += ((pd.getCrankChange() / 3) - self.crankage) * self.lerp
            end
        else
            self.crankage += ((0 / 1.5) - self.crankage) * self.lerp
        end
        self.rotation -= self.crankage
        self.rotation += self.turningspeed
        self.rotation = self.rotation % 360
        self.radtation = math.rad(self.rotation)
    end
    if self.moving then
        camx, camy = gfx.getDrawOffset()
        gfx.setDrawOffset(camx + math.sin(self.radtation) * self.currentspeed:currentValue(), camy + math.cos(self.radtation) * self.currentspeed:currentValue())
        camx, camy = gfx.getDrawOffset()
        self:moveTo(-camx + 200 + (math.sin(self.radtation) * self.camera_x:currentValue()), -camy + 120 + (math.cos(self.radtation) * self.camera_y:currentValue()))
    end
    self.boat_image = gfx.image.new(self.boat_size, self.boat_size)
    self.transform:scale(self.scale_x:currentValue() * self.boost_scale_x:currentValue(), self.scale_y:currentValue() * self.boost_scale_y:currentValue())
    self.transform:rotate(-self.rotation)
    self.transform_shadow:scale(self.boost_scale_x:currentValue(), self.boost_scale_y:currentValue())
    self.transform_shadow:rotate(-self.rotation)
    self.transform_shadow:translate(5 * (self.scale_x:currentValue()^2.5), 5 * (self.scale_y:currentValue()^3.5))
    gfx.pushContext(self.boat_image)
    gfx.setDrawOffset(self.boat_size / 2, self.boat_size / 2)
        gfx.fillPolygon(self.transform_shadow:transformedPolygon(self.poly_body))
        gfx.setColor(gfx.kColorWhite)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.75, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
        gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_inside))
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(2)
        gfx.drawPolygon(self.transform:transformedPolygon(self.poly_body))
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(-math.cos(self.radtation) * (12 * self.scale_x:currentValue()), math.sin(self.radtation) * (12 * self.scale_x:currentValue()), 11 * self.scale_x:currentValue())
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_rowbot_fill))
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(self.transform:transformedPolygon(self.poly_rowbot))
        gfx.drawCircleAtPoint(-math.cos(self.radtation) * (12 * self.scale_x:currentValue()), math.sin(self.radtation) * (12 * self.scale_x:currentValue()), 11 * self.scale_x:currentValue())
        gfx.drawCircleAtPoint(-math.cos(self.radtation) * (12 * self.scale_x:currentValue()), math.sin(self.radtation) * (12 * self.scale_x:currentValue()), 8 * self.scale_x:currentValue())
        gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
        gfx.fillCircleAtPoint(-math.cos(self.radtation) * (5 * self.scale_x:currentValue()), math.sin(self.radtation) * (5 * self.scale_x:currentValue()), 6 * self.scale_x:currentValue())
        gfx.fillCircleAtPoint(-math.cos(self.radtation) * (19 * self.scale_x:currentValue()), math.sin(self.radtation) * (19 * self.scale_x:currentValue()), 6 * self.scale_x:currentValue())
        gfx.fillCircleAtPoint(-math.cos(self.radtation) * (-13 * self.scale_x:currentValue()), math.sin(self.radtation) * (-13 * self.scale_x:currentValue()), 3 * self.scale_x:currentValue())
    gfx.popContext()
    self:setImage(self.boat_image)
end