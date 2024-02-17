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
        pedallica = gfx.font.new('fonts/pedallica'),
        kapel = gfx.font.new('fonts/kapel'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_start = pd.sound.sampleplayer.new('audio/sfx/start'),
        sfx_menu = pd.sound.sampleplayer.new('audio/sfx/menu'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
    }
    assets.sfx_bonk:setVolume(save.vol_sfx/5)
    assets.sfx_proceed:setVolume(save.vol_sfx/5)
    assets.sfx_start:setVolume(save.vol_sfx/5)
    assets.sfx_menu:setVolume(save.vol_sfx/5)
    assets.sfx_whoosh:setVolume(save.vol_sfx/5)

    gfx.setFont(assets.kapel_doubleup)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        selection = 1,
        listable = false,
        slot_selection = 1,
        slots_open = false,
        anim_bg = gfx.animator.new(1000, -400, 0, pd.easingFunctions.outCubic),
        anim_item = gfx.animator.new(0, 200, 200),
        anim_slots = gfx.animator.new(0, 400, 400),
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
                        assets.sfx_proceed:play()
                        scenemanager:transitionstoryoneway()
                    else
                        self:openslots()
                    end
                elseif vars.item_list[vars.selection] == 'time_trials' then
                    fademusic()
                    assets.sfx_proceed:play()
                    scenemanager:transitionscene(stages)
                elseif vars.item_list[vars.selection] == 'stats' then
                    assets.sfx_proceed:play()
                    scenemanager:transitionsceneoneway(stats)
                elseif vars.item_list[vars.selection] == 'cheats' then
                    fademusic()
                    assets.sfx_proceed:play()
                    scenemanager:transitionscene(cheats)
                elseif vars.item_list[vars.selection] == 'options' then
                    fademusic()
                    assets.sfx_proceed:play()
                    scenemanager:transitionscene(options)
                end
            end
        end,
    }
    vars.slotsHandlers = {
        leftButtonDown = function()
            self:selectslot(false)
        end,

        rightButtonDown = function()
            self:selectslot(true)
        end,

        AButtonDown = function()
            self:openslot(vars.slot_selection)
        end,
        
        BButtonDown = function()
            self:closeslots()
        end,
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
        if vars.anim_bg ~= nil then
            self:moveTo(0, vars.anim_bg:currentValue())
        end
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

    class('title_slots').extends(gfx.sprite)
    function title_slots:init()
        title_slots.super.init(self)
        self:setImage(assets.image_slots)
        self:setCenter(0, 0)
    end
    function title_slots:update()
        if vars.anim_slots ~= nil then
            self:moveTo(0, vars.anim_slots:currentValue())
        end
    end

    -- Set the sprites
    self.bg = title_bg()
    self.item = title_item()
    self.slots = title_slots()
    self:add()

    pd.timer.performAfterDelay(1000, function()
        vars.listable = true
    end)

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
            assets.sfx_menu:play()
            if dir then
                vars.anim_item = gfx.animator.new(200, 200, -200, pd.easingFunctions.inBack)
            else
                vars.anim_item = gfx.animator.new(200, 200, 600, pd.easingFunctions.inBack)
            end
            pd.timer.performAfterDelay(200, function()
                if vars.selection == 1 and demo then -- Bring in the demo text if necessary
                    assets.image_item = gfx.imageWithText(gfx.getLocalizedText('play_demo'), 200, 120)
                else
                    assets.image_item = gfx.imageWithText(gfx.getLocalizedText(vars.item_list[vars.selection]), 200, 120)
                end
                self.item:setImage(assets.image_item:scaledImage(2))
                if dir then
                    vars.anim_item = gfx.animator.new(200, 600, 200, pd.easingFunctions.outCubic)
                else
                    vars.anim_item = gfx.animator.new(200, -200, 200, pd.easingFunctions.outCubic)
                end
                pd.timer.performAfterDelay(200, function()
                    vars.listable = true
                end)
            end)
        end
    end
end

-- Opens the initial save slot picker
function title:openslots()
    if not vars.slots_open then
        assets.sfx_start:play()
        pd.inputHandlers.push(vars.slotsHandlers, true)
        self:updateslots()
        self.slots:add()
        vars.anim_slots = gfx.animator.new(250, 400, 0, pd.easingFunctions.outCubic)
        vars.slots_open = true
    end
end

-- Update the slot picker image
function title:updateslots()
    assets.image_slots = gfx.image.new(400, 240)
    gfx.pushContext(assets.image_slots)
        gfx.fillRect(0, 17, 400, 206)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 20, 400, 200)
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(3)
        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('story_slot'), 200, 28, kTextAlignment.center)
        assets.kapel:drawTextAligned(gfx.getLocalizedText('slot_1'), 100, 130, kTextAlignment.center)
        assets.kapel:drawTextAligned(gfx.getLocalizedText('slot_2'), 200, 130, kTextAlignment.center)
        assets.kapel:drawTextAligned(gfx.getLocalizedText('slot_3'), 300, 130, kTextAlignment.center)
        gfx.drawRect(10, 60, 120, 90)
        gfx.drawRect(140, 60, 120, 90)
        gfx.drawRect(270, 60, 120, 90)
        gfx.setLineWidth(5)
        if vars.slot_selection == 1 then
            gfx.drawRect(10, 60, 120, 90)
        elseif vars.slot_selection == 2 then
            gfx.drawRect(140, 60, 120, 90)
        elseif vars.slot_selection == 3 then
            gfx.drawRect(270, 60, 120, 90)
        end
        makebutton(gfx.getLocalizedText('this_one'), 'big'):drawAnchored(200, 185, 0.5, 0.5)
        makebutton(gfx.getLocalizedText('back'), 'small'):drawAnchored(395, 235, 1, 1)
    gfx.popContext()
    self.slots:setImage(assets.image_slots)
end

-- Selecting one of the three slots.
function title:selectslot(dir)
    vars.old_slot_selection = vars.slot_selection
    if dir then
        vars.slot_selection = math.clamp(vars.slot_selection + 1, 1, 3)
    else
        vars.slot_selection = math.clamp(vars.slot_selection - 1, 1, 3)
    end
    -- If this is true, then that means we've reached an end and nothing has changed.
    if vars.old_slot_selection == vars.slot_selection then
        assets.sfx_bonk:play()
        shakies()
    else
        assets.sfx_menu:play()
        self:updateslots()
    end
end

-- Close the slot picker
function title:closeslots()
    assets.sfx_whoosh:play()
    vars.anim_slots = gfx.animator.new(250, 0, 400, pd.easingFunctions.inCubic)
    pd.inputHandlers.pop()
    pd.timer.performAfterDelay(250, function()
        self.slots:remove()
        vars.slots_open = false
    end)
end

-- Opens the detailed options for each save slot.
function title:openslot()
    pd.inputHandlers.push(vars.slotHandlers, true)
end

-- Closes the detailed slot options.
function title:closeslot()
    pd.inputHandlers.pop()
end

-- Deletes the chosen slot.
function title:deleteslot(which)
    save['slot' .. which .. '_active'] = nil
    save['slot' .. which .. '_progress'] = nil
    save['slot' .. which .. '_finished'] = false
    save['slot' .. which .. '_ngplus'] = false
    save['slot' .. which .. '_crashes'] = 0
    save['slot' .. which .. '_racetime'] = 0
    title:closeslot()
end