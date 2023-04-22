-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('garage').extends(gfx.sprite)
function garage:init()
    garage.super.init(self)
    self:add()
end

function garage:update()
end