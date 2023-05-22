local pd <const> = playdate
local gfx <const> = pd.graphics

class('tracks').extends(gfx.sprite)
function tracks:init(...)
    tracks.super.init(self)
    local args = {...}
    show_crank = false

    self:add()
end

function tracks:update()
end