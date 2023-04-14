-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Defining some variables we'll need later
local rowbot_speed = 0
local max_rowbot_speed = 10
local move_speed = 0
local max_move_speed = 5
local boat_rotation = 0
local elapsed_time = 0
local race_started = false
local track_start_x = 750
local bonked = false

local rowbot_oar_anim = 1
local player_oar_anim = 1

-- Import all the images!!!!1!
local img_meter = gfx.image.new('images/meter')
local img_meter_mask = gfx.image.new('images/meter_mask')
local meter_image = gfx.image.new(130, 118)

local img_boat_wooden = gfx.image.new('images/boat_wooden')
local img_oar = gfx.imagetable.new('images/oar/oar')
local boat_image = gfx.image.new(107, 65)

local img_water = gfx.image.new('images/water')
local img_track_test_col = gfx.image.new('images/track_jungle_col')
local img_track_test_bg = gfx.image.new('images/track_jungle_bg')
local img_track_test_fg = gfx.image.new('images/track_jungle_fg')

local img_react_test = gfx.image.new('images/react_test')
local img_hud = gfx.image.new('images/hud')
local timesnewrally = gfx.font.new('Times New Rally')

local img_countdown = gfx.imagetable.new('images/countdown/countdown')
local countdown_anim = gfx.animation.loop.new(66, img_countdown, false)

function pd.AButtonDown()
    race_started = not race_started
end

-- Racism
class('race').extends(gfx.sprite)
function race:init()
    race.super.init(self)
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        img_water:draw(0, 0)
    end)
end

-- The track's collision sprite
class('track_col').extends(gfx.sprite)
function track_col:init()
    track_col.super.init(self)
    self:setImage(img_track_test_col)
    self:moveTo(track_start_x, 0)
    self:setCollideRect(0, 0, self:getSize())
    self:add()
end
local track_col_sprite = track_col()

-- The track sprite
class('track_bg').extends(gfx.sprite)
function track_bg:init()
    track_bg.super.init(self)
    self:setImage(img_track_test_bg)
    self:moveTo(track_start_x, 0)
    self:add()
end
local track_bg_sprite = track_bg()

-- The bote! :)
class('oar').extends(gfx.sprite)
function oar:init()
    oar.super.init(self)
    self:moveTo(200, 120)
    self:setIgnoresDrawOffset(true)
    self:add()
end
function oar:update()
    change = playdate.getCrankChange()
        self:setRotation(boat_rotation)
        rowbot_oar_anim += 0.1 * rowbot_speed
        if rowbot_oar_anim > 22 then rowbot_oar_anim = 1 end
        player_oar_anim += 0.1 * change
        if player_oar_anim > 22 then player_oar_anim = 1 end
        if player_oar_anim < 1 then player_oar_anim = 1 end
    local oar_image = gfx.image.new(107, 65)
    gfx.pushContext(oar_image)
        img_oar:drawImage(math.floor(rowbot_oar_anim), 5, 15)
        img_oar:drawImage(math.floor(player_oar_anim), 66, 15, gfx.kImageFlippedX)
    gfx.popContext()
    self:setImage(oar_image)
end
local oar_sprite = oar()

function bonk()
    if bonked == false then
        rowbot_speed = 0
        move_speed = move_speed*-1
    end
    bonked = true
    pd.timer.performAfterDelay(2000, function()
        bonked = false
    end)
end

-- The bote! :)
class('boat').extends(gfx.sprite)
function boat:init()
    boat.super.init(self)
    self:setImage(boat_image)
    self:moveTo(200, 120)
    self:setCollideRect(0, 0, self:getSize())
    self:add()
end
function boat:update()
    change = playdate.getCrankChange()
    if race_started == true then
        boat_rotation -= rowbot_speed
        if bonked == false then
            if change > 0 then
                boat_rotation += change
            end
            if move_speed < max_move_speed then
                move_speed += 0.1
            end
            if rowbot_speed < max_rowbot_speed then
                rowbot_speed += 0.5
            end
            if self:alphaCollision(track_col_sprite) == true then
                bonk()
            end
        else
            if move_speed < 0 then
                move_speed += 0.25
            end
            if move_speed > 0 then
                move_speed = 0
            end
        end
        self:setRotation(boat_rotation)
        gfx.setDrawOffset(-self.x+200, -self.y+120)
    else
        if move_speed > 0 then
            move_speed -= 0.1
        end
    end
    local boat_image = gfx.image.new(35, 65)
    gfx.pushContext(boat_image)
        img_boat_wooden:draw(0, 0)
    gfx.popContext()
    self:setImage(boat_image)
    self:moveBy(math.sin(math.rad(boat_rotation))*move_speed, math.cos(math.rad(boat_rotation))*-move_speed)
end
local boat_sprite = boat()

-- The foreground track elements
class('track_fg').extends(gfx.sprite)
function track_fg:init()
    track_fg.super.init(self)
    self:setImage(img_track_test_fg)
    self:moveTo(track_start_x, 0)
    self:add()
end
local track_fg_sprite = track_fg()

-- The power meter around the boat
class('meter').extends(gfx.sprite)
function meter:init()
    meter.super.init(self)
    self:setImage(meter_image)
    self:moveTo(200, 120)
    self:setIgnoresDrawOffset(true)
    self:add()
end
function meter:update()
    change = playdate.getCrankChange()
    gfx.pushContext(meter_image)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, 130, 118)
        gfx.setColor(gfx.kColorBlack)
        if race_started == true then
            gfx.fillRect(0, 33, 50, rowbot_speed*2.5)
        end
        gfx.fillRect(80, 33, 50, change*2.5)
        meter_image:setMaskImage(img_meter_mask)
        img_meter:draw(0, 0)
    gfx.popContext()
    self:setImage(meter_image, gfx.kImageFlippedY)
end
local meter_sprite = meter()

-- Bottom-right UI junk
class('react').extends(gfx.sprite)
function react:init()
    react.super.init(self)
    self:setImage(img_react_test)
    self:moveTo(400, 240)
    self:setCenter(1, 1)
    self:setIgnoresDrawOffset(true)
    self:add()
end
local react_sprite = react()

-- Top-left UI junk
class('hud').extends(gfx.sprite)
function hud:init()
    hud.super.init(self)
    self:setImage(img_timer)
    self:moveTo(10, 10)
    self:setCenter(0, 0)
    self:setIgnoresDrawOffset(true)
    self:add()
end
function hud:update()
    gfx.setFont(timesnewrally)
    if race_started == true then
        elapsed_time += 1
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
local hud_sprite = hud()

class('countdown').extends(gfx.sprite)
function countdown:init()
    countdown.super.init(self)
    self:setImage(countdown_anim:image())
    self:setCenter(0, 0)
    self:setIgnoresDrawOffset(true)
    playdate.timer.performAfterDelay(3000, function() race_started = not race_started end)
    playdate.timer.performAfterDelay(3600, function() self:remove() end)
    self:add()
end
function countdown:update()
    self:setImage(countdown_anim:image())
end
local countdown_sprite = countdown()

local race_sprite = race()

-- Update!
function race:update()
end