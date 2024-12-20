-- This file contains the code for the title screen!
-- This screen lets you start or continue a Story game, take you to Time Trials (when unlocked), Play Stats, and Options.

-- Importing other scenes that we'll have to travel to:
import 'opening'
import 'options'
if not demo then
    import 'chill'
    import 'cutscene'
    import 'intro'
    import 'stages'
    import 'stats'
    import 'notif'
    import 'cheats'
    import "Tanuk_CodeSequence"
	import 'credits'
end

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
    title.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
		if not scenemanager.transitioning then
			if save.seen_credits then
				menu:addMenuItem(text('credits'), function()
					fademusic()
					scenemanager:transitionsceneoneway(credits, true)
				end)
			end
			if save.seen_chill then
				menu:addMenuItem(text('chillmode'), function()
					fademusic()
					scenemanager:transitionsceneoneway(chill)
				end)
			end
		end
        setpauseimage(200)
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
            scenemanager:transitionsceneoneway(notif, text('cheatcode'), text('popup_cheat_big'), text('title_screen'), false, function()
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
            scenemanager:transitionsceneoneway(notif, text('cheatcode'), text('popup_cheat_small'), text('title_screen'), false, function()
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
            scenemanager:transitionsceneoneway(notif, text('cheatcode'), text('popup_cheat_tiny'), text('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_retro = Tanuk_CodeSequence({pd.kButtonUp, pd.kButtonUp, pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonRight, pd.kButtonLeft, pd.kButtonRight, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_retro = true
            enabled_cheats = true
            enabled_cheats_retro = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, text('cheatcode'), text('popup_cheat_retro'), text('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_scream = Tanuk_CodeSequence({pd.kButtonLeft, pd.kButtonDown, pd.kButtonDown, pd.kButtonLeft, pd.kButtonRight, pd.kButtonB, pd.kButtonUp, pd.kButtonUp, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_scream = true
            enabled_cheats = true
            enabled_cheats_scream = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, text('cheatcode'), text('popup_cheat_scream'), text('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_trippy = Tanuk_CodeSequence({pd.kButtonLeft, pd.kButtonUp, pd.kButtonRight, pd.kButtonDown, pd.kButtonLeft, pd.kButtonUp, pd.kButtonRight, pd.kButtonDown, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_trippy = true
            enabled_cheats = true
            enabled_cheats_trippy = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, text('cheatcode'), text('popup_cheat_trippy'), text('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_all = Tanuk_CodeSequence({pd.kButtonRight, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB}, function()
            save.unlocked_cheats = true
            save.unlocked_cheats_big = true
            save.unlocked_cheats_small = true
            save.unlocked_cheats_tiny = true
            save.unlocked_cheats_retro = true
            save.unlocked_cheats_scream = true
            save.unlocked_cheats_trippy = true
            fademusic()
            scenemanager:transitionsceneoneway(notif, text('cheatcode'), text('popup_cheat_all'), text('title_screen'), false, function()
                scenemanager:switchscene(title)
            end)
        end, false)
        local cheat_code_chill = Tanuk_CodeSequence({pd.kButtonDown, pd.kButtonDown, pd.kButtonDown, pd.kButtonDown, pd.kButtonDown, pd.kButtonDown, pd.kButtonDown, pd.kButtonUp, pd.kButtonB}, function()
            fademusic()
            save.seen_chill = true
            scenemanager:transitionsceneoneway(chill)
        end, false)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('stages/tutorial/water_bg'),
        image_bg = gfx.image.new('images/ui/title_bg'),
        image_checker = gfx.image.new('images/ui/title_checker'),
        kapel = gfx.font.new('fonts/kapel'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        fade = gfx.imagetable.new('images/ui/fade/fade'),
        sfx_bonk = smp.new('audio/sfx/bonk'),
        sfx_proceed = smp.new('audio/sfx/proceed'),
        sfx_start = smp.new('audio/sfx/start'),
        sfx_menu = smp.new('audio/sfx/menu'),
        sfx_whoosh = smp.new('audio/sfx/whoosh'),
        sfx_rowboton = smp.new('audio/sfx/rowboton'),
        arrow = gfx.image.new('images/ui/arrow'),
    }
    assets.sfx_bonk:setVolume(save.vol_sfx/5)
    assets.sfx_proceed:setVolume(save.vol_sfx/5)
    assets.sfx_start:setVolume(save.vol_sfx/5)
    assets.sfx_menu:setVolume(save.vol_sfx/5)
    assets.sfx_whoosh:setVolume(save.vol_sfx/5)
    assets.sfx_rowboton:setVolume(save.vol_sfx/5)

    if not demo then
        assets.sfx_ping = smp.new('audio/sfx/ping')
        assets.sfx_ping:setVolume(save.vol_sfx/5)
    end

    gfx.setFont(assets.kapel_doubleup)

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        memorize = args[1],
        selection = 1,
        list_open = false,
        slot_selection = 1,
        slots_open = false,
        slot_open = false,
        anim_bg = pd.timer.new(1000, -240, 0, pd.easingFunctions.outCubic),
        anim_item = pd.timer.new(0, 200, 200),
        anim_fade = pd.timer.new(0, 0, 0),
        anim_slots = pd.timer.new(0, 400, 400),
        anim_slot_u = pd.timer.new(1, 0, 0),
        anim_slot_d = pd.timer.new(1, 0, 0),
        anim_slot_l = pd.timer.new(1, 0, 0),
        anim_slot_r = pd.timer.new(1, 0, 0),
        anim_pulse = pd.timer.new(995, 15, 7, pd.easingFunctions.outCubic),
        anim_checker_x = pd.timer.new(2300, 0, -124),
        anim_checker_y = pd.timer.new(2300, 0, -32),
        circuit = 1,
        arrow_left_x = pd.timer.new(1, 15, 15),
        arrow_right_x = pd.timer.new(1, 364, 364),
    }
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
                        fademusic()
                        title_memorize = 'story_mode'
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
                    assets.sfx_proceed:play()
                    scenemanager:transitionsceneoneway(cheats)
                elseif vars.item_list[vars.selection] == 'options' then
                    assets.sfx_proceed:play()
                    scenemanager:transitionsceneoneway(options)
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
            -- If they've finished the game before, then let them start a new Circuit.
            if save['slot' .. save.current_story_slot .. '_progress'] == 'finish' and save['slot' .. save.current_story_slot .. '_circuit'] < 4 then
                save['slot' .. save.current_story_slot .. '_circuit'] += 1
                save['slot' .. save.current_story_slot .. '_progress'] = 'cutscene1'
                scenemanager:transitionstoryoneway()
                title_memorize = 'story_mode'
                fademusic()
                assets.sfx_proceed:play()
            elseif save['slot' .. save.current_story_slot .. '_progress'] ~= 'finish' then
                scenemanager:transitionstoryoneway()
                fademusic()
                title_memorize = 'story_mode'
                assets.sfx_proceed:play()
            end
        end,

        BButtonDown = function()
            self:closeslot(true)
        end,

        upButtonDown = function()
            -- If there's anything to erase, let them do so.
            if save['slot' .. save.current_story_slot .. '_progress'] ~= nil then
                self:deleteslot(vars.slot_selection)
            end
        end
    }
    pd.inputHandlers.push(vars.titleHandlers)

    vars.anim_pulse.repeats = true
    vars.anim_checker_x.repeats = true
    vars.anim_checker_y.repeats = true
    vars.anim_item.discardOnCompletion = false
    vars.anim_slots.discardOnCompletion = false
    vars.anim_fade.discardOnCompletion = false
    vars.anim_slot_u.discardOnCompletion = false
    vars.anim_slot_d.discardOnCompletion = false
    vars.anim_slot_l.discardOnCompletion = false
    vars.anim_slot_r.discardOnCompletion = false
    vars.arrow_left_x.discardOnCompletion = false
    vars.arrow_right_x.discardOnCompletion = false

    vars.item_list = {'story_mode'} -- Add story mode — that's always there!
    if save.stages_unlocked >= 1 and not demo then
        table.insert(vars.item_list, 'time_trials')
    end
    if not demo then
        table.insert(vars.item_list, 'stats')
    end
    if save.unlocked_cheats then
        table.insert(vars.item_list, 'cheats')
    end
    table.insert(vars.item_list, 'options')

    for i = 1, #vars.item_list do
        if vars.memorize == vars.item_list[i] then
            vars.selection = i
        end
    end

    if vars.item_list[vars.selection] == 'story_mode' and demo then -- If there's a demo around, change the wording accordingly.
        assets.image_item = gfx.imageWithText(text('play_demo'), 200, 120)
    else
        assets.image_item = gfx.imageWithText(text(vars.item_list[vars.selection]), 200, 120)
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('title_checker', _, classes).extends(gfx.sprite)
    function classes.title_checker:init()
        classes.title_checker.super.init(self)
        self:setImage(assets.image_checker)
        self:setCenter(0, 0)
        self:add()
    end
    function classes.title_checker:update()
        self:moveTo(vars.anim_checker_x.value, vars.anim_checker_y.value)
    end

    class('title_bg', _, classes).extends(gfx.sprite)
    function classes.title_bg:init()
        classes.title_bg.super.init(self)
        self:setSize(400, 480)
        self:setCenter(0, 0)
        self:add()
    end
    function classes.title_bg:update()
        if vars.anim_bg ~= nil then
            self:moveTo(0, vars.anim_bg.value)
        end
        if vars.arrow_left_x.value ~= 15 or vars.arrow_right_x.value ~= 364 then
            self:markDirty()
        end
    end
    function classes.title_bg:draw()
        assets.image_bg:draw(0, 0)
        assets.kapel:drawTextAligned(text('select'), 375, 115, kTextAlignment.right)
        if vars.selection == 1 then
            assets.arrow:fadedImage(0.5, gfx.image.kDitherTypeBayer2x2):draw(vars.arrow_left_x.value, 160)
        else
            assets.arrow:draw(vars.arrow_left_x.value, 160)
        end
        if vars.selection == #vars.item_list then
            assets.arrow:fadedImage(0.5, gfx.image.kDitherTypeBayer2x2):draw(vars.arrow_right_x.value, 160, gfx.kImageFlippedX)
        else
            assets.arrow:draw(vars.arrow_right_x.value, 160, gfx.kImageFlippedX)
        end
    end

    class('title_item', _, classes).extends(gfx.sprite)
    function classes.title_item:init()
        classes.title_item.super.init(self)
        self:setImage(assets.image_item:scaledImage(2))
        self:moveTo(200, 170)
        self:add()
    end
    function classes.title_item:update()
        if vars.anim_item ~= nil then
            self:moveTo(vars.anim_item.value, 170)
        end
        if vars.anim_bg.timeLeft ~= 0 then
            self:moveTo(200, vars.anim_bg.value + 170)
        end
    end

    class('title_slots', _, classes).extends(gfx.sprite)
    function classes.title_slots:init()
        classes.title_slots.super.init(self)
        self:setImage(assets.image_slots)
        self:setCenter(0, 0)
        self:setSize(400, 240)
    end
    function classes.title_slots:update()
        if vars.anim_slots ~= nil then
            self:moveTo(0, vars.anim_slots.value)
        end
        self:markDirty()
    end
    function classes.title_slots:draw()
        gfx.fillRect(0, 17, 400, 206)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 20, 400, 200)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
        gfx.setLineWidth(vars.anim_pulse.value)
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
            assets.kapel_doubleup:drawTextAligned(text('story_slot'), 200, 28, kTextAlignment.center)
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
            assets.kapel:drawText(text('slot_1'), 20, 68)
            assets.kapel:drawText(text('slot_2'), 150, 68)
            assets.kapel:drawText(text('slot_3'), 280, 68)
            assets.kapel:drawText(vars.slot_percent_1 .. '%', 20, 78)
            assets.kapel:drawText(vars.slot_percent_2 .. '%', 150, 78)
            assets.kapel:drawText(vars.slot_percent_3 .. '%', 280, 78)
            if save.slot1_progress ~= nil then
                assets.image_slot_full:draw(14, 94)
            else
                assets.image_slot_empty:draw(14, 94)
            end
            if save.slot2_progress ~= nil then
                assets.image_slot_full:draw(144, 94)
            else
                assets.image_slot_empty:draw(144, 94)
            end
            if save.slot3_progress ~= nil then
                assets.image_slot_full:draw(274, 94)
            else
                assets.image_slot_empty:draw(274, 94)
            end

            if (save.slot1_progress == 'finish' and save.slot1_circuit == 1) or (save.slot1_progress ~= 'finish' and save.slot1_circuit == 2) then
                assets.kapel:drawTextAligned('🌟', 122, 68, kTextAlignment.right)
            elseif (save.slot1_progress == 'finish' and save.slot1_circuit == 2) or (save.slot1_progress ~= 'finish' and save.slot1_circuit == 3) then
                assets.kapel:drawTextAligned('🌟🌟', 122, 68, kTextAlignment.right)
            elseif (save.slot1_progress == 'finish' and save.slot1_circuit == 3) or (save.slot1_progress ~= 'finish' and save.slot1_circuit == 4) then
                assets.kapel:drawTextAligned('🌟🌟🌟', 122, 68, kTextAlignment.right)
            elseif (save.slot1_progress == 'finish' and save.slot1_circuit == 4) then
                assets.kapel:drawTextAligned('🌟🌟🌟🌟', 122, 68, kTextAlignment.right)
            end

            if (save.slot2_progress == 'finish' and save.slot2_circuit == 1) or (save.slot2_progress ~= 'finish' and save.slot2_circuit == 2) then
                assets.kapel:drawTextAligned('🌟', 252, 68, kTextAlignment.right)
            elseif (save.slot2_progress == 'finish' and save.slot2_circuit == 2) or (save.slot2_progress ~= 'finish' and save.slot2_circuit == 3) then
                assets.kapel:drawTextAligned('🌟🌟', 252, 68, kTextAlignment.right)
            elseif (save.slot2_progress == 'finish' and save.slot2_circuit == 3) or (save.slot2_progress ~= 'finish' and save.slot2_circuit == 4) then
                assets.kapel:drawTextAligned('🌟🌟🌟', 252, 68, kTextAlignment.right)
            elseif (save.slot2_progress == 'finish' and save.slot2_circuit == 4) then
                assets.kapel:drawTextAligned('🌟🌟🌟🌟', 252, 68, kTextAlignment.right)
            end

            if (save.slot3_progress == 'finish' and save.slot3_circuit == 1) or (save.slot3_progress ~= 'finish' and save.slot3_circuit == 2) then
                assets.kapel:drawTextAligned('🌟', 382, 68, kTextAlignment.right)
            elseif (save.slot3_progress == 'finish' and save.slot3_circuit == 2) or (save.slot3_progress ~= 'finish' and save.slot3_circuit == 3) then
                assets.kapel:drawTextAligned('🌟🌟', 382, 68, kTextAlignment.right)
            elseif (save.slot3_progress == 'finish' and save.slot3_circuit == 3) or (save.slot3_progress ~= 'finish' and save.slot3_circuit == 4) then
                assets.kapel:drawTextAligned('🌟🌟🌟', 382, 68, kTextAlignment.right)
            elseif (save.slot3_progress == 'finish' and save.slot3_circuit == 4) then
                assets.kapel:drawTextAligned('🌟🌟🌟🌟', 382, 68, kTextAlignment.right)
            end
        end
        if not vars.slots_open then
            if save.current_story_slot == 1 then
                assets.rectzoom = pd.geometry.rect.new(10 - vars.anim_slot_l.value, 60 - vars.anim_slot_u.value, 120 + vars.anim_slot_r.value, 90 + vars.anim_slot_d.value)
                assets.fillzoom = pd.geometry.rect.new(12 - vars.anim_slot_l.value, 62 - vars.anim_slot_u.value, 116 + vars.anim_slot_r.value, 86 + vars.anim_slot_d.value)
            elseif save.current_story_slot == 2 then
                assets.rectzoom = pd.geometry.rect.new(140 - vars.anim_slot_l.value, 60 - vars.anim_slot_u.value, 120 + vars.anim_slot_r.value, 90 + vars.anim_slot_d.value)
                assets.fillzoom = pd.geometry.rect.new(142 - vars.anim_slot_l.value, 62 - vars.anim_slot_u.value, 116 + vars.anim_slot_r.value, 86 + vars.anim_slot_d.value)
            elseif save.current_story_slot == 3 then
                assets.rectzoom = pd.geometry.rect.new(270 - vars.anim_slot_l.value, 60 - vars.anim_slot_u.value, 120 + vars.anim_slot_r.value, 90 + vars.anim_slot_d.value)
                assets.fillzoom = pd.geometry.rect.new(272 - vars.anim_slot_l.value, 62 - vars.anim_slot_u.value, 116 + vars.anim_slot_r.value, 86 + vars.anim_slot_d.value)
            end
            gfx.drawRect(assets.rectzoom)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(assets.fillzoom)
            gfx.setColor(gfx.kColorBlack)
            gfx.setClipRect(assets.fillzoom)
            assets.kapel_doubleup:drawText(text('slot_' .. save.current_story_slot), 15, 28)
            assets.pedallica:drawText(text('circuit') .. ' ' .. vars.circuit, 15, 145)
            assets.pedallica:drawText(vars['slot_percent_' .. save.current_story_slot] .. text('percent_complete'), 15, 160)
            assets.pedallica:drawText(text('stats_racetime') .. ': ' .. vars.mins .. ':' .. vars.secs .. '.' .. vars.mils, 15, 175)
            if save['slot' .. save.current_story_slot .. '_crashes'] == 1 then
                assets.pedallica:drawText(save['slot' .. save.current_story_slot .. '_crashes'] .. ' ' .. text('stats_crash'), 15, 190)
            else
                assets.pedallica:drawText(commalize(save['slot' .. save.current_story_slot .. '_crashes']) .. ' ' .. text('stats_crashes'), 15, 190)
            end
            if save['slot' .. save.current_story_slot .. '_progress'] == 'finish' and save['slot' .. save.current_story_slot .. '_circuit'] == 4 then
                assets.image_preview:draw(150, 60)
                gfx.drawRect(150, 60, 235, 120)
            else
                assets.image_play:drawAnchored(385, 205, 1, 1)
                assets.image_preview:draw(150, 30)
                gfx.drawRect(150, 30, 235, 120)
            end
            if vars.anim_fade.timeLeft ~= 0 then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(vars.anim_fade.value, gfx.image.kDitherTypeBayer2x2)
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
        if vars.anim_overlay ~= nil then
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            vars.anim_overlay:draw(0, 0)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
    end

    -- Set the sprites
    sprites.checker = classes.title_checker()
    sprites.bg = classes.title_bg()
    sprites.item = classes.title_item()
    sprites.slots = classes.title_slots()
    self:add()

    pd.timer.performAfterDelay(1000, function()
        vars.list_open = true
    end)

    newmusic('audio/music/title', true, 1.1) -- Adding new music
end

function title:newselection(dir, num)
    if vars.list_open then
        vars.old_selection = vars.selection
        if dir then
            vars.selection = math.clamp(vars.selection + (num or 1), 1, #vars.item_list)
        else
            vars.selection = math.clamp(vars.selection - (num or 1), 1, #vars.item_list)
        end
        -- If this is true, then that means we've reached an end and nothing has changed.
        if vars.old_selection == vars.selection then
            assets.sfx_bonk:play()
            shakies()
        else
            vars.list_open = false
            assets.sfx_menu:play()
            if dir then
                vars.anim_item:resetnew(150, 200, -200, pd.easingFunctions.inCubic)
                vars.arrow_right_x:resetnew(300, 374, 364, pd.easingFunctions.outCubic)
            else
                vars.anim_item:resetnew(150, 200, 600, pd.easingFunctions.inCubic)
                vars.arrow_left_x:resetnew(300, 5, 15, pd.easingFunctions.outCubic)
            end
            vars.anim_item.timerEndedCallback = function()
                if vars.selection == 1 and demo then -- Bring in the demo text if necessary
                    assets.image_item = gfx.imageWithText(text('play_demo'), 200, 120)
                else
                    assets.image_item = gfx.imageWithText(text(vars.item_list[vars.selection]), 200, 120)
                end
                sprites.item:setImage(assets.image_item:scaledImage(2))
                if dir then
                    vars.anim_item:resetnew(150, 600, 200, pd.easingFunctions.outBack)
                else
                    vars.anim_item:resetnew(150, -200, 200, pd.easingFunctions.outBack)
                end
                vars.anim_item.timerEndedCallback = function()
                    vars.list_open = true
                end
            end
        end
    end
end

-- Opens the initial save slot picker
function title:openslots()
    if not vars.slots_open then
        vars.slot_percent_1 = self:checkpercent(1)
        vars.slot_percent_2 = self:checkpercent(2)
        vars.slot_percent_3 = self:checkpercent(3)
        assets.image_slot_empty = gfx.image.new('images/ui/slot_empty')
        assets.image_slot_full = gfx.image.new('images/ui/slot_full')
        assets.image_this_one = makebutton(text('this_one'), 'big')
        assets.image_back = makebutton(text('back'), 'small')
        assets.sfx_start:play()
        pd.inputHandlers.pop()
        pd.inputHandlers.push(vars.slotsHandlers, true)
        sprites.slots:add()
        vars.anim_slots:resetnew(250, 400, 0, pd.easingFunctions.outCubic)
        vars.slots_open = true
    end
end

-- Selecting one of the three slots.
function title:selectslot(dir, num)
    vars.old_slot_selection = vars.slot_selection
    if dir then
        vars.slot_selection = math.clamp(vars.slot_selection + (num or 1), 1, 3)
    else
        vars.slot_selection = math.clamp(vars.slot_selection - (num or 1), 1, 3)
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
    vars.anim_slots:resetnew(200, 0, 400, pd.easingFunctions.inCubic)
    pd.inputHandlers.pop()
    pd.inputHandlers.push(vars.titleHandlers)
    pd.timer.performAfterDelay(200, function()
        sprites.slots:remove()
        vars.slots_open = false
    end)
end

-- Opens the detailed options for each save slot.
function title:openslot(slot)
    assets.pedallica = gfx.font.new('fonts/pedallica')
    assets.image_preview = gfx.image.new('images/story/previews/' .. self:checkpreview(slot))
    vars.slots_open = false
    save.current_story_slot = slot
    assets.sfx_ping:play()
    pd.inputHandlers.pop()
    assets.image_erase = makebutton(text('erase'), 'small')
    vars.circuit = save['slot' .. save.current_story_slot .. '_circuit']
    vars.mins, vars.secs, vars.mils = timecalc(save['slot' .. save.current_story_slot .. '_racetime'])
    vars.anim_fade:resetnew(250, 0, 1)
    if save['slot' .. slot .. '_progress'] == nil then
        assets.image_play = makebutton(text('start'), 'big')
    elseif save['slot' .. slot .. '_progress'] == 'finish' and save['slot' .. slot .. '_circuit'] <= 3 then
        assets.image_play = makebutton(text('newcircuit'), 'big')
    else
        assets.image_play = makebutton(text('play'), 'big')
    end
    vars.anim_slot_u:resetnew(250, 0, 43, pd.easingFunctions.inCubic)
    vars.anim_slot_d:resetnew(250, 0, 115, pd.easingFunctions.inCubic)
    vars.anim_slot_r:resetnew(250, 0, 800, pd.easingFunctions.inCubic)
    vars.anim_slot_l:resetnew(250, 0, 400, pd.easingFunctions.inCubic)
    vars.anim_slot_u.timerEndedCallback = function()
        pd.inputHandlers.push(vars.slotHandlers, true)
        vars.slot_open = true
    end
end

-- Closes the detailed slot options.
function title:closeslot(transition)
    pd.inputHandlers.pop()
    vars.slot_open = false
    if transition then
        assets.sfx_whoosh:play()
        vars.anim_fade:resetnew(250, 1, 0)
        vars.anim_slot_u:resetnew(200, 43, 0, pd.easingFunctions.outCubic)
        vars.anim_slot_d:resetnew(200, 115, 0, pd.easingFunctions.outCubic)
        vars.anim_slot_r:resetnew(200, 800, 0, pd.easingFunctions.outCubic)
        vars.anim_slot_l:resetnew(200, 400, 0, pd.easingFunctions.outCubic)
        vars.anim_slot_u.timerEndedCallback = function()
            vars.slots_open = true
            pd.inputHandlers.push(vars.slotsHandlers, true)
        end
    else
        vars.slots_open = true
        pd.inputHandlers.push(vars.slotsHandlers, true)
    end
end

-- Deletes the chosen slot.
function title:deleteslot(slot)
    makepopup(text('heads_up'), text('popup_overwrite_a') .. save.current_story_slot .. text('popup_overwrite_b'), text('yes_delete'), true, function()
        save['slot' .. slot .. '_progress'] = nil
        save['slot' .. slot .. '_highest_progress'] = nil
        save['slot' .. slot .. '_circuit'] = 1
        save['slot' .. slot .. '_ngplus'] = false
        save['slot' .. slot .. '_crashes'] = 0
        save['slot' .. slot .. '_racetime'] = 0
        vars['slot_percent_' .. save.current_story_slot] = '0'
        if not pd.getReduceFlashing() then
            vars.anim_overlay = gfx.animation.loop.new(20, assets.fade, false)
        end
        assets.sfx_rowboton:play()
        self:closeslot(false)
    end)
end

function title:checkpreview(slot)
    if save['slot' .. slot .. '_progress'] == nil then
        slot_preview = 'empty'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene1' then
        slot_preview = 'tutorial'
    elseif save['slot' .. slot .. '_progress'] == 'tutorial' then
        slot_preview = 'tutorial'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene2' then
        slot_preview = 'race1'
    elseif save['slot' .. slot .. '_progress'] == 'race1' then
        slot_preview = 'race1'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene3' then
        slot_preview = 'race2'
    elseif save['slot' .. slot .. '_progress'] == 'race2' then
        slot_preview = 'race2'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene4' then
        slot_preview = 'race3'
    elseif save['slot' .. slot .. '_progress'] == 'race3' then
        slot_preview = 'race3'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene5' then
        slot_preview = 'race4'
    elseif save['slot' .. slot .. '_progress'] == 'race4' then
        slot_preview = 'race4'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene6' then
        slot_preview = 'chase'
    elseif save['slot' .. slot .. '_progress'] == 'chase' then
        slot_preview = 'chase'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene7' then
        slot_preview = 'race5'
    elseif save['slot' .. slot .. '_progress'] == 'race5' then
        slot_preview = 'race5'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene8' then
        slot_preview = 'race6'
    elseif save['slot' .. slot .. '_progress'] == 'race6' then
        slot_preview = 'race6'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene9' then
        slot_preview = 'race7'
    elseif save['slot' .. slot .. '_progress'] == 'race7' then
        slot_preview = 'race7'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene10' then
        slot_preview = 'finish'
    elseif save['slot' .. slot .. '_progress'] == 'finish' then
        slot_preview = 'finish'
    end
    return slot_preview
end

function title:checkpercent(slot)
    if save['slot' .. slot .. '_progress'] == nil then
        slot_percent = '0'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene1' then
        slot_percent = '5'
    elseif save['slot' .. slot .. '_progress'] == 'tutorial' then
        slot_percent = '10'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene2' then
        slot_percent = '15'
    elseif save['slot' .. slot .. '_progress'] == 'race1' then
        slot_percent = '20'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene3' then
        slot_percent = '25'
    elseif save['slot' .. slot .. '_progress'] == 'race2' then
        slot_percent = '30'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene4' then
        slot_percent = '35'
    elseif save['slot' .. slot .. '_progress'] == 'race3' then
        slot_percent = '40'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene5' then
        slot_percent = '45'
    elseif save['slot' .. slot .. '_progress'] == 'race4' then
        slot_percent = '50'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene6' then
        slot_percent = '55'
    elseif save['slot' .. slot .. '_progress'] == 'chase' then
        slot_percent = '60'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene7' then
        slot_percent = '65'
    elseif save['slot' .. slot .. '_progress'] == 'race5' then
        slot_percent = '70'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene8' then
        slot_percent = '75'
    elseif save['slot' .. slot .. '_progress'] == 'race6' then
        slot_percent = '80'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene9' then
        slot_percent = '85'
    elseif save['slot' .. slot .. '_progress'] == 'race7' then
        slot_percent = '90'
    elseif save['slot' .. slot .. '_progress'] == 'cutscene10' then
        slot_percent = '95'
    elseif save['slot' .. slot .. '_progress'] == 'finish' then
        slot_percent = '100'
    end
    return slot_percent
end

function title:update()
	if not scenemanager.transitioning then
		local ticks = pd.getCrankTicks(5)
		if not vars.transitioning then
			if vars.slots_open and not vars.slot_open then
				if ticks < 0 then
					self:selectslot(false, -ticks)
				elseif ticks > 0 then
					self:selectslot(true, ticks)
				end
			elseif vars.list_open and not vars.slots_open and not vars.slot_open then
				if ticks < 0 then
					self:newselection(false, -ticks)
				elseif ticks > 0 then
					self:newselection(true, ticks)
				end
			end
		end
	end
end