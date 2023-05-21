local pd <const> = playdate
local gfx <const> = pd.graphics

class('race').extends(gfx.sprite)
function race:init()
    race.super.init(self)
    self:add()
end

function race:update()
end