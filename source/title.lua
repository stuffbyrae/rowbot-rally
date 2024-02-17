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

    if not demo then -- If this game's not a demo, then...
        -- Cheat codes!
        local cheat_code_big = Tanuk_CodeSequence({pd.kButtonUp, pd.kButtonUp, pd.kButtonUp, pd.kButtonRight, pd.kButtonDown, pd.kButtonLeft, pd.kButtonDown, pd.kButtonRight, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_big = true
            enabled_cheats = true
            enabled_cheats_big = true
            enabled_cheats_small = false
            enabled_cheats_tiny = false
            fademusic()
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_big'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_small = Tanuk_CodeSequence({pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonDown, pd.kButtonRight, pd.kButtonUp, pd.kButtonDown, pd.kButtonLeft, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_small = true
            enabled_cheats = true
            enabled_cheats_big = false
            enabled_cheats_small = true
            enabled_cheats_tiny = false
            fademusic()
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_small'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_tiny = Tanuk_CodeSequence({pd.kButtonUp, pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonDown, pd.kButtonRight, pd.kButtonB, pd.kButtonDown, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_tiny = true
            enabled_cheats = true
            enabled_cheats_big = false
            enabled_cheats_small = false
            enabled_cheats_tiny = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_tiny'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_dents = Tanuk_CodeSequence({pd.kButtonLeft, pd.kButtonLeft, pd.kButtonRight, pd.kButtonDown, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonRight, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_dents = true
            enabled_cheats = true
            enabled_cheats_dents = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_dents'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        self.cheat_code_retro = Tanuk_CodeSequence({pd.kButtonUp, pd.kButtonUp, pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonRight, pd.kButtonLeft, pd.kButtonRight, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_retro = true
            enabled_cheats = true
            enabled_cheats_retro = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_retro'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        self.cheat_code_all = Tanuk_CodeSequence({pd.kButtonRight, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_big = true
            save.unlocked_cheats_small = true
            save.unlocked_cheats_tiny = true
            save.unlocked_cheats_dents = true
            save.unlocked_cheats_retro = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_all'), gfx.getLocalizedText('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/stages/water_bg'),
        image_bg = gfx.image.new('images/title/bg'),
        image_checker = gfx.image.new('images/title/checker'),
        pedallica = gfx.font.new('fonts/pedallica'),
        kapel = gfx.font.new('fonts/kapel'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_start = pd.sound.sampleplayer.new('audio/sfx/start'),
        sfx_menu = pd.sound.sampleplayer.new('audio/sfx/menu'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
        sfx_ping = pd.sound.sampleplayer.new('audio/sfx/ping'),
    }
    assets.sfx_bonk:setVolume(save.vol_sfx/5)
    assets.sfx_proceed:setVolume(save.vol_sfx/5)
    assets.sfx_start:setVolume(save.vol_sfx/5)
    assets.sfx_menu:setVolume(save.vol_sfx/5)
    assets.sfx_whoosh:setVolume(save.vol_sfx/5)
    assets.sfx_ping:setVolume(save.vol_sfx/5)

    gfx.setFont(assets.kapel_doubleup)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        selection = 1,
        list_open = false,
        slot_selection = 1,
        slots_open = false,
        slot_open = false,
        anim_bg = gfx.animator.new(1000, -400, 0, pd.easingFunctions.outCubic),
        anim_item = gfx.animator.new(0, 200, 200),
        anim_fade = gfx.animator.new(0, 0, 0),
        anim_pulse = gfx.animator.new(1015, 15, 7, pd.easingFunctions.outCubic, 507),
    }
    vars.anim_pulse.repeats = true
    vars.titleHandlers = {
        leftButtonDown = function()
            self:newselection(false)
        end,

        rightButtonDown = function()
            self:newselection(true)
        end,

        AButtonDown = function()
            if vars.list_open then
                if vars.item_list[vars.selection] == 'story_mode' then
                    if demo then -- If this is a demo, just start in slot one. who cares
                        save.current_story_slot = 1
                        save.slot1_progress = nil
                        assets.sfx_proceed:play()
                        scenemanager:transitionstoryoneway()
                    else -- Otherwise, open the slot picker.
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
        AButtonDown = function()
            fademusic()
            assets.sfx_proceed:play()
            -- If they've finished the game before, then bring them to the chapter select.
            if save['slot' .. save.current_story_slot .. '_finished'] then
                scenemanager:transitionscene(chapters)
            else
                scenemanager:transitionstoryoneway()
            end
        end,

        BButtonDown = function()
            self:closeslot(save.current_story_slot)
        end,

        upButtonDown = function()
            -- If there's anything to erase, let them do so.
            if save['slot' .. save.current_story_slot .. '_progress'] ~= nil then
                self:deleteslot(vars.slot_selection)
            end
        end
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
    if save.unlocked_cheats then
        table.insert(vars.item_list, 'cheats')
    end
    table.insert(vars.item_list, 'options')

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('title_checker').extends(gfx.sprite)
    function title_checker:init()
        title_checker.super.init(self)
        self:setImage(assets.image_checker)
        self:setCenter(0, 0)
        self:add()
    end

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
        if not vars.anim_bg:ended() then
            self:moveTo(200, vars.anim_bg:currentValue() + 160)
        end
    end

    class('title_slots').extends(gfx.sprite)
    function title_slots:init()
        title_slots.super.init(self)
        self:setImage(assets.image_slots)
        self:setCenter(0, 0)
        self:setSize(400, 240)
    end
    function title_slots:update()
        if vars.anim_slots ~= nil then
            self:moveTo(0, vars.anim_slots:currentValue())
        end
        self:markDirty()
    end
    function title_slots:draw()
        gfx.fillRect(0, 17, 400, 206)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 20, 400, 200)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
        gfx.setLineWidth(vars.anim_pulse:currentValue())
        if vars.slots_open then
            if vars.slot_selection == 1 then
                gfx.drawRect(10, 60, 120, 90)
            elseif vars.slot_selection == 2 then
                gfx.drawRect(140, 60, 120, 90)
            elseif vars.slot_selection == 3 then
                gfx.drawRect(270, 60, 120, 90)
            end
        end
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(3)
        if not vars.slot_open then
            assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('story_slot'), 200, 28, kTextAlignment.center)
            assets.image_this_one:drawAnchored(200, 185, 0.5, 0.5)
            assets.rect1 = pd.geometry.rect.new(10, 60, 120, 90)
            assets.rect2 = pd.geometry.rect.new(140, 60, 120, 90)
            assets.rect3 = pd.geometry.rect.new(270, 60, 120, 90)
            assets.fill1 = pd.geometry.rect.new(12, 62, 116, 86)
            assets.fill2 = pd.geometry.rect.new(142, 62, 116, 86)
            assets.fill3 = pd.geometry.rect.new(272, 62, 116, 86)
            gfx.drawRect(assets.rect1)
            gfx.drawRect(assets.rect2)
            gfx.drawRect(assets.rect3)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(assets.fill1)
            gfx.fillRect(assets.fill2)
            gfx.fillRect(assets.fill3)
            gfx.setColor(gfx.kColorBlack)
            assets.kapel:drawTextAligned(gfx.getLocalizedText('slot_1'), 70, 100, kTextAlignment.center)
            assets.kapel:drawTextAligned(gfx.getLocalizedText('slot_2'), 200, 100, kTextAlignment.center)
            assets.kapel:drawTextAligned(gfx.getLocalizedText('slot_3'), 330, 100, kTextAlignment.center)
            assets.kapel:drawTextAligned(vars.slot_percent_1 .. '%', 25, 65, kTextAlignment.center)
            assets.kapel:drawTextAligned(vars.slot_percent_2 .. '%', 155, 65, kTextAlignment.center)
            assets.kapel:drawTextAligned(vars.slot_percent_3 .. '%', 285, 65, kTextAlignment.center)
        end
        if not vars.slots_open then
            if save.current_story_slot == 1 then
                assets.rectzoom = pd.geometry.rect.new(10 - vars.anim_slot_l:currentValue(), 60 - vars.anim_slot_u:currentValue(), 120 + vars.anim_slot_r:currentValue(), 90 + vars.anim_slot_d:currentValue())
                assets.fillzoom = pd.geometry.rect.new(12 - vars.anim_slot_l:currentValue(), 62 - vars.anim_slot_u:currentValue(), 116 + vars.anim_slot_r:currentValue(), 86 + vars.anim_slot_d:currentValue())
            elseif save.current_story_slot == 2 then
                assets.rectzoom = pd.geometry.rect.new(140 - vars.anim_slot_l:currentValue(), 60 - vars.anim_slot_u:currentValue(), 120 + vars.anim_slot_r:currentValue(), 90 + vars.anim_slot_d:currentValue())
                assets.fillzoom = pd.geometry.rect.new(142 - vars.anim_slot_l:currentValue(), 62 - vars.anim_slot_u:currentValue(), 116 + vars.anim_slot_r:currentValue(), 86 + vars.anim_slot_d:currentValue())
            elseif save.current_story_slot == 3 then
                assets.rectzoom = pd.geometry.rect.new(270 - vars.anim_slot_l:currentValue(), 60 - vars.anim_slot_u:currentValue(), 120 + vars.anim_slot_r:currentValue(), 90 + vars.anim_slot_d:currentValue())
                assets.fillzoom = pd.geometry.rect.new(272 - vars.anim_slot_l:currentValue(), 62 - vars.anim_slot_u:currentValue(), 116 + vars.anim_slot_r:currentValue(), 86 + vars.anim_slot_d:currentValue())
            end
            gfx.drawRect(assets.rectzoom)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(assets.fillzoom)
            gfx.setColor(gfx.kColorBlack)
            gfx.setClipRect(assets.fillzoom)
            assets.kapel_doubleup:drawText(gfx.getLocalizedText('slot_' .. save.current_story_slot), 15, 28)
            assets.pedallica:drawText(vars['slot_percent_' .. save.current_story_slot] .. gfx.getLocalizedText('percent_complete'), 15, 160)
            assets.pedallica:drawText(gfx.getLocalizedText('stats_racetime') .. ': ' .. vars.mins .. ':' .. vars.secs .. '.' .. vars.mils, 15, 175)
            assets.pedallica:drawText(save['slot' .. save.current_story_slot .. '_crashes'] .. ' ' .. gfx.getLocalizedText('stats_crashes'), 15, 190)
            assets.image_play:drawAnchored(385, 205, 1, 1)
            --TODO: add progress image here
            gfx.drawRect(150, 30, 235, 120)
            if not vars.anim_fade:ended() then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(vars.anim_fade:currentValue(), gfx.image.kDitherTypeBayer2x2)
                gfx.fillRect(0, 0, 400, 240)
                gfx.setColor(gfx.kColorBlack)
            end
            gfx.clearClipRect()
        end
        if vars.slot_open then
            if save['slot' .. save.current_story_slot .. '_progress'] ~= nil then
                assets.image_erase:drawAnchored(5, 235, 0, 1)
            end
        end
        assets.image_back:drawAnchored(395, 235, 1, 1)
        gfx.setLineWidth(2)
    end

    -- Set the sprites
    self.checker = title_checker()
    self.bg = title_bg()
    self.item = title_item()
    self.slots = title_slots()
    self:add()

    pd.timer.performAfterDelay(1000, function()
        vars.list_open = true
    end)

    newmusic('audio/music/title', true, 1.1) -- Adding new music
end

function title:newselection(dir)
    if vars.list_open then
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
            vars.list_open = false
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
                    vars.list_open = true
                end)
            end)
        end
    end
end

-- Opens the initial save slot picker
function title:openslots()
    if not vars.slots_open then
        vars.slot_percent_1 = self:checkpercent(1)
        vars.slot_percent_2 = self:checkpercent(2)
        vars.slot_percent_3 = self:checkpercent(3)
        assets.image_this_one = makebutton(gfx.getLocalizedText('this_one'), 'big')
        assets.image_back = makebutton(gfx.getLocalizedText('back'), 'small')
        assets.sfx_start:play()
        pd.inputHandlers.pop()
        pd.inputHandlers.push(vars.slotsHandlers, true)
        self.slots:add()
        vars.anim_slots = gfx.animator.new(250, 400, 0, pd.easingFunctions.outCubic)
        vars.slots_open = true
    end
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
    end
end

-- Close the slot picker
function title:closeslots()
    assets.sfx_whoosh:play()
    vars.anim_slots = gfx.animator.new(200, 0, 400, pd.easingFunctions.inCubic)
    pd.inputHandlers.pop()
    pd.inputHandlers.push(vars.titleHandlers)
    pd.timer.performAfterDelay(200, function()
        self.slots:remove()
        vars.slots_open = false
    end)
end

-- Opens the detailed options for each save slot.
function title:openslot(slot)
    vars.slots_open = false
    save.current_story_slot = slot
    assets.sfx_ping:play()
    pd.inputHandlers.pop()
    assets.image_erase = makebutton(gfx.getLocalizedText('erase'), 'small')
    vars.mins, vars.secs, vars.mils = timecalc(save['slot' .. save.current_story_slot .. '_racetime'])
    vars.anim_fade = gfx.animator.new(250, 0, 1)
    vars.anim_slot_u = gfx.animator.new(250, 0, 43, pd.easingFunctions.inCubic)
    vars.anim_slot_d = gfx.animator.new(250, 0, 115, pd.easingFunctions.inCubic)
    vars.anim_slot_r = gfx.animator.new(250, 0, 800, pd.easingFunctions.inCubic)
    vars.anim_slot_l = gfx.animator.new(250, 0, 400, pd.easingFunctions.inCubic)
    pd.timer.performAfterDelay(250, function()
        pd.inputHandlers.push(vars.slotHandlers, true)
        vars.slot_open = true
    end)
end

-- Closes the detailed slot options.
function title:closeslot(slot)
    assets.sfx_whoosh:play()
    pd.inputHandlers.pop()
    vars.slot_open = false
    vars.anim_fade = gfx.animator.new(250, 1, 0)
    vars.anim_slot_u = gfx.animator.new(200, 43, 0, pd.easingFunctions.outCubic)
    vars.anim_slot_d = gfx.animator.new(200, 115, 0, pd.easingFunctions.outCubic)
    vars.anim_slot_r = gfx.animator.new(200, 800, 0, pd.easingFunctions.outCubic)
    vars.anim_slot_l = gfx.animator.new(200, 400, 0, pd.easingFunctions.outCubic)
    pd.timer.performAfterDelay(200, function()
        vars.slots_open = true
        pd.inputHandlers.push(vars.slotsHandlers, true)
    end)
end

-- Deletes the chosen slot.
function title:deleteslot(slot)
    makepopup(gfx.getLocalizedText('heads_up'), gfx.getLocalizedText('popup_overwrite'), gfx.getLocalizedText('ok'), true, function()
        save['slot' .. slot .. '_active'] = false
        save['slot' .. slot .. '_progress'] = nil
        save['slot' .. slot .. '_finished'] = false
        save['slot' .. slot .. '_ngplus'] = false
        save['slot' .. slot .. '_crashes'] = 0
        save['slot' .. slot .. '_racetime'] = 0
        vars['slot_percent_' .. current_story_slot] = '0'
        self:closeslot()
    end)
end

function title:checkpercent(slot)
    if save['slot' .. slot .. '_progress'] == nil then
        slot_percent = '0'
        assets.image_play = makebutton(gfx.getLocalizedText('start'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene1' then
        slot_percent = '5'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'tutorial' then
        slot_percent = '10'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene2' then
        slot_percent = '15'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'race1' then
        slot_percent = '20'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene3' then
        slot_percent = '25'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'race2' then
        slot_percent = '30'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene4' then
        slot_percent = '35'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'race3' then
        slot_percent = '40'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene5' then
        slot_percent = '45'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'race4' then
        slot_percent = '50'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene6' then
        slot_percent = '55'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'shark' then
        slot_percent = '60'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene7' then
        slot_percent = '65'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'race5' then
        slot_percent = '70'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene8' then
        slot_percent = '75'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'race6' then
        slot_percent = '80'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene9' then
        slot_percent = '85'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'race7' then
        slot_percent = '90'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'cutscene10' then
        slot_percent = '95'
        assets.image_play = makebutton(gfx.getLocalizedText('play'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'finish' then
        slot_percent = '100'
        assets.image_play = makebutton(gfx.getLocalizedText('chapters'), 'big')
    end
    return slot_percent
end