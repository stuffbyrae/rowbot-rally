-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Pictures!
local img_blank_plate = gfx.image.new('images/results/blank_plate') -- Plate background, a blank one as a backup
local img_win_plate = gfx.image.new('images/results/win_plate') -- Plate background for winning
local img_lose_plate = gfx.image.new('images/results/lose_plate') -- Plate background for losing
local img_tt_plate = gfx.image.new('images/results/tt_plate') -- Plate background for Time Trials race

local img_underlay = gfx.imagetable.new('images/screen_effects/fadetoblack70/fadetoblack70') -- Black fade for the race screen
local img_new_best = gfx.image.new('images/results/new_best') -- "New best!" graphic

local img_win_react = gfx.image.new('images/results/win_react') -- Reaction if you win,

local times_new_rally = gfx.font.new('fonts/times_new_rally') -- Regular timer font
local double_time = gfx.font.new('fonts/double_time') -- Big-boy timer font

class('results').extends(gfx.sprite)
function results:init(elapsed_time, lastraceimage)
    results.super.init(self)
    showcrankindicator = false

    local elapsed_time = elapsedtime

    local plate_anim = gfx.animator.new(500, -120, 120, pd.easingFunctions.outBack)
    local underlay_anim = gfx.animation.loop.new(66, img_underlay, false)
    local react_anim = gfx.animator.new(100, 480, 480)
    pd.timer.performAfterDelay(100, function() react_anim = gfx.animator.new(500, 480, 240, pd.easingFunctions.outQuad) end)

    local mins = string.format("%02.f", math.floor((elapsed_time/30) / 60))
    local secs = string.format("%02.f", math.floor((elapsed_time/30) - mins * 60))
    local mils = string.format("%02.f", (elapsed_time/30)*99 - mins * 5940 - secs * 99)

    local best_mins = string.format("%02.f", math.floor((stage_1_best_time/30) / 60))
    local best_secs = string.format("%02.f", math.floor((stage_1_best_time/30) - best_mins * 60))
    local best_mils = string.format("%02.f", (stage_1_best_time/30)*99 - best_mins * 5940 - best_secs * 99)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        gfx.fillRect(0, 0, 400, 240) -- Fill the background with black...
        if lastraceimage then lastraceimage:draw(0, 0) end -- ...and if we have a race screen, show that.
    end)

    class('underlay').extends(gfx.sprite)
    function underlay:init()
        underlay.super.init(self)
        self:moveTo(200, 120)
        self:add()
    end
    function underlay:update()
        self:setImage(underlay_anim:image())
    end
    underlay = underlay()
    
    class('plate').extends(gfx.sprite) -- Results plate
    function plate:init()
        plate.super.init(self)
        self:moveTo(200, 120)
        self:add()
        local plate_image = gfx.image.new(373, 208)
        gfx.pushContext(plate_image)
            img_win_plate:draw(0, 0)
            gfx.setFont(double_time)
            img_new_best:draw(155, 65)
            gfx.drawTextAligned("O "..mins..":"..secs.."."..mils, 245, 95, kTextAlignment.center)
            gfx.setFont(times_new_rally)
            gfx.drawTextAligned("D "..best_mins..":"..best_secs.."."..best_mils, 245, 130, kTextAlignment.center)
        gfx.popContext()
        self:setImage(plate_image)
    end
    function plate:update()
        self:moveTo(200, plate_anim:currentValue())
    end
    plate = plate()

    class('react').extends(gfx.sprite)
    function react:init()
        react.super.init(self)
        self:setCenter(0, 1)
        self:moveTo(0, 240)
        self:setImage(img_win_react)
        self:add()
    end
    function react:update()
        self:moveTo(0, react_anim:currentValue())
    end
    react = react()

    self:add()
end

function pd.AButtonDown()
end

function results:update()
end