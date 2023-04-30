-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('results').extends(gfx.sprite)
function results:init()
    results.super.init(self)
    gfx.sprite.setBackgroundDrawingCallback(function(s, y, width, height)
        lastraceimage:drawFaded(0, 0, 0.5, gfx.image.kDitherTypeBayer8x8)
    end)
    self:add()
end

function results:update()
end