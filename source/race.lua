import 'title'
import 'results'
import 'boat'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local geo <const> = pd.geometry
local min <const> = math.min
local max <const> = math.max
local ceil <const> = math.ceil
local floor <const> = math.floor
local random <const> = math.random
local deg <const> = math.deg
local rad <const> = math.rad
local sqrt <const> = math.sqrt
local abs <const> = math.abs
local sin <const> = math.sin
local cos <const> = math.cos
local text <const> = gfx.getLocalizedText
local reverse <const> = string.reverse
local spritescpu
local spritesboat
local spritesdebug
local spritesstage
local cpu_body
local player_body

class('race').extends(gfx.sprite) -- Create the scene's class
function race:init(...)
    race.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if vars.in_progress then
            menu:addMenuItem(text('disqualify'), function() self:finish(true) end)
        end
        if not vars.finished then
            menu:addCheckmarkMenuItem(text('proui'), save.pro_ui, function(new)
                save.pro_ui = new
                if not vars.finished then
                    if new then
                        vars.anim_hud:resetnew(200, vars.anim_hud.value, -130, pd.easingFunctions.inOutSine)
                        vars.anim_ui_offset:resetnew(200, vars.anim_ui_offset.value, 88, pd.easingFunctions.inOutSine)
                    else
                        vars.anim_hud:resetnew(200, vars.anim_hud.value, 0, pd.easingFunctions.inOutSine)
                        vars.anim_ui_offset:resetnew(200, vars.anim_ui_offset.value, 0, pd.easingFunctions.inOutSine)
                    end
                end
            end)
        end
        setpauseimage(100)
        if vars.mirror then pd.display.setFlipped(false, false) end
    end

    function pd.gameWillResume()
        if vars.mirror then pd.display.setFlipped(true, false) end
    end

    function pd.deviceWillLock()
        if vars.mirror then pd.display.setFlipped(false, false) end
    end

    function pd.deviceWillSleep()
        if vars.mirror then pd.display.setFlipped(false, false) end
    end

    function pd.deviceDidUnlock()
        if vars.mirror then pd.display.setFlipped(true, false) end
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_pole_cap = gfx.image.new('images/race/pole_cap'),
        image_pole = gfx.image.new('images/race/pole'),
        overlay_fade = gfx.imagetable.new('images/ui/fade_white/fade'),
        overlay_countdown = gfx.imagetable.new('images/race/countdown'),
        overlay_boost = gfx.imagetable.new('images/race/boost/boost'),
        sfx_countdown = smp.new('audio/sfx/countdown'),
        sfx_start = smp.new('audio/sfx/start'),
        sfx_finish = smp.new('audio/sfx/finish'),
        sfx_ref = smp.new('audio/sfx/ref'),
        sfx_final = smp.new('audio/sfx/final'),
        image_meter_r = gfx.imagetable.new('images/race/meter/meter_r'),
        image_meter_p = gfx.imagetable.new('images/race/meter/meter_p'),
    }
    assets.sfx_countdown:setVolume(save.vol_sfx/5)
    assets.sfx_start:setVolume(save.vol_sfx/5)
    assets.sfx_finish:setVolume(save.vol_sfx/5)
    assets.sfx_ref:setVolume(save.vol_sfx/5)
    assets.sfx_final:setVolume(save.vol_sfx/5)

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        stage = args[1], -- A number, 1 through 7, to determine which stage to play.
        mode = args[2], -- A string, either "story" or "tt" or "debug", to determine which mode to choose.
        mirror = args[3], -- A bool, true or false, determining whether to activate mirror mechanics.
        current_time = 0,
        mins = "0",
        secs = "00",
        mils = "00",
        started = false,
        in_progress = false,
        current_lap = 1,
        current_checkpoint = 0,
        last_checkpoint = 0,
        finished = false,
        won = true,
        water = pd.timer.new(2000, 1, 16),
        audience_1 = pd.timer.new(5000, 10, -10),
        audience_2 = pd.timer.new(15000, 10, -10),
        audience_3 = pd.timer.new(25000, 10, -10),
        reverse_cooldown = true,
        perf_message_displayed = false,
        circle1radius = 14,
        circle2radius = 20,
        circle3radius = 19,
    }
    vars.water.repeats = true
    vars.audience_1.repeats = true
    vars.audience_1.reverses = true
    vars.audience_2.repeats = true
    vars.audience_2.reverses = true
    vars.audience_3.repeats = true
    vars.audience_3.reverses = true
    vars.raceHandlers = {
        BButtonDown = function()
            if vars.mode == "tt" then
                self:boost(true)
            end
        end,
        upButtonDown = function()
            spritesboat.straight = true
        end,
        upButtonUp = function()
            spritesboat.straight = false
        end,
        rightButtonDown = function()
            spritesboat.right = true
        end,
        rightButtonUp = function()
            spritesboat.right = false
        end
    }
    if vars.mode ~= "debug" then
        pd.inputHandlers.push(vars.raceHandlers)
    end

    if enabled_cheats_retro and vars.mode ~= "story" then pd.display.setMosaic(2, 0) end

    if vars.mirror then
        assets.times_new_rally = gfx.font.new('fonts/yllar_wen_semit')
        assets.kapel_doubleup_outline = gfx.font.new('fonts/kdu_reversed')
    else
        assets.times_new_rally = gfx.font.new('fonts/times_new_rally')
        assets.kapel_doubleup_outline = gfx.font.new('fonts/kapel_doubleup_outline')
    end

    vars.anim_overlay = pd.timer.new(1000, 1, assets.overlay_fade:getLength())
    vars.anim_overlay.discardOnCompletion = false
    vars.overlay = "fade"

    if save.pro_ui then
        vars.anim_hud = pd.timer.new(500, -230, -130, pd.easingFunctions.outSine)
        vars.anim_ui_offset = pd.timer.new(0, 88, 88)
    else
        vars.anim_hud = pd.timer.new(500, -130, 0, pd.easingFunctions.outSine)
        vars.anim_ui_offset = pd.timer.new(0, 0, 0)
    end
    vars.anim_hud.discardOnCompletion = false
    vars.anim_ui_offset.discardOnCompletion = false

    -- Load in the appropriate stuffs depending on what stage is called. EZ!
    pd.file.run('stages/' .. vars.stage .. '/stage.pdz')

    self:stage_init()

    if vars.laps > 1 then -- Set the timer graphic
        assets.image_timer = gfx.image.new('images/race/timer_1')
        assets.image_timer_2 = gfx.image.new('images/race/timer_2')
        assets.image_timer_3 = gfx.image.new('images/race/timer_3')
    else
        assets.image_timer = gfx.image.new('images/race/timer')
    end

    if vars.mode == "tt" then -- If time trials is here, then add in some boosts.
        assets.image_item_3 = gfx.image.new('images/race/item_3')
        assets.image_item_2 = gfx.image.new('images/race/item_2')
        assets.image_item_1 = gfx.image.new('images/race/item_1')
        assets.image_item_active = gfx.image.new('images/race/item_active')
        assets.image_item_used = gfx.image.new('images/race/item_used')
        assets.image_item = assets.image_item_3
        vars.boosts_remaining = 3
    end

    class('race_below').extends(gfx.sprite)
    function race_below:init()
        race_below.super.init(self)
        self:setZIndex(-2)
        self:setCenter(0, 0)
        self:setSize(vars.stage_x, vars.stage_y)
        self:setOpaque(true)
        self:add()
    end
    function race_below:draw(x, y, width, height)
        local x = vars.x
        local y = vars.y
        if not (vars.mode == "tt" and enabled_cheats_trippy) then
            assets.image_water_bg:draw(-x, -y)
            if assets.caustics ~= nil then
                assets.caustics:getImage(floor(vars.water.value)):drawIgnoringOffset(((floor(x / 4) * 2) % 400) - 400, ((floor(y / 4) * 2) % 240) - 240) -- Move the water sprite to keep it in frame
            end
            if assets.caustics_overlay ~= nil then
                assets.caustics_overlay:draw(-x, -y)
            end
            if assets.water ~= nil then
                assets.water:getImage(floor(vars.water.value)):drawIgnoringOffset(((x * 0.8) % 400) - 400, ((y * 0.8) % 240) - 240) -- Move the water sprite to keep it in frame
            end
            if assets.popeyes ~= nil then
                assets.popeyes:draw(-x, -y)
            end
        end

        local time = save.total_playtime
        local stage_x = vars.stage_x
        local stage_y = vars.stage_y

        if assets.whirlpool ~= nil then
            local whirlpools_x
            local whirlpools_y
            local whirlpool = assets.whirlpool
            for i = 1, #vars.whirlpools_x do
                whirlpools_x = vars.whirlpools_x[i]
                whirlpools_y = vars.whirlpools_y[i]
                if (whirlpools_x < -x + 468 and whirlpools_x > -x - 68) and (whirlpools_y < -y + 308 and whirlpools_y > -y - 68) then
                    whirlpool:drawImage(floor(vars.anim_whirlpool.value), whirlpools_x, whirlpools_y)
                end
            end
        end

        if assets.boost_pad ~= nil then
            local boost_pads_x
            local boost_pads_y
            local boost_pads_flip
            local boost_pad = assets.boost_pad
            for i = 1, #vars.boost_pads_x do
                boost_pads_x = vars.boost_pads_x[i]
                boost_pads_y = vars.boost_pads_y[i]
                boost_pads_flip = vars.boost_pads_flip[i]
                if (boost_pads_x < -x + 498 and boost_pads_x > -x - 98) and (boost_pads_y < -y + 363 and boost_pads_y > -y - 123) then
                    boost_pad:drawImage(floor(vars.anim_boost_pad.value), boost_pads_x, boost_pads_y, boost_pads_flip)
                end
            end
        end

        if assets.leap_pad ~= nil then
            local leap_pads_x
            local leap_pads_y
            local leap_pad = assets.leap_pad
            for i = 1, #vars.leap_pads_x do
                leap_pads_x = vars.leap_pads_x[i]
                leap_pads_y = vars.leap_pads_y[i]
                if (leap_pads_x < -x + 498 and leap_pads_x > -x - 98) and (leap_pads_y < -y + 363 and leap_pads_y > -y - 123) then
                    leap_pad:drawImage(floor(vars.anim_leap_pad.value), leap_pads_x, leap_pads_y)
                end
            end
        end

        if assets.reverse_pad ~= nil then
            local reverse_pads_x
            local reverse_pads_y
            local reverse_pad = assets.reverse_pad
            for i = 1, #vars.reverse_pads_x do
                reverse_pads_x = vars.reverse_pads_x[i]
                reverse_pads_y = vars.reverse_pads_y[i]
                if (reverse_pads_x < -x + 498 and reverse_pads_x > -x - 98) and (reverse_pads_y < -y + 363 and reverse_pads_y > -y - 123) then
                    reverse_pad:drawImage(floor(vars.anim_reverse_pad.value), reverse_pads_x, reverse_pads_y)
                end
            end
        end
    end

    class('race_stage').extends(gfx.sprite)
    function race_stage:init()
        race_stage.super.init(self)
        self:setZIndex(1)
        self:setCenter(0, 0)
        self:setSize(vars.stage_x, vars.stage_y)
        self:add()
    end
    function race_stage:draw()
        local x = vars.x
        local y = vars.y
        assets.image_stage:draw(0, 0)

        if not perf then
            local x = vars.x
            local y = vars.y
            local time = save.total_playtime
            local stage_x = vars.stage_x
            local stage_y = vars.stage_y
            local parallax_short_amount = vars.parallax_short_amount
            local parallax_medium_amount = vars.parallax_medium_amount
            local parallax_long_amount = vars.parallax_long_amount
            local stage_progress_short_x = stage_x * -vars.stage_progress_short_x
            local stage_progress_short_y = stage_y * -vars.stage_progress_short_y
            local stage_progress_medium_x = stage_x * -vars.stage_progress_medium_x
            local stage_progress_medium_y = stage_y * -vars.stage_progress_medium_y
            local stage_progress_long_x = stage_x * -vars.stage_progress_long_x
            local stage_progress_long_y = stage_y * -vars.stage_progress_long_y

            if time % 3 == 0 then
                race:fill_polygons()
                race:both_polygons()
            end

            if vars.audience_x ~= nil then
                local audience_x
                local audience_y
                local audience_rand
                local audience_angle
                local audience_image
                for i = 1, #vars.audience_x do
                    audience_x = vars.audience_x[i]
                    audience_y = vars.audience_y[i]
                    audience_rand = vars.audience_rand[i]
                    if (audience_x > -x-10 and audience_x < -x+410) and (audience_y > -y-10 and audience_y < -y+250) then
                        audience_image = assets['audience' .. audience_rand]
                        if audience_image[1] ~= nil then
                            audience_angle = (deg(race:fastatan(-y + 120 - audience_y, -x + 200 - audience_x)) + 90) % 360
                            audience_angle = (floor(audience_angle / 8)) + 1
                            audience_image:getImage(audience_angle):draw(
                                (audience_x - 21) * parallax_short_amount + (stage_progress_short_x),
                                (audience_y - 21) * parallax_short_amount + (stage_progress_short_y)
                            )
                        else
                            audience_image:draw(
                                (audience_x - 21) * parallax_short_amount + (stage_progress_short_x),
                                (audience_y - 21) * parallax_short_amount + (stage_progress_short_y)
                            )
                        end
                    end
                end
            end

            if assets.parallax_short_bake ~= nil then assets.parallax_short_bake:draw(stage_progress_short_x, stage_progress_short_y) end
            if assets.parallax_medium_bake ~= nil then assets.parallax_medium_bake:draw(stage_progress_medium_x, stage_progress_medium_y) end
            if assets.parallax_long_bake ~= nil then assets.parallax_long_bake:draw(stage_progress_long_x, stage_progress_long_y) end

            gfx.setLineWidth(18) -- Make the lines phat
            local image_pole_cap = assets.image_pole_cap

            local checkpoint_x = vars.checkpoint_x
            local checkpoint_y = vars.checkpoint_y
            local checkpoint_width = vars.checkpoint_width
            if (checkpoint_x > -x-10 and checkpoint_x < -x+410) and (checkpoint_y > -y-10 and checkpoint_y < -y+250) then
                gfx.drawLine(
                    checkpoint_x,
                    checkpoint_y,
                    (checkpoint_x * parallax_medium_amount) + (stage_progress_medium_x),
                    (checkpoint_y * parallax_medium_amount) + (stage_progress_medium_y))
                image_pole_cap:draw(
                    (checkpoint_x - 6) * parallax_medium_amount + (stage_progress_medium_x),
                    (checkpoint_y - 6) * parallax_medium_amount + (stage_progress_medium_y))
            end
            if (checkpoint_x + checkpoint_width > -x-10 and checkpoint_x + checkpoint_width < -x+410) and (checkpoint_y > -y-10 and checkpoint_y < -y+250) then
                gfx.drawLine(
                    checkpoint_x + checkpoint_width,
                    checkpoint_y,
                    ((checkpoint_x + checkpoint_width) * parallax_medium_amount) + (stage_progress_medium_x),
                    (checkpoint_y * parallax_medium_amount) + (stage_progress_medium_y))
                image_pole_cap:draw(
                    ((checkpoint_x + checkpoint_width) - 6) * parallax_medium_amount + (stage_progress_medium_x),
                    (checkpoint_y - 6) * parallax_medium_amount + (stage_progress_medium_y))
            end

            gfx.setLineWidth(2) -- Set the line width back

            local fill_polygons
            for i = 1, #vars.fill_polygons do
                fill_polygons = vars.fill_polygons[i]
                gfx.fillPolygon(fill_polygons)
            end

            local both_polygons
            for i = 1, #vars.both_polygons do
                both_polygons = vars.both_polygons[i]
                gfx.setColor(gfx.kColorWhite)
                gfx.fillPolygon(both_polygons)
                gfx.setColor(gfx.kColorBlack)
                gfx.drawPolygon(both_polygons)
            end

            if assets.wave ~= nil and vars.anim_wave ~= nil then
                assets.wave[floor(vars.anim_wave.value)]:draw(((stage_x - 400) * parallax_long_amount) + stage_progress_long_x, 0)
            end
        end

        local anim_ui_offset = vars.anim_ui_offset.value
        local anim_ui_sevenfour = anim_ui_offset / 7.4
        local anim_hud = vars.anim_hud.value
        local stage_overlay = assets.stage_overlay
        local anim_stage_overlay = vars.anim_stage_overlay
        local anim_overlay = vars.anim_overlay
        if vars.mode ~= "debug" then
            gfx.setDrawOffset(0, 0)
            if vars.mirror then
                -- If there's some kind of stage overlay anim going on, play it.
                if anim_stage_overlay ~= nil then
                    stage_overlay:drawImage(floor(anim_stage_overlay.value), 0, 0, "flipX")
                elseif stage_overlay ~= nil then
                    stage_overlay:draw(0, 0, "flipX")
                end
                -- If there's some kind of gameplay overlay anim going on, play it.
                if anim_overlay.timeLeft ~= 0 then
                    assets['overlay_' .. vars.overlay]:getImage(floor(anim_overlay.value)):draw(0, 0, "flipX")
                end
                if vars.lap_string ~= nil and not save.pro_ui then
                    assets.kapel_doubleup_outline:drawTextAligned(reverse(vars.lap_string), 400 - vars.anim_lap_string.value, 12, kTextAlignment.right)
                end
                -- Draw the timer
                assets.image_timer:draw(277 - anim_hud - anim_ui_offset, 3 - anim_ui_sevenfour, "flipX")
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                vars.my_cool_buffer = reverse(vars.mins .. ":" .. vars.secs .. "." .. vars.mils)
                assets.times_new_rally:drawTextAligned(vars.my_cool_buffer, 356 - anim_hud - anim_ui_offset, 20 - anim_ui_sevenfour, kTextAlignment.right)
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
                -- Draw the Rocket Arms icon, when applicable
                if assets.image_item ~= nil then
                    assets.image_item:draw(anim_hud, 0, "flipX")
                end
                -- Draw the power meter
                assets.image_meter_r:getImage(floor(vars.rowbot * 14.5) + 1):draw(200, 177 - anim_hud, "flipX")
                assets.image_meter_p:getImage(min(30, max(1, 30 - floor(vars.player * 14.5)))):draw(0, 177 - anim_hud, "flipX")
                if assets.shades ~= nil then
                    assets.shades:draw(311 + vars.anim_shades_x.value, 215 - vars.anim_hud.value - vars.anim_shades_y.value, "flipX")
                end
            else
                -- If there's some kind of stage overlay anim going on, play it.
                if anim_stage_overlay ~= nil and stage_overlay ~= nil then
                    stage_overlay:drawImage(floor(anim_stage_overlay.value), 0, 0)
                elseif stage_overlay ~= nil then
                    stage_overlay:draw(0, 0)
                end
                -- If there's some kind of gameplay overlay anim going on, play it.
                if anim_overlay.timeLeft ~= 0 then
                    assets['overlay_' .. vars.overlay]:getImage(floor(anim_overlay.value)):draw(0, 0)
                end
                if vars.lap_string ~= nil and not save.pro_ui then
                    assets.kapel_doubleup_outline:drawText(vars.lap_string, vars.anim_lap_string.value, 12)
                end
                -- Draw the timer
                assets.image_timer:draw(anim_hud + anim_ui_offset, 3 - anim_ui_sevenfour)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                vars.my_cool_buffer = vars.mins .. ":" .. vars.secs .. "." .. vars.mils
                assets.times_new_rally:drawText(vars.my_cool_buffer, 44 + anim_hud + anim_ui_offset, 20 - anim_ui_sevenfour)
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
                -- Draw the Rocket Arms icon, when applicable
                if assets.image_item ~= nil then
                    assets.image_item:draw(313 - anim_hud, 0)
                end
                -- Draw the power meter
                assets.image_meter_r:getImage(floor(vars.rowbot * 14.5) + 1):draw(0, 177 - anim_hud)
                assets.image_meter_p:getImage(min(30, max(1, 30 - floor(vars.player * 14.5)))):draw(200, 177 - anim_hud)
                if assets.shades ~= nil then
                    assets.shades:draw(89 - vars.anim_shades_x.value, 215 - vars.anim_hud.value - vars.anim_shades_y.value)
                end
            end
            gfx.setDrawOffset(x, y)
        end
    end

    -- Little debug dot, representing the middle of the screen.
    class('race_debug').extends(gfx.sprite)
    function race_debug:init()
        race_debug.super.init(self)
        if vars.cpu_x ~= nil then
            self:moveTo(vars.cpu_x, vars.cpu_y)
        else
            self:moveTo(vars.boat_x, vars.boat_y)
        end
        self:setImage(gfx.image.new(4, 4, gfx.kColorBlack))
        self:setZIndex(99)
        self:add()
    end

    -- Set the sprites
    sprites.below = race_below()
    sprites.stage = race_stage()
    if vars.mode == "debug" then -- If there's debug mode, add the dot.
        sprites.debug = race_debug()
    else -- If not, then add the boat.
        if vars.cpu_x ~= nil then
            sprites.cpu = boat("cpu", vars.cpu_x, vars.cpu_y, vars.stage, vars.stage_x, vars.stage_y, vars.follow_polygon)
        end
        sprites.boat = boat("race", vars.boat_x, vars.boat_y, vars.stage, vars.stage_x, vars.stage_y, nil, vars.mirror, vars.mode)
        -- After the intro animation, start the race.
        pd.timer.performAfterDelay(2000, function()
            self:start()
        end)
    end
    self:add()
    spritescpu = sprites.cpu
    spritesboat = sprites.boat
    spritesdebug = sprites.debug
    spritesstage = sprites.stage
    if vars.mirror then pd.display.setFlipped(true, false) end
end

-- fast atan2. Thanks, nnnn!
function race:fastatan(y, x)
    local a = min(abs(x), abs(y)) / max(abs(x), abs(y))
    local s = a * a
    local r = ((-0.0464964749 * s + 0.15931422) * s - 0.327622764) * s * a + a
    if abs(y) > abs(x) then r = 1.57079637 - r end
    if x < 0 then r = 3.14159274 - r end
    if y < 0 then r = -r end
    return r
end

-- BOOOOOOOOOOOOOOOOSH!!! This is for rocket arms in the time trials, and boost pads in the race courses.
-- If rocketarms (bool) is true, then the player activated this at will in a time trial.
function race:boost(rocketarms)
    if rocketarms and vars.boosts_remaining > 0 or not rocketarms then
        if spritesboat.movable and not spritesboat.boosting and not spritesboat.leaping then
            -- ... then boost! :3
            spritesboat:boost() -- The boat does most of this, of course.
            vars.overlay = "boost"
            vars.anim_overlay:resetnew(1000, 1, assets.overlay_boost:getLength()) -- Setting the WOOOOSH overlay
            vars.anim_overlay.repeats = true
            pd.timer.performAfterDelay(2000, function() -- and taking it away after a while.
                if vars.overlay == "boost" then
                    vars.anim_overlay:resetnew(0, 0, 0)
                end
            end)
            if vars.shades then
                vars.shades = false
                vars.anim_shades_x:resetnew(800, 0, 80)
                vars.anim_shades_y:resetnew(400, 0, 20, pd.easingFunctions.outCubic)
                vars.anim_shades_y.timerEndedCallback = function()
                    vars.anim_shades_y:resetnew(400, 20, -30, pd.easingFunctions.inSine)
                    vars.anim_shades_y.timerEndedCallback = nil
                end
            end
            if rocketarms then
                vars.boosts_remaining -= 1
                assets.image_item = assets.image_item_active
                pd.timer.performAfterDelay(50, function()
                    if vars.boosts_remaining ~= 0 then
                        assets.image_item = assets['image_item_' .. vars.boosts_remaining]
                    else
                        assets.image_item = assets.image_item_used
                    end
                end)
            end
        end
    end
end

-- Start the race! (Start the countdown for the race, more specifically.)
function race:start()
    vars.started = true
    assets.sfx_countdown:play()
    vars.overlay = "countdown"
    vars.anim_overlay:resetnew(3900, 2, assets.overlay_countdown:getLength())
    pd.timer.performAfterDelay(3000, function()
        vars.in_progress = true
        if music ~= nil then music:play(0) end
        spritesboat:state(true, true, true)
        spritesboat:start()
        if vars.cpu_x ~= nil then
            spritescpu:state(true)
            spritescpu:start()
        end
    end)
end

-- Finish the race
-- Timeout's a boolean for if you finished normally or by running the clock.
-- Duration is a number for the amount of time the boat should take to stop.
function race:finish(timeout, duration)
    if vars.in_progress then
        if save.pro_ui then
            vars.anim_hud:resetnew(500, vars.anim_hud.value, -230, pd.easingFunctions.inSine)
        else
            vars.anim_hud:resetnew(500, vars.anim_hud.value, -130, pd.easingFunctions.inSine)
        end
        if vars.anim_lap_string ~= nil then vars.anim_lap_string:resetnew(500, vars.anim_lap_string.value, -175, pd.easingFunctions.inSine) end
        vars.in_progress = false
        vars.finished = true
        stopmusic()
        spritesboat:state(false, false, false)
        if timeout then -- If you ran the timer past 09:59.00...
            vars.won = false -- Beans to whatever the other thing says, YOU LOST!
            spritesboat:finish(duration, false) -- This true/false is for the turning peel-out, btw.
            vars.anim_overlay:resetnew(0, 0, 0)
            assets.sfx_ref:play() -- TWEEEEEEEEEEEEET!!!
        else
            spritesboat:finish(duration, true)
            vars.anim_overlay:resetnew(1000, 1, assets.overlay_fade:getLength()) -- Flash!
            vars.overlay = "fade"
            assets.sfx_finish:play() -- Applause!
        end
        pd.timer.performAfterDelay(2500, function()
            scenemanager:switchscene(results, vars.stage, vars.mode, floor(vars.current_time), vars.won, timeout, spritesboat.crashes, vars.mirror)
        end)
    end
end

-- This function takes a score number as input, and spits out the proper time in minutes, seconds, and milliseconds
function race:timecalc(num)
    num = floor(num)
    vars.mins = floor((num/30) / 60)
    vars.secs = floor((num/30) - vars.mins * 60)
    vars.mils = floor((num/30)*99 - vars.mins * 5940 - vars.secs * 99)
    if vars.secs < 10 then vars.secs = '0' .. vars.secs end
    if vars.mils < 10 then vars.mils = '0' .. vars.mils end
end

function race:checkpointcheck(cpu)
    if cpu then
        local x, y, cpu_collisions, cpu_count = spritescpu:checkCollisions(spritescpu.x, spritescpu.y)
        for i = 1, cpu_count do
            local tag = cpu_collisions[i].other:getTag()
            if tag >= 1 and tag <= 3 then
                if vars.cpu_current_checkpoint == tag - 1 and vars.cpu_last_checkpoint == tag - 1 then
                    vars.cpu_current_checkpoint = tag
                end
                vars.cpu_last_checkpoint = tag
            elseif tag == 0 then
                if vars.cpu_current_checkpoint == 3 and vars.cpu_last_checkpoint == 3 then
                    vars.cpu_current_checkpoint = 0
                    vars.cpu_current_lap += 1
                    if vars.cpu_current_lap > vars.laps then
                        spritescpu:finish(1500, true)
                        if not vars.finished then
                            vars.won = false
                        end
                    end
                end
                vars.cpu_last_checkpoint = tag
            elseif tag == 255 and vars.stage ~= 7 then
                -- CPU is colliding with boat.
                local collision = self:cpucollisioncheck()
                while collision == true do
                    local angle = self:fastatan(spritesboat.y - spritescpu.y, spritesboat.x - spritescpu.x) - 1.57
                    spritescpu:moveBy(sin(angle) * 1, -cos(angle) * 1)
                    spritesboat:moveBy(-sin(angle) * 1, cos(angle) * 1)
                    collision = self:cpucollisioncheck()
                end
            elseif vars.whirlpools_x ~= nil and tag ~= 255 then
                -- CPU is colliding with a whirlpool.
                local angle = race:fastatan(spritescpu.y - (vars.whirlpools_y[tag - 42] + 34), spritescpu.x - (vars.whirlpools_x[tag - 42] + 34)) - 1.57
                spritescpu:moveBy(sin(angle) * 2.5, -cos(angle) * 2.5)
            elseif vars.boost_pads_x ~= nil and tag ~= 255 then
                -- CPU is colliding with a boost pad.
                spritescpu:boost()
            elseif vars.leap_pads_x ~= nil and tag ~= 255 then
                -- CPU is colliding with a leap pad.
                spritescpu:leap()
            end
        end
    else
        local _, _, boat_collisions, boat_count = spritesboat:checkCollisions(spritesboat.x, spritesboat.y)
        for i = 1, boat_count do
            local tag = boat_collisions[i].other:getTag()
            if tag >= 1 and tag <= 3 then
                if tag == 1 and vars.lever ~= nil then
                    vars.lever = 2
                    self:lever()
                elseif tag == 3 and vars.lever ~= nil then
                    vars.lever = 1
                    self:lever()
                end
                if vars.current_checkpoint == tag - 1 and vars.last_checkpoint == tag - 1 then
                    vars.current_checkpoint = tag
                end
                vars.last_checkpoint = tag
            elseif tag == 0 then
                if vars.current_checkpoint == 3 and vars.last_checkpoint == 3 then
                    vars.current_checkpoint = 0
                    vars.current_lap += 1
                    if vars.current_lap > vars.laps then -- The race is done.
                        self:finish(false)
                    else
                        if not save.pro_ui then
                            vars.lap_string = vars['lap_string_' .. vars.current_lap]
                            vars.anim_lap_string:resetnew(500, -175, 130, pd.easingFunctions.outBack)
                            pd.timer.performAfterDelay(1500, function()
                                if vars.in_progress then
                                    vars.anim_lap_string:resetnew(500, 130, -175, pd.easingFunctions.inBack)
                                end
                            end)
                        end
                        if vars.current_lap == 2 then
                            assets.sfx_start:play()
                        elseif vars.current_lap == 3 then
                            assets.sfx_final:play()
                            if music ~= nil then
                                music:pause()
                                music:setOffset(0)
                                music:setRate(1.1)
                                pd.timer.performAfterDelay(1750, function()
                                    music:play()
                                end)
                            end
                        end
                        assets.image_timer = assets['image_timer_' .. vars.current_lap]
                    end
                end
                vars.last_checkpoint = tag
            elseif vars.whirlpools_x ~= nil and tag ~= 255 then
                -- Boat is colliding with a whirlpool.
                local player_scale = spritesboat.scale_factor
                local angle = race:fastatan(spritesboat.y - (vars.whirlpools_y[tag - 42] + 34), spritesboat.x - (vars.whirlpools_x[tag - 42] + 34)) - 1.57
                spritesboat:moveBy(sin(angle) * (2.5 * player_scale), -cos(angle) * (2.5 * player_scale))
            elseif vars.boost_pads_x ~= nil and tag ~= 255 then
                -- Boat is colliding with a boost pad.
                self:boost(false)
            elseif vars.leap_pads_x ~= nil and tag ~= 255 then
                -- Boat is colliding with a leap pad.
                spritesboat:leap()
                -- I hate how hard-baked this is, but whatever.
                if tag == 43 then
                    spritesboat.safety_x = 1525
                    spritesboat.safety_y = 490
                    spritesboat.safety_rot = 270
                elseif tag == 44 then
                    spritesboat.safety_x = 650
                    spritesboat.safety_y = 235
                    spritesboat.safety_rot = 270
                elseif tag == 45 then
                    spritesboat.safety_x = 1390
                    spritesboat.safety_y = 1710
                    spritesboat.safety_rot = 90
                end
            elseif vars.reverse_pads_x ~= nil and tag ~= 255 then
                -- Boat is colliding with a reverse pad.
                if vars.mirror then
                    if spritesboat.reversed == -1 then
                        assets.sfx_cymbal:play()
                        shakies()
                        shakies_y()
                        if not pd.getReduceFlashing() then
                            vars.anim_overlay:resetnew(500, 1, #assets.overlay_fade)
                            vars.overlay = "fade"
                        end
                        spritesboat.reversed = 1
                    end
                else
                    if spritesboat.reversed == 1 then
                        assets.sfx_cymbal:play()
                        shakies()
                        shakies_y()
                        if not pd.getReduceFlashing() then
                            vars.anim_overlay:resetnew(500, 1, #assets.overlay_fade)
                            vars.overlay = "fade"
                        end
                        spritesboat.reversed = -1
                    end
                end
            end
        end
    end
end

function race:circleinit()
    local cpu_x = spritescpu.x
    local cpu_y = spritescpu.y
    local cpu_rot = spritescpu.rotation

    local player_x = spritesboat.x
    local player_y = spritesboat.y
    local player_rot = spritesboat.rotation

    local coscpu = cos(rad(cpu_rot))
    local sincpu = sin(rad(cpu_rot))
    local cosplayer = cos(rad(player_rot))
    local sinplayer = sin(rad(player_rot))

    vars.cpu_circle1 = geo.vector2D.new((-coscpu + 18 * sincpu) + cpu_x, (-sincpu - 18 * coscpu) + cpu_y)
    vars.cpu_circle2 = geo.vector2D.new(cpu_x, cpu_y)
    vars.cpu_circle3 = geo.vector2D.new((-coscpu - 15 * sincpu) + cpu_x, (-sincpu + 15 * coscpu) + cpu_y)

    vars.player_circle1 = geo.vector2D.new((-cosplayer + 18 * sinplayer) + player_x, (-sinplayer - 18 * cosplayer) + player_y)
    vars.player_circle2 = geo.vector2D.new(player_x, player_y)
    vars.player_circle3 = geo.vector2D.new((-cosplayer - 15 * sinplayer) + player_x, (-sinplayer + 15 * cosplayer) + player_y)
end

function race:circlecheck(cpucircle, cpucircleradius, playercircle, playercircleradius)
    local circtocirc = cpucircle - playercircle
    local distance = circtocirc:magnitude()
    if distance < cpucircleradius + playercircleradius then
        return true
    end
end

function race:cpucollisioncheck()
    self:circleinit()
    if self:circlecheck(vars.cpu_circle1, vars.circle1radius, vars.player_circle1, vars.circle1radius) == true then return true end
    if self:circlecheck(vars.cpu_circle2, vars.circle2radius, vars.player_circle1, vars.circle1radius) == true then return true end
    if self:circlecheck(vars.cpu_circle3, vars.circle3radius, vars.player_circle1, vars.circle1radius) == true then return true end
    if self:circlecheck(vars.cpu_circle1, vars.circle1radius, vars.player_circle2, vars.circle2radius) == true then return true end
    if self:circlecheck(vars.cpu_circle2, vars.circle2radius, vars.player_circle2, vars.circle2radius) == true then return true end
    if self:circlecheck(vars.cpu_circle3, vars.circle3radius, vars.player_circle2, vars.circle2radius) == true then return true end
    if self:circlecheck(vars.cpu_circle1, vars.circle1radius, vars.player_circle3, vars.circle3radius) == true then return true end
    if self:circlecheck(vars.cpu_circle2, vars.circle2radius, vars.player_circle3, vars.circle3radius) == true then return true end
    if self:circlecheck(vars.cpu_circle3, vars.circle3radius, vars.player_circle3, vars.circle3radius) == true then return true end
end

-- Scene update loop
function race:update()
    local delta = pd.getElapsedTime()
    pd.resetElapsedTime()
    if vars.mode == "debug" then -- If debug mode is enabled,
        -- These have to be in the update loop because there's no way to just check if a button's held on every frame using an input handler. Weird.
        if pd.buttonIsPressed('up') then
            if pd.buttonIsPressed('b') then
                spritesdebug:moveBy(0, -50)
            else
                spritesdebug:moveBy(0, -5)
            end
        end
        if pd.buttonIsPressed('down') then
            if pd.buttonIsPressed('b') then
                spritesdebug:moveBy(0, 50)
            else
                spritesdebug:moveBy(0, 5)
            end
        end
        if pd.buttonIsPressed('left') then
            if pd.buttonIsPressed('b') then
                spritesdebug:moveBy(-50, 0)
            else
                spritesdebug:moveBy(-5, 0)
            end
        end
        if pd.buttonIsPressed('right') then
            if pd.buttonIsPressed('b') then
                spritesdebug:moveBy(50, 0)
            else
                spritesdebug:moveBy(5, 0)
            end
        end
        if pd.buttonJustPressed('a') then -- If A is pressed, print out the coords that the debug dot is sitting on.
            print(floor(spritesdebug.x) .. ', ' .. floor(spritesdebug.y) .. ', ')
        end
        gfx.setDrawOffset(-spritesdebug.x + 200, -spritesdebug.y + 120) -- Move the camera to wherever the debug dot is.
    else
        spritesboat:update(delta)
        if spritescpu ~= nil then spritescpu:update(delta) end
        if vars.in_progress then -- If the race is happenin', then
            self:timecalc(vars.current_time) -- Calc this thing out for the timer
            -- if pd.getFPS() <= 25 and pd.getFPS() > 0 and not perf and not vars.perf_message_displayed then
            --     corner("perf", vars.mirror) -- Warning to tell the user to turn on perf mode
            --     vars.perf_message_displayed = true
            -- end
            if spritesboat.beached and not spritesboat.leaping then -- Oh. If the boat's beached, then
                self:finish(true, 400) -- end the race. Ouch.
            end
            vars.current_time += 30 * delta -- Up that timer, babyyyyyyyyy!
            if vars.current_time >= 17970 then -- If you pass 9:59.00 in game-time,
                self:finish(true) -- YOU'RE OUT!!
            end
            save.total_racetime += 30 * delta -- Statz!
            if vars.mode == "story" then -- If you're in the story mode...
                if save.current_story_slot == 1 then
                    save.slot1_racetime += 30 * delta -- Per-slot statz!!
                elseif save.current_story_slot == 2 then
                    save.slot2_racetime += 30 * delta -- Per-slot statz!!
                elseif save.current_story_slot == 3 then
                    save.slot3_racetime += 30 * delta -- Per-slot statz!!
                end
            end
            self:checkpointcheck(false)
        end
        vars.rowbot = spritesboat.turn_speedo.value
        vars.player = spritesboat.crankage_divvied
        if spritesboat.crashable and not spritesboat.beached then spritesboat:collision_check(vars.edges_polygons, assets.image_stagec, spritesstage.x, spritesstage.y) end
        if spritescpu ~= nil then
            self:checkpointcheck(true)
            if spritescpu.crashable then
                spritescpu:collision_check(vars.edges_polygons, assets.image_stagec_cpu or assets.image_stagec, spritesstage.x, spritesstage.y)
            end
        end
    end
    vars.x, vars.y = gfx.getDrawOffset() -- Gimme the draw offset
    local x = vars.x
    local y = vars.y
    -- Set up the parallax!
    if not perf then
        vars.stage_progress_short_x = (((-x + 200) / vars.stage_x) * (vars.parallax_short_amount - 1))
        vars.stage_progress_short_y = (((-y + 120) / vars.stage_y) * (vars.parallax_short_amount - 1))
        vars.stage_progress_medium_x = (((-x + 200) / vars.stage_x) * (vars.parallax_medium_amount - 1))
        vars.stage_progress_medium_y = (((-y + 120) / vars.stage_y) * (vars.parallax_medium_amount - 1))
        vars.stage_progress_long_x = (((-x + 135) / vars.stage_x) * (vars.parallax_long_amount - 1))
        vars.stage_progress_long_y = (((-y + 60) / vars.stage_y) * (vars.parallax_long_amount - 1))
    end
end