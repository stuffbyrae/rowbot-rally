-- This file contains the code for the title screen!
-- This screen lets you start or continue a Story game, take you to Time Trials (when unlocked), Play Stats, and Options.

-- Importing other scenes that we'll have to travel to:
import 'opening'
import 'cutscene'
import 'intro'
import 'stages'
import 'stats'
import 'options'
import 'notif'
import 'chapters'
import 'cheats'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Cheat code setup
import "Tanuk_CodeSequence"

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
    title.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end

    if not demo then
        local cheat_code_big = Tanuk_CodeSequence({pd.kButtonUp, pd.kButtonUp, pd.kButtonUp, pd.kButtonRight, pd.kButtonDown, pd.kButtonLeft, pd.kButtonDown, pd.kButtonRight, pd.kButtonB}, function()
            save.cheats = true
            save.cheats_big = true
            cheats_big = true
            cheats_small = false
            cheats_tiny = false
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_big'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_small = Tanuk_CodeSequence({pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonDown, pd.kButtonRight, pd.kButtonUp, pd.kButtonDown, pd.kButtonLeft, pd.kButtonB}, function()
            save.cheats = true
            save.cheats_small = true
            cheats_big = false
            cheats_small = true
            cheats_tiny = false
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_small'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_tiny = Tanuk_CodeSequence({pd.kButtonUp, pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonDown, pd.kButtonRight, pd.kButtonB, pd.kButtonDown, pd.kButtonB}, function()
            save.cheats = true
            save.cheats_tiny = true
            cheats_big = false
            cheats_small = false
            cheats_tiny = true
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_tiny'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_dents = Tanuk_CodeSequence({pd.kButtonLeft, pd.kButtonLeft, pd.kButtonRight, pd.kButtonDown, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonRight, pd.kButtonB}, function()
            save.cheats = true
            save.cheats_dents = true
            cheats_dents = true
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_dents'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        self.cheat_code_retro = Tanuk_CodeSequence({pd.kButtonUp, pd.kButtonUp, pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonRight, pd.kButtonLeft, pd.kButtonRight, pd.kButtonB}, function()
            save.cheats = true
            save.cheats_retro = true
            cheats_retro = true
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_retro'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        self.cheat_code_all = Tanuk_CodeSequence({pd.kButtonRight, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB}, function()
            save.cheats = true
            save.cheats_big = true
            save.cheats_small = true
            save.cheats_tiny = true
            save.cheats_dents = true
            save.cheats_retro = true
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_all'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/stages/water_bg'),
        image_bg = gfx.image.new('images/title/bg'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
    }
    assets.sfx_bonk:setVolume(save.vol_sfx/5)

    gfx.setFont(assets.kapel_doubleup)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        selection = 1,
        listable = true,
        anim_bg = gfx.animator.new(100, -400, 0, pd.easingFunctions.outCubic),
        anim_item = gfx.animator.new(0, 200, 200),
    }
    vars.titleHandlers = {
        leftButtonDown = function()
            self:newselection(false)
        end,

        rightButtonDown = function()
            self:newselection(true)
        end,

        AButtonDown = function()
            if vars.listable then
                if vars.item_list[vars.selection] == 'story_mode' then
                    if demo then
                        save.current_story_slot = 1
                        save.slot1_progress = nil
                        scenemanager:transitionstoryoneway()
                    else
                    end
                elseif vars.item_list[vars.selection] == 'time_trials' then
                    scenemanager:transitionscene(stages)
                elseif vars.item_list[vars.selection] == 'stats' then
                    scenemanager:transitionsceneoneway(stats)
                elseif vars.item_list[vars.selection] == 'cheats' then
                    scenemanager:transitionscene(cheats)
                elseif vars.item_list[vars.selection] == 'options' then
                    scenemanager:transitionscene(options)
                end
            end
        end,
    }
    vars.slotsHandlers = {
    }
    vars.slotHandlers = {
    }
    pd.inputHandlers.push(vars.titleHandlers)

    vars.item_list = {'story_mode'} -- Add story mode — that's always there!
    if demo then -- If there's a demo around, change the wording accordingly.
        assets.image_item = gfx.imageWithText(gfx.getLocalizedText('play_demo'), 200, 120)
    else
        assets.image_item = gfx.imageWithText(gfx.getLocalizedText('story_mode'), 200, 120)
    end
    if save.stages_unlocked >= 1 then
        table.insert(vars.item_list, 'time_trials')
    end
    table.insert(vars.item_list, 'stats')
    if save.cheats then
        table.insert(vars.item_list, 'cheats')
    end
    table.insert(vars.item_list, 'options')

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('title_bg').extends(gfx.sprite)
    function title_bg:init()
        title_bg.super.init(self)
        self:setImage(assets.image_bg)
        self:setCenter(0, 0)
        self:add()
    end
    function title_bg:update()
    end

    class('title_item').extends(gfx.sprite)
    function title_item:init()
        title_item.super.init(self)
        self:setImage(assets.image_item:scaledImage(2))
        self:moveTo(200, 160)
        self:add()
    end
    function title_item:update()
        if vars.anim_item ~= nil then
            self:moveTo(vars.anim_item:currentValue(), 160)
        end
    end

    -- Set the sprites
    self.bg = title_bg()
    self.item = title_item()
    self:add()

    newmusic('audio/music/title', true, 1.1) -- Adding new music
end

function title:newselection(dir)
    if vars.listable then
        vars.old_selection = vars.selection
        if dir then
            vars.selection = math.clamp(vars.selection + 1, 1, #vars.item_list)
        else
            vars.selection = math.clamp(vars.selection - 1, 1, #vars.item_list)
        end
        -- If this is true, then that means we've reached an end and nothing has changed.
        if vars.old_selection == vars.selection then
            assets.sfx_bonk:play()
            shakies()
        else
            vars.listable = false
            if dir then
                vars.anim_item = gfx.animator.new(200, 200, -200, pd.easingFunctions.inBack)
            else
                vars.anim_item = gfx.animator.new(200, 200, 600, pd.easingFunctions.inBack)
            end
            pd.timer.performAfterDelay(200, function()
                assets.image_item = gfx.imageWithText(gfx.getLocalizedText(vars.item_list[vars.selection]), 200, 120)
                self.item:setImage(assets.image_item:scaledImage(2))
                if dir then
                    vars.anim_item = gfx.animator.new(200, 600, 200, pd.easingFunctions.outSine)
                else
                    vars.anim_item = gfx.animator.new(200, -200, 200, pd.easingFunctions.outSine)
                end
                pd.timer.performAfterDelay(200, function()
                    vars.listable = true
                end)
            end)
        end
    end
end

-- Scene update loop
function title:update()
end