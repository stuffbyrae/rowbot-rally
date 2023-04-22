-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

local finished = false
local fading = true

local img_black = gfx.image.new(370, 212, gfx.kColorBlack)
local fade_anim = gfx.animator.new(1000, 1, 0)

local img_opening = gfx.imagetable.new('images/story/opening')
local opening_progress = 1

class('opening').extends(gfx.sprite)
function opening:init()
    opening.super.init(self)
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        img_opening:drawImage(opening_progress, 0, 0)
    end)
    pd.timer.performAfterDelay(1000, function() if finished == false then fading = false end end)
    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:setCenter(1, 1)
        self:moveTo(393, 235)
        self:add()
    end
    spr_fade = fade()
    function fade:update()
        if fading == true then
            self:setImage(img_black:fadedImage(fade_anim:currentValue(), gfx.image.kDitherTypeBayer8x8))
        end
    end
end

function finish()
    finished = true
    fading = true
    fade_anim = gfx.animator.new(1000, 0, 1)
end

function pd.AButtonDown()
    if opening_progress <= 5 then
        opening_progress += 1
        gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
            img_opening:drawImage(opening_progress, 0, 0)
        end)
    elseif finished == false then
        finish()
    end
end