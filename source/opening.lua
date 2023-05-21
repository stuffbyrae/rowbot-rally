local pd <const> = playdate
local gfx <const> = pd.graphics

class('opening').extends(gfx.sprite)
function opening:init()
    opening.super.init(self)
    self:add()
end

function opening:update()
end