-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)
function cutscene:init()
    cutscene.super.init(self)
    self:add()
end

function cutscene:update()
end