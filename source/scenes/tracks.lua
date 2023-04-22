-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('tracks').extends(gfx.sprite)
function tracks:init()
    tracks.super.init(self)
end

function tracks:update()
end