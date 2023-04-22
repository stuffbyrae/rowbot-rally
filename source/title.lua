-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('title').extends(gfx.sprite)
function title:init()
    title.super.init(self)
    self:add()
end

function title:update()
end