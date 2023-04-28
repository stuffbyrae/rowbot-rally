-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- We're gonna move to these scenes later, so call 'em now!
import "title"
import "results"

class('race').extends(gfx.sprite)
function race:init()
    race.super.init(self)

    -- Defining thingies...
    local race_ongoing = false -- this variable tracks if the race is ongoing
    local race_finished = false
    local crashed = false -- this variable tracks if the boat is crashed or not
    local elapsed_time = 0 -- this number will track the elapsed time during the race

    local boat_speed = 0 -- this is the boat's current speed relative to it's stat, a number that will change during gameplay
    local turn_speed = 0 -- this is the boat's current turning speed, a number that will change during gameplay
    local boat_rotation = 0 -- this tracks the boat's current rotation, and will change during gameplay

    local track_start_x = 710 -- this is the track's starting X coordinate, and should change depending on the track value fed into it
    local max_boat_speed = 6 -- this is the boat's maximum speed, and should change depending on the boat value fed into it
    local max_turn_speed = 8
    local turn_rate = 1.5 -- this is the boat's turning rate, and should change depending on the boat value fed into it 
    local change = pd.getCrankChange()

    local img_water = gfx.image.new('images/tracks/water')
    local img_track_col = gfx.image.new('images/tracks/track_river_col')
    local img_track = gfx.image.new('images/tracks/track_river')

    local img_boat = gfx.imagetable.new('images/boats/boat_wooden')
    local img_wake = gfx.image.new('images.boats/wake.png')
    local wake_particles = ParticleImage(200, 120)

    local img_meter = gfx.image.new('images/race/meter')
    local img_meter_mask = gfx.image.new('images/race/meter_mask')

    local img_hud = gfx.image.new('images/race/hud')

    local react_idle = gfx.imagetable.new('images/react/react_idle')
    local react_curious = gfx.image.new('images/react/react_curious')
    local react_crash = gfx.imagetable.new('images/react/react_crash')
    local react_idle_loop = gfx.animation.loop.new(500, react_idle, true)
    local react_crash_loop = gfx.animation.loop.new(10, react_crash, true)

    local img_countdown = gfx.imagetable.new('images/countdown/countdown')

    local song = pd.sound.fileplayer.new('sounds/songs/song')
    local times_new_rally = gfx.font.new('fonts/times_new_rally')

    -- Draw the water behind everything else
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height) img_water:draw(0, 0)
    end)

    function startrace()
        countdown_anim = gfx.animation.loop.new(66, img_countdown, false)
        playdate.timer.performAfterDelay(3000, function() race_ongoing = true song:play(0) end)
    end
    startrace()

    function endrace()
        if race_ongoing then
            song:stop()
            race_ongoing = false
            race_finished = true
        end
    end

    function pd.AButtonDown()
    endrace()
    end

    function restartrace()
        race_ongoing = false
        boat_speed = 0
        boat_rotation = 0
        boat:setRotation(boat_rotation)
        elapsed_time = 0
        boat:moveTo(200, 120)
        song:stop()
        startrace()
    end

    function crash()
    end

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if race_ongoing then
            menu:addMenuItem('restart race', function() restartrace() end)
        end
        menu:addMenuItem('back to title', function() scenemanger:switchscene(title) end)
    end

    class('track_col').extends(gfx.sprite)
    function track_col:init()
        track_col.super.init(self)
        self:setImage(img_track_col)
        self:moveTo(track_start_x, 0)
        self:add()
    end
    local track_col = track_col()


    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:moveTo(200, 120)
        self:add()
    end
    function boat:update()
        if race_ongoing then
            gfx.setDrawOffset(-boat.x+200, -boat.y+120)
            change = pd.getCrankChange()/2
            if crashed == false then
                if turn_speed < change then
                    turn_speed += turn_rate
                else
                    turn_speed -= turn_rate
                end
                boat_rotation += turn_speed
                if turn_speed < 0 then turn_speed = 0 end
                if boat_speed < max_boat_speed then boat_speed += 0.1 end
            else

            end
            boat_rotation -= max_turn_speed
        else
            if boat_speed > 0 then boat_speed -= 0.1 end
            if boat_speed < 0 then boat_speed = 0 end
        end
        if boat_rotation <= 1 then boat_rotation = 359 end
        if boat_rotation >= 360 then boat_rotation = 2 end
        self:setImage(img_boat[math.floor(boat_rotation)])
        boat_radtation = math.rad(boat_rotation)
        self:moveBy(math.sin(boat_radtation)*boat_speed, math.cos(boat_radtation)*-boat_speed)
    end
    boat = boat()

    class('track').extends(gfx.sprite)
    function track:init()
        track.super.init(self)
        self:setImage(img_track)
        self:moveTo(track_start_x, 0)
        self:add()
    end
    local track = track()

    class('meter').extends(gfx.sprite)
    function meter:init()
        meter.super.init(self)
        self:setCenter(0.5, 0.5)
        self:setIgnoresDrawOffset(true)
        self:moveTo(200, 120)
        self:add()
    end
    function meter:update()
        local meter_image = gfx.image.new(130, 118)
        gfx.pushContext(meter_image)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(0, 0, meter_image:getSize())
            gfx.setColor(gfx.kColorBlack)
            if race_ongoing then
                gfx.fillRect(0, 33, 50, boat_speed*3)
                gfx.fillRect(80, 33, 50, turn_speed*3)
            end
            meter_image:setMaskImage(img_meter_mask)
            img_meter:draw(0, 0)
        gfx.popContext()
        self:setImage(meter_image, gfx.kImageFlippedY)
        if race_finished then
            self:remove()
        end
    end
    local meter = meter()

    class('react').extends(gfx.sprite)
    function react:init()
        react.super.init(self)
        self:setCenter(1, 1)
        self:moveTo(400, 240)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function react:update()
        self:setImage(react_idle_loop:image())
        if race_finished then
            self:remove()
        end
    end
    local react = react()

    class('countdown').extends(gfx.sprite)
    function countdown:init()
        countdown.super.init(self)
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        playdate.timer.performAfterDelay(3000, function() race_started = true end)
        self:add()
    end
    function countdown:update()
        self:setImage(countdown_anim:image())
    end
    local countdown = countdown()

    self:add()
end

function race:update()
    if race_ongoing then
        elapsed_time += 1
        print(elapsed_time)
    end
end