classes = {} -- fuck this

-- Importing things
import 'CoreLibs/ui'
import 'CoreLibs/math'
import 'CoreLibs/crank'
import 'CoreLibs/timer'
import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'CoreLibs/animation'
import 'CoreLibs/nineslice'
import 'scenemanager'
import 'opening'
import 'title'
scenemanager = scenemanager()

-- Setting up basic SDK params
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local text <const> = gfx.getLocalizedText
local floor <const> = math.floor
local datestamp <const> = pd.getTime()

fps = 30
pd.display.setRefreshRate(fps)
pd.display.setFlipped(false, false)
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setLineCapStyle(gfx.kLineCapStyleRound)
gfx.setLineWidth(2)

-- Game variables
show_crank = false -- do you show the crankindicator in this scene?
show_crank_override = false -- If this is turned on, then show the crankindicator regardless of dock status.
corner_active = false -- Is the corner UI active?
demo = true
if not string.find(pd.metadata.bundleID, "demo") then demo = false end -- DEMO check.
playtest = false -- Playtesting build - locks scoreboard sending, and self-destructs after launch.

-- Cheats checks
enabled_cheats = false -- Set this to true if ANY cheats are enabled. Important!, as this stops saving cheated times to leaderboards
enabled_cheats_big = false
enabled_cheats_small = false
enabled_cheats_tiny = false
enabled_cheats_retro = false
enabled_cheats_scream = false
enabled_cheats_trippy = false

title_memorize = 'story_mode'

local kapel <const> = gfx.font.new('fonts/kapel') -- Kapel font
local lepak <const> = gfx.font.new('fonts/lepak') -- Kapel font, reversed
local reverse <const> = string.reverse
local kapel_doubleup <const> = gfx.font.new('fonts/kapel_doubleup') -- Kapel double-big font
local pedallica <const> = gfx.font.new('fonts/pedallica') -- Pedallica font

local button_image_big <const> = gfx.nineSlice.new('images/ui/button_big', 23, 5, 114, 31) -- Big button image
local button_image_small <const> = gfx.nineSlice.new('images/ui/button_small', 26, 4, 47, 15) -- and the smaller button images
local button_image_small2 <const> = gfx.nineSlice.new('images/ui/button_small2', 26, 4, 47, 15)

local image_popup <const> = gfx.image.new('images/ui/popup') -- Pop-up UI Plate image
local popup_in <const> = smp.new('audio/sfx/ui') -- Pop-up CHA-CHING! noise
local popup_out <const> = smp.new('audio/sfx/whoosh') -- Pop-up out whoosh sound

-- Save check
function savecheck()
    save = pd.datastore.read()
    if save == nil then save = {} end
    -- Cheat codes!
    if save.unlocked_cheats == nil then save.unlocked_cheats = false end
    if save.unlocked_cheats_big == nil then save.unlocked_cheats_big = false end
    if save.unlocked_cheats_small == nil then save.unlocked_cheats_small = false end
    if save.unlocked_cheats_tiny == nil then save.unlocked_cheats_tiny = false end
    if save.unlocked_cheats_retro == nil then save.unlocked_cheats_retro = false end
    if save.unlocked_cheats_scream == nil then save.unlocked_cheats_scream = false end
    if save.unlocked_cheats_trippy == nil then save.unlocked_cheats_trippy = false end
    -- Last saved slot, used to determine which save slot is being played right now. This changes when a new story slot is opened up.
    save.current_story_slot = save.current_story_slot or 1
    -- Local best time-trial records for all courses
    save.stage1_best = save.stage1_best or 17970
    save.stage2_best = save.stage2_best or 17970
    save.stage3_best = save.stage3_best or 17970
    save.stage4_best = save.stage4_best or 17970
    save.stage5_best = save.stage5_best or 17970
    save.stage6_best = save.stage6_best or 17970
    save.stage7_best = save.stage7_best or 17970
    -- Local best time-trial records for all courses (mirror mode)
    save.stage1_best_mirror = save.stage1_best_mirror or 17970
    save.stage2_best_mirror = save.stage2_best_mirror or 17970
    save.stage3_best_mirror = save.stage3_best_mirror or 17970
    save.stage4_best_mirror = save.stage4_best_mirror or 17970
    save.stage5_best_mirror = save.stage5_best_mirror or 17970
    save.stage6_best_mirror = save.stage6_best_mirror or 17970
    save.stage7_best_mirror = save.stage7_best_mirror or 17970
    -- How many times each stage has been played
    save.stage1_plays = save.stage1_plays or 0
    save.stage2_plays = save.stage2_plays or 0
    save.stage3_plays = save.stage3_plays or 0
    save.stage4_plays = save.stage4_plays or 0
    save.stage5_plays = save.stage5_plays or 0
    save.stage6_plays = save.stage6_plays or 0
    save.stage7_plays = save.stage7_plays or 0
    -- Has the stage been completed with a Flawless ranking (no crashes)?
    if save.stage1_flawless == nil then save.stage1_flawless = false end
    if save.stage2_flawless == nil then save.stage2_flawless = false end
    if save.stage3_flawless == nil then save.stage3_flawless = false end
    if save.stage4_flawless == nil then save.stage4_flawless = false end
    if save.stage5_flawless == nil then save.stage5_flawless = false end
    if save.stage6_flawless == nil then save.stage6_flawless = false end
    if save.stage7_flawless == nil then save.stage7_flawless = false end
    -- Has the stage been completed with a Speedy ranking (under par time)?
    if save.stage1_speedy == nil then save.stage1_speedy = false end
    if save.stage2_speedy == nil then save.stage2_speedy = false end
    if save.stage3_speedy == nil then save.stage3_speedy = false end
    if save.stage4_speedy == nil then save.stage4_speedy = false end
    if save.stage5_speedy == nil then save.stage5_speedy = false end
    if save.stage6_speedy == nil then save.stage6_speedy = false end
    if save.stage7_speedy == nil then save.stage7_speedy = false end
    -- Has the stage been completed with a Flawless ranking (no crashes)? (mirror mode)
    if save.stage1_flawless_mirror == nil then save.stage1_flawless_mirror = false end
    if save.stage2_flawless_mirror == nil then save.stage2_flawless_mirror = false end
    if save.stage3_flawless_mirror == nil then save.stage3_flawless_mirror = false end
    if save.stage4_flawless_mirror == nil then save.stage4_flawless_mirror = false end
    if save.stage5_flawless_mirror == nil then save.stage5_flawless_mirror = false end
    if save.stage6_flawless_mirror == nil then save.stage6_flawless_mirror = false end
    if save.stage7_flawless_mirror == nil then save.stage7_flawless_mirror = false end
    -- Has the stage been completed with a Speedy ranking (under par time)? (mirror mode)
    if save.stage1_speedy_mirror == nil then save.stage1_speedy_mirror = false end
    if save.stage2_speedy_mirror == nil then save.stage2_speedy_mirror = false end
    if save.stage3_speedy_mirror == nil then save.stage3_speedy_mirror = false end
    if save.stage4_speedy_mirror == nil then save.stage4_speedy_mirror = false end
    if save.stage5_speedy_mirror == nil then save.stage5_speedy_mirror = false end
    if save.stage6_speedy_mirror == nil then save.stage6_speedy_mirror = false end
    if save.stage7_speedy_mirror == nil then save.stage7_speedy_mirror = false end
    -- Story slot 1
    save.slot1_progress = save.slot1_progress or nil
    save.slot1_highest_progress = save.slot1_highest_progress or nil
    save.slot1_circuit = save.slot1_circuit or 1
    save.slot1_crashes = save.slot1_crashes or 0
    save.slot1_racetime = save.slot1_racetime or 0
    -- Story slot 2
    save.slot2_progress = save.slot2_progress or nil
    save.slot2_highest_progress = save.slot2_highest_progress or nil
    save.slot2_circuit = save.slot2_circuit or 1
    save.slot2_crashes = save.slot2_crashes or 0
    save.slot2_racetime = save.slot2_racetime or 0
    -- Story slot 3
    save.slot3_progress = save.slot3_progress or nil
    save.slot3_highest_progress = save.slot3_highest_progress or nil
    save.slot3_circuit = save.slot3_circuit or 1
    save.slot3_crashes = save.slot3_crashes or 0
    save.slot3_racetime = save.slot3_racetime or 0
    -- Preferences, adjustable in Options menu
    save.vol_music = save.vol_music or 5
    save.vol_sfx = save.vol_sfx or 5
    if save.pro_ui == nil then save.pro_ui = false end
    if save.minimap == nil then save.minimap = false end
    if save.button_controls == nil then save.button_controls = pd.isSimulator == 1 and true or false end
    save.sensitivity = save.sensitivity or 3
    -- Global stats
    if save.first_launch == nil then save.first_launch = true end
    save.stages_unlocked = save.stages_unlocked or 0
    save.stories_completed = save.stories_completed or 0
    save.total_crashes = save.total_crashes or 0
    save.total_racetime = save.total_racetime or 0
    save.total_races_completed = save.total_races_completed or 0
    save.total_playtime = save.total_playtime or 0
    save.total_degrees_cranked = save.total_degrees_cranked or 0
    if save.metric == nil then save.metric = true end
    if save.seen_chill == nil then save.seen_chill = false end
    if save.seen_credits == nil then save.seen_credits = false end
    if save.perf == nil then save.perf = false end
end

-- ... now we run that!
savecheck()

-- I don't *love* this, but for some inexplicable reason replacing the global with the save table feels dangerous in a way I can't describe.
if save.perf then
    perf = true
else
    perf = false
end

-- Math clamp function
function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

-- Save the game mid-play.
function savegame(hidecorner)
    if not demo then -- Make sure you don't save in a demo, though.
        save.total_racetime = floor(save.total_racetime)
        save.slot1_racetime = floor(save.slot1_racetime)
        save.slot2_racetime = floor(save.slot2_racetime)
        save.slot3_racetime = floor(save.slot3_racetime)
        save.total_degrees_cranked = floor(save.total_degrees_cranked)
        pd.datastore.write(save)
        if not hidecorner then
            corner('saving')
        end
    end
end

savegame(true)

-- When the game closes...
function pd.gameWillTerminate()
    pd.display.setFlipped(false, false)
    savegame()
    if pd.isSimulator ~= 1 then -- Only play the exit animation if the game's not running in Simulator.
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
end

function pd.deviceWillSleep()
    savegame()
end

-- Setting up music
music = nil

-- Fades the music out, and trashes it when finished. Should be called alongside a scene change, only if the music is expected to change. Delay can set the delay (in seconds) of the fade
function fademusic(delay)
    delay = delay or 950
    if music ~= nil then
        music:setVolume(0, 0, delay/1000, function()
            music:stop()
            music = nil
        end)
    end
end

function stopmusic()
    if music ~= nil then
        music:stop()
        music = nil
    end
end

-- New music track. This should be called in a scene's init, only if there's no track leading into it. File is a path to an audio file in the PDX. Loop, if true, will loop the audio file. Range will set the loop's starting range.
function newmusic(file, loop, range)
    if music == nil and save.vol_music > 0 then -- If a music file isn't actively playing...then go ahead and set a new one.
        music = fle.new(file)
        if save.vol_music == 0 then
            music:setVolume(0)
        else
            music:setVolume(save.vol_music/5)
        end
        music:setStopOnUnderrun(flag)
        if loop then -- If set to loop, then ... loop it!
            if range then
                music:setLoopRange(range)
            end
            music:play(0)
        else
            music:play()
            music:setFinishCallback(function()
                music = nil
            end)
        end
    end
end

-- Generates buttons for use in buttonery. Type can either be "small", "small2", or "big". The default if no arg is passed, is Big. string can be a string (lol)
function makebutton(button_string, button_type)
    local button_image = button_image_big
    local button_font = kapel_doubleup -- Kapel double-big font for big button
    if button_type == "small" then -- But if those buttons are small...
        button_font = kapel -- Use the smaller font,
        button_image = button_image_small -- and the appropriate image.
    end
    if button_type == "small2" then -- Small button with white border for dark BGs
        button_font = kapel -- Use the smaller font,
        button_image = button_image_small2 -- and the appropriate image.
    end
    local button_text_width = button_font:getTextWidth(button_string) -- Get the width of the string
    local button_text_height = button_font:getHeight() -- Get the height of the text
    local button_img = gfx.image.new(button_text_width + 46, button_text_height + 21) -- Make that image pretty big
    if button_type == "small" or button_type == "small2" then -- But if the button's small...
        button_img = gfx.image.new(button_text_width + 52, button_text_height + 11) -- ...make it pretty small instead.
    end
    local button_img_width, button_img_height = button_img:getSize() -- Get the image's size.
    gfx.pushContext(button_img) -- Now, we draw to that image.
        button_image:drawInRect(0, 0, button_img_width, button_img_height) -- Draw the button's image within the space
        if button_type == "small" or button_type == "small2" then -- If the buttons are small, then...
            button_font:drawTextAligned(button_string, button_img_width / 2, button_img_height / 5, kTextAlignment.center) -- Draw it here!
        else -- Otherwise...
            button_font:drawTextAligned(button_string, button_img_width / 2, button_img_height / 6.5, kTextAlignment.center) -- Draw it a bit higher, to account for the button's margin.
        end
    gfx.popContext()
    return button_img -- Now gimme that image, please!
end

-- This function generates a string that shows up briefly in the top left corner of the screen
-- 'type' is a string that takes a slug to determine what string to show. Accepted slugs are "saving", and "sendscore"
function corner(type, flip)
    local font
    if flip then
        font = lepak
    else
        font = kapel
    end
    local width = font:getTextWidth(text('corner_' .. type))
    local height = font:getHeight()
    if not corner_active then -- If there's nothing in that corner already ...
        corner_active = true -- then let's take that for ourselves
        img_corner = gfx.image.new(width + 12, height + 6) -- Make a new image with abouts the width of the text
        gfx.pushContext(img_corner) -- Now let's draw into it...
            -- Draw a funny polygon that's the length of the text
            if flip then
                gfx.fillPolygon(0, 0, width + 12, 0, width + 12, height + 6, 6, height + 6)
            else
                gfx.fillPolygon(0, 0, width + 12, 0, width + 6, height + 6, 0, height + 6)
            end
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Set the color to white...
            if flip then
                font:drawTextAligned(reverse(text('corner_' .. type)), width + 9, 3, kTextAlignment.right) -- and draw the text!
            else
                font:drawText(text('corner_' .. type), 3, 3) -- and draw the text!
            end
            gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Set this back,
        gfx.popContext() -- and leave the image context.
        if flip then
            anim_corner = pd.timer.new(501, 400, 388 - width, pd.easingFunctions.outSine) -- Intro animation
        else
            anim_corner = pd.timer.new(501, -width - 12, 0, pd.easingFunctions.outSine) -- Intro animation
        end
        anim_corner.timerEndedCallback = function()
            if flip then
                anim_corner = pd.timer.new(501, 388 - width, 400, pd.easingFunctions.inSine)
            else
                anim_corner = pd.timer.new(501, 0, -width - 12, pd.easingFunctions.inSine)
            end
            if type == "perf" then
                anim_corner.delay = 15000
            else
                anim_corner.delay = 1500
            end
            anim_corner.timerEndedCallback = function()
                anim_corner = nil
                img_corner = nil
                corner_active = false
            end
        end
    end
end

-- Generates a pop-up UI. head_text, body_text, and button_text all take strings. callback is a function determining what happens on A press. b_close is a bool determining if B closes the pop-up.
function makepopup(head_text, body_text, button_text, b_close, callback)
    if popup == nil then -- If there isn't already a popup in existence...
        popup_in:setVolume(save.vol_sfx/5) -- Set the volume for the pop-up in sound,
        popup_in:play() -- and play it right away why not?
        local img_popup = gfx.image.new(400, 240) -- New blank image,,,
        gfx.pushContext(img_popup) -- Now, let's build this thing.
            image_popup:draw(0, 0)
            makebutton(button_text):drawAnchored(200, 185, 0.5, 0.5) -- Now, the button.
            if b_close then -- If the B button can close this,
                makebutton(text('back'), 'small'):drawAnchored(395, 235, 1, 1) -- let's make that.
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
        popupHandlers = { -- Now, the input handlers.
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
        anim_popup = pd.timer.new(350, 240, 0, pd.easingFunctions.outBack) -- Tee up that intro animation.
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
        popup_out:setVolume(save.vol_sfx/5) -- Set the volume,
        popup_out:play() -- and play it!
        anim_popup = pd.timer.new(150, 0, 240, pd.easingFunctions.inCubic) -- Also, animate that out.
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

-- This function turns a polygon into a list of coordinates. Thanks, TheMediocritist!
function listpoly(polygon)
    local polyString = tostring(polygon)
    local coordList = {}
    local i = 1
    for number in polyString:gmatch("[-%d%.]+") do
        coordList[i] = tonumber(number)
        i += 1
    end

    return coordList
end

-- This function makes the pause image.
-- 'xoffset' is a number that determines the x offset. naturally
function setpauseimage(xoffset, hideoracle)
    if not hideoracle then
        if demo then
            rowtip_oracle = 'demo'
        else
            if save.stages_unlocked == 7 then
                rowtip_oracle = math.random(1, 75)
            elseif save.stages_unlocked == 6 then
                rowtip_oracle = math.random(1, 60)
            elseif save.stages_unlocked == 5 then
                rowtip_oracle = math.random(1, 55)
            elseif save.stages_unlocked == 4 then
                rowtip_oracle = math.random(1, 50)
            elseif save.stages_unlocked == 3 then
                rowtip_oracle = math.random(1, 45)
            elseif save.stages_unlocked == 2 then
                rowtip_oracle = math.random(1, 40)
            elseif save.stages_unlocked == 1 then
                rowtip_oracle = math.random(1, 35)
            else
                rowtip_oracle = math.random(1, 20)
            end
        end
    end
    local pauseimage = gfx.image.new(400, 240)
    gfx.pushContext(pauseimage)
        gfx.fillRect(0, 0, 400, 40)
        if not hideoracle then
            gfx.fillRoundRect(10 + xoffset, 100, 180, 130, 10)
            gfx.setColor(gfx.kColorWhite)
        end
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        if not hideoracle then
            gfx.drawRoundRect(10 + xoffset, 100, 180, 130, 10)
            pedallica:drawText(text('rowtip' .. rowtip_oracle), 19 + xoffset, 111)
        end
        kapel_doubleup:drawText(text('paused'), 10 + xoffset, 5)
    gfx.popContext()
    pd.setMenuImage(pauseimage, xoffset)
end

-- This function takes a score number as input, and spits out the proper time in minutes, seconds, and milliseconds
function timecalc(num)
    local mins = math.floor((num/30) / 60)
    local secs = math.floor((num/30) - mins * 60)
    local mils = math.floor((num/30)*99 - mins * 5940 - secs * 99)
    if secs < 10 then secs = '0' .. secs end
    if mils < 10 then mils = '0' .. mils end
    return mins, secs, mils
end

-- This function returns the inputted number, with the ordinal suffix tacked on at the end (as a string)
function ordinal(num)
    local m10 = num % 10 -- This is the number, modulo'd by 10.
    local m100 = num % 100 -- This is the number, modulo'd by 100.
    if m10 == 1 and m100 ~= 11 then -- If the number ends in 1 but NOT 11...
        return tostring(num) .. text("st") -- add "st" on.
    elseif m10 == 2 and m100 ~= 12 then -- If the number ends in 2 but NOT 12...
        return tostring(num) .. text("nd") -- add "nd" on,
    elseif m10 == 3 and m100 ~= 13 then -- and if the number ends in 3 but NOT 13...
        return tostring(num) .. text("rd") -- add "rd" on.
    else -- If all those checks passed us by,
        return tostring(num) .. text("th") -- then it ends in "th".
    end
end

-- http://lua-users.org/wiki/FormattingNumbers
function commalize(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function pd.timer:resetnew(duration, startValue, endValue, easingFunction)
	self.duration = duration
	self._startValue = startValue
    self.originalValues.startValue = startValue
	self._endValue = endValue or 0
    self.originalValues.endValue = endValue or 0
	self._easingFunction = easingFunction or pd.easingFunctions.linear
	self.originalValues.easingFunction = easingFunction or pd.easingFunctions.linear
    self._currentTime = 0
	self._lastTime = nil
	self.active = true
	self.hasReversed = false
    self.reverses = false
    self.repeats = false
	self.remainingDelay = self.delay
	self.value = self._startValue
	self._calledOnRepeat = nil
    self.discardOnCompletion = false
    self.paused = false
end

-- This function shakes the screen. int is a number representing intensity. time is a number representing duration
function shakies(time, int)
    if pd.getReduceFlashing() or perf then -- If reduce flashing is enabled, then don't shake.
        return
    end
    anim_shakies = pd.timer.new(time or 500, int or 10, 0, pd.easingFunctions.outElastic)
end

function shakies_y(time, int)
    if pd.getReduceFlashing() or perf then
        return
    end
    anim_shakies_y = pd.timer.new(time or 500, int or 10, 0, pd.easingFunctions.outElastic)
end

-- Final launch
if save.first_launch then
    scenemanager:switchscene(opening, true)
else
    scenemanager:switchscene(title)
end

local offsetx
local offsety

function pd.update()
	drawoffsetx, drawoffsety = gfx.getDrawOffset()
    -- Pop-up UI update logic
    if anim_popup ~= nil and popup ~= nil then -- If the pop-up exists, and its animation exists...
        popup:moveTo(drawoffsetx, anim_popup.value + drawoffsety) -- Move it there!
    end
    offsetx, offsety = pd.display.getOffset()
    -- Screen shake update logic
    if anim_shakies ~= nil then
        pd.display.setOffset(anim_shakies.value, offsety)
    end
    offsetx, offsety = pd.display.getOffset()
    if anim_shakies_y ~= nil then
        pd.display.setOffset(offsetx, anim_shakies_y.value)
    end
    save.total_playtime += 1 -- Up the total playtime by one every frame while the game is open.
    -- Catch-all stuff ...
    gfx.sprite.update()
    pd.timer.updateTimers()
    if (pd.isCrankDocked() or show_crank_override) and show_crank then -- If the crank's docked, and the variable allows for it...
        pd.ui.crankIndicator:draw(-3, -17) -- Show the Use the Crank! indicator.
    end
    -- Corner update logic
    if anim_corner ~= nil and img_corner ~= nil then -- If the intro anim exists...
        img_corner:drawIgnoringOffset(anim_corner.value, 0) -- Move the corner piece in using it
    end
    if playtest then -- Playtesting logic
        pd.display.setRefreshRate(fps) -- Allow the player to change the target FPS via console
        pd.drawFPS(10, 10) -- Show the FPS in the corner
        if ((datestamp.year >= 2024 and datestamp.month >= 12) or (datestamp.year >= 2025)) then -- Postdate lockout
            playdate.stop()
            gfx.image.new('images/ui/corner'):draw(0, 0)
            print("The playtesting period for this game is now over. If you wanna keep playing RowBot Rally, please buy the game in Catalog!")
            kapel_doubleup:drawTextAligned("Thank you for playtesting!", 200, 15, kTextAlignment.center)
            pedallica:drawText("The playtesting period for this\ngame is now over. If you wanna\nkeep playing RowBot Rally, please\nbuy the game in Catalog!\n\nTo transfer your save data over to\nthe full version, make sure the\nRowBot Rally save folder in your Data\nDisk is named \"wtf.rae.rowbotrally\".\n\n🌐 play.date/games/rowbot-rally\nThanks again for your help!", 30, 45)
            playdate.display.flush()
        end
    end
end