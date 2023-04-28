-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)
function cutscene:init()
    cutscene.super.init(self)
    local img_test = gfx.imagetable.new('images/story/cutscene1/cutscene')
    anim = gfx.animation.loop.new(125, img_test, true)
    self:add()
    class('test').extends(gfx.sprite)
    function test:init()
        test.super.init(self)
        self:setCenter(0, 0)
        self:add()
    end
    function test:update()
        self:setImage(anim:image())
    end
    test = test()
end

function cutscene:update()
end