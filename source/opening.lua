-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('opening').extends(gfx.sprite) -- Create the scene's class
function opening:init(...)
    opening.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if not vars.arg_title then -- If this isn't the first total viewing of it...
            menu:addMenuItem(gfx.getLocalizedText('backtotitle'), function() -- then let the player skip.
                if not vars.leaving then -- Make sure they're not already leaving, that'd screw something up.
                    self:leave() -- If they aren't, then they can go.
                end
            end)
        end
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        image_opening = gfx.imagetable.new('images/story/opening'),
        image_a = gfx.image.new('images/ui/a'),
        pedallica = gfx.font.new('fonts/pedallica')
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        arg_title = args[1], -- A boolean. If this is true, transition into title screen. Otherwise, move to first story cutscene.
        leaving = false,
        anim_fade = gfx.animator.new(2500, 1, 34, pd.easingFunctions.outCubic),
        progress = 1,
    }
    vars.openingHandlers = {
        AButtonDown = function()
            self:progress()
        end
    }
    pd.inputHandlers.push(vars.openingHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_a:drawAnchored(395, 235, 1, 1)
    end)

    class('content').extends(gfx.sprite)
    function content:init()
        content.super.init(self)
        self:setCenter(0, 0)
        self:add()
    end

    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:setImage(assets.image_fade[1])
        self:setCenter(0, 0)
        self:setZIndex(9)
        self:add()
    end
    function fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade:currentValue())])
        end
    end

    -- Set the sprites
    self.content = content()
    self.fade = fade()
    self:add()

    self:newcontent(vars.progress)
end

function opening:progress()
    vars.progress += 1
    if vars.progress <= 7 then
        self:newcontent(vars.progress)
    else
        self:leave()
    end
end

function opening:newcontent(progress) -- Progress the scene when the user presses A.
    assets.img_content = gfx.image.new(400, 240) -- Create a new image...
    gfx.pushContext(assets.img_content) -- Now let's draw stuff to it!
        if assets.image_opening[math.ceil(progress/2)] ~= nil then -- If there's an image to be drawn,
            assets.image_opening[math.ceil(progress/2)]:drawAnchored(200, 20, 0.5, 0) -- draw it. (Every image shows up for two scenes, so ceiling-ing the progress number and divvying it by 2 shows them properly.)
        end
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Draw this text in white.
        if progress < 7 then -- If it has an associated image displaying alongside it...
            assets.pedallica:drawTextAligned(gfx.getLocalizedText('opening_' .. progress), 200, 145, kTextAlignment.center) -- Shift it down a bit.
        else -- Otherwise,
            assets.pedallica:drawTextAligned(gfx.getLocalizedText('opening_' .. progress), 200, 120, kTextAlignment.center) -- show it right in the middle.
        end
        gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Let me just put this spork over here.
    gfx.popContext() -- We're done here.
    self.content:setImage(assets.img_content) -- Give the sprite that image!
end

function opening:leave()
    if not vars.leaving then
        vars.leaving = true
        vars.anim_fade = gfx.animator.new(1000, math.floor(vars.anim_fade:currentValue()), 0)
        pd.timer.performAfterDelay(1000, function()
            if vars.arg_title then
                scenemanager:switchscene(title)
            else
                scenemanager:switchscene(cutscene, 1, true)
            end
        end)
    end
end