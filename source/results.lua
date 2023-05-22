local pd <const> = playdate
local gfx <const> = pd.graphics

class('results').extends(gfx.sprite)
function results:init(...)
    results.super.init(self)
    local args = {...}
    show_crank = false
    
    self:add()
end

function results:update()
end