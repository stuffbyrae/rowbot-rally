import 'cutscene'
import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer

class('opening').extends(gfx.sprite) -- Create the scene's class
function opening:init(...)
    opening.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local pauseimage = gfx.image.new(400, 240)
        pd.setMenuImage(pauseimage, 100)
        menu:addMenuItem(gfx.getLocalizedText('skipscene'), function()
            self:leave()
        end)
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        image_opening = gfx.imagetable.new('images/story/opening'),
        image_a = gfx.image.new('images/ui/a'),
        pedallica = gfx.font.new('fonts/pedallica'),
        sfx_clickon = smp.new('audio/sfx/clickon'),
        sfx_clickoff = smp.new('audio/sfx/clickoff'),
    }
    assets.sfx_clickon:setVolume(save.vol_sfx/5)
    assets.sfx_clickoff:setVolume(save.vol_sfx/5)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        title = args[1],
        leaving = false,
        anim_fade = pd.timer.new(2500, 1, 34, pd.easingFunctions.outCubic),
        progress = 1,
    }
    vars.openingHandlers = {
        AButtonDown = function()
            self.a:moveTo(395, 240)
            assets.sfx_clickon:play()
        end,
        
        AButtonUp = function()
            self:progress()
            self.a:moveTo(395, 235)
            assets.sfx_clickoff:play()
        end
    }
    pd.inputHandlers.push(vars.openingHandlers)

    class('opening_content').extends(gfx.sprite)
    function opening_content:init()
        opening_content.super.init(self)
        self:setCenter(0, 0)
        self:add()
    end

    class('opening_a').extends(gfx.sprite)
    function opening_a:init()
        opening_a.super.init(self)
        self:setImage(assets.image_a)
        self:setCenter(1, 1)
        self:moveTo(395, 235)
        self:add()
    end

    class('opening_fade').extends(gfx.sprite)
    function opening_fade:init()
        opening_fade.super.init(self)
        self:setImage(assets.image_fade[1])
        self:setCenter(0, 0)
        self:setZIndex(9)
        self:add()
    end
    function opening_fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade.value)])
        end
    end

    -- Set the sprites
    self.content = opening_content()
    self.a = opening_a()
    self.fade = opening_fade()
    self:add()

    self:newcontent(vars.progress)

    newmusic('audio/music/opening', true, 0) -- Adding new music
end

function opening:progress()
    if not vars.leaving then
        vars.progress += 1
        if vars.progress <= 7 then
            self:newcontent(vars.progress)
        else
            self:leave()
        end
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
        fademusic(999)
        vars.anim_fade = pd.timer.new(1000, math.floor(vars.anim_fade.value), 0)
        vars.anim_fade.timerEndedCallback = function()
            if vars.title then
                scenemanager:switchscene(title)
            else
                save['slot' .. save.current_story_slot .. '_progress'] = 'cutscene1'
                scenemanager:switchstory()
            end
        end
    end
end