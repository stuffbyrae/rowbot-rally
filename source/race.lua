-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Defining some variables we'll need later
local rowbot_speed = 8
local boat_rotation = 0

local rowbot_oar_anim = 1
local player_oar_anim = 1

local time_elapsed = 0
local time_limit = 600 * 30

-- Import all the images!!!!1!
local img_meter = gfx.image.new('images/meter')
local img_meter_mask = gfx.image.new('images/meter_mask')
local meter_image = gfx.image.new(130, 118)

local img_boat_wooden = gfx.image.new('images/boat_wooden')
local img_oar = gfx.imagetable.new('images/oar/oar')
local boat_image = gfx.image.new(107, 65)

local img_track_test_col = gfx.image.new('images/track_test_col')
local img_track_test_bg = gfx.image.new('images/track_test_bg')
local img_track_test_fg = gfx.image.new('images/track_test_fg')

local img_react_test = gfx.image.new('images/react_test')
local img_timer = gfx.image.new('images/timer')

-- Racism
class('race').extends(gfx.sprite)
function race:init()
    race.super.init(self)
end

-- The track's collision sprite
class('track_col').extends(gfx.sprite)
function track_col:init()
    track_col.super.init(self)
    self:setImage(img_track_test_col)
    self:moveTo(650, 0)
    self:setCollideRect(0, 0, self:getSize())
    self:add()
end

-- The track sprite
class('track_bg').extends(gfx.sprite)
function track_bg:init()
    track_bg.super.init(self)
    self:setImage(img_track_test_bg)
    self:moveTo(650, 0)
    self:add()
end

-- The bote! :)
class('boat').extends(gfx.sprite)
function boat:init()
    boat.super.init(self)
    self:setImage(boat_image)
    self:moveTo(200, 120)
    self:setCollideRect(0, 0, 5, 5)
    self:add()
end
function boat:update()
    change = playdate.getCrankChange()

    rowbot_oar_anim += 0.1 * rowbot_speed
    if rowbot_oar_anim > 22 then rowbot_oar_anim = 1 end
    player_oar_anim += 0.1 * change
    if player_oar_anim > 22 then player_oar_anim = 1 end
    if player_oar_anim < 1 then player_oar_anim = 1 end

    boat_rotation -= rowbot_speed
    if change > 0 then
        boat_rotation += change
    end
    self:setRotation(boat_rotation)
    local boat_image = gfx.image.new(107, 65)
    gfx.pushContext(boat_image)
        img_oar:drawImage(math.floor(rowbot_oar_anim), 5, 15)
        img_oar:drawImage(math.floor(player_oar_anim), 66, 15, gfx.kImageFlippedX)
        img_boat_wooden:draw(36, 0)
    gfx.popContext()
    self:setImage(boat_image)
    self:moveBy(math.sin(math.rad(boat_rotation))*4, math.cos(math.rad(boat_rotation))*-4)
    gfx.setDrawOffset(-self.x+200, -self.y+120)
end

-- The foreground track elements
class('track_fg').extends(gfx.sprite)
function track_fg:init()
    track_fg.super.init(self)
    self:setImage(img_track_test_fg)
    self:moveTo(650, 0)
    self:add()
end

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
        gfx.fillRect(0, 33, 50, rowbot_speed*2.5)
        gfx.fillRect(80, 33, 50, change*2.5)
        meter_image:setMaskImage(img_meter_mask)
        img_meter:draw(0, 0)
    gfx.popContext()
    self:setImage(meter_image, gfx.kImageFlippedY)
end

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

-- Top-left UI junk
class('timer').extends(gfx.sprite)
function timer:init()
    timer.super.init(self)
    self:setImage(img_timer)
    self:moveTo(10, 10)
    self:setCenter(0, 0)
    self:setIgnoresDrawOffset(true)
    self:add()
end

-- aaaaaaaaaaaaaaaaaagh
local track_col_sprite = track_col()
local track_bg_sprite = track_bg()
local boat_sprite = boat()
local track_fg_sprite = track_fg()
local meter_sprite = meter()
local react_sprite = react()
local timer_sprite = timer()

local race_sprite = race()

-- Update!
function race:update()
    time_elapsed += 1
    if time_elapsed > time_limit then
        -- Write some code that stops you for "TIME UP!!"
    end
    print(math.floor((time_limit - time_elapsed) / 30))
end