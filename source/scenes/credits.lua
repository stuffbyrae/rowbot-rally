-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('credits').extends(gfx.sprite)
function credits:init()
    credits.super.init(self)
end

function credits:update()
end