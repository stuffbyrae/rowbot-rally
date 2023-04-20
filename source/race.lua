-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

local rowbot_speed = 0
local max_rowbot_speed = 7

local boat_speed = 0
local max_boat_speed = 5
local bonkable = true

local turn_rate = 1.5
local turn_speed = 0
local boat_rotation = 0

local race_started = false
local elapsed_time = 0

local img_meter = gfx.image.new('images/race/meter')
local img_meter_mask = gfx.image.new('images/race/meter_mask')

local img_boat_wooden = gfx.imagetable.new('images/boats/boat_wooden2')
local img_wake = gfx.image.new('images/boats/wake')

local img_water = gfx.image.new('images/tracks/water')
local img_track_test_col = gfx.image.new('images/tracks/track_jungle_col')
local img_track_test = gfx.image.new('images/tracks/track_jungle')
local track_start_x = 750

local img_hud = gfx.image.new('images/race/hud')
local timesnewrally = gfx.font.new('Times New Rally')

local img_countdown = gfx.imagetable.new('images/countdown/countdown')
local countdown_anim = gfx.animation.loop.new(66, img_countdown, false)

class('race').extends(gfx.sprite)
function race:init()
    race.super.init(self)
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height) img_water:draw(0, 0) end)
end
local spr_race = race()

class('track_col').extends(gfx.sprite)
function track_col:init()
    track_col.super.init(self)
    self:setImage(img_track_test_col)
    self:moveTo(track_start_x, 0)
    self:setCollideRect(0, 0, self:getSize())
    self:add()
end
local spr_track_col = track_col()

function bonk()
    rowbot_speed = 0
    turn_speed = 0
    boat_speed = boat_speed*-1
    bonkable = false
    pd.timer.performAfterDelay(500, function() bonkable = true end)
end

class('wake').extends(gfx.sprite)
function wake:init()
    wake.super.init(self)
    wake_particles = ParticleImage(200, 120)
    wake_particles:setImage(img_wake)
    wake_particles:setMode(Particles.modes.DECAY)
    wake_particles:setDecay(0.1)
    self:setIgnoresDrawOffset(true)
    self:moveTo(200, 120)
    self:add()
end
function wake:update()
    wake_particles:setSpread(math.floor(boat_rotation)-180)
    wake_particles:setRotation(math.floor(boat_rotation)-180)
    wake_particles:setSpeed(math.floor(boat_speed))
    local wake_image = gfx.image.new(400, 240)
    gfx.pushContext(wake_image)
    if race_started == true and bonkable == true then
        wake_particles:add(1)
    end
    wake_particles:update()
    gfx.popContext()
    local boat_radtation = math.rad(boat_rotation)
    self:moveTo(200+(math.sin(boat_radtation)*-20), 120+(math.cos(boat_radtation)*20))
    self:setImage(wake_image)
end
spr_wake = wake()

class('boat').extends(gfx.sprite)
function boat:init()
    boat.super.init(self)
    self:moveTo(200, 120)
    self:setCollideRect(0, 0, 70, 70)
    self:add()
end
function boat:update()
    change = pd.getCrankChange()/1.3
    if race_started == true then
        elapsed_time += 1
        if bonkable == true then
            if change > 0 then
                if turn_speed < change then
                    turn_speed += turn_rate
                end
                if turn_speed > change then
                    turn_speed -= turn_rate
                end
                boat_rotation += turn_speed
            else
                turn_speed -= turn_rate
            end
            if turn_speed < 0 then turn_speed = 0 end
            if boat_speed < max_boat_speed then boat_speed += 0.1 end
            if rowbot_speed < max_rowbot_speed then rowbot_speed += turn_rate end
            if self:alphaCollision(spr_track_col) == true then bonk() end
        else
            if boat_speed < 0 then boat_speed += 0.25 end
            if boat_speed > 0 then boat_speed = 0 end
        end
        boat_rotation -= rowbot_speed
        gfx.setDrawOffset(-self.x+200, -self.y+120)
    else
        if boat_speed > 0 then boat_speed -= 0.1 end
    end
    if boat_rotation <= 1 then boat_rotation = 359 end
    if boat_rotation >= 360 then boat_rotation = 2 end
    self:setImage(img_boat_wooden[math.floor(boat_rotation)])
    local boat_radtation = math.rad(boat_rotation)
    self:moveBy(math.sin(boat_radtation)*boat_speed, math.cos(boat_radtation)*-boat_speed)
end
local spr_boat = boat()

class('track').extends(gfx.sprite)
function track:init()
    track.super.init(self)
    self:setImage(img_track_test)
    self:moveTo(track_start_x, 0)
    self:add()
end
local spr_track = track()

class('meter').extends(gfx.sprite)
function meter:init()
    meter.super.init(self)
    self:moveTo(200, 120)
    self:setIgnoresDrawOffset(true)
    self:add()
end
function meter:update()
    local meter_image = gfx.image.new(130, 118)
    gfx.pushContext(meter_image)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, meter_image:getSize())
        gfx.setColor(gfx.kColorBlack)
        if race_started == true then
            gfx.fillRect(0, 33, 50, rowbot_speed*2.5)
            gfx.fillRect(80, 33, 50, turn_speed*2.5)
        end
        meter_image:setMaskImage(img_meter_mask)
        img_meter:draw(0, 0)
    gfx.popContext()
    self:setImage(meter_image, gfx.kImageFlippedY)
end
local spr_meter = meter()

class('hud').extends(gfx.sprite)
function hud:init()
    hud.super.init(self)
    self:moveTo(10, 10)
    self:setCenter(0, 0)
    self:setIgnoresDrawOffset(true)
    self:add()
end
function hud:update()
    gfx.setFont(timesnewrally)
    if race_started == true then
        mins = string.format("%02.f", math.floor((elapsed_time/30) / 60))
        secs = string.format("%02.f", math.floor((elapsed_time/30) - mins * 60))
        mils = string.format("%02.f", (elapsed_time/30)*99 - mins * 5940 - secs * 99)
    end
    local hud_image = gfx.image.new(89, 46)
    gfx.pushContext(hud_image)
        img_hud:draw(0, 0)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        if elapsed_time <= 0 then
            gfx.drawText("O 00:00.00", 5, 6)
        else
            gfx.drawText("O "..mins..":"..secs.."."..mils, 5, 6)
        end
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        gfx.drawTextAligned("C AB 0!", 46, 27, kTextAlignment.center)
    gfx.popContext()
    self:setImage(hud_image)
end
local spr_hud = hud()

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
local spr_countdown = countdown()

function restart_race()
    rowbot_speed = 0
    boat_speed = 0
    boat_rotation = 0
    elapsed_time = 0
    race_started = false
    spr_boat:moveTo(200, 120)
    spr_boat:setRotation(boat_rotation)
    gfx.setDrawOffset(-spr_boat.x+200, -spr_boat.y+120)
    countdown_anim = gfx.animation.loop.new(66, img_countdown, false)
    playdate.timer.performAfterDelay(3000, function() race_started = true end)
end

function playdate.gameWillPause()
    local menu = playdate.getSystemMenu()
    menu:removeAllMenuItems()
    if race_started == true then
        menu:addMenuItem('restart race', function() restart_race() end)
    end
    menu:addMenuItem('back to title', function() end)
end