local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)
function cutscene:init(...)
    cutscene.super.init(self)
    local args = {...}
    local play = args[1]
    local move = args[2]
    show_crank = false

    self:add()
end

function cutscene:update()
end