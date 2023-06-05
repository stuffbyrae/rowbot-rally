local pd <const> = playdate
local gfx <const> = pd.graphics

class('intro').extends(gfx.sprite)
function intro:init(...)
    intro.super.init(self)
    args = {...}
    local track = args[1]
    show_crank = false
    
    self:add()
end

function intro:update()
end