-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('settings').extends(gfx.sprite)
function settings:init()
    settings.super.init(self)
end

function settings:update()
end