import 'race'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('intro').extends(gfx.sprite) -- Create the scene's class
function intro:init(...)
    intro.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(200)
        menu:addMenuItem(text('quitfornow'), function()
            fademusic()
            title_memorize = 'story_mode'
            scenemanager:transitionsceneonewayback(title, title_memorize)
        end)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        kapel = gfx.font.new('fonts/kapel'),
        pedallica = gfx.font.new('fonts/pedallica'),
        image_a = gfx.image.new('images/ui/a'),
        image_gimmick_container = gfx.image.new('images/stages/gimmick_container'),
        image_gimmick_icons = gfx.imagetable.new('images/stages/gimmick_icons'),
        image_fade = gfx.imagetable.new('images/ui/fade_white/fade'),
        img_left = gfx.image.new(250, 150),
        img_bottom = gfx.image.new(400, 77),
        sfx_whoosh = smp.new('audio/sfx/whoosh'),
    }
    assets.sfx_whoosh:setVolume(save.vol_sfx/5)

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        stage = args[1],
        leaving = false,
        anim_left = pd.timer.new(400, -400, 0, pd.easingFunctions.outCubic),
        anim_right = pd.timer.new(400, 600, 400, pd.easingFunctions.outCubic),
        anim_bottom = pd.timer.new(300, 350, 235, pd.easingFunctions.outBack, 500),
        anim_fade = pd.timer.new(1, 34, 34),
    }
    vars.introHandlers = {
        AButtonDown = function()
            if not vars.leaving then
                self:leave()
            end
        end
    }
    pd.inputHandlers.push(vars.introHandlers)

    vars.anim_left.discardOnCompletion = false
    vars.anim_right.discardOnCompletion = false
    vars.anim_bottom.discardOnCompletion = false
    vars.anim_fade.discardOnCompletion = false

    save['slot' .. save.current_story_slot .. '_progress'] = "race" .. vars.stage

    assets.image_preview = gfx.image.new('images/stages/preview' .. vars.stage) -- Preview image table
    gfx.pushContext(assets.img_left) -- All the text that pops in from the left
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.kapel:drawText(text('stage') .. vars.stage .. " - " .. text('vs') .. text('stage_' .. vars.stage .. '_vs'), 10, 10)
        assets.kapel_doubleup:drawText(text('stage_' .. vars.stage .. '_name'), 10, 22)
        assets.pedallica:drawText(text('stage_' .. vars.stage .. '_desc'), 10, 65)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.popContext()

    gfx.pushContext(assets.img_bottom) -- All the guff that pops in from the bottom
        assets.image_a:drawAnchored(395, 75, 1, 1)
        assets.image_gimmick_container:drawAnchored(3, 77, 0, 1)
        assets.image_gimmick_icons:drawImage(vars.stage, 18,9)
        assets.kapel_doubleup:drawTextAligned(text('gimmick_' .. vars.stage .. '_name'), 160, 9, kTextAlignment.center)
        assets.pedallica:drawText(text('gimmick_' .. vars.stage .. '_desc'), 85, 34)
    gfx.popContext()

    class('intro_fade', _, classes).extends(gfx.sprite)
    function classes.intro_fade:init()
        classes.intro_fade.super.init(self)
        self:setImage(assets.image_fade[34])
        self:setCenter(0, 0)
        self:add()
    end
    function classes.intro_fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade.value)])
        end
    end

    class('intro_left', _, classes).extends(gfx.sprite)
    function classes.intro_left:init()
        classes.intro_left.super.init(self)
        self:setImage(assets.img_left)
        self:setCenter(0, 0)
        self:moveTo(-400, 0)
        self:add()
    end
    function classes.intro_left:update()
        if vars.anim_left ~= nil then
            self:moveTo(vars.anim_left.value, 0)
        end
    end

    class('intro_right', _, classes).extends(gfx.sprite)
    function classes.intro_right:init()
        classes.intro_right.super.init(self)
        self:setImage(assets.image_preview)
        self:setCenter(1, 0)
        self:moveTo(600, 0)
        self:add()
    end
    function classes.intro_right:update()
        if vars.anim_right ~= nil then
            self:moveTo(vars.anim_right.value, 0)
        end
    end

    class('intro_bottom', _, classes).extends(gfx.sprite)
    function classes.intro_bottom:init()
        classes.intro_bottom.super.init(self)
        self:setImage(assets.img_bottom)
        self:setCenter(0, 1)
        self:moveTo(0, 350)
        self:add()
    end
    function classes.intro_bottom:update()
        if vars.anim_left ~= nil then
            self:moveTo(0, vars.anim_bottom.value)
        end
    end

    -- Set the sprites
    sprites.fade = classes.intro_fade()
    sprites.left = classes.intro_left()
    sprites.right = classes.intro_right()
    sprites.bottom = classes.intro_bottom()
    self:add()

    newmusic('audio/music/intro') -- Adding new music
    savegame() -- Save the game!
end

function intro:leave()
    vars.leaving = true
    assets.sfx_whoosh:play()
    fademusic(250)
    vars.anim_left:resetnew(200, sprites.left.x, -400, pd.easingFunctions.inCubic)
    vars.anim_right:resetnew(200, sprites.right.x, 600, pd.easingFunctions.inCubic)
    vars.anim_bottom:resetnew(200, sprites.bottom.y, 350, pd.easingFunctions.inCubic)
    vars.anim_fade:resetnew(250, 34, 1)
    pd.timer.performAfterDelay(300, function()
        scenemanager:switchscene(race, vars.stage, "story", false)
    end)
end