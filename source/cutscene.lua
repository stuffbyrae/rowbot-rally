-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)
function cutscene:init()
    cutscene.super.init(self)
    local img_border = gfx.imagetable.new('images/story/border')
    local img_cutscene = gfx.imagetable.new('images/story/cutscene1/cutscene')
    border_anim = gfx.animation.loop.new(330, img_border, true)
    cutscene_anim = gfx.animation.loop.new(83, img_cutscene, true)

    class('cutscene_player').extends(gfx.sprite)
    function cutscene_player:init()
        cutscene_player.super.init(self)
        self:moveTo(200, 120)
        self:add()
    end
    function cutscene_player:update()
        self:setImage(cutscene_anim:image())
    end
    cutscene_player = cutscene_player()

    class('border').extends(gfx.sprite)
    function border:init()
        border.super.init(self)
        self:moveTo(200, 120)
        self:add()
    end
    function border:update()
        self:setImage(border_anim:image())
    end
    border = border()

    self:add()
end

function cutscene:update()
end