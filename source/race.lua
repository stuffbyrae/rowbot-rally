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
local atan <const> = math.atan2
local sqrt <const> = math.sqrt
local abs <const> = math.abs
local sin <const> = math.sin
local cos <const> = math.cos

class('race').extends(gfx.sprite) -- Create the scene's class
function race:init(...)
    race.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    if enabled_cheats_retro then pd.display.setMosaic(2, 0) end
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if vars.in_progress then
            menu:addMenuItem(gfx.getLocalizedText('disqualify'), function() self:finish(true) end)
        end
        if not vars.finished then
            menu:addCheckmarkMenuItem(gfx.getLocalizedText('proui'), save.pro_ui, function(new)
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
        setpauseimage(200) -- TODO: Set this X offset
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_pole_cap = gfx.image.new('images/race/pole_cap'),
        image_pole = gfx.image.new('images/race/pole'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        kapel_doubleup_outline = gfx.font.new('fonts/kapel_doubleup_outline'),
        overlay_boost = gfx.imagetable.new('images/race/boost'),
        overlay_fade = gfx.imagetable.new('images/ui/fade_white/fade'),
        overlay_countdown = gfx.imagetable.new('images/race/countdown'),
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
    if vars.mode ~= "debug" then
        pd.inputHandlers.push(vars.raceHandlers)
    end

    vars.anim_overlay = pd.timer.new(1000, 1, #assets.overlay_fade)
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
    if vars.stage == 1 then
        pd.file.run('stages/1/stage.pdz')
    elseif vars.stage == 2 then
        pd.file.run('stages/2/stage.pdz')
    elseif vars.stage == 3 then
        pd.file.run('stages/3/stage.pdz')
    elseif vars.stage == 4 then
        pd.file.run('stages/4/stage.pdz')
    elseif vars.stage == 5 then
        pd.file.run('stages/5/stage.pdz')
    elseif vars.stage == 6 then
        pd.file.run('stages/6/stage.pdz')
    elseif vars.stage == 7 then
        pd.file.run('stages/7/stage.pdz')
    end

    self:stage_init()

    self:bake_parallax()

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

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.image_water_bg:draw(0, 0)
        if assets.caustics ~= nil then
            assets.caustics[floor(vars.water.value)]:drawScaled((floor(vars.x / 4) * 2 % 400) - 400, (floor(vars.y / 4) * 2 % 240) - 240, 2) -- Move the water sprite to keep it in frame
        end
        if assets.caustics_overlay ~= nil then
            assets.caustics_overlay:draw(0, 0)
        end
        if assets.water ~= nil then
            assets.water[floor(vars.water.value)]:drawScaled(((vars.x * 0.8) % 400) - 400, ((vars.y * 0.8) % 240) - 240, 2) -- Move the water sprite to keep it in frame
        end
        if assets.popeyes ~= nil then
            assets.popeyes:draw(0, 0)
        end
    end)

    class('race_below').extends(gfx.sprite)
    function race_below:init()
        race_below.super.init(self)
        self:setZIndex(-1)
        self:setCenter(0, 0)
        self:setSize(vars.stage_x, vars.stage_y)
        if assets.whirlpool ~= nil or assets.boost_pad ~= nil or assets.leap_pad ~= nil then
            self:add()
        end
    end
    function race_below:draw()
        local x = vars.x
        local y = vars.y
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
                    whirlpool:drawImage(math.floor(vars.anim_whirlpool.value), whirlpools_x, whirlpools_y)
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
                    boost_pad:drawImage(math.floor(vars.anim_boost_pad.value), boost_pads_x, boost_pads_y, boost_pads_flip)
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
                    leap_pad:drawImage(math.floor(vars.anim_leap_pad.value), leap_pads_x, leap_pads_y)
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
                race:draw_polygons()
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
                            audience_angle = (deg(race:fastatan(-y + 120 - audience_y, -x + 200 - audience_x))) % 360
                            audience_image[(floor(audience_angle / 8)) + 1]:draw(
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

            gfx.setLineWidth(5)

            local draw_polygons
            local draw_bounds
            local draw_lowest_point_x
            local draw_highest_point_x
            local draw_lowest_point_y
            local draw_highest_point_y
            for i = 1, #vars.draw_polygons do
                draw_polygons = vars.draw_polygons[i]
                draw_bounds = vars.draw_bounds[i]
                draw_lowest_point_x = draw_bounds[1]
                draw_lowest_point_y = draw_bounds[2]
                draw_highest_point_x = draw_bounds[3]
                draw_highest_point_y = draw_bounds[4]
                if (draw_lowest_point_x < -x + 400 and draw_highest_point_x > -x) and (draw_lowest_point_y < -y + 240 and draw_highest_point_y > -y) then
                    gfx.drawPolygon(draw_polygons)
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
            local fill_bounds
            local fill_lowest_point_x
            local fill_highest_point_x
            local fill_lowest_point_y
            local fill_highest_point_y
            for i = 1, #vars.fill_polygons do
                fill_polygons = vars.fill_polygons[i]
                fill_bounds = vars.fill_bounds[i]
                fill_lowest_point_x = fill_bounds[1]
                fill_lowest_point_y = fill_bounds[2]
                fill_highest_point_x = fill_bounds[3]
                fill_highest_point_y = fill_bounds[4]
                if (fill_lowest_point_x < -x + 400 and fill_highest_point_x > -x) and (fill_lowest_point_y < -y + 240 and fill_highest_point_y > -y) then
                    gfx.fillPolygon(fill_polygons)
                end
            end

            local both_polygons
            local both_bounds
            local both_lowest_point_x
            local both_highest_point_x
            local both_lowest_point_y
            local both_highest_point_y
            for i = 1, #vars.both_polygons do
                both_polygons = vars.both_polygons[i]
                both_bounds = vars.both_bounds[i]
                both_lowest_point_x = both_bounds[1]
                both_lowest_point_y = both_bounds[2]
                both_highest_point_x = both_bounds[3]
                both_highest_point_y = both_bounds[4]
                if (both_lowest_point_x < -x + 400 and both_highest_point_x > -x) and (both_lowest_point_y < -y + 240 and both_highest_point_y > -y) then
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillPolygon(both_polygons)
                    gfx.setColor(gfx.kColorBlack)
                    gfx.drawPolygon(both_polygons)
                end
            end

            if assets.wave ~= nil then
                assets.wave[floor(vars.anim_wave.value)]:draw(stage_x - 388, 0)
            end
        end

        if vars.mode ~= "debug" then
            gfx.setDrawOffset(0, 0)

            -- If there's some kind of stage overlay anim going on, play it.
            if vars.anim_stage_overlay ~= nil then
                assets.stage_overlay:drawImage(floor(vars.anim_stage_overlay.value), 0, 0)
            end
            -- If there's some kind of gameplay overlay anim going on, play it.
            if vars.anim_overlay ~= nil then
                assets['overlay_' .. vars.overlay]:drawImage(floor(vars.anim_overlay.value), 0, 0)
            end
            if vars.lap_string ~= nil then
                assets.kapel_doubleup_outline:drawTextAligned(vars.lap_string, 200, vars.anim_lap_string.value, kTextAlignment.center)
            end
            -- Draw the timer
            assets.image_timer:draw(vars.anim_hud.value + vars.anim_ui_offset.value, 3 - (vars.anim_ui_offset.value / 7.4))
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            vars.my_cool_buffer = vars.mins .. ":" .. vars.secs .. "." .. vars.mils
            assets.times_new_rally:drawText(vars.my_cool_buffer, 44 + vars.anim_hud.value + vars.anim_ui_offset.value, 20 - (vars.anim_ui_offset.value / 7.4))
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            -- Draw the Rocket Arms icon, when applicable
            if assets.image_item ~= nil then
                assets.image_item:draw(313 - vars.anim_hud.value, 0)
            end
            -- Draw the power meter
            assets.image_meter_r:drawImage(floor((vars.rowbot * 14.5)) + 1, 0, 177 - vars.anim_hud.value)
            assets.image_meter_p:drawImage(min(30, max(1, 30 - floor(vars.player * 14.5))), 200, 177 - vars.anim_hud.value)
            if assets.shades ~= nil then
                assets.shades:draw(89 - vars.anim_shades_x.value, 215 - vars.anim_hud.value - vars.anim_shades_y.value)
            end

            gfx.setDrawOffset(vars.x, vars.y)
        end
    end

    -- Little debug dot, representing the middle of the screen.
    class('race_debug').extends(gfx.sprite)
    function race_debug:init()
        race_debug.super.init(self)
        self:moveTo(vars.boat_x, vars.boat_y)
        self:setImage(gfx.image.new(4, 4, gfx.kColorBlack))
        self:setZIndex(99)
        self:add()
    end

    -- Set the sprites
    self.below = race_below()
    self.stage = race_stage()
    if vars.mode == "debug" then -- If there's debug mode, add the dot.
        self.debug = race_debug()
    else -- If not, then add the boat.
        if vars.cpu_x ~= nil then
            self.cpu = boat("cpu", vars.cpu_x, vars.cpu_y, vars.stage, vars.stage_x, vars.stage_y, vars.follow_polygon)
        end
        self.boat = boat("race", vars.boat_x, vars.boat_y, vars.stage, vars.stage_x, vars.stage_y)
        -- After the intro animation, start the race.
        pd.timer.performAfterDelay(2000, function()
            self:start()
        end)
    end
    self:add()
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
        if vars.in_progress and not self.boat.boosting then
            -- ... then boost! :3
            self.boat:boost() -- The boat does most of this, of course.
            vars.overlay = "boost"
            vars.anim_overlay:resetnew(1000, 1, #assets.overlay_boost) -- Setting the WOOOOSH overlay
            vars.anim_overlay.repeats = true
            pd.timer.performAfterDelay(2500, function() -- and taking it away after a while.
                vars.anim_overlay:resetnew(0, 0, 0)
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

-- The function what makes the boat leap up high in the air
function race:leap(cpu)
    -- If you're not already leaping,
    if cpu then
        if not self.cpu.leaping then
            self.cpu:leap() -- The boat.lua code handles most of this.
            self.stage:setZIndex(-2) -- Put the stage under the boat
            pd.timer.performAfterDelay(1450, function()
                if not self.boat.leaping then -- If the race hasn't ended (e.g. if you haven't been beached,)
                    self.stage:setZIndex(1) -- Put the stage back over the boat
                end
            end)
        end
    else
        if vars.in_progress and not self.boat.leaping then
            self.boat:leap() -- The boat.lua code handles most of this.
            self.stage:setZIndex(-2) -- Put the stage under the boat
            pd.timer.performAfterDelay(1450, function()
                if vars.in_progress then -- If the race hasn't ended (e.g. if you haven't been beached,)
                    if self.cpu ~= nil then
                        if not self.cpu.leaping then
                            self.stage:setZIndex(1) -- Put the stage back over the boat
                        end
                    else
                        self.stage:setZIndex(1) -- Put the stage back over the boat
                    end
                end
            end)
        end
    end
end

-- Start the race! (Start the countdown for the race, more specifically.)
function race:start()
    vars.started = true
    assets.sfx_countdown:play()
    vars.anim_overlay:resetnew(3900, 1, #assets.overlay_countdown)
    vars.overlay = "countdown"
    pd.timer.performAfterDelay(3000, function()
        vars.in_progress = true
        music:play(0)
        self.boat:state(true, true, true)
        self.boat:start()
        if vars.cpu_x ~= nil then
            self.cpu:state(true)
            self.cpu:start()
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
        vars.in_progress = false
        vars.finished = true
        fademusic(1) -- I gotta see if 0 works on this thing LOL
        self.boat:state(false, false, false)
        if timeout then -- If you ran the timer past 09:59.00...
            vars.won = false -- Beans to whatever the other thing says, YOU LOST!
            self.boat:finish(duration, false) -- This true/false is for the turning peel-out, btw.
            vars.anim_overlay:resetnew(0, 0, 0)
            assets.sfx_ref:play() -- TWEEEEEEEEEEEEET!!!
        else
            self.boat:finish(duration, true)
            vars.anim_overlay:resetnew(1000, 1, #assets.overlay_fade) -- Flash!
            vars.overlay = "fade"
            assets.sfx_finish:play() -- Applause!
        end
        pd.timer.performAfterDelay(2500, function()
            scenemanager:switchscene(results, vars.stage, vars.mode, vars.current_time, vars.won, self.boat.crashes)
        end)
    end
end

-- This function takes a score number as input, and spits out the proper time in minutes, seconds, and milliseconds
function race:timecalc(num)
    vars.mins = floor((num/30) / 60)
    vars.secs = floor((num/30) - vars.mins * 60)
    vars.mils = floor((num/30)*99 - vars.mins * 5940 - vars.secs * 99)
    if vars.secs < 10 then vars.secs = '0' .. vars.secs end
    if vars.mils < 10 then vars.mils = '0' .. vars.mils end
end

function race:checkpointcheck(cpu)
    if cpu then
        local x, y, cpu_collisions, cpu_count = self.cpu:checkCollisions(self.cpu.x, self.cpu.y)
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
                        self.cpu:finish(1500, true)
                        if not vars.finished then
                            vars.won = false
                        end
                    end
                end
                vars.cpu_last_checkpoint = tag
            elseif tag == 255 then
                -- CPU is colliding with boat.
                local cpu_body = self.cpu.transform:transformedPolygon(self.cpu.poly_body_crash)
                cpu_body:translate(self.cpu.x, self.cpu.y)
                local player_scale = self.boat.scale_factor
                local player_body = self.boat.transform:transformedPolygon(self.boat.poly_body_crash)
                player_body:translate(self.boat.x, self.boat.y)
                for i = 1, player_body:count() do
                    if cpu_body:containsPoint(player_body:getPointAt(i)) then
                        local angle = atan(self.boat.y - self.cpu.y, self.boat.x - self.cpu.x) - 1.57
                        self.cpu:moveBy(sin(angle) * 1.9, -cos(angle) * 1.9)
                        self.boat:moveBy(-sin(angle) * (1.9 * player_scale), cos(angle) * (1.9 * player_scale))
                    end
                end
            elseif vars.whirlpools_x ~= nil and tag ~= 255 then
                -- CPU is colliding with a whirlpool.
                local angle = atan(self.cpu.y - (vars.whirlpools_y[tag - 42] + 34), self.cpu.x - (vars.whirlpools_x[tag - 42] + 34)) - 1.57
                self.cpu:moveBy(sin(angle) * 2.5, -cos(angle) * 2.5)
            elseif vars.boost_pads_x ~= nil and tag ~= 255 then
                -- CPU is colliding with a boost pad.
                self.cpu:boost()
            elseif vars.leap_pads_x ~= nil and tag ~= 255 then
                -- CPU is colliding with a leap pad.
                self:leap(true)
            end
        end
    else
        local _, _, boat_collisions, boat_count = self.boat:checkCollisions(self.boat.x, self.boat.y)
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
                        vars.lap_string = vars['lap_string_' .. vars.current_lap]
                        vars.anim_lap_string:resetnew(500, -30, 20, pd.easingFunctions.outBack)
                        pd.timer.performAfterDelay(1500, function()
                            vars.anim_lap_string:resetnew(500, 20, -30, pd.easingFunctions.inBack)
                        end)
                        if vars.current_lap == 2 then
                            assets.sfx_start:play()
                        elseif vars.current_lap == 3 then
                            assets.sfx_final:play()
                            music:pause()
                            music:setOffset(0)
                            music:setRate(1.1)
                            pd.timer.performAfterDelay(1750, function()
                                music:play()
                            end)
                        end
                        assets.image_timer = assets['image_timer_' .. vars.current_lap]
                    end
                end
                vars.last_checkpoint = tag
            elseif vars.whirlpools_x ~= nil and tag ~= 255 then
                -- Boat is colliding with a whirlpool.
                local player_scale = self.boat.scale_factor
                local angle = atan(self.boat.y - (vars.whirlpools_y[tag - 42] + 34), self.boat.x - (vars.whirlpools_x[tag - 42] + 34)) - 1.57
                self.boat:moveBy(sin(angle) * (2.5 * player_scale), -cos(angle) * (2.5 * player_scale))
            elseif vars.boost_pads_x ~= nil and tag ~= 255 then
                -- Boat is colliding with a boost pad.
                self:boost(false)
            elseif vars.leap_pads_x ~= nil and tag ~= 255 then
                -- Boat is colliding with a leap pad.
                self:leap(false)
            end
        end
    end
end

-- Scene update loop
function race:update()
    vars.x, vars.y = gfx.getDrawOffset() -- Gimme the draw offset
    local x = vars.x
    local y = vars.y
    local time = save.total_playtime
    if vars.mode == "debug" then -- If debug mode is enabled,
        -- These have to be in the update loop because there's no way to just check if a button's held on every frame using an input handler. Weird.
        if pd.buttonIsPressed('up') then
            self.debug:moveBy(0, -5)
        end
        if pd.buttonIsPressed('down') then
            self.debug:moveBy(0, 5)
        end
        if pd.buttonIsPressed('left') then
            self.debug:moveBy(-5, 0)
        end
        if pd.buttonIsPressed('right') then
            self.debug:moveBy(5, 0)
        end
        if pd.buttonJustPressed('a') then -- If A is pressed, print out the coords that the debug dot is sitting on.
            print(floor(self.debug.x) .. ', ' .. floor(self.debug.y) .. ', ')
        end
        gfx.setDrawOffset(-self.debug.x + 200, -self.debug.y + 120) -- Move the camera to wherever the debug dot is.
    else
        vars.rowbot = self.boat.turn_speedo.value
        vars.player = self.boat.crankage_divvied
        self:timecalc(vars.current_time) -- Calc this thing out for the timer
        if vars.in_progress then -- If the race is happenin', then
            vars.current_time += 1 -- Up that timer, babyyyyyyyyy!
            if vars.current_time == 17970 then -- If you pass 9:59.00 in game-time,
                self:finish(true) -- YOU'RE OUT!!
            end
            save.total_racetime += 1 -- Statz!
            if vars.mode == "story" then -- If you're in the story mode...
                if save.current_story_slot == 1 then
                    save.slot1_racetime += 1 -- Per-slot statz!!
                elseif save.current_story_slot == 2 then
                    save.slot2_racetime += 1 -- Per-slot statz!!
                elseif save.current_story_slot == 3 then
                    save.slot3_racetime += 1 -- Per-slot statz!!
                end
            end
            self:checkpointcheck(false)
        end
        if self.boat.crashable and not self.boat.beached then self.boat:collision_check(vars.edges_polygons, assets.image_stagec, self.stage.x, self.stage.y) end
        if self.cpu ~= nil then
            self:checkpointcheck(true)
            if self.cpu.crashable then
                self.cpu:collision_check(vars.edges_polygons, assets.image_stagec_cpu, self.stage.x, self.stage.y)
            end
        end
        if self.boat.beached and vars.in_progress then -- Oh. If it's beached, then
            self:finish(true, 400) -- end the race. Ouch.
        end
    end
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