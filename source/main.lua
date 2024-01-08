-- Importing things
import 'CoreLibs/ui'
import 'CoreLibs/math'
import 'CoreLibs/timer'
import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'CoreLibs/animation'
import 'CoreLibs/nineslice'
import 'title' -- Title screen, so we can transition to it on start-up
import 'opening' -- ...but we transition to the opening instead, if first launch is true
import 'intro'
import 'scenemanager'
scenemanager = scenemanager()

-- Setting up basic SDK params
local pd <const> = playdate
local gfx <const> = pd.graphics

pd.display.setRefreshRate(30)
gfx.setBackgroundColor(gfx.kColorBlack)

-- Game variables
show_crank = false -- do you show the crankindicator in this scene?
first_pause = true -- so that when you pause the first time, it always reads "Paused!" first.
if string.find(pd.metadata.bundleID, "demo") then demo = true else demo = false end -- DEMO check.

local kapel_doubleup <const> = gfx.font.new('fonts/kapel_doubleup') -- Kapel double-big font
local kapel <const> = gfx.font.new('fonts/kapel') -- Kapel font
local pedallica <const> = gfx.font.new('fonts/pedallica') -- Pedallica font

local button_image_big <const> = gfx.nineSlice.new('images/ui/button_big', 23, 5, 114, 31) -- Big button image
local button_image_small <const> = gfx.nineSlice.new('images/ui/button_small', 26, 4, 47, 15) -- and the smaller button images
local button_image_small2 <const> = gfx.nineSlice.new('images/ui/button_small2', 26, 4, 47, 15)

local image_popup <const> = gfx.image.new('images/ui/popup') -- Pop-up UI Plate image
local popup_in <const> = pd.sound.sampleplayer.new('audio/sfx/ui') -- Pop-up CHA-CHING! noise

-- Save check
function savecheck()
    save = pd.datastore.read()
    if save == nil then save = {} end
    -- Last saved mode, used to determine which save slot is being played right now. This changes when a new story slot is opened up.
    save.last_story_slot = save.last_story_slot or 1
    -- Local best time-trial records for all courses
    save.stage1_best = save.stage1_best or 17970
    save.stage2_best = save.stage2_best or 17970
    save.stage3_best = save.stage3_best or 17970
    save.stage4_best = save.stage4_best or 17970
    save.stage5_best = save.stage5_best or 17970
    save.stage6_best = save.stage6_best or 17970
    save.stage7_best = save.stage7_best or 17970
    -- How many times each stage has been played
    save.stage1_plays = save.stage1_plays or 0
    save.stage2_plays = save.stage2_plays or 0
    save.stage3_plays = save.stage3_plays or 0
    save.stage4_plays = save.stage4_plays or 0
    save.stage5_plays = save.stage5_plays or 0
    save.stage6_plays = save.stage6_plays or 0
    save.stage7_plays = save.stage7_plays or 0
    -- Story slot 1
    if save.slot1_active == nil then save.slot1_active = false end
    save.slot1_stage = save.slot1_stage or 0
    save.slot1_cutscene = save.slot1_cutscene or 0
    save.slot1_crashes = save.slot1_crashes or 0
    save.slot1_racetime = save.slot1_racetime or 0
    -- Story slot 2
    if save.slot2_active == nil then save.slot2_active = false end
    save.slot2_stage = save.slot2_stage or 0
    save.slot2_cutscene = save.slot2_cutscene or 0
    save.slot2_crashes = save.slot2_crashes or 0
    save.slot2_racetime = save.slot2_racetime or 0
    -- Story slot 3
    if save.slot3_active == nil then save.slot3_active = false end
    save.slot3_stage = save.slot3_stage or 0
    save.slot3_cutscene = save.slot3_cutscene or 0
    save.slot3_crashes = save.slot3_crashes or 0
    save.slot3_racetime = save.slot3_racetime or 0
    -- Global unlocks
    save.stages_unlocked = save.stages_unlocked or 0
    save.cutscenes_unlocked = save.cutscenes_unlocked or 0
    if save.credits_unlocked == nil then save.credits_unlocked = false end
    if save.tutorial_unlocked == nil then save.tutorial_unlocked = false end
    if save.time_trials_unlocked == nil then save.time_trials_unlocked = false end
    -- Preferences, adjustable in Options menu
    save.vol_music = save.vol_music or 5
    save.vol_sfx = save.vol_sfx or 5
    if save.pro_ui == nil then save.pro_ui = false end
    if save.power_flip == nil then save.power_flip = false end
    if save.dpad_controls == nil then save.dpad_controls = false end
    save.sensitivty = save.sensitivity or 3
    if save.autoskip == nil then save.autoskip = false end
    -- Global stats
    if save.first_launch == nil then save.first_launch = true end
    save.stories_completed = save.stories_completed or 0
    save.total_crashes = save.total_crashes or 0
    save.total_racetime = save.total_racetime or 0
    save.total_races_completed = save.races_completed or 0
    save.total_playtime = save.total_playtime or 0
    save.total_degrees_cranked = save.total_degrees_cranked or 0
    if save.metric == nil then save.metric = true end
end

-- ... now we run that!
savecheck()

-- Math clamp function
function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

-- When the game closes...
function pd.gameWillTerminate()
    if not demo then
        pd.datastore.write(save)
    end
    local img = gfx.getDisplayImage()
    local byebye = gfx.image.new('images/ui/byebye')
    local fade = gfx.imagetable.new('images/ui/fade/fade')
    local imgslide = gfx.animator.new(350, 1, 240, pd.easingFunctions.outSine)
    local fadeout = gfx.animator.new(150, #fade, 1, pd.easingFunctions.outSine, 1000)
    gfx.setDrawOffset(0, 0)
    while not fadeout:ended() do
        byebye:draw(0, 0)
        img:draw(0, imgslide:currentValue())
        fade:drawImage(math.floor(fadeout:currentValue()), 0, 0)
        pd.display.flush()
    end
end

-- Setting up music
music = nil

-- Fades the music out, and trashes it when finished. Should be called alongside a scene change, only if the music is expected to change. Delay can set the delay (in seconds) of the fade
function fademusic(delay)
    delay = delay or 950
    music:setVolume(0, 0, delay/1000, function()
        music:stop()
        music = nil
    end)
end
-- New music track. This should be called in a scene's init, only if there's no track leading into it. File is a path to an audio file in the PDX. Loop, if true, will loop the audio file. Range will set the loop's starting range.
function newmusic(file, loop, range)
    if music == nil then -- If a music file isn't actively playing...then go ahead and set a new one.
        music = pd.sound.fileplayer.new(file)
        music:setVolume(save.vol_music)
        music:setStopOnUnderrun(flag)
        if loop then -- If set to loop, then ... loop it!
            music:setLoopRange(range)
            music:play(0)
        else
            music:play()
        end
    end
end

-- Generates buttons for use in buttonery. Type can either be "small", "small2", or "big". The default if no arg is passed, is Big. string can be a string (lol)
function makebutton(button_string, button_type)
    button_image = button_image_big
    button_font = kapel_doubleup -- Kapel double-big font for big button
    if button_type == "small" then -- But if those buttons are small...
        button_font = kapel -- Use the smaller font,
        button_image = button_image_small -- and the appropriate image.
    end
    if button_type == "small2" then -- Small button with white border for dark BGs
        button_font = kapel -- Use the smaller font,
        button_image = button_image_small2 -- and the appropriate image.
    end
    button_text_width = button_font:getTextWidth(button_string) -- Get the width of the string
    button_text_height = button_font:getHeight() -- Get the height of the text
    button_img = gfx.image.new(button_text_width + 46, button_text_height + 21) -- Make that image pretty big
    if button_type == "small" or button_type == "small2" then -- But if the button's small...
        button_img = gfx.image.new(button_text_width + 52, button_text_height + 11) -- ...make it pretty small instead.
    end
    button_img_width, button_img_height = button_img:getSize() -- Get the image's size.
    gfx.pushContext(button_img) -- Now, we draw to that image.
        button_image:drawInRect(0, 0, button_img_width, button_img_height) -- Draw the button's image within the space
        if button_type == "small" or button_type == "small2" then -- If the buttons are small, then...
            button_font:drawTextAligned(button_string, button_img_width / 2, button_img_height / 5, kTextAlignment.center) -- Draw it here!
        else -- Otherwise...
            button_font:drawTextAligned(button_string, button_img_width / 2, button_img_height / 6.5, kTextAlignment.center) -- Draw it a bit higher, to account for the button's margin.
        end
    gfx.popContext()
    button_image = nil -- Nilling stuff...
    button_font = nil
    button_text_width = nil
    button_text_height = nil
    return button_img -- Now gimme that image, please!
end

-- Generates a pop-up UI. head_text, body_text, and button_text all take strings. callback is a function determining what happens on A press. b_close is a bool determining if B closes the pop-up.
function makepopup(head_text, body_text, button_text, b_close, callback)
    if popup == nil then -- If there isn't already a popup in existence...
        popup_in:setVolume(save.vol_sfx/5) -- Set the volume for the pop-up in sound,
        popup_in:play() -- and play it right away why not?
        img_popup = gfx.image.new(400, 240) -- New blank image,,,
        gfx.pushContext(img_popup) -- Now, let's build this thing.
            image_popup:draw(0, 0)
            makebutton(button_text):drawAnchored(200, 185, 0.5, 0.5) -- Now, the button.
            if b_close then -- If the B button can close this,
                makebutton(gfx.getLocalizedText('back'), 'small'):drawAnchored(395, 235, 1, 1) -- let's make that.
            end
            kapel_doubleup:drawTextAligned(head_text, 200, 30, kTextAlignment.center) -- Add the header text,
            pedallica:drawTextAligned(body_text, 200, 60, kTextAlignment.center) -- and the body as well.
        gfx.popContext() -- We're done here.
        popup = gfx.sprite.new(img_popup) -- Set the sprite image there.
        img_popup = nil -- We don't need it anymore; nil it.
        popup:setCenter(0, 0) -- Set up the rest of the sprite too:
        popup:setZIndex(9999) -- Make it high,
        popup:moveTo(0, 240) -- Move it down,
        popup:add() -- and add it!
        local popupHandlers = { -- Now, the input handlers.
            BButtonDown = function()
                if b_close then -- If the B button can close this,
                    closepopup() -- then close it. Don't do anything else.
                end
            end,
            AButtonDown = function() -- When the A button's pressed,
                closepopup(callback) -- Close the pop-up, and perform the callback.
            end
        }
        popup_transitioning = true -- Let the transition kick in, so you can't close it *too* immediately.
        anim_popup = gfx.animator.new(350, 240, 0, pd.easingFunctions.outBack) -- Tee up that intro animation.
        pd.timer.performAfterDelay(350, function()
            popup_transitioning = false
        end)
        pd.inputHandlers.push(popupHandlers, true) -- Now push those inputs onto the stack!
    end
end

-- This function closes an open popup. Callback gets passed in from the makepopup function.
function closepopup(callback)
    if popup ~= nil and not popup_transitioning then -- If there isn't any popup to close, or it's already *being* closed, then don't do anything.
        popup_transitioning = true
        popup_out = pd.sound.sampleplayer.new('audio/sfx/whoosh') -- Add in whoosh sound
        popup_out:setVolume(save.vol_sfx/5) -- Set the volume,
        popup_out:play() -- and play it!
        anim_popup = gfx.animator.new(150, 0, 240, pd.easingFunctions.inCubic) -- Also, animate that out.
        pd.timer.performAfterDelay(151, function() -- When the animation's done...
            popup:remove() -- Remove the sprite,
            popup = nil -- Nil it,
            -- .... better nil a couple other things too, just to be sure.
            popup_transitioning = nil
            anim_popup = nil
            pd.inputHandlers.pop() -- and return the input handlers to where they were.
            popupHandlers = nil
            if callback ~= nil then -- If there's a function passed to callback, then we know that the A button was pressed, and that there's a callback for it.
                callback() -- Anyway, perform that.
            end
        end)
    end
end

scenemanager:switchscene(title) -- Start up the game to this scene.

function pd.update()
    if anim_popup ~= nil and popup ~= nil then -- If the pop-up exists, and its animation exists...
        popup:moveTo(0, anim_popup:currentValue()) -- Move it there!
    end
    save.total_playtime += 1 -- Up the total playtime by one every frame while the game is open.
    gfx.sprite.update()
    pd.timer.updateTimers()
    if pd.isCrankDocked() and show_crank then -- If the crank's docked, and the variable allows for it...
        pd.ui.crankIndicator:update() -- Show the Use the Crank! indicator.
    end
end