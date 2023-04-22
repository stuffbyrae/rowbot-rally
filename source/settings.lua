-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('settings').extends(gfx.sprite)
function settings:init()
    settings.super.init(self)
    self:add()
end

function settings:update()
end