import 'title'
import 'cutscene'
import 'boat'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry

class('tutorial').extends(gfx.sprite) -- Create the scene's class
function tutorial:init(...)
    tutorial.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem(gfx.getLocalizedText('skiptutorial'), function()
            self:leave()
        end)
        menu:addMenuItem(gfx.getLocalizedText('quitfornow'), function()
            self.boat.sfx_row:stop()
            scenemanager:transitionsceneonewayback(title)
        end)
        setpauseimage(200) -- TODO: Set this X offset
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/stages/water_bg'),
        image_water = gfx.image.new('images/race/stages/water'),
        image_meter = gfx.image.new('images/race/meter'),
        image_popup_banner = gfx.image.new('images/ui/popup_banner'),
        pedallica = gfx.font.new('fonts/pedallica'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        overlay_fade = gfx.imagetable.new('images/ui/fade/fade'),
        sfx_ref = smp.new('audio/sfx/ref'),
        sfx_ui = smp.new('audio/sfx/ui'),
        sfx_clickon = smp.new('audio/sfx/clickon'),
        sfx_clickoff = smp.new('audio/sfx/clickoff'),
        image_a = gfx.image.new('images/ui/a'),
        image_tutorial_crank = gfx.image.new('images/ui/tutorial_crank'),
        image_tutorial_up = gfx.image.new('images/ui/tutorial_up'),
    }
    assets.sfx_ref:setVolume(save.vol_sfx/5)
    assets.sfx_ui:setVolume(save.vol_sfx/5)
    assets.sfx_clickon:setVolume(save.vol_sfx/5)
    assets.sfx_clickoff:setVolume(save.vol_sfx/5)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        current_step = 1,
        progressable = false,
        hud_open = false,
        progress_delay = 1500,
        gameplay_progress = 0,
        up = pd.timer.new(500, 0, 10, pd.easingFunctions.inSine)
    }
    vars.tutorialHandlers = {
        AButtonDown = function()
            self:progress()
        end,
        upButtonDown = function()
            self.boat.straight = true
        end,
        upButtonUp = function()
            self.boat.straight = false
        end,
        rightButtonDown = function()
            self.boat.right = true
        end,
        rightButtonUp = function()
            self.boat.right = false
        end
    }
    pd.inputHandlers.push(vars.tutorialHandlers)
    
    vars.up.repeats = true
    vars.up.reverses = true
    vars.up.reverseEasingFunction = pd.easingFunctions.outBack

    -- Show HUD no matter what Pro says. Power Meter is important
    vars.anim_hud = pd.timer.new(0, -130, -130)

    -- TODO: add stage and stagefg images. They gotta get made first!

    vars.anim_overlay = pd.timer.new(1000, 1, #assets.overlay_fade)
    vars.finish = gfx.sprite.addEmptyCollisionSprite(1, 1, 1, 1)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('tutorial_water').extends(gfx.sprite)
    function tutorial_water:init()
        tutorial_water.super.init(self)
        self:setImage(assets.image_water)
        self:setIgnoresDrawOffset(true)
        self:setZIndex(-4)
        self:add()
    end

    class('tutorial_stage').extends(gfx.sprite)
    function tutorial_stage:init()
        tutorial_stage.super.init(self)
        self:setZIndex(-3)
        self:setCenter(0, 0)
        self:setImage(assets.image_stage)
    end

    class('tutorial_stage_fg').extends(gfx.sprite)
    function tutorial_stage_fg:init()
        tutorial_stage_fg.super.init(self)
        self:setZIndex(1)
        self:setCenter(0, 0)
        self:setImage(assets.image_stagefg)
    end

    class('tutorial_hud').extends(gfx.sprite)
    function tutorial_hud:init()
        tutorial_hud.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:setSize(400, 240)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function tutorial_hud:draw()
        if vars.hud_open then
            assets.image_popup_banner:draw(0, 0)
            if vars.current_step == 6 then
                if not save.button_controls and pd.isSimulator ~= 1 then
                    if pd.isCrankDocked() then
                        assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_6c'), 200, 14, kTextAlignment.center)
                    else
                        assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_6a'), 200, 14, kTextAlignment.center)
                    end
                else
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_6b'), 200, 14, kTextAlignment.center)
                end
            elseif vars.current_step == 14 then
                assets.image_tutorial_up:draw(10, 80 + vars.up.value)
                assets.kapel_doubleup:drawText('Up!!', 30, 103 + vars.up.value)
                if not save.button_controls and pd.isSimulator ~= 1 then
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_14a'), 200, 14, kTextAlignment.center)
                else
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_14b'), 200, 14, kTextAlignment.center)
                end
            else
                assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_' .. vars.current_step), 200, 14, kTextAlignment.center)
            end
            if vars.progressable then
                assets.image_a:draw(340, 50)
            end
        end
        -- Draw the power meter
        assets.image_meter:draw(0, 177 - vars.anim_hud.value)
        gfx.setLineWidth(8)
        if vars.rowbot > 0 then
            gfx.drawArc(200, 380 - vars.anim_hud.value, 160, math.clamp(32 - vars.player * 2.2, 3, 32), 328 + (vars.rowbot * 15))
        end
        gfx.setLineWidth(2)
        -- If there's some kind of gameplay overlay anim going on, play it.
        if vars.anim_overlay ~= nil then
            assets['overlay_fade']:drawImage(math.floor(vars.anim_overlay.value), 0, 0)
        end
    end

    -- Set the sprites
    self.water = tutorial_water()
    self.stage = tutorial_stage()
    self.boat = boat(0, 0, false)
    self.stage_fg = tutorial_stage_fg()
    self.hud = tutorial_hud()
    self:add()

    pd.timer.performAfterDelay(1500, function()
        vars.hud_open = true
        pd.timer.performAfterDelay(vars.progress_delay, function()
            vars.progressable = true
        end)
    end)

    newmusic('audio/sfx/sea', true)
end

function tutorial:progress()
    if vars.progressable then
        assets.sfx_clickon:play()
        vars.hud_open = false
        vars.current_step += 1
        vars.progressable = false
        if vars.current_step == 3 then
            -- Turn rowbot on, play SFX
            self.boat:state(true, true, false)
            self.boat:start()
        elseif vars.current_step == 6 then
            -- Turn on player turning, check for any rowing
            self.boat:state(true, true, true)
        elseif vars.current_step == 7 then
            -- Turn off player turning
            self.boat:state(true, true, false)
        elseif vars.current_step == 8 then
            -- Roll in power meter, play SFX
            vars.anim_hud = pd.timer.new(750, -130, 0, pd.easingFunctions.outSine)
            assets.sfx_ui:play()
        elseif vars.current_step == 14 then
            -- Turn player turning back on, check for straight line
            self.boat:state(true, true, true)
        elseif vars.current_step == 15 then
            -- Add in course just above player
            -- Add in nets
        end
        if vars.current_step <= 15 then -- If there's more progression, then show the new UI.
            if vars.current_step == 3 or vars.current_step == 8 then -- If you're just turning the Rowbot on, then give it some more time.
                pd.timer.performAfterDelay(vars.progress_delay, function()
                    assets.sfx_clickoff:play()
                    vars.hud_open = true
                    pd.timer.performAfterDelay(vars.progress_delay, function()
                        vars.progressable = true
                    end)
                end)
            else -- Otherwise, just get to it.
                pd.timer.performAfterDelay(vars.progress_delay / 3, function()
                    assets.sfx_clickoff:play()
                    vars.hud_open = true
                    if vars.current_step ~= 6 and vars.current_step ~= 14 then -- Only turn on A-button progression if it's not a gameplay-based skill.
                        pd.timer.performAfterDelay(vars.progress_delay, function()
                            vars.progressable = true
                        end)
                    end
                end)
            end
        end
    end
end

function tutorial:leave()
    save['slot' .. save.current_story_slot .. '_progress'] = "cutscene2"
    self.boat.sfx_row:stop()
    fademusic(999)
    vars.anim_overlay = pd.timer.new(1000, #assets.overlay_fade, 1)
    self.boat:state(false, false, false)
    self.boat:finish(false)
    pd.timer.performAfterDelay(1000, function()
        scenemanager:switchstory()
    end)
end

function tutorial:update()
    vars.rowbot = self.boat.turn_speedo.value
    vars.player = self.boat.crankage
    if vars.current_step == 6 and vars.player > 0 then
        vars.gameplay_progress += 1
        if vars.gameplay_progress >= 250 then
            vars.progressable = true
            self:progress()
        end
    end
    if vars.current_step == 14 and vars.player > 0 then
    end
    local x, y = gfx.getDrawOffset() -- Gimme the draw offset
    self.water:moveTo(x%400, y%240) -- Move the water sprite to keep it in frame
end