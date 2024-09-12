import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local min <const> = math.min
local max <const> = math.max
local text <const> = gfx.getLocalizedText

class('chill').extends(gfx.sprite) -- Create the scene's class
function chill:init(...)
    chill.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    pd.setAutoLockDisabled(true)

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addCheckmarkMenuItem(text('music'), vars.music, function(new)
            vars.music = new
            if new then
                save.vol_music = 5
                newmusic('audio/music/chill', true) -- Adding new music
            else
                fademusic(1)
                save.vol_music = 0
            end
        end)
        menu:addCheckmarkMenuItem(text('autolock'), vars.lock, function(new)
            vars.lock = new
            if new then
                pd.setAutoLockDisabled(true)
            else
                pd.setAutoLockDisabled(false)
            end
        end)
        menu:addMenuItem(text('backtotitle'), function()
            self:leave()
        end)
        setpauseimage(0)
    end

    function pd.gameWillResume()
        self:checktime()
    end

    function pd.deviceDidUnlock()
        self:checktime()
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        bg = gfx.imagetable.new('images/story/chill-bg'),
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        image_boat = gfx.image.new('images/stages/boat'),
        image_wave = gfx.image.new('images/ui/wave'),
        sfx_sea = smp.new('audio/sfx/sea'),
        image_wave_composite = gfx.image.new(464, 280),
    }
    assets.sfx_sea:setVolume(save.vol_sfx/5)
    assets.sfx_sea:play(0)

    -- Writing in the image for the wave banner along the bottom
    gfx.pushContext(assets.image_wave_composite)
        assets.image_wave:drawTiled(0, 0, 464, 280)
    gfx.popContext()

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        anim_wave_x = pd.timer.new(5000, 0, -58),
        anim_boat_y = pd.timer.new(2500, 175, 180, pd.easingFunctions.inOutCubic),
        bg_image = 1,
        leaving = false,
        anim_fade = pd.timer.new(1000, 1, 34, pd.easingFunctions.outCubic),
        lock = false,
    }
    vars.chillHandlers = {
        BButtonDown = function()
            self:leave()
        end
    }
    pd.inputHandlers.push(vars.chillHandlers)

    vars.anim_wave_x.repeats = true
    vars.anim_boat_y.repeats = true
    vars.anim_boat_y.reverses = true
    vars.anim_fade.discardOnCompletion = false

    vars.update_timer = pd.timer.new(300000, function()
        self:checktime()
        gfx.sprite.redrawBackground()
    end)
    vars.update_timer.repeats = true

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.bg:drawImage(vars.bg_image, 0, 0)
    end)

    class('chill_wave').extends(gfx.sprite)
    function chill_wave:init()
        chill_wave.super.init(self)
        self:setImage(assets.image_wave_composite)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:moveTo(0, 205)
        self:setZIndex(0)
        self:add()
    end
    function chill_wave:update()
        self:moveTo(vars.anim_wave_x.value, 205)
    end

    class('chill_boat').extends(gfx.sprite)
    function chill_boat:init()
        chill_boat.super.init(self)
        self:setImage(assets.image_boat)
        self:moveTo(45, 195)
        self:setZIndex(1)
        self:add()
    end
    function chill_boat:update()
        self:moveTo(65, vars.anim_boat_y.value)
    end

    class('chill_fade').extends(gfx.sprite)
    function chill_fade:init()
        chill_fade.super.init(self)
        self:setImage(assets.image_fade[1])
        self:setCenter(0, 0)
        self:setZIndex(9)
        self:add()
    end
    function chill_fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade.value)])
        end
    end

    -- Set the sprites
    sprites.wave = chill_wave()
    sprites.boat = chill_boat()
    sprites.fade = chill_fade()
    self:add()

    self:checktime()

    if save.vol_music ~= 0 then
        vars.music = true
        newmusic('audio/music/chill', true) -- Adding new music
    else
        vars.music = false
    end
end

function chill:checktime()
    local time = pd.getTime()
    local hour = time.hour
    if max(4, min(5, hour)) == hour then
        vars.bg_image = 2
    elseif max(6, min(7, hour)) == hour then
        vars.bg_image = 3
    elseif max(8, min(12, hour)) == hour then
        vars.bg_image = 4
    elseif max(13, min(16, hour)) == hour then
        vars.bg_image = 5
    elseif max(17, min(19, hour)) == hour then
        vars.bg_image = 6
    elseif hour == 20 then
        vars.bg_image = 7
    elseif max(21, min(22, hour)) == hour then
        vars.bg_image = 8
    else
        vars.bg_image = 1
    end
end

function chill:leave()
    if not vars.leaving then
        vars.leaving = true
        vars.anim_fade:resetnew(1000, math.floor(vars.anim_fade.value), 1)
        fademusic(999)
        assets.sfx_sea:stop()
        vars.anim_fade.timerEndedCallback = function()
            pd.setAutoLockDisabled(false)
            scenemanager:switchscene(title, title_memorize)
        end
    end
end