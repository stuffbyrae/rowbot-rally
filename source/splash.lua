-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('splash').extends(gfx.sprite)
function splash:init()
    splash.super.init(self)
    self:add()
end

function splash:update()
end