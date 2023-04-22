-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('intro').extends(gfx.sprite)
function intro:init()
    intro.super.init(self)
    self:add()
end

function intro:update()
end