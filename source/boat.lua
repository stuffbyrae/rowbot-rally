-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

local sin = {0.01745241,0.0348995,0.05233596,0.06975647,0.08715574,0.1045285,0.1218693,0.1391731,0.1564345,0.1736482,0.190809,0.2079117,0.224951,0.2419219,0.258819,0.2756374,0.2923717,0.309017,0.3255681,0.3420201,0.3583679,0.3746066,0.3907311,0.4067366,0.4226183,0.4383712,0.4539905,0.4694716,0.4848096,0.5,0.5150381,0.5299193,0.5446391,0.5591929,0.5735765,0.5877852,0.601815,0.6156615,0.6293204,0.6427876,0.656059,0.6691306,0.6819984,0.6946584,0.7071068,0.7193398,0.7313537,0.7431449,0.7547095,0.7660444,0.7771459,0.7880107,0.7986355,0.809017,0.8191521,0.8290375,0.8386706,0.8480481,0.8571673,0.8660254,0.8746197,0.8829476,0.8910065,0.8987941,0.9063078,0.9135455,0.9205048,0.9271839,0.9335804,0.9396926,0.9455186,0.9510565,0.9563047,0.9612617,0.9659258,0.9702957,0.9743701,0.9781476,0.9816272,0.9848077,0.9876884,0.9902681,0.9925461,0.9945219,0.9961947,0.9975641,0.9986295,0.9993908,0.9998477,1.0,0.9998477,0.9993908,0.9986295,0.9975641,0.9961947,0.9945219,0.9925461,0.9902681,0.9876884,0.9848077,0.9816272,0.9781476,0.9743701,0.9702957,0.9659258,0.9612617,0.9563047,0.9510565,0.9455186,0.9396926,0.9335805,0.9271839,0.9205049,0.9135455,0.9063078,0.8987941,0.8910066,0.8829476,0.8746197,0.8660254,0.8571673,0.848048,0.8386706,0.8290376,0.819152,0.809017,0.7986355,0.7880108,0.777146,0.7660444,0.7547096,0.7431448,0.7313537,0.7193399,0.7071068,0.6946585,0.6819983,0.6691306,0.656059,0.6427876,0.6293205,0.6156614,0.6018151,0.5877852,0.5735765,0.559193,0.5446391,0.5299193,0.515038,0.5000001,0.4848095,0.4694716,0.4539906,0.4383711,0.4226183,0.4067366,0.3907312,0.3746067,0.3583679,0.3420202,0.3255681,0.309017,0.2923718,0.2756374,0.2588191,0.2419219,0.2249511,0.2079116,0.190809,0.1736483,0.1564344,0.1391732,0.1218693,0.1045285,0.08715588,0.06975647,0.05233605,0.03489945,0.01745246,-8.742278e-08,-0.01745239,-0.03489939,-0.05233599,-0.0697564,-0.08715581,-0.1045284,-0.1218692,-0.1391731,-0.1564344,-0.1736482,-0.190809,-0.2079118,-0.224951,-0.2419218,-0.2588191,-0.2756373,-0.2923718,-0.309017,-0.3255681,-0.3420202,-0.3583679,-0.3746066,-0.3907311,-0.4067365,-0.4226183,-0.4383711,-0.4539905,-0.4694715,-0.4848097,-0.5,-0.515038,-0.5299193,-0.544639,-0.559193,-0.5735764,-0.5877851,-0.601815,-0.6156614,-0.6293204,-0.6427876,-0.6560591,-0.6691306,-0.6819983,-0.6946584,-0.7071067,-0.7193398,-0.7313537,-0.7431448,-0.7547096,-0.7660446,-0.777146,-0.7880107,-0.7986354,-0.8090168,-0.8191521,-0.8290376,-0.8386706,-0.848048,-0.8571672,-0.8660254,-0.8746197,-0.8829476,-0.8910065,-0.8987941,-0.9063078,-0.9135454,-0.9205048,-0.9271838,-0.9335805,-0.9396927,-0.9455186,-0.9510565,-0.9563047,-0.9612617,-0.9659259,-0.9702957,-0.9743701,-0.9781476,-0.9816272,-0.9848078,-0.9876883,-0.9902681,-0.9925461,-0.9945219,-0.9961947,-0.997564,-0.9986295,-0.9993908,-0.9998477,-1.0,-0.9998477,-0.9993908,-0.9986295,-0.997564,-0.9961947,-0.9945219,-0.9925462,-0.9902681,-0.9876883,-0.9848077,-0.9816272,-0.9781476,-0.97437,-0.9702957,-0.9659258,-0.9612617,-0.9563048,-0.9510565,-0.9455186,-0.9396926,-0.9335805,-0.9271839,-0.9205048,-0.9135454,-0.9063078,-0.8987941,-0.8910066,-0.8829476,-0.8746197,-0.8660254,-0.8571674,-0.848048,-0.8386705,-0.8290376,-0.8191521,-0.8090171,-0.7986354,-0.7880107,-0.777146,-0.7660445,-0.7547097,-0.7431448,-0.7313536,-0.7193398,-0.7071069,-0.6946585,-0.6819983,-0.6691306,-0.6560591,-0.6427878,-0.6293206,-0.6156614,-0.601815,-0.5877853,-0.5735766,-0.5591931,-0.5446389,-0.5299193,-0.5150381,-0.5000002,-0.4848095,-0.4694715,-0.4539905,-0.4383712,-0.4226184,-0.4067365,-0.3907311,-0.3746066,-0.3583681,-0.3420204,-0.325568,-0.3090169,-0.2923717,-0.2756375,-0.2588193,-0.2419218,-0.224951,-0.2079118,-0.1908092,-0.1736484,-0.1564344,-0.1391731,-0.1218694,-0.1045287,-0.08715603,-0.06975638,-0.05233596,-0.0348996,-0.01745261,1.748456e-07}
local cos = {0.9998477, 0.9993908, 0.9986295, 0.9975641, 0.9961947, 0.9945219, 0.9925461, 0.9902681, 0.9876884, 0.9848077, 0.9816272, 0.9781476, 0.9743701, 0.9702957, 0.9659258, 0.9612617, 0.9563048, 0.9510565, 0.9455186, 0.9396926, 0.9335804, 0.9271839, 0.9205049, 0.9135454, 0.9063078, 0.8987941, 0.8910065, 0.8829476, 0.8746197, 0.8660254, 0.8571673, 0.8480481, 0.8386706, 0.8290376, 0.8191521, 0.809017, 0.7986355, 0.7880108, 0.7771459, 0.7660444, 0.7547096, 0.7431448, 0.7313537, 0.7193398, 0.7071068, 0.6946584, 0.6819984, 0.6691306, 0.656059, 0.6427876, 0.6293204, 0.6156615, 0.601815, 0.5877853, 0.5735765, 0.5591929, 0.5446391, 0.5299193, 0.5150381, 0.5, 0.4848096, 0.4694716, 0.4539905, 0.4383712, 0.4226182, 0.4067366, 0.3907312, 0.3746066, 0.358368, 0.3420202, 0.3255681, 0.309017, 0.2923718, 0.2756374, 0.2588191, 0.2419219, 0.224951, 0.2079117, 0.1908091, 0.1736482, 0.1564345, 0.1391731, 0.1218693, 0.1045284, 0.0871558, 0.06975651, 0.05233597, 0.0348995, 0.01745238, -4.371139e-08, -0.01745235, -0.03489946, -0.05233594, -0.06975648, -0.08715577, -0.1045285, -0.1218693, -0.1391731, -0.1564344, -0.1736482, -0.190809, -0.2079116, -0.224951, -0.2419219, -0.258819, -0.2756374, -0.2923717, -0.3090169, -0.3255681, -0.3420201, -0.3583679, -0.3746066, -0.3907312, -0.4067366, -0.4226183, -0.4383711, -0.4539904, -0.4694716, -0.4848095, -0.5000001, -0.515038, -0.5299193, -0.5446391, -0.5591928, -0.5735765, -0.5877852, -0.6018151, -0.6156614, -0.6293203, -0.6427876, -0.656059, -0.6691307, -0.6819983, -0.6946583, -0.7071068, -0.7193397, -0.7313538, -0.7431448, -0.7547097, -0.7660444, -0.7771459, -0.7880108, -0.7986355, -0.8090171, -0.8191521, -0.8290375, -0.8386706, -0.848048, -0.8571673, -0.8660254, -0.8746198, -0.8829476, -0.8910065, -0.8987941, -0.9063078, -0.9135455, -0.9205049, -0.9271838, -0.9335805, -0.9396926, -0.9455186, -0.9510565, -0.9563047, -0.9612617, -0.9659258, -0.9702957, -0.9743701, -0.9781476, -0.9816272, -0.9848077, -0.9876884, -0.9902681, -0.9925461, -0.9945219, -0.9961947, -0.9975641, -0.9986295, -0.9993908, -0.9998477, -1.0, -0.9998477, -0.9993908, -0.9986295, -0.9975641, -0.9961947, -0.9945219, -0.9925461, -0.9902681, -0.9876884, -0.9848077, -0.9816272, -0.9781476, -0.9743701, -0.9702957, -0.9659258, -0.9612617, -0.9563047, -0.9510565, -0.9455186, -0.9396926, -0.9335805, -0.9271838, -0.9205049, -0.9135455, -0.9063078, -0.8987941, -0.8910065, -0.8829476, -0.8746197, -0.8660254, -0.8571674, -0.8480481, -0.8386706, -0.8290375, -0.8191521, -0.8090171, -0.7986355, -0.7880108, -0.7771459, -0.7660445, -0.7547095, -0.7431448, -0.7313538, -0.7193398, -0.7071068, -0.6946583, -0.6819984, -0.6691307, -0.656059, -0.6427875, -0.6293203, -0.6156615, -0.6018152, -0.5877854, -0.5735763, -0.5591929, -0.5446391, -0.5299194, -0.5150383, -0.4999999, -0.4848096, -0.4694716, -0.4539907, -0.438371, -0.4226182, -0.4067366, -0.3907312, -0.3746068, -0.3583678, -0.3420201, -0.3255682, -0.3090171, -0.2923719, -0.2756372, -0.258819, -0.2419219, -0.2249512, -0.2079119, -0.1908088, -0.1736481, -0.1564345, -0.1391733, -0.1218696, -0.1045283, -0.08715571, -0.06975655, -0.05233612, -0.03489976, -0.0174523, 1.192488e-08, 0.01745232, 0.03489931, 0.05233615, 0.06975657, 0.08715574, 0.1045284, 0.1218691, 0.1391733, 0.1564345, 0.1736481, 0.1908089, 0.2079115, 0.2249512, 0.2419219, 0.258819, 0.2756372, 0.2923715, 0.3090171, 0.3255682, 0.3420201, 0.3583678, 0.3746064, 0.3907312, 0.4067367, 0.4226182, 0.438371, 0.4539903, 0.4694717, 0.4848096, 0.4999999, 0.5150379, 0.5299194, 0.5446391, 0.5591929, 0.5735763, 0.5877851, 0.6018152, 0.6156615, 0.6293204, 0.6427875, 0.6560588, 0.6691307, 0.6819984, 0.6946583, 0.7071066, 0.7193396, 0.7313538, 0.7431449, 0.7547095, 0.7660443, 0.7771458, 0.7880108, 0.7986355, 0.8090169, 0.8191519, 0.8290374, 0.8386706, 0.8480481, 0.8571672, 0.8660253, 0.8746198, 0.8829476, 0.8910065, 0.898794, 0.9063077, 0.9135455, 0.9205049, 0.9271839, 0.9335804, 0.9396926, 0.9455186, 0.9510565, 0.9563047, 0.9612616, 0.9659258, 0.9702958, 0.9743701, 0.9781476, 0.9816272, 0.9848077, 0.9876884, 0.9902681, 0.9925461, 0.9945219, 0.9961947, 0.9975641, 0.9986295, 0.9993908, 0.9998477, 1.0}

class('boat').extends(gfx.sprite)
function boat:init(x, y)
    boat.super.init(self)
    self.boat_size = 400
    self.poly_body = pd.geometry.polygon.new(0,-38, 11,-29, 17,-19, 20,-6, 18,20, 15,30, 12,33, -12,33, -15,30, -18,20, -20,6, -20,-6, -17,-19, -11,-29, 0,-38)
    self.poly_inside = pd.geometry.polygon.new(12,-20, 0,-23, -12,-20, -16,-7, 16,-7, 16,5, -16,5, -14,20, 14,20, 16,5, 16,-7, 12,-20)
    self.poly_rowbot = pd.geometry.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11, 6,-8, 6,6, 20,6, 20,-8, 6,-8, 3,-11)
    self.poly_rowbot_fill = pd.geometry.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11)
    self.transform = pd.geometry.affineTransform.new()
    self.transform_shadow = pd.geometry.affineTransform.new()
    self.scale = 1
    self.scale_x = gfx.animator.new(0, self.scale, self.scale)
    self.scale_y = gfx.animator.new(0, self.scale, self.scale)
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
    self.rotation = 0
    self.crankage = 0
    self.camera_x = gfx.animator.new(1500, 0, 20, pd.easingFunctions.inOutSine)
    self.camera_y = gfx.animator.new(1500, 0, 20, pd.easingFunctions.inOutSine)
    self:moveTo(x, y)
    self:setSize(self.boat_size, self.boat_size)
    self:add()
end

function boat:finish()
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
        self.scale_x = gfx.animator.new(650, self.scale * 1, self.scale * 2, pd.easingFunctions.outCubic)
        self.scale_y = gfx.animator.new(650, self.scale * 1, self.scale * 2, pd.easingFunctions.outCubic)
        self.scale_x.reverses = true
        self.scale_y.reverses = true
        self.boat_size = 200
        self:setSize(self.boat_size, self.boat_size)
        pd.timer.performAfterDelay(1300, function()
            self.leaping = false
            self.turning = true
            self.scale_x = gfx.animator.new(500, self.scale * 0.8, self.scale * 1, pd.easingFunctions.outBack)
            self.scale_y = gfx.animator.new(500, self.scale * 0.8, self.scale * 1, pd.easingFunctions.outBack)
            self.boat_size = 100
            self:setSize(self.boat_size, self.boat_size)
        end)
    end
end

function boat:update()
    self.transform:reset()
    self.transform_shadow:reset()
    if self.turning then
        if pd.getCrankChange() >= 0 then
            save.total_degrees_cranked += pd.getCrankChange()
            self.crankage += ((pd.getCrankChange() / 2) - self.crankage) * self.lerp
        else
            self.crankage += ((0 / 2) - self.crankage) * self.lerp
        end
        self.rotation += self.crankage
        self.rotation -= self.turningspeed
        self.rotation = math.floor(self.rotation) % 360 + 1
        self.radtation = math.rad(self.rotation)
    end
    if self.moving then
        camx, camy = gfx.getDrawOffset()
        gfx.setDrawOffset(camx + -sin[self.rotation] * self.currentspeed:currentValue(), camy + cos[self.rotation] * self.currentspeed:currentValue())
        camx, camy = gfx.getDrawOffset()
        self:moveTo(-camx + 200 - (sin[self.rotation] * self.camera_x:currentValue()), -camy + 120 + (cos[self.rotation] * self.camera_y:currentValue()))
    end
    self.transform:scale(self.scale_x:currentValue() * self.boost_scale_x:currentValue(), self.scale_y:currentValue() * self.boost_scale_y:currentValue())
    self.transform:rotate(self.rotation)
    self.transform_shadow:scale(self.scale * self.boost_scale_x:currentValue(), self.scale * self.boost_scale_y:currentValue())
    self.transform_shadow:rotate(self.rotation)
end

function boat:draw(x, y, width, height)
    gfx.setLineWidth(2)
    self.transform:translate(self.boat_size / 2, self.boat_size / 2)
    self.transform_shadow:translate(5 * (self.scale_x:currentValue()*1.25) + self.boat_size / 2, 5 * (self.scale_y:currentValue()*1.25) + self.boat_size / 2)
    gfx.fillPolygon(self.transform_shadow:transformedPolygon(self.poly_body))
    gfx.setColor(gfx.kColorWhite)
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
    gfx.setColor(gfx.kColorBlack)
    gfx.drawPolygon(self.transform:transformedPolygon(self.poly_body))
    gfx.setDitherPattern(0.75, gfx.image.kDitherTypeBayer2x2)
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
    gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_inside))
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(cos[self.rotation] * (-12 * self.scale_x:currentValue()) + self.boat_size / 2, sin[self.rotation] * (-12 * self.scale_x:currentValue()) + self.boat_size / 2, 11 * self.scale_x:currentValue())
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_rowbot_fill))
    gfx.setColor(gfx.kColorBlack)
    gfx.drawPolygon(self.transform:transformedPolygon(self.poly_rowbot))
    gfx.drawCircleAtPoint(cos[self.rotation] * (-12 * self.scale_x:currentValue()) + self.boat_size / 2, sin[self.rotation] * (-12 * self.scale_x:currentValue()) + self.boat_size / 2, 11 * self.scale_x:currentValue())
    gfx.drawCircleAtPoint(cos[self.rotation] * (-12 * self.scale_x:currentValue()) + self.boat_size / 2, sin[self.rotation] * (-12 * self.scale_x:currentValue()) + self.boat_size / 2, 8 * self.scale_x:currentValue())
    gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
    gfx.fillCircleAtPoint(cos[self.rotation] * (-5 * self.scale_x:currentValue()) + self.boat_size / 2, sin[self.rotation] * (-5 * self.scale_x:currentValue()) + self.boat_size / 2, 6 * self.scale_x:currentValue())
    gfx.fillCircleAtPoint(cos[self.rotation] * (-19 * self.scale_x:currentValue()) + self.boat_size / 2, sin[self.rotation] * (-19 * self.scale_x:currentValue()) + self.boat_size / 2, 6 * self.scale_x:currentValue())
    gfx.fillCircleAtPoint(cos[self.rotation] * (13 * self.scale_x:currentValue()) + self.boat_size / 2, sin[self.rotation] * (13 * self.scale_x:currentValue()) + self.boat_size / 2, 3 * self.scale_x:currentValue())
end