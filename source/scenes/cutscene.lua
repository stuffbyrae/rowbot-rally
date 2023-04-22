-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)
function cutscene:init()
    cutscene.super.init(self)
end

function cutscene:update()
end