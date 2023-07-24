local pd <const> = playdate
local gfx <const> = pd.graphics

class('intro').extends(gfx.sprite)
function intro:init(...)
    intro.super.init(self)
    args = {...}
    show_crank = false
    
    assets = {
        
    }
    
    vars = {
        arg_track = args[1] -- 1 through 7
    }

    self:add()
end

function intro:update()
end