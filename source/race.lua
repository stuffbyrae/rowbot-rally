-- Setting up scenes
import "title"
import "results"

-- Handy Shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Defining some stuff for the race
local race_ongoing = false
local race_finished = false
local elapsed_time = 0
local laps = 0
local track_start_x = 710
local track_start_y = 100

-- Now, let's fire up the scene!
class('race').extends(gfx.sprite)
function race:init(track_type, boat_type, race_mode)
    race.super.init(self)
    showcrankindicator = true

    -- Pictures!
local img_track_river_col = gfx.image.new('images/tracks/track_river_col') -- The bit of the track that checks collision
local img_track_river = gfx.image.new('images/tracks/track_river') -- The bit of the track you can actually see

local img_boat_wooden = gfx.imagetable.new('images/boats/boat_wooden') -- The boat!
local img_boat_rower = gfx.imagetable.new('images/boats/boat_rower') -- The boat!
local img_boat_tug = gfx.imagetable.new('images/boats/boat_tug') -- The boat!
local img_boat_raft = gfx.imagetable.new('images/boats/boat_raft') -- The boat!
local img_boat_swan = gfx.imagetable.new('images/boats/boat_swan') -- The boat!
local img_boat_pedal = gfx.imagetable.new('images/boats/boat_pedal') -- The boat!
local img_boat_hoverjet = gfx.imagetable.new('images/boats/boat_hoverjet') -- The boat!

local img_water = gfx.image.new('images/tracks/water') -- The water you row on
local img_wake = gfx.image.new('images/boats/wake.png') -- The wake behind the boat
local img_hud = gfx.image.new('images/race/hud')
local img_meter = gfx.image.new('images/race/meter') -- The meter that shows each sides' power
local img_meter_mask = gfx.image.new('images/race/meter_mask') -- The mask for that aforementioned meter
local img_react_idle = gfx.imagetable.new('images/race/react_idle') -- Idle reaction
local img_react_curious = gfx.image.new('images/race/react_curious') -- Reaction if you find a secret
local img_react_obscured = gfx.image.new('images/race/react_obscured') -- Reaction if the crank is docked
local img_react_crash = gfx.imagetable.new('images/race/react_crash') -- Reaction if you CRASH
local img_countdown = gfx.imagetable.new('images/screen_effects/countdown/countdown') -- Countdown overlay for the start of the race
local img_finish = gfx.imagetable.new('images/screen_effects/fadefromwhite100/fadefromwhite100') -- Photo finish overlay for the end of the race

local times_new_rally = gfx.font.new('fonts/times_new_rally')
gfx.setFont(times_new_rally)

    local img_track_col = gfx.image.new(1, 1)
    if track_type == 1 then
        local img_track_col = img_track_river_col
    elseif track_type == 2 then
    elseif track_type == 3 then
    elseif track_type == 4 then
    elseif track_type == 5 then
    elseif track_type == 6 then
    elseif track_type == 7 then
    end

    local img_track = gfx.image.new(1, 1)
    if track_type == 1 then
        local img_track = img_track_river
    elseif track_type == 2 then
    elseif track_type == 3 then
    elseif track_type == 4 then
    elseif track_type == 5 then
    elseif track_type == 6 then
    elseif track_type == 7 then
    end

    local img_boat = img_boat_wooden
    if boat_type == 1 then
        img_boat = img_boat_wooden
    elseif boat_type == 2 then
        img_boat = img_boat_rower
    elseif boat_type == 3 then
        img_boat = img_boat_tug
    elseif boat_type == 4 then
        img_boat = img_boat_raft
    elseif boat_type == 5 then
        img_boat = img_boat_swan
    elseif boat_type == 6 then
        img_boat = img_boat_pedal
    elseif boat_type == 7 then
        img_boat = img_boat_hoverjet
    end

    if race_mode == story then
    elseif race_mode == timetrials then
    elseif race_mode == tutorial then
    end

    -- Boat variables
    local boat_speed = 0 -- How fast the boat's going
    local max_boat_speed = 6 -- How fast the boat can go
    local turn_speed = 0 -- How fast the boat's turning
    local max_turn_speed = 8 -- How much the boat can turn
    local turn_rate = 1.5 -- How quickly the boat can turn
    local boat_rotation = 0 -- Where the boat is rotated
    local crashed = false -- Is the boat crashed or not?
    local boat_crash_x = 0 -- Boat crash movement
    local boat_crash_y = 0 -- Boat crash movement

    -- Sprite time!
    class('track_col').extends(gfx.sprite) -- The collision track
    function track_col:init()
        track_col.super.init(self)
        self:setImage(img_track_col)
        self:moveTo(track_start_x, track_start_y)
        self:setCollideRect(0, 0, self:getSize())
        --track_col:setGroups(1)
        self:add()
    end
    local track_col = track_col()

    class('water').extends(gfx.sprite) -- The water (drawn above all the collision stuff, so it can be hidden)
    function water:init()
        water.super.init(self)
        self:setCenter(0, 0)
        self:setImage(img_water)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    water = water()

    class('boat').extends(gfx.sprite) -- Bote! :)
    function boat:init()
        boat.super.init(self)
        self:moveTo(200, 120)
        self:setCollideRect(0, 0, 65, 65)
        --self:setCollidesWithGroups(1)
        self:add()
    end
    function boat:update()
        if race_ongoing then
            change = pd.getCrankChange()/2 -- Get the crank's change
            if crashed == false then
                boat_rotation -= max_turn_speed -- Subtract the max turn speed from the rotation, to simulate RowBot
                if turn_speed < change then turn_speed += turn_rate else turn_speed -= turn_rate end -- Turn depend on crank
                if turn_speed < 0 then turn_speed = 0 end -- Make sure that value doesn't go into the negatives
                boat_rotation += turn_speed -- Add the player turn speed to the rotation
                boat_radtation = math.rad(boat_rotation) -- Converting the boat rotation to radians so we can get the sine and cosine
                if boat_speed < max_boat_speed then boat_speed += 0.1 end -- Increase boat speed if you can
                self:moveBy(math.sin(boat_radtation)*boat_speed, math.cos(boat_radtation)*-boat_speed) -- Move that damn boat!
                if self:alphaCollision(track_col) then crash() end -- If there's a collision, then CRASH!
            end
        else
            if boat_speed > 0 then boat_speed -= 0.15 end -- Send the boat speed downwards.
            if boat_speed < 0 then boat_speed = 0 end --- ...but make sure it doesn't go below 0.
            if race_finished then -- If the race is done...
                self:moveBy(math.sin(0.0174533)*boat_speed, math.cos(0.0174533)*-boat_speed) -- Move that damn boat!
                boat_rotation = boat_drift_anim:currentValue() -- Drift animation
            end
        end
        --TODO: fix the boat table so i don't have to do this in these next two lines
        if boat_rotation <= 1 then boat_rotation = 359 end
        if boat_rotation >= 360 then boat_rotation = 2 end
        self:setImage(img_boat[math.floor(boat_rotation)]) -- Set the proper image for the rotation
    end
    boat = boat()

    class('track').extends(gfx.sprite) -- The track graphics.
    function track:init()
        track.super.init(self)
        self:setImage(img_track)
        self:moveTo(track_start_x, track_start_y)
        self:add()
    end
    track = track()
    
    class('hud').extends(gfx.sprite) -- The HUD bit that shows the current time and lap count
    function hud:init()
        hud.super.init(self)
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:moveTo(10, 10)
        self:add()
    end
    function hud:update()
        local mins = string.format("%02.f", math.floor((elapsed_time/30) / 60))
        local secs = string.format("%02.f", math.floor((elapsed_time/30) - mins * 60))
        local mils = string.format("%02.f", (elapsed_time/30)*99 - mins * 5940 - secs * 99)
        local hud_image = gfx.image.new(102, 45)
        gfx.pushContext(hud_image)
            img_hud:draw(0, 0)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText('O ' .. mins .. ':' .. secs .. ':' .. mils, 10, 4)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.drawTextAligned('C AB ' .. laps .. "!", 39, 24, kTextAlignment.center)
        gfx.popContext()
        self:setImage(hud_image)
        if race_finished then
            self:remove()
        end
    end
    hud = hud()
    
    class('react').extends(gfx.sprite) -- The reaction sprite in the bottom right
    function react:init()
        react.super.init(self)
        self:setCenter(1, 1)
        self:moveTo(400, 240)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function react:update()
        if crashed then -- If the boat's crashed...
            local react_crash_loop = gfx.animation.loop.new(10, img_react_crash, true)
            self:setImage(react_crash_loop:image()) -- Show the crash sprite.
        else -- If it's not...
            local react_idle_loop = gfx.animation.loop.new(500, img_react_idle, true)
            self:setImage(react_idle_loop:image()) -- Show the idle sprite.
        end
        if pd.isCrankDocked() then
            self:setImage(img_react_obscured) -- Show an obscured version if the crank's docked, to reduce clutter
        end
        if race_finished then
            self:remove() -- Remove the object if the race is done, for that clean look.
        end
    end
    local react = react()
    
    class('overlay').extends(gfx.sprite) -- The overlay drawn over everything else, used for the countdown and photo finish effects
    function overlay:init()
        overlay.super.init(self)
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function overlay:update()
        self:setImage(overlay_anim:image())
    end
    local overlay = overlay()
    
    -- Functions...
    function startrace() -- Start the race!
        overlay_anim = gfx.animation.loop.new(66, img_countdown, false) -- Make the countdown animation play
        playdate.timer.performAfterDelay(3000, function() race_ongoing = true end) -- After three seconds, start the race.
    end
    function endrace() -- End the race!
        if race_ongoing then -- Check if it's going first...
            race_ongoing = false -- If it is, make it...not.
            race_finished = true -- Also, tell everything that the race is in fact done.
            overlay_anim = gfx.animation.loop.new(66, img_finish, false) -- Play the photo finish animation
            boat_drift_anim = gfx.animator.new(1500, 0, 20*boat_speed, pd.easingFunctions.outQuad)
            pd.timer.performAfterDelay(1500, function() local lastraceimage = gfx.getDisplayImage() print(elapsed_time) scenemanager:switchscene(results, elapsed_time, lastraceimage) end) -- Then, move over to the results page with that image and the total time in tow.
        end
    end
    function restartrace() -- Restart the race!
        if race_ongoing then -- Check if it's going first...
            race_ongoing = false -- If it is, once more, make it not.
            boat_speed = 0
            boat_rotation = 0
            elapsed_time = 0
            boat:setRotation(boat_rotation)
            boat:moveTo(200, 120) -- Zero literally everything out!!
            gfx.setDrawOffset(-boat.x+200, -boat.y+120) -- Set the camera back as well.
            startrace() -- Now, we can restart the race.
        end
    end
    function crash() -- CRASH!!!
    end
    
    function pd.gameWillPause() -- If the game's being paused...
        local menu = pd.getSystemMenu() -- MENU!!
        menu:removeAllMenuItems() -- Clear all the stuff out of there.
        if race_ongoing then menu:addMenuItem('restart race', function() restartrace() end) end -- If the race is going, add an option to restart it
        menu:addMenuItem('back to title', function() scenemanager:switchscene(title) end) -- an option to go back to the title screen
    end
    
    startrace()
    self:add()
end

function race:update()
    function pd.AButtonDown()
        endrace()
    end
    if race_ongoing == true then
        elapsed_time += 1
        gfx.setDrawOffset(-boat.x+200, -boat.y+120)
    end
end