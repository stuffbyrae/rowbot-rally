-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local geo <const> = pd.geometry
local lerp <const> = pd.math.lerp

-- Baking sin and cos calculations for performance
local sin = {0.01745241,0.0348995,0.05233596,0.06975647,0.08715574,0.1045285,0.1218693,0.1391731,0.1564345,0.1736482,0.190809,0.2079117,0.224951,0.2419219,0.258819,0.2756374,0.2923717,0.309017,0.3255681,0.3420201,0.3583679,0.3746066,0.3907311,0.4067366,0.4226183,0.4383712,0.4539905,0.4694716,0.4848096,0.5,0.5150381,0.5299193,0.5446391,0.5591929,0.5735765,0.5877852,0.601815,0.6156615,0.6293204,0.6427876,0.656059,0.6691306,0.6819984,0.6946584,0.7071068,0.7193398,0.7313537,0.7431449,0.7547095,0.7660444,0.7771459,0.7880107,0.7986355,0.809017,0.8191521,0.8290375,0.8386706,0.8480481,0.8571673,0.8660254,0.8746197,0.8829476,0.8910065,0.8987941,0.9063078,0.9135455,0.9205048,0.9271839,0.9335804,0.9396926,0.9455186,0.9510565,0.9563047,0.9612617,0.9659258,0.9702957,0.9743701,0.9781476,0.9816272,0.9848077,0.9876884,0.9902681,0.9925461,0.9945219,0.9961947,0.9975641,0.9986295,0.9993908,0.9998477,1.0,0.9998477,0.9993908,0.9986295,0.9975641,0.9961947,0.9945219,0.9925461,0.9902681,0.9876884,0.9848077,0.9816272,0.9781476,0.9743701,0.9702957,0.9659258,0.9612617,0.9563047,0.9510565,0.9455186,0.9396926,0.9335805,0.9271839,0.9205049,0.9135455,0.9063078,0.8987941,0.8910066,0.8829476,0.8746197,0.8660254,0.8571673,0.848048,0.8386706,0.8290376,0.819152,0.809017,0.7986355,0.7880108,0.777146,0.7660444,0.7547096,0.7431448,0.7313537,0.7193399,0.7071068,0.6946585,0.6819983,0.6691306,0.656059,0.6427876,0.6293205,0.6156614,0.6018151,0.5877852,0.5735765,0.559193,0.5446391,0.5299193,0.515038,0.5000001,0.4848095,0.4694716,0.4539906,0.4383711,0.4226183,0.4067366,0.3907312,0.3746067,0.3583679,0.3420202,0.3255681,0.309017,0.2923718,0.2756374,0.2588191,0.2419219,0.2249511,0.2079116,0.190809,0.1736483,0.1564344,0.1391732,0.1218693,0.1045285,0.08715588,0.06975647,0.05233605,0.03489945,0.01745246,-8.742278e-08,-0.01745239,-0.03489939,-0.05233599,-0.0697564,-0.08715581,-0.1045284,-0.1218692,-0.1391731,-0.1564344,-0.1736482,-0.190809,-0.2079118,-0.224951,-0.2419218,-0.2588191,-0.2756373,-0.2923718,-0.309017,-0.3255681,-0.3420202,-0.3583679,-0.3746066,-0.3907311,-0.4067365,-0.4226183,-0.4383711,-0.4539905,-0.4694715,-0.4848097,-0.5,-0.515038,-0.5299193,-0.544639,-0.559193,-0.5735764,-0.5877851,-0.601815,-0.6156614,-0.6293204,-0.6427876,-0.6560591,-0.6691306,-0.6819983,-0.6946584,-0.7071067,-0.7193398,-0.7313537,-0.7431448,-0.7547096,-0.7660446,-0.777146,-0.7880107,-0.7986354,-0.8090168,-0.8191521,-0.8290376,-0.8386706,-0.848048,-0.8571672,-0.8660254,-0.8746197,-0.8829476,-0.8910065,-0.8987941,-0.9063078,-0.9135454,-0.9205048,-0.9271838,-0.9335805,-0.9396927,-0.9455186,-0.9510565,-0.9563047,-0.9612617,-0.9659259,-0.9702957,-0.9743701,-0.9781476,-0.9816272,-0.9848078,-0.9876883,-0.9902681,-0.9925461,-0.9945219,-0.9961947,-0.997564,-0.9986295,-0.9993908,-0.9998477,-1.0,-0.9998477,-0.9993908,-0.9986295,-0.997564,-0.9961947,-0.9945219,-0.9925462,-0.9902681,-0.9876883,-0.9848077,-0.9816272,-0.9781476,-0.97437,-0.9702957,-0.9659258,-0.9612617,-0.9563048,-0.9510565,-0.9455186,-0.9396926,-0.9335805,-0.9271839,-0.9205048,-0.9135454,-0.9063078,-0.8987941,-0.8910066,-0.8829476,-0.8746197,-0.8660254,-0.8571674,-0.848048,-0.8386705,-0.8290376,-0.8191521,-0.8090171,-0.7986354,-0.7880107,-0.777146,-0.7660445,-0.7547097,-0.7431448,-0.7313536,-0.7193398,-0.7071069,-0.6946585,-0.6819983,-0.6691306,-0.6560591,-0.6427878,-0.6293206,-0.6156614,-0.601815,-0.5877853,-0.5735766,-0.5591931,-0.5446389,-0.5299193,-0.5150381,-0.5000002,-0.4848095,-0.4694715,-0.4539905,-0.4383712,-0.4226184,-0.4067365,-0.3907311,-0.3746066,-0.3583681,-0.3420204,-0.325568,-0.3090169,-0.2923717,-0.2756375,-0.2588193,-0.2419218,-0.224951,-0.2079118,-0.1908092,-0.1736484,-0.1564344,-0.1391731,-0.1218694,-0.1045287,-0.08715603,-0.06975638,-0.05233596,-0.0348996,-0.01745261,1.748456e-07}
local cos = {0.9998477, 0.9993908, 0.9986295, 0.9975641, 0.9961947, 0.9945219, 0.9925461, 0.9902681, 0.9876884, 0.9848077, 0.9816272, 0.9781476, 0.9743701, 0.9702957, 0.9659258, 0.9612617, 0.9563048, 0.9510565, 0.9455186, 0.9396926, 0.9335804, 0.9271839, 0.9205049, 0.9135454, 0.9063078, 0.8987941, 0.8910065, 0.8829476, 0.8746197, 0.8660254, 0.8571673, 0.8480481, 0.8386706, 0.8290376, 0.8191521, 0.809017, 0.7986355, 0.7880108, 0.7771459, 0.7660444, 0.7547096, 0.7431448, 0.7313537, 0.7193398, 0.7071068, 0.6946584, 0.6819984, 0.6691306, 0.656059, 0.6427876, 0.6293204, 0.6156615, 0.601815, 0.5877853, 0.5735765, 0.5591929, 0.5446391, 0.5299193, 0.5150381, 0.5, 0.4848096, 0.4694716, 0.4539905, 0.4383712, 0.4226182, 0.4067366, 0.3907312, 0.3746066, 0.358368, 0.3420202, 0.3255681, 0.309017, 0.2923718, 0.2756374, 0.2588191, 0.2419219, 0.224951, 0.2079117, 0.1908091, 0.1736482, 0.1564345, 0.1391731, 0.1218693, 0.1045284, 0.0871558, 0.06975651, 0.05233597, 0.0348995, 0.01745238, -4.371139e-08, -0.01745235, -0.03489946, -0.05233594, -0.06975648, -0.08715577, -0.1045285, -0.1218693, -0.1391731, -0.1564344, -0.1736482, -0.190809, -0.2079116, -0.224951, -0.2419219, -0.258819, -0.2756374, -0.2923717, -0.3090169, -0.3255681, -0.3420201, -0.3583679, -0.3746066, -0.3907312, -0.4067366, -0.4226183, -0.4383711, -0.4539904, -0.4694716, -0.4848095, -0.5000001, -0.515038, -0.5299193, -0.5446391, -0.5591928, -0.5735765, -0.5877852, -0.6018151, -0.6156614, -0.6293203, -0.6427876, -0.656059, -0.6691307, -0.6819983, -0.6946583, -0.7071068, -0.7193397, -0.7313538, -0.7431448, -0.7547097, -0.7660444, -0.7771459, -0.7880108, -0.7986355, -0.8090171, -0.8191521, -0.8290375, -0.8386706, -0.848048, -0.8571673, -0.8660254, -0.8746198, -0.8829476, -0.8910065, -0.8987941, -0.9063078, -0.9135455, -0.9205049, -0.9271838, -0.9335805, -0.9396926, -0.9455186, -0.9510565, -0.9563047, -0.9612617, -0.9659258, -0.9702957, -0.9743701, -0.9781476, -0.9816272, -0.9848077, -0.9876884, -0.9902681, -0.9925461, -0.9945219, -0.9961947, -0.9975641, -0.9986295, -0.9993908, -0.9998477, -1.0, -0.9998477, -0.9993908, -0.9986295, -0.9975641, -0.9961947, -0.9945219, -0.9925461, -0.9902681, -0.9876884, -0.9848077, -0.9816272, -0.9781476, -0.9743701, -0.9702957, -0.9659258, -0.9612617, -0.9563047, -0.9510565, -0.9455186, -0.9396926, -0.9335805, -0.9271838, -0.9205049, -0.9135455, -0.9063078, -0.8987941, -0.8910065, -0.8829476, -0.8746197, -0.8660254, -0.8571674, -0.8480481, -0.8386706, -0.8290375, -0.8191521, -0.8090171, -0.7986355, -0.7880108, -0.7771459, -0.7660445, -0.7547095, -0.7431448, -0.7313538, -0.7193398, -0.7071068, -0.6946583, -0.6819984, -0.6691307, -0.656059, -0.6427875, -0.6293203, -0.6156615, -0.6018152, -0.5877854, -0.5735763, -0.5591929, -0.5446391, -0.5299194, -0.5150383, -0.4999999, -0.4848096, -0.4694716, -0.4539907, -0.438371, -0.4226182, -0.4067366, -0.3907312, -0.3746068, -0.3583678, -0.3420201, -0.3255682, -0.3090171, -0.2923719, -0.2756372, -0.258819, -0.2419219, -0.2249512, -0.2079119, -0.1908088, -0.1736481, -0.1564345, -0.1391733, -0.1218696, -0.1045283, -0.08715571, -0.06975655, -0.05233612, -0.03489976, -0.0174523, 1.192488e-08, 0.01745232, 0.03489931, 0.05233615, 0.06975657, 0.08715574, 0.1045284, 0.1218691, 0.1391733, 0.1564345, 0.1736481, 0.1908089, 0.2079115, 0.2249512, 0.2419219, 0.258819, 0.2756372, 0.2923715, 0.3090171, 0.3255682, 0.3420201, 0.3583678, 0.3746064, 0.3907312, 0.4067367, 0.4226182, 0.438371, 0.4539903, 0.4694717, 0.4848096, 0.4999999, 0.5150379, 0.5299194, 0.5446391, 0.5591929, 0.5735763, 0.5877851, 0.6018152, 0.6156615, 0.6293204, 0.6427875, 0.6560588, 0.6691307, 0.6819984, 0.6946583, 0.7071066, 0.7193396, 0.7313538, 0.7431449, 0.7547095, 0.7660443, 0.7771458, 0.7880108, 0.7986355, 0.8090169, 0.8191519, 0.8290374, 0.8386706, 0.8480481, 0.8571672, 0.8660253, 0.8746198, 0.8829476, 0.8910065, 0.898794, 0.9063077, 0.9135455, 0.9205049, 0.9271839, 0.9335804, 0.9396926, 0.9455186, 0.9510565, 0.9563047, 0.9612616, 0.9659258, 0.9702958, 0.9743701, 0.9781476, 0.9816272, 0.9848077, 0.9876884, 0.9902681, 0.9925461, 0.9945219, 0.9961947, 0.9975641, 0.9986295, 0.9993908, 0.9998477, 1.0}

-- Bote!
class('boat').extends(gfx.sprite)
function boat:init(x, y, race)
    boat.super.init(self)

    -- Boat image setup
    self.poly_body = geo.polygon.new(0,-38, 11,-29, 17,-19, 20,-6, 18,20, 15,30, 12,33, -12,33, -15,30, -18,20, -20,6, -20,-6, -17,-19, -11,-29, 0,-38)
    self.poly_inside = geo.polygon.new(12,-20, 0,-23, -12,-20, -16,-7, 16,-7, 16,5, -16,5, -14,20, 14,20, 16,5, 16,-7, 12,-20)
    self.poly_rowbot = geo.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11, 6,-8, 6,6, 20,6, 20,-8, 6,-8, 3,-11)
    self.poly_rowbot_fill = geo.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11)
    self.transform = geo.affineTransform.new()
    self.shadow = geo.affineTransform.new()

    -- Boat sound effects
    self.sfx_rowboton = smp.new('audio/sfx/rowboton')
    self.sfx_row = smp.new('audio/sfx/row')
    self.sfx_crash = smp.new('audio/sfx/crash')
    self.sfx_boost = smp.new('audio/sfx/boost')

    self.sfx_rowboton:setVolume(save.vol_sfx/5)
    self.sfx_row:setVolume(save.vol_sfx/5)
    self.sfx_crash:setVolume(save.vol_sfx/5)
    self.sfx_boost:setVolume(save.vol_sfx/5)
    
    -- Boat properties
    self.scale_factor = 1 -- Default scale of the boat.
    self.lerp = 0.15 -- Rate at which the cranking is interpolated.
    self.speed = 6 -- Forward movement speed of the boat.
    self.turn = 7 -- The RowBot's default turning rate.

    if enabled_cheats_big then
        self.scale_factor = 1.75
        self.speed = 4
        self.turn = 4
    end
    if enabled_cheats_small then
        self.scale_factor = 0.5
        self.speed = 9
        self.turn = 7
    end
    if enabled_cheats_tiny then
        self.scale_factor = 0.1
        self.speed = 12
        self.turn = 10
    end

    -- Boat animations
    self.scale = pd.timer.new(2500, self.scale_factor, self.scale_factor * 1.1) -- Idle scaling anim
    self.scale.reverses = true -- Make the idle reverse after
    self.scale.repeatCount = -1 -- Make the idle loop
    self.boost_x = pd.timer.new(0, 1, 1) -- Boost animation on the X axis
    self.boost_y = pd.timer.new(0, 1, 1) -- Boost animation on the Y axis
    self.move_speedo = pd.timer.new(0, 0, 0)
    self.turn_speedo = pd.timer.new(0, 0, 0) -- Current movement speed
    self.cam_x = pd.timer.new(0, 0, 0) -- Camera X position
    if race then
        self.cam_y = pd.timer.new(2500, -300, 0, pd.easingFunctions.outCubic)
    else
        self.cam_y = pd.timer.new(0, 0, 0) -- Camera Y position
    end

    -- Other setup
    self.movable = false -- Can the boat be propelled forward?
    self.rowbot = false -- Can the RowBot turn?
    self.turnable = false -- Can the player turn?
    self.crashed = false -- Are you crashed?
    self.crashable = true -- Can you crash? (e.g. are you not in the air?)
    self.boosting = false -- Boosting?
    self.leaping = false -- Are you currently soaring into the air?
    self.reversed = false -- Flips the direction of both RowBot and bunny turning.
    self.straight = false -- For button controls. If this is enabled, the boat will move straight.
    self.right = false -- For button controls. If this is enabled, the boat will move right.
    self.dentable = enabled_cheats_dents -- Hidden dent mode for the boat's body.
    self.crash_direction = 360
    self.rotation = 360
    self.crankage = 0
    self.crashes = 0

    if save['slot' .. save.current_story_slot .. '_ngplus'] then
        self.dentable = true
    end

    -- Final sprite stuff
    self:moveTo(x, y)
    self:setnewsize(85)
    self:setZIndex(0)
    self:add()
end

function boat:setnewsize(size)
    self.boat_size = size * self.scale_factor
    self:setSize(self.boat_size, self.boat_size)
    self:setCollideRect(0, 0, self.boat_size, self.boat_size)
end

-- Changes the boat's state. Make sure to call start and finish alongside if you're changing move state!
function boat:state(move, rowbot, turn)
    if self.rowbot and not rowbot then
        self.turn_speedo = pd.timer.new(1000, self.turn_speedo.value, 0, pd.easingFunctions.inOutSine)
    elseif not self.rowbot and rowbot then
        self.sfx_rowboton:play()
        self.turn_speedo = pd.timer.new(1000, self.turn_speedo.value, 1, pd.easingFunctions.inOutSine)
    end
    self.movable = move
    self.rowbot = rowbot
    self.turnable = turn
end

-- Starts boat movement and camera
function boat:start(duration) -- 1000 is default
    duration = duration or 1000
    self.move_speedo = pd.timer.new(duration, self.move_speedo.value, 1, pd.easingFunctions.inOutSine)
    self.cam_x = pd.timer.new(duration * 1.5, self.cam_x.value, 40, pd.easingFunctions.inOutSine)
    self.cam_y = pd.timer.new(duration * 1.5, self.cam_y.value, 40, pd.easingFunctions.inOutSine)
    self.sfx_row:play(0)
end

-- Stops boat movement and camera
function boat:finish(peelout, duration) -- Disable peelout in tutorial!
    duration = duration or 1500
    self.move_speedo = pd.timer.new(duration, 1.5, 0, pd.easingFunctions.inOutSine)
    self.cam_x = pd.timer.new(duration, self.cam_x.value, 0, pd.easingFunctions.inOutSine)
    self.cam_y = pd.timer.new(duration, self.cam_y.value, 0, pd.easingFunctions.inOutSine)
    self.sfx_row:stop()
    if peelout then
        if self.crankage > self.turn * 1.1 then
            self.peelout = pd.timer.new(duration, self.rotation, self.rotation + math.random(30, 75), pd.easingFunctions.outSine)
        else
            self.peelout = pd.timer.new(duration, self.rotation, self.rotation - math.random(30, 75), pd.easingFunctions.outSine)
        end
    end
end

function boat:collision_check(image)
    local points_collided = {}
    for i = 1, self.poly_body:count() do
        local point = self.transform:transformedPolygon(self.poly_body):getPointAt(i)
        point_x, point_y = point:unpack()
        moved_x = point_x + self.x
        moved_y = point_y + self.y
        if image:sample(moved_x, moved_y) ~= gfx.kColorClear then
            self:crash(point_x, point_y)
            if self.dentable then
                angle = math.deg(math.atan2(point_y, point_x))
                new_point = self.poly_body:getPointAt(i)
                new_point_x, new_point_y = new_point:unpack()
                self.poly_body:setPointAt(i, 0 + (new_point_x * 0.9), 0 + (new_point_y * 0.9))
            end
            table.insert(points_collided, i)
        end
        point_x = nil
        point_y = nil
        moved_x = nil
        moved_y = nil
    end
    if #points_collided == self.poly_body:count() then
        self:beached()
    end
    points_collided = nil
end

function boat:crash(x, y)
    if self.crashable then
        if not self.crashed then
            self.crashed = true
            self.sfx_crash:stop()
            self.sfx_crash:setRate(1 + (math.random() - 0.5))
            self.sfx_crash:setVolume(math.clamp(self.move_speedo.value, 0, save.vol_sfx/5))
            self.sfx_crash:play()
            self.crash_time = 500 * math.clamp(self.move_speedo.value, 0.25, 1)
            if self.movable then
                self.crashes += 1
                save.total_crashes += 1
                if story then
                    save['slot' .. save.current_story_slot .. '_crashes'] += 1
                end
                self.move_speedo = pd.timer.new(self.crash_time, 1, 0, pd.easingFunctions.outSine)
                self.turn_speedo = pd.timer.new(self.crash_time, 1, 0.5, pd.easingFunctions.outSine)
                self.move_speedo.reverses = true
                self.turn_speedo.reverses = true
                pd.timer.performAfterDelay(self.crash_time, function()
                    if self.movable then
                        self.crashed = false
                    end
                end)
            end
        end
        angle = math.deg(math.atan2(y, x))
        self.crash_direction = math.floor(angle - 90 + math.random(-20, 20)) % 360 + 1
    end
end

function boat:beached()
    -- TODO: add logic for when the boat gets Beached (all points are colliding with something)
    -- This means that the boat is stuck in quite the predicament, to put it lightly
    -- So use some mario kart fishing logic to grab the boat, place it back at a safe point
    print('beached!')
end

function boat:boost()
    if self.movable and not self.boosting then -- Make sure they're not boosting already
        self.boosting = true
        self.sfx_boost:play()
        -- Throw the camera back
        self.cam_x = pd.timer.new(500, self.cam_x.value, -40, pd.easingFunctions.outBack)
        self.cam_y = pd.timer.new(500, self.cam_y.value, -40, pd.easingFunctions.outBack)
        -- Stretch the boat
        self.boost_x = pd.timer.new(500, 0.8, 1)
        self.boost_y = pd.timer.new(500, 1.2, 1)
        self.speed = self.speed * 2 -- Make the boat go faster (duh)
        self.lerp = 0.1 -- Make it turn a little less quickly, though!
        pd.timer.performAfterDelay(2000, function()
            self.boosting = false
            -- Throw the camera ... back
            if self.movable then
                self.cam_x = pd.timer.new(1500, self.cam_x.value, 40, pd.easingFunctions.inOutSine)
                self.cam_y = pd.timer.new(1500, self.cam_y.value, 40, pd.easingFunctions.inOutSine)
            end
            self.speed = self.speed / 2 -- Set the speed back
            self.lerp = 0.15 -- Set the lerp back
        end)
    end
end

function boat:leap()
    if self.movable and not self.leaping then
        self.leaping = true
        self.crashable = false
        self:state(true, false, false) -- Disable turning. Do we need to do this?
        self:setnewsize(200)
        -- Scale anim — this is like 90% of the work
        self.scale = pd.timer.new(700, self.scale_factor, self.scale_factor * 2, pd.easingFunctions.outCubic)
        self.scale.reverses = true
        pd.timer.performAfterDelay(1400, function()
            self:state(true, true, true) -- Re-enable turning
            -- Bounce-back animation
            self.scale = pd.timer.new(500, self.scale_factor * 0.8, self.scale_factor, pd.easingFunctions.outBack)
            -- Re-set boat size
            self:setnewsize(90)
            self.crashable = true
            -- Set the idle scaling anim back
            pd.timer.performAfterDelay(500, function()
                self.leaping = false
                self.scale = pd.timer.new(2500, self.scale_factor, self.scale_factor * 1.1)
            end)
        end)
    end
end

function boat:update()
    self.transform:reset()
    self.shadow:reset()
    x, y = gfx.getDrawOffset() -- Gimme the draw offset
    gfx.setDrawOffset(-self.x + 200 - sin[self.rotation] * self.cam_x.value, -self.y + 120 + cos[self.rotation] * self.cam_y.value)
    if not self.crashed then
        self:moveBy(sin[self.rotation] * (self.speed * self.move_speedo.value), -cos[self.rotation] * (self.speed * self.move_speedo.value))
    else
        self:moveBy(sin[self.crash_direction] * (self.speed * self.move_speedo.value), -cos[self.crash_direction] * (self.speed * self.move_speedo.value))
    end
    if save.button_controls or pd.isSimulator == 1 then
        if self.right then
            self.crankage += (self.turn * 2 - self.crankage) * self.turn_speedo.value * self.lerp
        elseif self.straight then
            self.crankage += (self.turn * 1.1 - self.crankage) * self.turn_speedo.value * self.lerp
        elseif self.crankage >= 0.01 then
            self.crankage += (0 - self.crankage) * self.lerp -- Decrease with lerp if nothing is going on
        else
            self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
        end
    else
        if pd.getCrankChange() > 0 then
            save.total_degrees_cranked += pd.getCrankChange() -- Save degrees cranked stat
            self.crankage += ((pd.getCrankChange() / 2.5) - self.crankage) * self.turn_speedo.value * self.lerp -- Lerp crankage to itself
        elseif self.crankage >= 0.01 then
            self.crankage += (0 - self.crankage) * self.lerp -- Decrease with lerp if either the player isn't cranking, or the crankage was just turned off.
        else
            self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
        end
    end
    if self.turnable then -- If the player can turn the boat,
        self.rotation += self.crankage -- Add crankage value on there
    end
    if self.rowbot then -- If the RowBot needs to turn the boat,
        self.rotation -= self.turn * self.turn_speedo.value -- Apply RowBot turning. Duh!
    end
    -- If there's a peelout anim, ignore EVERYTHING BEFORE JUST NOW and respect that instead.
    if self.peelout ~= nil then
        self.rotation = self.peelout.value
    end
    -- Make sure rotation winds up as integer 1 through 360
    self.rotation = math.floor(self.rotation) % 360
    if self.rotation == 0 then self.rotation = 360 end
    -- Transform ALL the polygons!!!!1!
    self.transform:scale(self.scale.value * self.boost_x.value, self.scale.value * self.boost_y.value)
    self.shadow:scale(self.scale_factor * self.boost_x.value, self.scale_factor * self.boost_y.value)
    self.transform:rotate(self.rotation)
    self.shadow:rotate(self.rotation)
    self:markDirty()
end

function boat:draw(x, y, width, height)
    self.transform:translate(self.boat_size / 2, self.boat_size / 2)
    self.shadow:translate(7 * self.scale_factor + self.boat_size / 2, 7 * self.scale_factor + self.boat_size / 2)
    gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
    gfx.fillPolygon(self.shadow:transformedPolygon(self.poly_body))
    gfx.setColor(gfx.kColorWhite)
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
    gfx.setColor(gfx.kColorBlack)
    gfx.drawPolygon(self.transform:transformedPolygon(self.poly_body))
    gfx.setDitherPattern(0.75, gfx.image.kDitherTypeBayer2x2)
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
    gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_inside))
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(cos[self.rotation] * (-12 * self.scale.value) + self.boat_size / 2, sin[self.rotation] * (-12 * self.scale.value) + self.boat_size / 2, 11 * self.scale.value)
    gfx.fillPolygon(self.transform:transformedPolygon(self.poly_rowbot_fill))
    gfx.setColor(gfx.kColorBlack)
    gfx.drawPolygon(self.transform:transformedPolygon(self.poly_rowbot))
    gfx.drawCircleAtPoint(cos[self.rotation] * (-12 * self.scale.value) + self.boat_size / 2, sin[self.rotation] * (-12 * self.scale.value) + self.boat_size / 2, 11 * self.scale.value)
    gfx.drawCircleAtPoint(cos[self.rotation] * (-12 * self.scale.value) + self.boat_size / 2, sin[self.rotation] * (-12 * self.scale.value) + self.boat_size / 2, 8 * self.scale.value)
    gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
    gfx.fillCircleAtPoint(cos[self.rotation] * (-5 * self.scale.value) + self.boat_size / 2, sin[self.rotation] * (-5 * self.scale.value) + self.boat_size / 2, 6 * self.scale.value)
    gfx.fillCircleAtPoint(cos[self.rotation] * (-19 * self.scale.value) + self.boat_size / 2, sin[self.rotation] * (-19 * self.scale.value) + self.boat_size / 2, 6 * self.scale.value)
    gfx.fillCircleAtPoint(cos[self.rotation] * (13 * self.scale.value) + self.boat_size / 2, sin[self.rotation] * (13 * self.scale.value) + self.boat_size / 2, 3 * self.scale.value)
    gfx.setColor(gfx.kColorBlack) -- Make sure to set this back afterward, or else your corner UIs will suffer!!
end