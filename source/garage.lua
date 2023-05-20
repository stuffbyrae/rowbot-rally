-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

local img_bg = gfx.image.new('images/garage/bg')
local img_raft = gfx.imagetable.new('images/garage/raft/raft')
local img_hover = gfx.imagetable.new('images/garage/hover/hover')
local img_gold = gfx.imagetable.new('images/garage/gold/gold')
local img_surf = gfx.imagetable.new('images/garage/surf/surf')
local img_classic = gfx.imagetable.new('images/garage/classic/classic')
local img_pro = gfx.imagetable.new('images/garage/pro/pro')
local img_swan = gfx.imagetable.new('images/garage/swan/swan')
local boat_anim = gfx.animation.loop.new(10, img_hover, true)

class('garage').extends(gfx.sprite)
function garage:init()
    garage.super.init(self)
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        img_bg:draw(0, 0)
    end)
    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:moveTo(200, 120)
        self:add()
    end
    function boat:update()
        self:setImage(boat_anim:image())
    end
    boat = boat()
    self:add()
end

function garage:update()
end