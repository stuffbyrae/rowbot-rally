import 'pdParticles'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local geo <const> = pd.geometry
local lerp <const> = pd.math.lerp
local min <const> = math.min
local max <const> = math.max
local floor <const> = math.floor
local random <const> = math.random
local deg <const> = math.deg
local atan <const> = math.atan2
local sqrt <const> = math.sqrt
local abs <const> = math.abs

-- Baking sin and cos calculations for performance
local sin <const> = {0.01745241,0.0348995,0.05233596,0.06975647,0.08715574,0.1045285,0.1218693,0.1391731,0.1564345,0.1736482,0.190809,0.2079117,0.224951,0.2419219,0.258819,0.2756374,0.2923717,0.309017,0.3255681,0.3420201,0.3583679,0.3746066,0.3907311,0.4067366,0.4226183,0.4383712,0.4539905,0.4694716,0.4848096,0.5,0.5150381,0.5299193,0.5446391,0.5591929,0.5735765,0.5877852,0.601815,0.6156615,0.6293204,0.6427876,0.656059,0.6691306,0.6819984,0.6946584,0.7071068,0.7193398,0.7313537,0.7431449,0.7547095,0.7660444,0.7771459,0.7880107,0.7986355,0.809017,0.8191521,0.8290375,0.8386706,0.8480481,0.8571673,0.8660254,0.8746197,0.8829476,0.8910065,0.8987941,0.9063078,0.9135455,0.9205048,0.9271839,0.9335804,0.9396926,0.9455186,0.9510565,0.9563047,0.9612617,0.9659258,0.9702957,0.9743701,0.9781476,0.9816272,0.9848077,0.9876884,0.9902681,0.9925461,0.9945219,0.9961947,0.9975641,0.9986295,0.9993908,0.9998477,1.0,0.9998477,0.9993908,0.9986295,0.9975641,0.9961947,0.9945219,0.9925461,0.9902681,0.9876884,0.9848077,0.9816272,0.9781476,0.9743701,0.9702957,0.9659258,0.9612617,0.9563047,0.9510565,0.9455186,0.9396926,0.9335805,0.9271839,0.9205049,0.9135455,0.9063078,0.8987941,0.8910066,0.8829476,0.8746197,0.8660254,0.8571673,0.848048,0.8386706,0.8290376,0.819152,0.809017,0.7986355,0.7880108,0.777146,0.7660444,0.7547096,0.7431448,0.7313537,0.7193399,0.7071068,0.6946585,0.6819983,0.6691306,0.656059,0.6427876,0.6293205,0.6156614,0.6018151,0.5877852,0.5735765,0.559193,0.5446391,0.5299193,0.515038,0.5000001,0.4848095,0.4694716,0.4539906,0.4383711,0.4226183,0.4067366,0.3907312,0.3746067,0.3583679,0.3420202,0.3255681,0.309017,0.2923718,0.2756374,0.2588191,0.2419219,0.2249511,0.2079116,0.190809,0.1736483,0.1564344,0.1391732,0.1218693,0.1045285,0.08715588,0.06975647,0.05233605,0.03489945,0.01745246,-8.742278e-08,-0.01745239,-0.03489939,-0.05233599,-0.0697564,-0.08715581,-0.1045284,-0.1218692,-0.1391731,-0.1564344,-0.1736482,-0.190809,-0.2079118,-0.224951,-0.2419218,-0.2588191,-0.2756373,-0.2923718,-0.309017,-0.3255681,-0.3420202,-0.3583679,-0.3746066,-0.3907311,-0.4067365,-0.4226183,-0.4383711,-0.4539905,-0.4694715,-0.4848097,-0.5,-0.515038,-0.5299193,-0.544639,-0.559193,-0.5735764,-0.5877851,-0.601815,-0.6156614,-0.6293204,-0.6427876,-0.6560591,-0.6691306,-0.6819983,-0.6946584,-0.7071067,-0.7193398,-0.7313537,-0.7431448,-0.7547096,-0.7660446,-0.777146,-0.7880107,-0.7986354,-0.8090168,-0.8191521,-0.8290376,-0.8386706,-0.848048,-0.8571672,-0.8660254,-0.8746197,-0.8829476,-0.8910065,-0.8987941,-0.9063078,-0.9135454,-0.9205048,-0.9271838,-0.9335805,-0.9396927,-0.9455186,-0.9510565,-0.9563047,-0.9612617,-0.9659259,-0.9702957,-0.9743701,-0.9781476,-0.9816272,-0.9848078,-0.9876883,-0.9902681,-0.9925461,-0.9945219,-0.9961947,-0.997564,-0.9986295,-0.9993908,-0.9998477,-1.0,-0.9998477,-0.9993908,-0.9986295,-0.997564,-0.9961947,-0.9945219,-0.9925462,-0.9902681,-0.9876883,-0.9848077,-0.9816272,-0.9781476,-0.97437,-0.9702957,-0.9659258,-0.9612617,-0.9563048,-0.9510565,-0.9455186,-0.9396926,-0.9335805,-0.9271839,-0.9205048,-0.9135454,-0.9063078,-0.8987941,-0.8910066,-0.8829476,-0.8746197,-0.8660254,-0.8571674,-0.848048,-0.8386705,-0.8290376,-0.8191521,-0.8090171,-0.7986354,-0.7880107,-0.777146,-0.7660445,-0.7547097,-0.7431448,-0.7313536,-0.7193398,-0.7071069,-0.6946585,-0.6819983,-0.6691306,-0.6560591,-0.6427878,-0.6293206,-0.6156614,-0.601815,-0.5877853,-0.5735766,-0.5591931,-0.5446389,-0.5299193,-0.5150381,-0.5000002,-0.4848095,-0.4694715,-0.4539905,-0.4383712,-0.4226184,-0.4067365,-0.3907311,-0.3746066,-0.3583681,-0.3420204,-0.325568,-0.3090169,-0.2923717,-0.2756375,-0.2588193,-0.2419218,-0.224951,-0.2079118,-0.1908092,-0.1736484,-0.1564344,-0.1391731,-0.1218694,-0.1045287,-0.08715603,-0.06975638,-0.05233596,-0.0348996,-0.01745261,1.748456e-07}
local cos <const> = {0.9998477, 0.9993908, 0.9986295, 0.9975641, 0.9961947, 0.9945219, 0.9925461, 0.9902681, 0.9876884, 0.9848077, 0.9816272, 0.9781476, 0.9743701, 0.9702957, 0.9659258, 0.9612617, 0.9563048, 0.9510565, 0.9455186, 0.9396926, 0.9335804, 0.9271839, 0.9205049, 0.9135454, 0.9063078, 0.8987941, 0.8910065, 0.8829476, 0.8746197, 0.8660254, 0.8571673, 0.8480481, 0.8386706, 0.8290376, 0.8191521, 0.809017, 0.7986355, 0.7880108, 0.7771459, 0.7660444, 0.7547096, 0.7431448, 0.7313537, 0.7193398, 0.7071068, 0.6946584, 0.6819984, 0.6691306, 0.656059, 0.6427876, 0.6293204, 0.6156615, 0.601815, 0.5877853, 0.5735765, 0.5591929, 0.5446391, 0.5299193, 0.5150381, 0.5, 0.4848096, 0.4694716, 0.4539905, 0.4383712, 0.4226182, 0.4067366, 0.3907312, 0.3746066, 0.358368, 0.3420202, 0.3255681, 0.309017, 0.2923718, 0.2756374, 0.2588191, 0.2419219, 0.224951, 0.2079117, 0.1908091, 0.1736482, 0.1564345, 0.1391731, 0.1218693, 0.1045284, 0.0871558, 0.06975651, 0.05233597, 0.0348995, 0.01745238, -4.371139e-08, -0.01745235, -0.03489946, -0.05233594, -0.06975648, -0.08715577, -0.1045285, -0.1218693, -0.1391731, -0.1564344, -0.1736482, -0.190809, -0.2079116, -0.224951, -0.2419219, -0.258819, -0.2756374, -0.2923717, -0.3090169, -0.3255681, -0.3420201, -0.3583679, -0.3746066, -0.3907312, -0.4067366, -0.4226183, -0.4383711, -0.4539904, -0.4694716, -0.4848095, -0.5000001, -0.515038, -0.5299193, -0.5446391, -0.5591928, -0.5735765, -0.5877852, -0.6018151, -0.6156614, -0.6293203, -0.6427876, -0.656059, -0.6691307, -0.6819983, -0.6946583, -0.7071068, -0.7193397, -0.7313538, -0.7431448, -0.7547097, -0.7660444, -0.7771459, -0.7880108, -0.7986355, -0.8090171, -0.8191521, -0.8290375, -0.8386706, -0.848048, -0.8571673, -0.8660254, -0.8746198, -0.8829476, -0.8910065, -0.8987941, -0.9063078, -0.9135455, -0.9205049, -0.9271838, -0.9335805, -0.9396926, -0.9455186, -0.9510565, -0.9563047, -0.9612617, -0.9659258, -0.9702957, -0.9743701, -0.9781476, -0.9816272, -0.9848077, -0.9876884, -0.9902681, -0.9925461, -0.9945219, -0.9961947, -0.9975641, -0.9986295, -0.9993908, -0.9998477, -1.0, -0.9998477, -0.9993908, -0.9986295, -0.9975641, -0.9961947, -0.9945219, -0.9925461, -0.9902681, -0.9876884, -0.9848077, -0.9816272, -0.9781476, -0.9743701, -0.9702957, -0.9659258, -0.9612617, -0.9563047, -0.9510565, -0.9455186, -0.9396926, -0.9335805, -0.9271838, -0.9205049, -0.9135455, -0.9063078, -0.8987941, -0.8910065, -0.8829476, -0.8746197, -0.8660254, -0.8571674, -0.8480481, -0.8386706, -0.8290375, -0.8191521, -0.8090171, -0.7986355, -0.7880108, -0.7771459, -0.7660445, -0.7547095, -0.7431448, -0.7313538, -0.7193398, -0.7071068, -0.6946583, -0.6819984, -0.6691307, -0.656059, -0.6427875, -0.6293203, -0.6156615, -0.6018152, -0.5877854, -0.5735763, -0.5591929, -0.5446391, -0.5299194, -0.5150383, -0.4999999, -0.4848096, -0.4694716, -0.4539907, -0.438371, -0.4226182, -0.4067366, -0.3907312, -0.3746068, -0.3583678, -0.3420201, -0.3255682, -0.3090171, -0.2923719, -0.2756372, -0.258819, -0.2419219, -0.2249512, -0.2079119, -0.1908088, -0.1736481, -0.1564345, -0.1391733, -0.1218696, -0.1045283, -0.08715571, -0.06975655, -0.05233612, -0.03489976, -0.0174523, 1.192488e-08, 0.01745232, 0.03489931, 0.05233615, 0.06975657, 0.08715574, 0.1045284, 0.1218691, 0.1391733, 0.1564345, 0.1736481, 0.1908089, 0.2079115, 0.2249512, 0.2419219, 0.258819, 0.2756372, 0.2923715, 0.3090171, 0.3255682, 0.3420201, 0.3583678, 0.3746064, 0.3907312, 0.4067367, 0.4226182, 0.438371, 0.4539903, 0.4694717, 0.4848096, 0.4999999, 0.5150379, 0.5299194, 0.5446391, 0.5591929, 0.5735763, 0.5877851, 0.6018152, 0.6156615, 0.6293204, 0.6427875, 0.6560588, 0.6691307, 0.6819984, 0.6946583, 0.7071066, 0.7193396, 0.7313538, 0.7431449, 0.7547095, 0.7660443, 0.7771458, 0.7880108, 0.7986355, 0.8090169, 0.8191519, 0.8290374, 0.8386706, 0.8480481, 0.8571672, 0.8660253, 0.8746198, 0.8829476, 0.8910065, 0.898794, 0.9063077, 0.9135455, 0.9205049, 0.9271839, 0.9335804, 0.9396926, 0.9455186, 0.9510565, 0.9563047, 0.9612616, 0.9659258, 0.9702958, 0.9743701, 0.9781476, 0.9816272, 0.9848077, 0.9876884, 0.9902681, 0.9925461, 0.9945219, 0.9961947, 0.9975641, 0.9986295, 0.9993908, 0.9998477, 1.0}

class('wake').extends(gfx.sprite)
function wake:init(boat)
    wake.super.init(self)
    self.boat = boat

    Particles:setPrecision(0.1)

    self.wake = ParticleCircle(self.boat.start_x, self.boat.start_y)
    self.wake:setSize(120 * self.boat.scale_factor, 160 * self.boat.scale_factor)
    self.wake:setMode(Particles.modes.DECAY)
    self.wake:setDecay(0.3)
    self.wake:setSpeed(10 * self.boat.scale_factor)
    self.wake:setColor(gfx.kColorWhite)
    
    self:setSize(400 * self.boat.scale_factor, 240 * self.boat.scale_factor)
    self:setZIndex(-1)
    self:add()
end

function wake:update()
    self:moveTo(self.boat.x, self.boat.y)
    self.wake:moveTo((self.boat.x - (sin[self.boat.rotation] * 20)) + (200 * self.boat.scale_factor), (self.boat.y + (cos[self.boat.rotation] * 20)) + (120 * self.boat.scale_factor))
    self.wake:setSpread(self.boat.rotation + 170, self.boat.rotation + 190)
    if self.boat.movable and not self.boat.leaping then
        self.wake:add(1)
    end
end

function wake:draw()
    local cam_x, cam_y = gfx.getDrawOffset()
    gfx.setDrawOffset(cam_x - self.boat.x, cam_y - self.boat.y)
    Particles:update()
    gfx.setDrawOffset(cam_x, cam_y)
end

-- Bote!
class('boat').extends(gfx.sprite)
function boat:init(mode, start_x, start_y, stage, stage_x, stage_y, crash_polygons, crash_image, follow_polygon)
    boat.super.init(self)
    self.mode = mode -- "cpu", "race", or "tutorial"
    
    self.poly_body = geo.polygon.new(0,-38, 11,-29, 17,-19, 20,-6, 20,6, 18,20, 15,30, 12,33, -12,33, -15,30, -18,20, -20,6, -20,-6, -17,-19, -11,-29, 0,-38)
    self.poly_inside = geo.polygon.new(12,-20, 0,-23, -12,-20, -16,-7, 16,-7, 16,5, -16,5, -14,20, 14,20, 16,5, 16,-7, 12,-20)
    self.poly_body_crash = geo.polygon.new(0,-38, 17,-19, 20,6, 12,33, -12,33, -20,6, -17,-19, 0,-38)
    
    self.transform = geo.affineTransform.new()
    self.crash_transform = geo.affineTransform.new()
    self.ripple = geo.affineTransform.new()

    self.image_crash = gfx.image.new('images/race/crash')
    self.crash_polygons = crash_polygons
    self.crash_image = crash_image
    
    self.sfx_crash = smp.new('audio/sfx/crash')
    self.sfx_air = smp.new('audio/sfx/air')
    self.sfx_splash = smp.new('audio/sfx/splash')

    self.sfx_crash:setVolume(save.vol_sfx/5)
    self.sfx_air:setVolume(save.vol_sfx/5)
    self.sfx_splash:setVolume(save.vol_sfx/5)
    
    self.scale_factor = 1 -- Default scale of the boat.
    self.speed = 5 -- Forward movement speed of the boat.
    self.turn = 7 -- The RowBot's default turning rate.
    self.random = random()

    if self.mode == "cpu" then
        self.stage = stage

        self.follow_polygon = follow_polygon
        self.lerp = ((self.stage / 2) * 0.09) * (1 + (save['slot' .. save.current_story_slot .. '_circuit'] / 8)) -- Rate at which the rotation towards the angle is interpolated.

        self.follow_points = {}
        self.follow_count = self.follow_polygon:count()
        self.follow_next = 1

        for i = 1, self.follow_count do
            table.insert(self.follow_points, i)
        end
        self.point_x, self.point_y = self.follow_polygon:getPointAt(self.follow_next):unpack()
    else
        self.poly_rowbot = geo.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11, 6,-8, 6,6, 20,6, 20,-8, 6,-8, 3,-11)
        self.poly_rowbot_fill = geo.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11)
        
        self.sfx_rowboton = smp.new('audio/sfx/rowboton')
        self.sfx_row = smp.new('audio/sfx/row')
        self.sfx_boost = smp.new('audio/sfx/boost')
        
        self.sfx_rowboton:setVolume(save.vol_sfx/5)
        self.sfx_row:setVolume(save.vol_sfx/5)
        self.sfx_boost:setVolume(save.vol_sfx/5)

        if enabled_cheats_big then
            self.scale_factor = 1.70
            self.speed = 4
            self.turn = 4
        end
        if enabled_cheats_small then
            self.scale_factor = 0.5
            self.speed = 6
            self.turn = 7
        end
        if enabled_cheats_tiny then
            self.scale_factor = 0.1
            self.speed = 7
            self.turn = 10
        end
        
        self.cam_x = pd.timer.new(0, 0, 0) -- Camera X position
        self.cam_x.discardOnCompletion = false
        if self.mode == "race" then
            self.stage_x = stage_x
            self.stage_y = stage_y
            self.cam_y = pd.timer.new(2500, -300, 0, pd.easingFunctions.outCubic)
        else
            self.cam_y = pd.timer.new(0, 0, 0) -- Camera Y position
        end
        self.cam_y.discardOnCompletion = false

        self.sensitivity = save.sensitivity
        self.lerp = 0.2 -- Rate at which the cranking is interpolated.
        self.rowbot = false -- Can the RowBot turn?
        self.turnable = false -- Can the player turn?
        self.beached = false -- Are you beached? (Crashed from all angles)
        self.boosting = false -- Boosting?
        self.straight = false -- For button controls. If this is enabled, the boat will move straight.
        self.right = false -- For button controls. If this is enabled, the boat will move right.
        self.dentable = enabled_cheats_dents -- Hidden dent mode for the boat's body.
        self.crankage = 0
        self.crashes = 0
    end

    self.scale = pd.timer.new(2000 + (1000 * self.random), self.scale_factor, self.scale_factor * 1.1) -- Idle scaling anim
    self.scale.reverses = true -- Make the idle reverse after
    self.scale.repeats = true -- Make the idle loop
    self.move_speedo = pd.timer.new(0, 0, 0)
    self.move_speedo.discardOnCompletion = false
    self.wobble_speedo = pd.timer.new(0, 0, 0)
    self.wobble_speedo.discardOnCompletion = false
    self.turn_speedo = pd.timer.new(0, 0, 0) -- Current movement speed
    self.turn_speedo.discardOnCompletion = false
    
    self.movable = false -- Can the boat be propelled forward?
    self.crashed = false -- Are you crashed?
    self.crashable = true -- Can you crash? (e.g. are you not in the air?)
    self.leaping = false -- Are you currently soaring into the air?
    self.in_wall = false
    self.rotation = 360
    self.reversed = 1 -- Flips the direction of both RowBot and bunny turning.
    self.collision_size = 80 * self.scale_factor

    self.wake = wake(self)

    self.boost_x = pd.timer.new(0, 1, 1) -- Boost animation on the X axis
    self.boost_y = pd.timer.new(0, 1, 1) -- Boost animation on the Y axis
    self.boost_x.discardOnCompletion = false
    self.boost_y.discardOnCompletion = false

    self.ripple_scale = pd.timer.new(2000 + (1000 * self.random), 0.95, 1.3)
    self.ripple_scale.discardOnCompletion = false
    self.ripple_opacity = pd.timer.new(2000 + (1000 * self.random), 0, 1)
    self.ripple_opacity.discardOnCompletion = false
    self.ripple_scale.timerEndedCallback = function()
        if not self.movable then
            self.ripple_scale:reset()
            self.ripple_opacity:reset()
            self.ripple_scale:start()
            self.ripple_opacity:start()
        end
    end
    
    self:setTag(255)
    self:moveTo(start_x, start_y)
    self:setnewsize(90)
    self:setCollideRect((self.boat_size - self.collision_size) / 2, (self.boat_size - self.collision_size) / 2, self.collision_size, self.collision_size)
    self:setZIndex(0)
    self:add()
end

function boat:setnewsize(size)
    self.boat_size = size * self.scale_factor
    self:setSize(self.boat_size, self.boat_size)
end

-- Changes the boat's state. Make sure to call start and finish alongside if you're changing move state!
-- Please don't call if the boat is CPU. instead, only use the start and finish functions.
function boat:state(move, rowbot, turn)
    if self.rowbot and not rowbot then
        self.turn_speedo:resetnew(1000, self.turn_speedo.value, 0, pd.easingFunctions.inOutSine)
    elseif not self.rowbot and rowbot then
        self.sfx_rowboton:play()
        self.turn_speedo:resetnew(1000, self.turn_speedo.value, 1, pd.easingFunctions.inOutSine)
    end
    self.movable = move
    self.rowbot = rowbot
    self.turnable = turn
end

-- Starts boat movement and camera
function boat:start(duration) -- 1000 is default
    duration = duration or 1000
    self.move_speedo:resetnew(duration, self.move_speedo.value, 1, pd.easingFunctions.inOutSine)
    self.wobble_speedo:resetnew(duration, self.move_speedo.value, 1, pd.easingFunctions.inOutSine)
    if self.mode == "cpu" then
        self.movable = true
    else
        if self.mode == "tutorial" then
            self.cam_x:resetnew(duration * 1.5, self.cam_x.value, 15, pd.easingFunctions.inOutSine)
            self.cam_y:resetnew(duration * 1.5, self.cam_y.value, 15, pd.easingFunctions.inOutSine)
        else
            self.cam_x:resetnew(duration * 1.5, self.cam_x.value, 40, pd.easingFunctions.inOutSine)
            self.cam_y:resetnew(duration * 1.5, self.cam_y.value, 40, pd.easingFunctions.inOutSine)
        end
        self.sfx_row:play(0)
        if not save.button_controls and pd.isSimulator ~= 1 then show_crank = true end
        if enabled_cheats_scream then
            playdate.sound.micinput.startListening()
        end
    end
end

-- Stops boat movement and camera
function boat:finish(duration, peelout)
    duration = duration or 1500
    self.move_speedo:resetnew(duration, self.move_speedo.value, 0, pd.easingFunctions.inOutSine)
    self.wobble_speedo:resetnew(duration, self.wobble_speedo.value, 0, pd.easingFunctions.outBack)
    self.ripple_scale:reset()
    self.ripple_opacity:reset()
    self.ripple_scale:start()
    self.ripple_opacity:start()
    if self.mode == "cpu" then
        self.movable = false
    else
        self.cam_x:resetnew(duration, self.cam_x.value, 0, pd.easingFunctions.inOutSine)
        self.cam_y:resetnew(duration, self.cam_y.value, 0, pd.easingFunctions.inOutSine)
        self.sfx_row:stop()
        show_crank = false
        if peelout then
            if self.crankage > self.turn * 1.1 then
                self.peelout = pd.timer.new(duration, self.rotation, self.rotation + random(30, 75), pd.easingFunctions.outSine)
            else
                self.peelout = pd.timer.new(duration, self.rotation, self.rotation - random(30, 75), pd.easingFunctions.outSine)
            end
        end
        if enabled_cheats_scream then
            playdate.sound.micinput.stopListening()
        end
    end
end

function boat:collision_check(polygons, image, crash_stage_x, crash_stage_y)
    self.in_wall = false
    self.crash_body_scale = self.transform:transformedPolygon(self.poly_body_crash)
    self.crash_body_scale:translate(self.x, self.y)
    for i = 1, #polygons do
        if self.crash_body_scale:intersects(polygons[i]) then
            local points_collided = {}
            self.in_wall = true
            self.crash_body = self.crash_transform:transformedPolygon(self.poly_body)
            for i = 1, self.poly_body:count() do
                local transformed_point = self.crash_body:getPointAt(i)
                local point_x, point_y = transformed_point:unpack()
                local moved_x = ((point_x + self.x) - crash_stage_x)
                local moved_y = ((point_y + self.y) - crash_stage_y)
                if image:sample(moved_x, moved_y) == gfx.kColorBlack then
                    self:crash(point_x, point_y)
                    self.crash_point = i
                    if self.dentable then
                        angle = deg(atan(point_y, point_x))
                        new_point = self.poly_body:getPointAt(i)
                        new_point_x, new_point_y = new_point:unpack()
                        self.poly_body:setPointAt(i, 0 + (new_point_x * 0.9), 0 + (new_point_y * 0.9))
                    end
                    table.insert(points_collided, i)
                end
                if self.mode ~= "cpu" and #points_collided == self.poly_body:count() then
                    self.beached = true
                end
            end
        end
    end
end

function boat:crash(x, y)
    if self.crashable and not self.crashed then
        self.crashed = true
        local angle = deg(atan(y, x))
        self.crash_direction = floor(angle - 90 + random(-20, 20)) % 360 + 1
        angle = nil
        self.crash_time = 500 * (max(0.25, min(1, self.move_speedo.value)))
        if self.movable then
            self.move_speedo:resetnew(self.crash_time, 1, 0, pd.easingFunctions.outSine)
            self.wobble_speedo:resetnew(self.crash_time / 2, self.wobble_speedo.value, -1.5, pd.easingFunctions.outBack)
            self.move_speedo.reverses = true
            self.wobble_speedo.reverses = true
            self.wobble_speedo.reverseEasingFunction = pd.easingFunctions.inSine
            pd.timer.performAfterDelay(self.crash_time, function()
                if self.movable then
                    self.crashed = false
                end
            end)
        end
        if self.mode ~= "cpu" then
            self.show_crash_image = true
            pd.timer.performAfterDelay(200, function()
                self.show_crash_image = false
            end)
            self.sfx_crash:stop()
            self.sfx_crash:setRate(1 + (random() - 0.5))
            self.sfx_crash:setVolume(max(0, min(save.vol_sfx/5, self.move_speedo.value)))
            self.sfx_crash:play()
            if self.movable then
                self.crashes += 1
                save.total_crashes += 1
                if story then
                    save['slot' .. save.current_story_slot .. '_crashes'] += 1
                end
            end
        end
    end
end

function boat:boost()
    if self.movable and not self.boosting then -- Make sure they're not boosting already
        self.boosting = true
        -- Stretch the boat
        self.boost_x:resetnew(500, 0.8, 1)
        self.boost_y:resetnew(500, 1.2, 1)
        self.wobble_speedo:resetnew(500, 1, 4, pd.easingFunctions.outBack)
        self.speed = self.speed * 2 -- Make the boat go faster (duh)
        self.lerp = 0.1 -- Make it turn a little less quickly, though!
        pd.timer.performAfterDelay(2000, function()
            self.boosting = false
            self.speed = self.speed / 2 -- Set the speed back
            self.lerp = 0.15 -- Set the lerp back
        end)
        if self.mode ~= "cpu" then
            self.sfx_boost:play()
            -- Throw the camera back
            self.cam_x:resetnew(500, self.cam_x.value, -40, pd.easingFunctions.outBack)
            self.cam_y:resetnew(500, self.cam_y.value, -40, pd.easingFunctions.outBack)
            pd.timer.performAfterDelay(2000, function()
                self.wobble_speedo:resetnew(2000, 4, 1, pd.easingFunctions.outBack)
                -- Throw the camera ... back
                if self.movable then
                    self.cam_x:resetnew(1500, self.cam_x.value, 40, pd.easingFunctions.inOutSine)
                    self.cam_y:resetnew(1500, self.cam_y.value, 40, pd.easingFunctions.inOutSine)
                end
            end)
        end
    end
end

function boat:leap()
    if self.movable and not self.leaping then
        if self.mode ~= "cpu" then
            self.turn_speedo:resetnew(400, 1, 0, pd.easingFunctions.outSine)
            self.sfx_air:play()
            self.sfx_boost:play()
        end
        self.leaping = true
        self.crashable = false
        self:setnewsize(200)
        -- Scale anim — this is like 90% of the work
        self.scale:resetnew(700, self.scale_factor, self.scale_factor * 2, pd.easingFunctions.outCubic)
        self.scale.reverses = true
        self.scale.reverseEasingFunction = pd.easingFunctions.inCubic
        pd.timer.performAfterDelay(1400, function()
            self.sfx_splash:play()
            -- Bounce-back animation
            self.scale:resetnew(500, self.scale_factor * 0.8, self.scale_factor, pd.easingFunctions.outBack)
            -- Re-set boat size
            self:setnewsize(90)
            self.crashable = true
            -- Set the idle scaling anim back
            pd.timer.performAfterDelay(500, function()
                if self.mode ~= "cpu" and not self.beached then
                    self.turn_speedo:resetnew(600, 0, 1, pd.easingFunctions.outSine)
                    self.scale:resetnew(2000 + (1000 * self.random), self.scale_factor, self.scale_factor * 1.1)
                end
                self.leaping = false
            end)
        end)
    end
end

function boat:cpu_check()
    self.follow_next += 1
    if self.follow_next > self.follow_count then
        self.follow_next = 1
    end
    self.point_x, self.point_y = self.follow_polygon:getPointAt(self.follow_next):unpack()
end

function boat:distance2D(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return sqrt(dx * dx + dy * dy)
end

function boat:update()
    self.transform:reset()
    self.crash_transform:reset()
    self.ripple:reset()
    local x, y = gfx.getDrawOffset() -- Gimme the draw offset
    if not self.crashed then -- Move the boat
        self:moveBy(sin[self.rotation] * (self.speed * self.move_speedo.value), -cos[self.rotation] * (self.speed * self.move_speedo.value))
    else
        self:moveBy(sin[self.crash_direction] * (self.speed * self.move_speedo.value), -cos[self.crash_direction] * (self.speed * self.move_speedo.value))
    end
    if self.mode == "cpu" then -- CPU Controlling
        if self.movable then
            local targetangle = floor(deg(atan(self.point_y - self.y, self.point_x - self.x)) + 90)
            if math.abs(self.rotation - targetangle) > 180 then
                if self.rotation > targetangle then
                    self.rotation -= 360
                else
                    self.rotation += 360
                end
            end
            self.rotation += (targetangle - self.rotation) * self.lerp
            if boat:distance2D(self.x, self.y, self.point_x, self.point_y) <= 50 then
                self:cpu_check()
            end
        end
    else -- Player controlling
        gfx.setDrawOffset(-self.x + 200 - sin[self.rotation] * self.cam_x.value, -self.y + 120 + cos[self.rotation] * self.cam_y.value)
        -- if self.mode == "race" then -- Camera lock if the boat hits the edges of the map
        --     if x >= 0 then x = 0 elseif x - 400 <= -self.stage_x then x = -self.stage_x + 400 end
        --     if y >= 0 then y = 0 elseif y - 240 <= -self.stage_y then y = -self.stage_y + 240 end
        --     gfx.setDrawOffset(x, y)
        -- end
        if self.turnable then
            if enabled_cheats_scream then
                if pd.sound.micinput.getLevel() > 0 then
                    self.crankage += ((playdate.sound.micinput.getLevel() * 30) - self.crankage) * self.turn_speedo.value * self.lerp -- Lerp crankage to itself
                elseif self.crankage >= 0.01 then
                    self.crankage += (0 - self.crankage) * self.lerp -- Decrease with lerp if either the player isn't cranking, or the crankage was just turned off.
                else
                    self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
                end
            elseif save.button_controls or pd.isSimulator == 1 then
                if self.right then
                    if self.turn_speedo.value == 1 then
                        self.crankage += ((self.turn * (self.turn_speedo.value * 2)) - self.crankage) * self.lerp
                        if self.crankage >= (self.turn * (self.turn_speedo.value * 2)) - ((self.turn * (self.turn_speedo.value * 2)) * 0.01) then
                            self.crankage = self.turn * (self.turn_speedo.value * 2)
                        end
                    else
                        self.crankage = self.turn * (self.turn_speedo.value * 2)
                    end
                elseif self.straight then
                    if self.turn_speedo.value == 1 then
                        self.crankage += ((self.turn * self.turn_speedo.value) - self.crankage) * self.lerp
                        if (self.crankage >= (self.turn * (self.turn_speedo.value)) - ((self.turn * (self.turn_speedo.value)) * 0.05)) and (self.crankage <= (self.turn * (self.turn_speedo.value)) + ((self.turn * (self.turn_speedo.value)) * 0.01)) then
                            self.crankage = self.turn * (self.turn_speedo.value)
                        end
                    else
                        self.crankage = self.turn * self.turn_speedo.value
                    end
                elseif self.crankage >= 0.01 then
                    self.crankage += (0 - self.crankage) * self.lerp -- Decrease with lerp if either the player isn't cranking, or the crankage was just turned off.
                else
                    self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
                end
            else
                if pd.getCrankChange() > 0 then
                    save.total_degrees_cranked += pd.getCrankChange() -- Save degrees cranked stat
                    self.crankage += ((pd.getCrankChange() / self.sensitivity) - self.crankage) * self.turn_speedo.value * self.lerp -- Lerp crankage to itself
                elseif self.crankage >= 0.01 then
                    self.crankage += (0 - self.crankage) * self.lerp -- Decrease with lerp if either the player isn't cranking, or the crankage was just turned off.
                else
                    self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
                end
            end
        else
            if self.crankage >= 0.01 then
                self.crankage += (0 - self.crankage) * self.lerp -- Decrease with lerp if nothing is going on
            else
                self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
            end
        end
        if not self.leaping then
            if self.reversed == 1 then
                self.rotation += self.crankage -- Add crankage value on there
                if self.rowbot then -- If the RowBot needs to turn the boat,
                    self.rotation -= self.turn * self.turn_speedo.value -- Apply RowBot turning. Duh!
                end
            elseif self.reversed == -1 then -- If reverse is negative, then flip the boat.
                self.rotation -= self.crankage -- Add crankage value on there
                if self.rowbot then -- If the RowBot needs to turn the boat,
                    self.rotation += self.turn * self.turn_speedo.value -- Apply RowBot turning. Duh!
                end
            end
        end
        self.crankage_divvied = self.crankage / self.turn
        self.total_change = (self.crankage_divvied * self.turn) - (self.turn_speedo.value * self.turn)
    end
    -- If there's a peelout anim, ignore EVERYTHING BEFORE JUST NOW and respect that instead.
    if self.peelout ~= nil then
        self.rotation = self.peelout.value
    end
    -- Make sure rotation winds up as integer 1 through 360
    self.rotation = floor(self.rotation) % 360
    if self.rotation == 0 then self.rotation = 360 end
    -- Transform ALL the polygons!!!!1!
    self.transform:scale((self.scale.value * self.boost_x.value) * self.reversed, self.scale.value * self.boost_y.value)
    self.crash_transform:scale(max(1, min(self.scale.value, self.scale.value)))
    self.transform:rotate(self.rotation)
    self.crash_transform:rotate(self.rotation)
    self:markDirty()
end

function boat:draw(x, y, width, height)
    if self.mode == "cpu" then
        if self.ripple_scale.value ~= self.ripple_scale.endValue then
            self.ripple:scale((self.scale.value * self.boost_x.value) * self.ripple_scale.value, (self.scale.value * self.boost_y.value) * self.ripple_scale.value)
            self.ripple:rotate(self.rotation)
            self.ripple:translate(self.boat_size / 2, self.boat_size / 2)
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(self.ripple_opacity.value, gfx.image.kDitherTypeBayer4x4)
            gfx.setLineWidth(self.ripple_opacity.value * 4)
            gfx.drawPolygon(self.ripple:transformedPolygon(self.poly_body))
            gfx.setLineWidth(2)
            gfx.setColor(gfx.kColorBlack)
        end
        self.transform:translate(self.boat_size / 2, self.boat_size / 2)
        self.transform:translate(7 * self.scale_factor, 7 * self.scale_factor)
        gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
        self.transform:translate(-7 * self.scale_factor, -7 * self.scale_factor)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(self.transform:transformedPolygon(self.poly_body))
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_inside))
        gfx.setColor(gfx.kColorBlack)
        if self.stage == 1 then
            local r01_head_x = self.boat_size / 2
            local r01_head_y = self.boat_size / 2
            local r01_arm_1_x = -20 * -cos[self.rotation] + (self.boat_size / 2)
            local r01_arm_1_y = -20 * -sin[self.rotation] + (self.boat_size / 2)
            local r01_arm_2_x = 20 * -cos[self.rotation] + (self.boat_size / 2)
            local r01_arm_2_y = 20 * -sin[self.rotation] + (self.boat_size / 2)
            gfx.setLineWidth(10)
            gfx.drawLine(r01_arm_1_x, r01_arm_1_y, r01_arm_2_x, r01_arm_2_y)
            gfx.setLineWidth(2)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillCircleAtPoint(r01_head_x, r01_head_y, 15)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawCircleAtPoint(r01_head_x, r01_head_y, 15)
            gfx.drawCircleAtPoint(r01_head_x, r01_head_y, 10)
        end

    else

        if self.ripple_scale.value ~= self.ripple_scale.endValue and not self.beached then
            self.ripple:scale((self.scale.value * self.boost_x.value) * self.ripple_scale.value, (self.scale.value * self.boost_y.value) * self.ripple_scale.value)
            self.ripple:rotate(self.rotation)
            self.ripple:translate(self.boat_size / 2, self.boat_size / 2)
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(self.ripple_opacity.value, gfx.image.kDitherTypeBayer4x4)
            gfx.setLineWidth(self.ripple_opacity.value * 4)
            gfx.drawPolygon(self.ripple:transformedPolygon(self.poly_body))
            gfx.setLineWidth(2)
            gfx.setColor(gfx.kColorBlack)
        end
        self.transform:translate(self.boat_size / 2, self.boat_size / 2)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
        self.transform:translate(cos[self.rotation] * (self.total_change * (self.scale_factor * 0.75)), sin[self.rotation] * (self.total_change * (self.scale_factor * 0.75)))
        if self.show_crash_image and not enabled_cheats then
            local crash_x, crash_y = self.transform:transformedPolygon(self.poly_body):getPointAt(self.crash_point):unpack()
            self.image_crash:draw(crash_x - 20, crash_y - 20)
        end
        self.transform:translate(7 * self.scale_factor, 7 * self.scale_factor)
        gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
        self.transform:translate(-7 * self.scale_factor, -7 * self.scale_factor)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_body))
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(self.transform:transformedPolygon(self.poly_body))
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_inside))
        gfx.setColor(gfx.kColorBlack)
        -- Offset params for passengers
        local bunny_body_x = (((8 * self.reversed) * self.scale.value) * -cos[self.rotation] - (-10 + (self.cam_y.value * 0.05)) * sin[self.rotation]) + (self.boat_size / 2)
        local bunny_body_y = (((8 * self.reversed) * self.scale.value) * -sin[self.rotation] + (-10 + (self.cam_y.value * 0.05)) * cos[self.rotation]) + (self.boat_size / 2)
        local bunny_tuft_x = ((((11 * self.reversed) + (self.total_change * (self.scale_factor * 0.1))) * self.scale.value) * -cos[self.rotation] - (10 + (self.cam_y.value * 0.05)) * sin[self.rotation]) + (self.boat_size / 2)
        local bunny_tuft_y = ((((11 * self.reversed) + (self.total_change * (self.scale_factor * 0.1))) * self.scale.value) * -sin[self.rotation] + (10 + (self.cam_y.value * 0.05)) * cos[self.rotation]) + (self.boat_size / 2)
        local rowbot_body_x = (((-8 * self.reversed) * self.scale.value) * -cos[self.rotation] - (-10 + (self.cam_y.value * 0.05)) * sin[self.rotation]) + (self.boat_size / 2)
        local rowbot_body_y = (((-8 * self.reversed) * self.scale.value) * -sin[self.rotation] + (-10 + (self.cam_y.value * 0.05)) * cos[self.rotation]) + (self.boat_size / 2)
        local bunny_head_x = ((((12 * self.reversed) + (self.total_change * (self.scale_factor * -0.5))) * self.scale.value) * -cos[self.rotation] - (self.cam_y.value * 0.05) * sin[self.rotation]) + (self.boat_size / 2)
        local bunny_head_y = ((((12 * self.reversed) + (self.total_change * (self.scale_factor * -0.5))) * self.scale.value) * -sin[self.rotation] + (self.cam_y.value * 0.05) * cos[self.rotation]) + (self.boat_size / 2)
        local bunny_ear_1_x = ((((6 * self.reversed) + (self.total_change * (self.scale_factor * -1))) * self.scale.value) * -cos[self.rotation] - (-5 + self.wobble_speedo.value * (2 * self.scale.value) + (self.cam_y.value * 0.1)) * sin[self.rotation]) + (self.boat_size / 2)
        local bunny_ear_1_y = ((((6 * self.reversed) + (self.total_change * (self.scale_factor * -1))) * self.scale.value) * -sin[self.rotation] + (-5 + self.wobble_speedo.value * (2 * self.scale.value) + (self.cam_y.value * 0.1)) * cos[self.rotation]) + (self.boat_size / 2)
        local bunny_ear_2_x = ((((19 * self.reversed) + (self.total_change * (self.scale_factor * -1))) * self.scale.value) * -cos[self.rotation] - (4 + self.wobble_speedo.value * self.scale.value + (self.cam_y.value * 0.1)) * sin[self.rotation]) + (self.boat_size / 2)
        local bunny_ear_2_y = ((((19 * self.reversed) + (self.total_change * (self.scale_factor * -1))) * self.scale.value) * -sin[self.rotation] + (4 + self.wobble_speedo.value * self.scale.value + (self.cam_y.value * 0.1)) * cos[self.rotation]) + (self.boat_size / 2)
        local rowbot_antennae_x = ((((-14 * self.reversed) + (self.total_change * (self.scale_factor * -0.5))) * self.scale.value) * -cos[self.rotation] - (self.wobble_speedo.value * (2 * self.scale.value) + (self.cam_y.value * 0.1)) * sin[self.rotation]) + (self.boat_size / 2)
        local rowbot_antennae_y = ((((-14 * self.reversed) + (self.total_change * (self.scale_factor * -0.5))) * self.scale.value) * -sin[self.rotation] + (self.wobble_speedo.value * (2 * self.scale.value) + (self.cam_y.value * 0.1)) * cos[self.rotation]) + (self.boat_size / 2)
        -- Drawing passenger bodies, and bunny's hair tuft
        gfx.fillCircleAtPoint(bunny_body_x, bunny_body_y, 6 * self.scale.value)
        gfx.fillCircleAtPoint(bunny_tuft_x, bunny_tuft_y, 11 * self.scale.value)
        gfx.fillCircleAtPoint(rowbot_body_x, rowbot_body_y, 6 * self.scale.value)
        -- Drawing fills for heads
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(bunny_head_x, bunny_head_y, 11 * self.scale.value)
        self.transform:translate(-sin[self.rotation] * (self.cam_y.value * 0.05), cos[self.rotation] * (self.cam_y.value * 0.05))
        gfx.fillPolygon(self.transform:transformedPolygon(self.poly_rowbot_fill))
        -- Drawing hats, and ears/antennae
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(self.transform:transformedPolygon(self.poly_rowbot))
        gfx.drawCircleAtPoint(bunny_head_x, bunny_head_y, 11 * self.scale.value)
        gfx.drawCircleAtPoint(bunny_head_x, bunny_head_y, 8 * self.scale.value)
        gfx.fillCircleAtPoint(bunny_ear_1_x, bunny_ear_1_y, 6 * self.scale.value)
        gfx.fillCircleAtPoint(bunny_ear_2_x, bunny_ear_2_y, 6 * self.scale.value)
        gfx.fillCircleAtPoint(rowbot_antennae_x, rowbot_antennae_y, 3 * self.scale.value)
        
    end
    gfx.setColor(gfx.kColorBlack) -- Make sure to set this back afterward, or else your corner UIs will suffer!!
end