-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

local rowbot_speed = 0
local max_rowbot_speed = 8

local boat_speed = 0
local boat_rotation = 0
local max_boat_speed = 5
local bonkable = true

local race_started = false
local elapsed_time = 0

local img_meter = gfx.image.new('images/meter')
local img_meter_mask = gfx.image.new('images/meter_mask')

local img_boat_wooden = gfx.image.new('images/boat_wooden')
local img_oar = gfx.imagetable.new('images/oar/oar')

local img_water = gfx.image.new('images/water')
local img_track_test_col = gfx.image.new('images/track_jungle_col')
local img_track_test_bg = gfx.image.new('images/track_jungle_bg')
local img_track_test_fg = gfx.image.new('images/track_jungle_fg')
local track_start_x = 750

local img_react_idle = gfx.image.new('images/react_idle')
local img_react_bonk = gfx.image.new('images/react_bonk')

local img_hud = gfx.image.new('images/hud')
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

class('track_bg').extends(gfx.sprite)
function track_bg:init()
    track_bg.super.init(self)
    self:setImage(img_track_test_bg)
    self:moveTo(track_start_x, 0)
    self:add()
end
local spr_track_bg = track_bg()

function bonk()
    rowbot_speed = 0
    boat_speed = boat_speed*-1
    bonkable = false
    pd.timer.performAfterDelay(1500, function() bonkable = true end)
end

class('boat').extends(gfx.sprite)
function boat:init()
    boat.super.init(self)
    self:moveTo(200, 120)
    self:setCollideRect(0, 0, 70, 70)
    self:add()
end
function boat:update()
    change = pd.getCrankChange()
    if race_started == true then
        elapsed_time += 1
        if bonkable == true then
            if change > 0 then boat_rotation += change end
            if boat_speed < max_boat_speed then boat_speed += 0.1 end
            if rowbot_speed < max_rowbot_speed then rowbot_speed += 0.5 end
            if self:alphaCollision(spr_track_col) == true then bonk() end
        else
            if boat_speed < 0 then boat_speed += 0.25 end
            if boat_speed > 0 then boat_speed = 0 end
        end
        boat_rotation -= rowbot_speed
        self:setRotation(boat_rotation)
        gfx.setDrawOffset(-self.x+200, -self.y+120)
    else
        if boat_speed > 0 then boat_speed -= 0.1 end
    end
    self:setImage(img_boat_wooden)
    local boat_radtation = math.rad(boat_rotation)
    self:moveBy(math.sin(boat_radtation)*boat_speed, math.cos(boat_radtation)*-boat_speed)
end
local spr_boat = boat()

class('track_fg').extends(gfx.sprite)
function track_fg:init()
    track_fg.super.init(self)
    self:setImage(img_track_test_fg)
    self:moveTo(track_start_x, 0)
    self:add()
end
local spr_track_fg = track_fg()

class('meter').extends(gfx.sprite)
function meter:init()
    meter.super.init(self)
    self:moveTo(200, 120)
    self:setIgnoresDrawOffset(true)
    self:add()
end
function meter:update()
    change = pd.getCrankChange()
    local meter_image = gfx.image.new(130, 118)
    gfx.pushContext(meter_image)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, meter_image:getSize())
        gfx.setColor(gfx.kColorBlack)
        if race_started == true then
            gfx.fillRect(0, 33, 50, rowbot_speed*2.5)
            gfx.fillRect(80, 33, 50, change*2.5)
        end
        meter_image:setMaskImage(img_meter_mask)
        img_meter:draw(0, 0)
    gfx.popContext()
    self:setImage(meter_image, gfx.kImageFlippedY)
end
local spr_meter = meter()

class('react').extends(gfx.sprite)
function react:init()
    react.super.init(self)
    self:moveTo(400, 240)
    self:setCenter(1, 1)
    self:setIgnoresDrawOffset(true)
    self:add()
end
function react:update()
    if bonkable == false then
        self:setImage(img_react_bonk)
    else
        self:setImage(img_react_idle)
    end
end
local spr_react = react()

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