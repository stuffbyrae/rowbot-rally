local pd <const> = playdate
local gfx <const> = pd.graphics

class('credits').extends(gfx.sprite)
function credits:init(...)
    credits.super.init(self)
    local args = {...}
    show_crank = false
    
    self:add()
end

function credits:update()
end