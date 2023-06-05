local pd <const> = playdate
local gfx <const> = pd.graphics

class('chase').extends(gfx.sprite)
function chase:init()
    chase.super.init(self)
    show_crank = true
    
    self:add()
end

function chase:update()
end