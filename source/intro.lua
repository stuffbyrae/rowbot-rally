import 'race'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer

class('intro').extends(gfx.sprite) -- Create the scene's class
function intro:init(...)
    intro.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        kapel = gfx.font.new('fonts/kapel'),
        pedallica = gfx.font.new('fonts/pedallica'),
        image_a = gfx.image.new('images/ui/a'),
        image_gimmick_container = gfx.image.new('images/stages/gimmick_container'),
        image_gimmick_icons = gfx.imagetable.new('images/stages/gimmick_icons'),
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        img_left = gfx.image.new(250, 150),
        img_bottom = gfx.image.new(400, 73),
        sfx_whoosh = smp.new('audio/sfx/whoosh'),
    }
    assets.sfx_whoosh:setVolume(save.vol_sfx/5)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        stage = args[1],
        leaving = false,
        anim_left = gfx.animator.new(400, -400, 0, pd.easingFunctions.outCubic),
        anim_right = gfx.animator.new(400, 600, 400, pd.easingFunctions.outCubic),
        anim_bottom = gfx.animator.new(300, 350, 235, pd.easingFunctions.outBack, 500),
    }
    vars.introHandlers = {
        AButtonDown = function()
            if not vars.leaving then
                self:leave()
            end
        end
    }
    pd.inputHandlers.push(vars.introHandlers)

    save['slot' .. save.current_story_slot .. '_progress'] = "race" .. vars.stage
    
    assets.image_preview = gfx.image.new('images/stages/preview' .. vars.stage) -- Preview image table
    gfx.pushContext(assets.img_left) -- All the text that pops in from the left
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.kapel:drawText(gfx.getLocalizedText('stage') .. vars.stage .. " - " .. gfx.getLocalizedText('vs') .. gfx.getLocalizedText('stage_' .. vars.stage .. '_vs'), 10, 10)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stage_' .. vars.stage .. '_name'), 10, 22)
        assets.pedallica:drawText(gfx.getLocalizedText('stage_' .. vars.stage .. '_desc'), 10, 65)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.popContext()

    gfx.pushContext(assets.img_bottom) -- All the guff that pops in from the bottom
        assets.image_a:drawAnchored(395, 73, 1, 1)
        assets.image_gimmick_container:drawAnchored(5, 73, 0, 1)
        assets.image_gimmick_icons:drawImage(vars.stage, 18, 7)
        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('gimmick_' .. vars.stage .. '_name'), 160, 7, kTextAlignment.center)
        assets.pedallica:drawText(gfx.getLocalizedText('gimmick_' .. vars.stage .. '_desc'), 85, 32)
    gfx.popContext()

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
    end)

    class('intro_fade').extends(gfx.sprite)
    function intro_fade:init()
        intro_fade.super.init(self)
        self:setImage(assets.image_fade[1])
        self:setCenter(0, 0)
        self:add()
    end
    function intro_fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade:currentValue())])
        end
    end

    class('intro_left').extends(gfx.sprite)
    function intro_left:init()
        intro_left.super.init(self)
        self:setImage(assets.img_left)
        self:setCenter(0, 0)
        self:moveTo(-400, 0)
        self:add()
    end
    function intro_left:update()
        if vars.anim_left ~= nil then
            self:moveTo(vars.anim_left:currentValue(), 0)
        end
    end

    class('intro_right').extends(gfx.sprite)
    function intro_right:init()
        intro_right.super.init(self)
        self:setImage(assets.image_preview)
        self:setCenter(1, 0)
        self:moveTo(600, 0)
        self:add()
    end
    function intro_right:update()
        if vars.anim_right ~= nil then
            self:moveTo(vars.anim_right:currentValue(), 0)
        end
    end

    class('intro_bottom').extends(gfx.sprite)
    function intro_bottom:init()
        intro_bottom.super.init(self)
        self:setImage(assets.img_bottom)
        self:setCenter(0, 1)
        self:moveTo(0, 350)
        self:add()
    end
    function intro_bottom:update()
        if vars.anim_left ~= nil then
            self:moveTo(0, vars.anim_bottom:currentValue())
        end
    end

    -- Set the sprites
    self.fade = intro_fade()
    self.left = intro_left()
    self.right = intro_right()
    self.bottom = intro_bottom()
    self:add()

    newmusic('audio/music/intro') -- Adding new music
end

function intro:leave()
    vars.leaving = true
    assets.sfx_whoosh:play()
    vars.anim_left = gfx.animator.new(200, self.left.x, -400, pd.easingFunctions.inCubic)
    vars.anim_right = gfx.animator.new(200, self.right.x, 600, pd.easingFunctions.inCubic)
    vars.anim_bottom = gfx.animator.new(200, self.bottom.y, 350, pd.easingFunctions.inCubic)
    vars.anim_fade = gfx.animator.new(300, 1, 34)
    pd.timer.performAfterDelay(201, function()
        scenemanager:switchscene(race, vars.stage, "story")
    end)
end