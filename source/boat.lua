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
local sqrt <const> = math.sqrt
local abs <const> = math.abs

-- Baking sin and cos calculations for performance
local sin <const> = {0.0174, 0.034, 0.0523, 0.0697, 0.0871, 0.104, 0.121, 0.139, 0.156, 0.173, 0.19, 0.207, 0.22, 0.241, 0.25, 0.275, 0.292, 0.30, 0.325, 0.342, 0.358, 0.374, 0.390, 0.406, 0.422, 0.438, 0.453, 0.469, 0.484, 0.5, 0.515, 0.529, 0.544, 0.559, 0.573, 0.587, 0.60, 0.615, 0.629, 0.642, 0.65, 0.669, 0.681, 0.694, 0.707, 0.719, 0.731, 0.743, 0.754, 0.766, 0.777, 0.788, 0.798, 0.80, 0.819, 0.829, 0.838, 0.848, 0.857, 0.866, 0.874, 0.882, 0.891, 0.898, 0.906, 0.913, 0.920, 0.927, 0.933, 0.939, 0.945, 0.951, 0.956, 0.961, 0.965, 0.970, 0.974, 0.978, 0.981, 0.984, 0.987, 0.990, 0.992, 0.994, 0.996, 0.997, 0.998, 0.999, 0.999, 1.0, 0.999, 0.999, 0.998, 0.997, 0.996, 0.994, 0.992, 0.990, 0.987, 0.984, 0.981, 0.978, 0.974, 0.970, 0.965, 0.961, 0.956, 0.951, 0.945, 0.939, 0.933, 0.927, 0.920, 0.913, 0.906, 0.898, 0.891, 0.882, 0.874, 0.866, 0.857, 0.84, 0.838, 0.829, 0.81, 0.80, 0.798, 0.788, 0.77, 0.766, 0.754, 0.743, 0.731, 0.719, 0.707, 0.694, 0.681, 0.669, 0.65, 0.642, 0.629, 0.615, 0.601, 0.587, 0.573, 0.55, 0.544, 0.529, 0.51, 0.500, 0.484, 0.469, 0.453, 0.438, 0.422, 0.406, 0.390, 0.374, 0.358, 0.342, 0.325, 0.30, 0.292, 0.275, 0.258, 0.241, 0.224, 0.207, 0.19, 0.173, 0.156, 0.139, 0.121, 0.104, 0.0871, 0.0697, 0.0523, 0.0348, 0.0174, 0, -0.0174, -0.0348, -0.0523, -0.069, -0.0871, -0.104, -0.121, -0.139, -0.156, -0.173, -0.19, -0.207, -0.22, -0.241, -0.258, -0.275, -0.292, -0.30, -0.325, -0.342, -0.358, -0.374, -0.390, -0.406, -0.422, -0.438, -0.453, -0.469, -0.484, -0.5, -0.51, -0.529, -0.54, -0.55, -0.573, -0.587, -0.60, -0.615, -0.629, -0.642, -0.656, -0.669, -0.681, -0.694, -0.707, -0.719, -0.731, -0.743, -0.754, -0.766, -0.77, -0.788, -0.798, -0.809, -0.819, -0.829, -0.838, -0.84, -0.857, -0.866, -0.874, -0.882, -0.891, -0.898, -0.906, -0.913, -0.920, -0.927, -0.933, -0.939, -0.945, -0.951, -0.956, -0.961, -0.965, -0.970, -0.974, -0.978, -0.981, -0.984, -0.987, -0.990, -0.992, -0.994, -0.996, -0.99, -0.998, -0.999, -0.999, -1.0, -0.999, -0.999, -0.998, -0.99, -0.996, -0.994, -0.992, -0.990, -0.987, -0.984, -0.981, -0.978, -0.9, -0.970, -0.965, -0.961, -0.956, -0.951, -0.945, -0.939, -0.933, -0.927, -0.920, -0.913, -0.906, -0.898, -0.891, -0.882, -0.874, -0.866, -0.857, -0.84, -0.838, -0.829, -0.819, -0.809, -0.798, -0.788, -0.77, -0.766, -0.754, -0.743, -0.731, -0.719, -0.707, -0.694, -0.681, -0.669, -0.656, -0.642, -0.629, -0.615, -0.60, -0.587, -0.573, -0.559, -0.544, -0.529, -0.515, -0.500, -0.484, -0.469, -0.453, -0.438, -0.422, -0.406, -0.390, -0.374, -0.358, -0.342, -0.32, -0.309, -0.292, -0.275, -0.258, -0.241, -0.22, -0.207, -0.190, -0.173, -0.156, -0.139, -0.121, -0.104, -0.0871, -0.0697, -0.0523, -0.034, -0.0174, 0}
local cos <const> = {0.999, 0.999, 0.998, 0.997, 0.996, 0.994, 0.992, 0.990, 0.987, 0.984, 0.981, 0.978, 0.974, 0.970, 0.965, 0.961, 0.956, 0.951, 0.945, 0.939, 0.933, 0.927, 0.920, 0.913, 0.906, 0.898, 0.891, 0.882, 0.874, 0.866, 0.857, 0.848, 0.838, 0.829, 0.819, 0.80, 0.798, 0.788, 0.777, 0.766, 0.754, 0.743, 0.731, 0.719, 0.707, 0.694, 0.681, 0.669, 0.65, 0.642, 0.629, 0.615, 0.60, 0.587, 0.573, 0.559, 0.544, 0.529, 0.515, 0.5, 0.484, 0.469, 0.453, 0.438, 0.422, 0.406, 0.390, 0.374, 0.35, 0.342, 0.325, 0.30, 0.292, 0.275, 0.258, 0.241, 0.22, 0.207, 0.190, 0.173, 0.156, 0.139, 0.121, 0.104, 0.087, 0.0697, 0.0523, 0.034, 0.0174, 0, -0.0174, -0.0348, -0.0523, -0.0697, -0.0871, -0.104, -0.121, -0.139, -0.156, -0.173, -0.19, -0.207, -0.22, -0.241, -0.25, -0.275, -0.292, -0.309, -0.325, -0.342, -0.358, -0.374, -0.390, -0.406, -0.422, -0.438, -0.453, -0.469, -0.484, -0.500, -0.51, -0.529, -0.544, -0.559, -0.573, -0.587, -0.601, -0.615, -0.629, -0.642, -0.65, -0.669, -0.681, -0.694, -0.707, -0.719, -0.731, -0.743, -0.754, -0.766, -0.777, -0.788, -0.798, -0.809, -0.819, -0.829, -0.838, -0.84, -0.857, -0.866, -0.874, -0.882, -0.891, -0.898, -0.906, -0.913, -0.920, -0.927, -0.933, -0.939, -0.945, -0.951, -0.956, -0.961, -0.965, -0.970, -0.974, -0.978, -0.981, -0.984, -0.987, -0.990, -0.992, -0.994, -0.996, -0.997, -0.998, -0.999, -0.999, -1.0, -0.999, -0.999, -0.998, -0.997, -0.996, -0.994, -0.992, -0.990, -0.987, -0.984, -0.981, -0.978, -0.974, -0.970, -0.965, -0.961, -0.956, -0.951, -0.945, -0.939, -0.933, -0.927, -0.920, -0.913, -0.906, -0.898, -0.891, -0.882, -0.874, -0.866, -0.857, -0.848, -0.838, -0.829, -0.819, -0.809, -0.798, -0.788, -0.777, -0.766, -0.754, -0.743, -0.731, -0.719, -0.707, -0.694, -0.681, -0.669, -0.65, -0.642, -0.629, -0.615, -0.601, -0.587, -0.573, -0.559, -0.544, -0.529, -0.515, -0.499, -0.484, -0.469, -0.453, -0.43, -0.422, -0.406, -0.390, -0.374, -0.358, -0.342, -0.325, -0.309, -0.292, -0.275, -0.25, -0.241, -0.224, -0.207, -0.190, -0.173, -0.156, -0.139, -0.121, -0.104, -0.0871, -0.0697, -0.0523, -0.0348, -0.017, 0, 0.0174, 0.0348, 0.0523, 0.0697, 0.0871, 0.104, 0.121, 0.139, 0.156, 0.173, 0.190, 0.207, 0.224, 0.241, 0.25, 0.275, 0.292, 0.309, 0.325, 0.342, 0.358, 0.374, 0.390, 0.406, 0.422, 0.43, 0.453, 0.469, 0.484, 0.499, 0.515, 0.529, 0.544, 0.559, 0.573, 0.587, 0.601, 0.615, 0.629, 0.642, 0.656, 0.669, 0.681, 0.694, 0.707, 0.719, 0.731, 0.743, 0.754, 0.766, 0.777, 0.788, 0.798, 0.809, 0.819, 0.829, 0.838, 0.848, 0.857, 0.866, 0.874, 0.882, 0.891, 0.89, 0.906, 0.913, 0.920, 0.927, 0.933, 0.939, 0.945, 0.951, 0.956, 0.961, 0.965, 0.970, 0.974, 0.978, 0.981, 0.984, 0.987, 0.990, 0.992, 0.994, 0.996, 0.997, 0.998, 0.999, 0.999, 1.0}

-- Bote!
class('boat').extends(gfx.sprite)
function boat:init(mode, start_x, start_y, stage, stage_x, stage_y, follow_polygon, mirror, racemode)
    boat.super.init(self)
    self.mode = mode -- "cpu", "race", or "tutorial"
    self.racemode = racemode

    self.poly_body = geo.polygon.new(0,-38, 11,-29, 17,-19, 20,-6, 20,6, 18,20, 15,30, 12,33, -12,33, -15,30, -18,20, -20,6, -20,-6, -17,-19, -11,-29, 0,-38)
    self.poly_inside = geo.polygon.new(12,-20, 0,-23, -12,-20, -16,-7, 16,-7, 16,5, -16,5, -14,20, 14,20, 16,5, 16,-7, 12,-20)
    self.poly_body_crash = geo.polygon.new(0,-38, 17,-19, 20,6, 12,33, -12,33, -20,6, -17,-19, 0,-38)

    self.transform = geo.affineTransform.new()
    self.crash_transform = geo.affineTransform.new()

    self.scale_factor = 1 -- Default scale of the boat.
    self.turn = 7 -- The RowBot's default turning rate.
    self.random = random()

    if not perf then
        self.scale = pd.timer.new(2000 + (1000 * self.random), self.scale_factor, self.scale_factor * 1.1) -- Idle scaling anim
        self.scale.reverses = true -- Make the idle reverse after
        self.scale.repeats = true -- Make the idle loop
    else
        self.scale = pd.timer.new(100, self.scale_factor, self.scale_factor)
    end
    self.scale.discardOnCompletion = false

    if self.mode == "cpu" then
        self.stage = stage

        self.follow_polygon = follow_polygon
        self.lerp = 0.06 -- Rate at which the rotation towards the angle is interpolated.
        self.speed = 4.8 -- Forward movement speed of the boat.

        self.follow_points = {}
        self.follow_count = self.follow_polygon:count()
        self.follow_next = 1

        for i = 1, self.follow_count do
            table.insert(self.follow_points, i)
        end
        self.point_x, self.point_y = self.follow_polygon:getPointAt(self.follow_next):unpack()
    else
        if stage == 4 then
            self.speed = 3
        else
            self.speed = 5 -- Forward movement speed of the boat.
        end

        self.poly_rowbot = geo.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11, 6,-8, 6,6, 20,6, 20,-8, 6,-8, 3,-11)
        self.poly_rowbot_fill = geo.polygon.new(3,-11, 3,9, 23,9, 23,-11, 3,-11)

        self.sfx_crash = smp.new('audio/sfx/crash')
        self.sfx_rowboton = smp.new('audio/sfx/rowboton')
        self.sfx_row = smp.new('audio/sfx/row')
        self.sfx_crash:setVolume(save.vol_sfx/5)
        self.sfx_rowboton:setVolume(save.vol_sfx/5)
        self.sfx_row:setVolume(save.vol_sfx/5)

        if not demo then
            self.sfx_air = smp.new('audio/sfx/air')
            self.sfx_splash = smp.new('audio/sfx/splash')
            self.sfx_boost = smp.new('audio/sfx/boost')
            self.sfx_air:setVolume(save.vol_sfx/5)
            self.sfx_splash:setVolume(save.vol_sfx/5)
            self.sfx_boost:setVolume(save.vol_sfx/5)
        end

        if self.racemode ~= "story" then
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
        self.crankage = 0
        self.crashes = 0
        self.mirror = mirror
    end

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
    self.leap_boosting = false -- A temporary boost while leaping to clear obstacles.
    self.in_wall = false
    self.rotation = 360
    if mirror then
        self.reversed = -1 -- Flips the direction of both RowBot and bunny turning.
    else
        self.reversed = 1 -- Flips the direction of both RowBot and bunny turning.
    end
    self.collision_size = 80 * self.scale_factor

    self.boost_x = pd.timer.new(0, 1, 1) -- Boost animation on the X axis
    self.boost_y = pd.timer.new(0, 1, 1) -- Boost animation on the Y axis
    self.boost_x.discardOnCompletion = false
    self.boost_y.discardOnCompletion = false

    if not perf then
        self.ripple = geo.affineTransform.new()
        self.ripple_scale = pd.timer.new(2000 + (1000 * self.random), 0.95, 1.2)
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
    end

    self:setTag(255)
    self:moveTo(start_x, start_y)
    self:setUpdatesEnabled(false)
    self:setnewsize(120)
    self:setZIndex(0)
    self:add()
end

function boat:setnewsize(size)
    self.boat_size = size * self.scale_factor
    self:setSize(self.boat_size, self.boat_size)
    self:setCollideRect((self.boat_size - self.collision_size) / 2, (self.boat_size - self.collision_size) / 2, self.collision_size, self.collision_size)
end

-- fast atan2. Thanks, nnnn!
function boat:fastatan(y, x)
    local a = min(abs(x), abs(y)) / max(abs(x), abs(y))
    local s = a * a
    local r = ((-0.0464964749 * s + 0.15931422) * s - 0.327622764) * s * a + a
    if abs(y) > abs(x) then r = 1.57079637 - r end
    if x < 0 then r = 3.14159274 - r end
    if y < 0 then r = -r end
    return r
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
    self:setnewsize(90)
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
        if not save.button_controls then show_crank = true end
        if enabled_cheats_scream  and self.racemode ~= "story" then
            playdate.sound.micinput.startListening()
        end
    end
end

-- Stops boat movement and camera
function boat:finish(duration, peelout)
    duration = duration or 1500
    self.move_speedo:resetnew(duration, self.move_speedo.value, 0, pd.easingFunctions.inOutSine)
    self.wobble_speedo:resetnew(duration, self.wobble_speedo.value, 0, pd.easingFunctions.outBack)
    if not perf then
        self.ripple_scale:reset()
        self.ripple_opacity:reset()
        self.ripple_scale:start()
        self.ripple_opacity:start()
    end
    self:setnewsize(110)
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
        if enabled_cheats_scream  and self.racemode ~= "story" then
            playdate.sound.micinput.stopListening()
        end
    end
end

function boat:collision_check(polygons, image, crash_stage_x, crash_stage_y, dontcheck)
    local result = false
    self.crash_body_scale = self.transform:transformedPolygon(self.poly_body_crash)
    self.crash_body_scale:translate(self.x, self.y)
    for i = 1, #polygons do
        if self.crash_body_scale:intersects(polygons[i]) then
            result = true
            if not dontcheck then
                self:image_check(polygons, image, crash_stage_x, crash_stage_y)
            end
        end
    end
    print(result)
    return result
end

function boat:image_check(polygons, image, crash_stage_x, crash_stage_y)
    local points_collided = {}
    self.crash_body = self.crash_transform:transformedPolygon(self.poly_body_crash)
    for i = 1, self.poly_body_crash:count() do
        local transformed_point = self.crash_body:getPointAt(i)
        local point_x, point_y = transformed_point:unpack()
        local moved_x = ((point_x + self.x) - crash_stage_x)
        local moved_y = ((point_y + self.y) - crash_stage_y)
        if image:sample(moved_x, moved_y) ~= gfx.kColorClear then
            self:crash(point_x, point_y, polygons)
            table.insert(points_collided, i)
        end
        if self.mode ~= "cpu" and #points_collided == self.poly_body_crash:count() then
            self.beached = true
        end
    end
end

function boat:crash(point_x, point_y, polygons)
    local angle = deg(self:fastatan(point_y, point_x))
    self.crash_direction = floor(angle - 90 + random(-20, 20)) % 360 + 1
    self.crash_time = 500 * (max(0.25, min(1, self.move_speedo.value)))
    if self.crashable then
        if self.mode ~= "cpu" and not self.crashed then
            self.sfx_crash:stop()
            self.sfx_crash:setRate(1 + (random() - 0.5))
            self.sfx_crash:setVolume(max(0, min(save.vol_sfx/5, self.move_speedo.value)))
            self.sfx_crash:play()
            if self.movable then
                self.crashes += 1
                save.total_crashes += 1
                if self.racemode == "story" then
                    save['slot' .. save.current_story_slot .. '_crashes'] += 1
                end
            end
            self.move_speedo:resetnew(self.crash_time, 1, 0, pd.easingFunctions.outSine)
            self.wobble_speedo:resetnew(self.crash_time / 2, 1, -1.5, pd.easingFunctions.outBack)
            self.move_speedo.reverses = true
            self.wobble_speedo.reverses = true
            self.wobble_speedo.reverseEasingFunction = pd.easingFunctions.inSine
            if self.movable then
                pd.timer.performAfterDelay(self.crash_time, function()
                    self.crashed = false
                end)
            end
        end
        self.crashed = true
    end
end

function boat:boost()
    if self.movable and not self.boosting then -- Make sure they're not boosting already
        self.boosting = true
        -- Stretch the boat
        self.boost_x:resetnew(700, 0.9, 1)
        self.boost_y:resetnew(700, 1.1, 1)
        self.wobble_speedo:resetnew(500, 1, 3, pd.easingFunctions.outBack)
        self.speed = self.speed * 2 -- Make the boat go faster (duh)
        self.lerp = 0.1 -- Make it turn a little less quickly, though!
        pd.timer.performAfterDelay(2000, function()
            self.boosting = false
            self.speed = self.speed / 2 -- Set the speed back
            self.lerp = 0.2 -- Set the lerp back
        end)
        if self.mode ~= "cpu" then
            shakies(500, 10)
            shakies_y(750, 10)
            self.sfx_boost:play()
            -- Throw the camera back
            self.cam_x:resetnew(1000, self.cam_x.value, 70, pd.easingFunctions.inOutSine)
            self.cam_y:resetnew(1000, self.cam_y.value, 70, pd.easingFunctions.inOutSine)
            pd.timer.performAfterDelay(2000, function()
                if self.movable then
                    self.wobble_speedo:resetnew(2000, self.wobble_speedo.value, 1, pd.easingFunctions.outBack)
                end
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
            self.sfx_air:play()
            self.sfx_boost:play()
        end
        self.leaping = true
        self.crashable = false
        self:setnewsize(200)
        self:setZIndex(2)
        -- Scale anim — this is like 90% of the work
        self.scale:resetnew(700, self.scale_factor, self.scale_factor * 2, pd.easingFunctions.outCubic)
        self.scale.reverses = true
        self.scale.reverseEasingFunction = pd.easingFunctions.inCubic
        if not self.boosting and not self.leap_boosting then
            self.leap_boosting = true
            self.speed = self.speed * 1.5
        end
        pd.timer.performAfterDelay(1400, function()
            if self.mode ~= "cpu" then
                self.sfx_splash:play()
            end
            if self.leap_boosting then
                self.leap_boosting = false
                self.speed = self.speed / 1.5
            end
            -- Bounce-back animation
            self.scale:resetnew(500, self.scale_factor * 0.8, self.scale_factor, pd.easingFunctions.outBack)
            -- Re-set boat size
            self:setnewsize(90)
            self.leaping = false
            self.crashable = true
            -- Set the idle scaling anim back
            pd.timer.performAfterDelay(500, function()
                if perf then
                    self.scale:resetnew(100, self.scale_factor, self.scale_factor)
                else
                    self.scale:resetnew(2000 + (1000 * self.random), self.scale_factor, self.scale_factor * 1.1)
                end
            end)
            pd.timer.performAfterDelay(10, function()
                if not self.beached then
                    self:setZIndex(0)
                end
            end)
        end)
    end
end

function boat:update(delta)
    self.transform:reset()
    self.crash_transform:reset()
    if not perf then self.ripple:reset() end
    local x, y = gfx.getDrawOffset() -- Gimme the draw offset
    if not self.crashed then -- Move the boat
        self:moveBy((sin[self.rotation] * (self.speed * self.move_speedo.value) * 30) * delta, (-cos[self.rotation] * (self.speed * self.move_speedo.value) * 30) * delta)
    else
        self:moveBy((sin[self.crash_direction] * (self.speed * self.move_speedo.value) * 30) * delta, (-cos[self.crash_direction] * (self.speed * self.move_speedo.value) * 30) * delta)
    end
    -- If there's a peelout anim, just go for that instead.
    if self.peelout ~= nil then
        self.rotation = self.peelout.value
    else
        if self.mode == "cpu" then -- CPU Controlling
            if self.movable then
                local targetangle = floor(deg(self:fastatan(self.point_y - self.y, self.point_x - self.x)) + 90)
                if math.abs(self.rotation - targetangle) > 180 then
                    if self.rotation > targetangle then
                        self.rotation -= 360
                    else
                        self.rotation += 360
                    end
                end
                self.rotation += (targetangle - self.rotation) * self.lerp
                local dx = self.x - self.point_x
                local dy = self.y - self.point_y
                if sqrt(dx * dx + dy * dy) <= 80 then
                    self.follow_next += 1
                    if self.follow_next > self.follow_count then
                        self.follow_next = 1
                    end
                    self.point_x, self.point_y = self.follow_polygon:getPointAt(self.follow_next):unpack()
                end
            end
            -- gfx.setDrawOffset(-self.x + 200, -self.y + 120)
        else -- Player controlling
            gfx.setDrawOffset(-self.x + 200 - sin[self.rotation] * self.cam_x.value, -self.y + 120 + cos[self.rotation] * self.cam_y.value)
            if self.mode == "race" then
                local x, y = gfx.getDrawOffset()
                if x >= 0 then x = 0 elseif x - 400 <= -self.stage_x then x = -self.stage_x + 400 end
                if y >= 0 then y = 0 elseif y - 240 <= -self.stage_y then y = -self.stage_y + 240 end
                gfx.setDrawOffset(x, y)
            end
            if self.turnable then
                if enabled_cheats_scream and self.racemode ~= "story" then
                    if pd.sound.micinput.getLevel() > 0 then
                        self.crankage += ((playdate.sound.micinput.getLevel() * 30) - self.crankage) * self.turn_speedo.value * ((self.lerp * 30) * delta) -- Lerp crankage to itself
                    elseif self.crankage >= 0.01 then
                        self.crankage += (0 - self.crankage) * ((self.lerp * 30) * delta) -- Decrease with lerp if either the player isn't cranking, or the crankage was just turned off.
                    else
                        self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
                    end
                elseif save.button_controls then
                    if self.right then
                        if self.turn_speedo.value == 1 then
                            self.crankage += ((self.turn * (self.turn_speedo.value * 2)) - self.crankage) * ((self.lerp * 30) * delta)
                            if self.crankage >= (self.turn * (self.turn_speedo.value * 2)) - ((self.turn * (self.turn_speedo.value * 2)) * 0.15) then
                                self.crankage = self.turn * (self.turn_speedo.value * 2)
                            end
                        else
                            self.crankage = self.turn * (self.turn_speedo.value * 2)
                        end
                    elseif self.straight then
                        if self.turn_speedo.value == 1 then
                            self.crankage += ((self.turn * self.turn_speedo.value) - self.crankage) * ((self.lerp * 30) * delta)
                            if (self.crankage >= (self.turn * (self.turn_speedo.value)) - ((self.turn * (self.turn_speedo.value)) * 0.15)) and (self.crankage <= (self.turn * (self.turn_speedo.value)) + ((self.turn * (self.turn_speedo.value)) * 0.15)) then
                                self.crankage = self.turn * (self.turn_speedo.value)
                            end
                        else
                            self.crankage = self.turn * self.turn_speedo.value
                        end
                    elseif self.crankage >= 0.01 then
                        self.crankage += (0 - self.crankage) * ((self.lerp * 30) * delta) -- Decrease with lerp if either the player isn't cranking, or the crankage was just turned off.
                    else
                        self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
                    end
                else
                    if pd.getCrankChange() > 0 then
                        save.total_degrees_cranked += pd.getCrankChange() -- Save degrees cranked stat
                        self.crankage += ((pd.getCrankChange() / self.sensitivity) - self.crankage) * self.turn_speedo.value * ((self.lerp * 30) * delta) -- Lerp crankage to itself
                    elseif self.crankage >= 0.01 then
                        self.crankage += (0 - self.crankage) * ((self.lerp * 30) * delta) -- Decrease with lerp if either the player isn't cranking, or the crankage was just turned off.
                    else
                        self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
                    end
                end
            else
                if self.crankage >= 0.01 then
                    self.crankage += (0 - self.crankage) * ((self.lerp * 30) * delta) -- Decrease with lerp if nothing is going on
                else
                    self.crankage = 0 -- Round it down when it gets small enough, to ensure we don't enter floating point hell.
                end
            end
            if not self.leaping then
                if self.reversed == 1 then
                    self.rotation += ((self.crankage * 30) * delta) -- Add crankage value on there
                    if self.rowbot then -- If the RowBot needs to turn the boat,
                        self.rotation -= (((self.turn * self.turn_speedo.value) * 30) * delta) -- Apply RowBot turning. Duh!
                    end
                elseif self.reversed == -1 then -- If reverse is negative, then flip the boat.
                    self.rotation -= ((self.crankage * 30) * delta) -- Add crankage value on there
                    if self.rowbot then -- If the RowBot needs to turn the boat,
                        self.rotation += (((self.turn * self.turn_speedo.value) * 30) * delta) -- Apply RowBot turning. Duh!
                    end
                end
            end
            self.crankage_divvied = self.crankage / self.turn
        end
    end
    -- Make sure rotation winds up as integer 1 through 360
    self.rotation = ((floor(self.rotation / 2) * 2)) % 360
    if self.rotation == 0 then self.rotation = 360 end
    -- Transform ALL the polygons!!!!1!
    self.transform:scale(((self.scale.value * self.boost_x.value) * self.reversed) * self.scale_factor, (self.scale.value * self.boost_y.value) * self.scale_factor)
    if not perf then self.ripple:rotate(self.rotation) end
    self.transform:rotate(self.rotation)
    self.crash_transform:scale(max(1, min(self.scale.value, self.scale.value)))
    self.crash_transform:rotate(self.rotation)
end

function boat:draw(x, y, width, height)
    if self.mode == "cpu" then
        if self.ripple_scale ~= nil and self.ripple_scale.value ~= self.ripple_scale.endValue and not perf then
            self.ripple:scale((self.scale.value * self.boost_x.value) * self.ripple_scale.value, (self.scale.value * self.boost_y.value) * self.ripple_scale.value)
            self.ripple:translate(self.boat_size / 2, self.boat_size / 2)
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(self.ripple_opacity.value, gfx.image.kDitherTypeBayer4x4)
            gfx.setLineWidth(self.ripple_opacity.value * 4)
            gfx.drawPolygon(self.poly_body * self.ripple)
            gfx.setLineWidth(2)
            gfx.setColor(gfx.kColorBlack)
        end
        self.transform:translate(self.boat_size / 2, self.boat_size / 2)
        self.transform_polygon = self.poly_body * self.transform
        self.transform_inside = self.poly_inside * self.transform
        if not perf then
            self.transform_polygon:translate(7 * self.scale_factor, 7 * self.scale_factor)
            gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
            gfx.fillPolygon(self.transform_polygon)
            self.transform_polygon:translate(-7 * self.scale_factor, -7 * self.scale_factor)
        end
        gfx.setColor(gfx.kColorWhite)
        gfx.fillPolygon(self.transform_polygon)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(self.transform_polygon)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform_inside)
        gfx.setColor(gfx.kColorBlack)
        if self.stage == 1 then
            local r01_head = self.boat_size / 2
            local r01_arm_1_x = -20 * -cos[self.rotation] + (self.boat_size / 2)
            local r01_arm_1_y = -20 * -sin[self.rotation] + (self.boat_size / 2)
            local r01_arm_2_x = 20 * -cos[self.rotation] + (self.boat_size / 2)
            local r01_arm_2_y = 20 * -sin[self.rotation] + (self.boat_size / 2)
            gfx.setLineWidth(10)
            gfx.drawLine(r01_arm_1_x, r01_arm_1_y, r01_arm_2_x, r01_arm_2_y)
            gfx.setLineWidth(2)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillCircleAtPoint(r01_head, r01_head, 15)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawCircleAtPoint(r01_head, r01_head, 15)
            gfx.drawCircleAtPoint(r01_head, r01_head, 10)
        elseif self.stage == 2 then
            local robuzz_head = self.boat_size / 2
            local robuzz_body_x = -10 * sin[self.rotation] + (self.boat_size / 2)
            local robuzz_body_y = -10 * -cos[self.rotation] + (self.boat_size / 2)
            local robuzz_tail_x = -12 * -sin[self.rotation] + (self.boat_size / 2)
            local robuzz_tail_y = -12 * cos[self.rotation] + (self.boat_size / 2)
            gfx.fillCircleAtPoint(robuzz_tail_x, robuzz_tail_y, 8)
            gfx.fillCircleAtPoint(robuzz_body_x, robuzz_body_y, 10)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillCircleAtPoint(robuzz_head, robuzz_head, 12)
            gfx.setColor(gfx.kColorBlack)
            gfx.setLineWidth(2)
            gfx.drawCircleAtPoint(robuzz_head, robuzz_head, 12)
            gfx.drawCircleAtPoint(robuzz_head, robuzz_head, 8)
        end

    else

        if self.ripple_scale ~= nil and self.ripple_scale.value ~= self.ripple_scale.endValue and not self.beached then
            self.ripple:scale((self.scale.value * self.boost_x.value) * self.ripple_scale.value, (self.scale.value * self.boost_y.value) * self.ripple_scale.value)
            self.ripple:translate(self.boat_size / 2, self.boat_size / 2)
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(self.ripple_opacity.value, gfx.image.kDitherTypeBayer4x4)
            gfx.setLineWidth(self.ripple_opacity.value * 4)
            gfx.drawPolygon(self.poly_body * self.ripple)
            gfx.setLineWidth(2)
            gfx.setColor(gfx.kColorBlack)
        end
        self.transform:translate(self.boat_size / 2, self.boat_size / 2)
        self.transform_polygon = self.poly_body * self.transform
        self.transform_inside = self.poly_inside * self.transform
        if not perf then
            self.transform_polygon:translate(7 * self.scale_factor, 7 * self.scale_factor)
            gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
            gfx.fillPolygon(self.transform_polygon)
            self.transform_polygon:translate(-7 * self.scale_factor, -7 * self.scale_factor)
        end
        gfx.setColor(gfx.kColorWhite)
        gfx.fillPolygon(self.transform_polygon)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(self.transform_polygon)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
        gfx.fillPolygon(self.transform_inside)
        gfx.setColor(gfx.kColorBlack)
        -- Offset params for passengers
        local bunny_body_x
        local bunny_body_y
        local bunny_tuft_x
        local bunny_tuft_y
        local rowbot_body_x
        local rowbot_body_y
        local bunny_head_x
        local bunny_head_y
        local bunny_ear_1_x
        local bunny_ear_1_y
        local bunny_ear_2_x
        local bunny_ear_2_y
        local rowbot_antennae_x
        local rowbot_antennae_y

        --this should help alot
        local rev = self.reversed
        local scale = self.scale.value
        local rot = self.rotation
        local boatsize = self.boat_size
        local camy = self.cam_y.value
        local wobble = self.wobble_speedo.value
        local factor = self.scale_factor
        local center = boatsize/2
        local cosrot = cos[rot]
        local sinrot = sin[rot]

        --this is getting exessive but still should help
        local rev8 = rev*8
        local rev11 = rev*11
        local rev12 = rev*12
        local rev6 = rev*6
        local rev19 = rev*19
        local rev14 = rev*14

        if perf then
            bunny_body_x = (((rev8) * scale) * -cosrot - -10 * sinrot) + center
            bunny_body_y = (((rev8) * scale) * -sinrot + -10 * cosrot) + center
            bunny_tuft_x = ((((rev11)) * scale) * -cosrot - 10 * sinrot) + center
            bunny_tuft_y = ((((rev11)) * scale) * -sinrot + 10 * cosrot) + center
            rowbot_body_x = (((-rev8) * scale) * -cosrot - -10 * sinrot) + center
            rowbot_body_y = (((-rev8) * scale) * -sinrot + -10 * cosrot) + center
            bunny_head_x = (((rev12)) * scale) * -cosrot + center
            bunny_head_y = (((rev12)) * scale) * -sinrot + center
            bunny_ear_1_x = (((rev6)) * scale) * -cosrot + 5 * sinrot + center
            bunny_ear_1_y = (((rev6)) * scale) * -sinrot - 5 * cosrot + center
            bunny_ear_2_x = (((rev19)) * scale) * -cosrot - 4 * sinrot + center
            bunny_ear_2_y = (((rev19)) * scale) * -sinrot + 4 * cosrot + center
            rowbot_antennae_x = (((-rev14)) * scale) * -cosrot + center
            rowbot_antennae_y = (((-rev14)) * scale) * -sinrot + center
        else
            local camyscaled005 = camy * 0.05
            local camyscaled01 = camy * 0.1
            bunny_body_x = (((rev8) * scale) * -cosrot - (-10 + (camyscaled005)) * sinrot) + center
            bunny_body_y = (((rev8) * scale) * -sinrot + (-10 + (camyscaled005)) * cosrot) + center
            bunny_tuft_x = ((((rev11)) * scale) * -cosrot - (10 + (camyscaled005)) * sinrot) + center
            bunny_tuft_y = ((((rev11)) * scale) * -sinrot + (10 + (camyscaled005)) * cosrot) + center
            rowbot_body_x = (((-rev8) * scale) * -cosrot - (-10 + (camyscaled005)) * sinrot) + center
            rowbot_body_y = (((-rev8) * scale) * -sinrot + (-10 + (camyscaled005)) * cosrot) + center
            bunny_head_x = ((((rev12)) * scale) * -cosrot - (camyscaled005) * sinrot) + center
            bunny_head_y = ((((rev12)) * scale) * -sinrot + (camyscaled005) * cosrot) + center
            bunny_ear_1_x = ((((rev6)) * scale) * -cosrot - (-5 + wobble * (2 * scale) + (camyscaled01)) * sinrot) + center
            bunny_ear_1_y = ((((rev6)) * scale) * -sinrot + (-5 + wobble * (2 * scale) + (camyscaled01)) * cosrot) + center
            bunny_ear_2_x = ((((rev19)) * scale) * -cosrot - (4 + wobble * scale + (camyscaled01)) * sinrot) + center
            bunny_ear_2_y = ((((rev19)) * scale) * -sinrot + (4 + wobble * scale + (camyscaled01)) * cosrot) + center
            rowbot_antennae_x = ((((-rev14)) * scale) * -cosrot - (wobble * (2 * scale) + (camyscaled01)) * sinrot) + center
            rowbot_antennae_y = ((((-rev14)) * scale) * -sinrot + (wobble * (2 * scale) + (camyscaled01)) * cosrot) + center
        self.transform:translate(-sinrot * (camyscaled005), cosrot * (camyscaled005))
        end
        -- Drawing passenger bodies, and bunny's hair tuft
        gfx.fillCircleAtPoint(bunny_body_x, bunny_body_y, 6 * scale)
        gfx.fillCircleAtPoint(bunny_tuft_x, bunny_tuft_y, 11 * scale)
        gfx.fillCircleAtPoint(rowbot_body_x, rowbot_body_y, 6 * scale)
        -- Drawing fills for heads
        gfx.setColor(gfx.kColorWhite)

        gfx.fillCircleAtPoint(bunny_head_x, bunny_head_y, 11 * scale)
        gfx.fillPolygon(self.poly_rowbot_fill * self.transform)
        -- Drawing hats, and ears/antennae
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(self.poly_rowbot * self.transform)
        gfx.drawCircleAtPoint(bunny_head_x, bunny_head_y, 11 * scale)
        gfx.drawCircleAtPoint(bunny_head_x, bunny_head_y, 8 * scale)
        gfx.fillCircleAtPoint(bunny_ear_1_x, bunny_ear_1_y, 6 * scale)
        gfx.fillCircleAtPoint(bunny_ear_2_x, bunny_ear_2_y, 6 * scale)
        gfx.fillCircleAtPoint(rowbot_antennae_x, rowbot_antennae_y, 3 * scale)

    end
    gfx.setColor(gfx.kColorBlack) -- Make sure to set this back afterward, or else your corner UIs will suffer!!
end