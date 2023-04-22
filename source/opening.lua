-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Let's set this thing up.
class('opening').extends(gfx.sprite)
function opening:init()
    opening.super.init(self)

    -- Defining thingies...
    img_opening = gfx.imagetable.new('images/story/opening')
    opening_progress = 1
    finished = false
    fading = true
    img_black = gfx.image.new(370, 212, gfx.kColorBlack)
    fade_anim = gfx.animator.new(1000, 1, 0)
    
    -- Make sure the fading stops after the animation's done, or else it'll keep refreshing for nothing
    pd.timer.performAfterDelay(1000, function() if finished == false then fading = false end end)

    -- Draw the image! Simple enough.
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        img_opening:drawImage(opening_progress, 0, 0)
    end)

    -- Making the sprite that fades the screen in and out
    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:setCenter(1, 1)
        self:moveTo(393, 235)
        self:add()
    end
    function fade:update()
        if fading == true then self:setImage(img_black:fadedImage(fade_anim:currentValue(), gfx.image.kDitherTypeBayer8x8)) end
    end
    fade = fade()

    -- Wrapping stuff up
    function finish()
        finished = true
        fading = true
        fade_anim = gfx.animator.new(1000, 0, 1)
        pd.timer.performAfterDelay(1000, function() scenemanager:switchscene(cutscene) end)
    end

    self:add()
end

-- Update!!
function opening:update()
    -- When the A button's pressed, progress through the table.
    function pd.AButtonDown()
        if opening_progress <= img_opening:getLength() then
            opening_progress += 1
            gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
                img_opening:drawImage(opening_progress, 0, 0)
            end)
        -- ...and if there's nothing else to do, wrap it up.
        elseif finished == false then
            finish()
        end
    end
end