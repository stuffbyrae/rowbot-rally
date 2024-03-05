import 'title'
import 'results'
import 'boat'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer

class('race').extends(gfx.sprite) -- Create the scene's class
function race:init(...)
    race.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
     -- Should the crank indicator be shown?
    if save.button_controls or pd.isSimulator == 1 then show_crank = false else show_crank = true end
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
                if new then
                    vars.anim_hud = gfx.animator.new(200, vars.anim_hud:currentValue(), -130, pd.easingFunctions.inOutSine)
                    vars.anim_ui_offset = gfx.animator.new(200, vars.anim_ui_offset:currentValue(), 88, pd.easingFunctions.inOutSine)
                else
                    vars.anim_hud = gfx.animator.new(200, vars.anim_hud:currentValue(), 0, pd.easingFunctions.inOutSine)
                    vars.anim_ui_offset = gfx.animator.new(200, vars.anim_ui_offset:currentValue(), 0, pd.easingFunctions.inOutSine)
                end
            end)
        end
        setpauseimage(200) -- TODO: Set this X offset
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/stages/water_bg'),
        image_timer = gfx.image.new('images/race/timer'),
        image_meter = gfx.image.new('images/race/meter'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        overlay_boost = gfx.imagetable.new('images/race/boost'),
        overlay_fade = gfx.imagetable.new('images/ui/fade/fade'),
        overlay_countdown = gfx.imagetable.new('images/race/countdown'),
        sfx_countdown = smp.new('audio/sfx/countdown'),
        sfx_start = smp.new('audio/sfx/start'),
        sfx_finish = smp.new('audio/sfx/finish'),
        sfx_ref = smp.new('audio/sfx/ref'),
    }
    assets.sfx_countdown:setVolume(save.vol_sfx/5)
    assets.sfx_start:setVolume(save.vol_sfx/5)
    assets.sfx_finish:setVolume(save.vol_sfx/5)
    assets.sfx_ref:setVolume(save.vol_sfx/5)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        stage = args[1], -- A number, 1 through 7, to determine which stage to play.
        mode = args[2], -- A string, either "story" or "tt", to determine which mode to choose.
        debug = args[3], -- A boolean. If true, then this is polygon debug mode.
        current_time = 0,
        mins = "00",
        secs = "00",
        mils = "00",
        started = false,
        in_progress = false,
        finished = false,
        rowbot = 0,
        player = 0,
        won = true,
    }
    vars.raceHandlers = {
        BButtonDown = function() -- TODO: add rocket boost code here.
            self:boost()
        end,
        AButtonDown = function()
            
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
    if not vars.debug then
        pd.inputHandlers.push(vars.raceHandlers)
    end

    local test = pd.geometry.polygon.new(335, 1410, 
    335, 1280, 
    335, 1120, 
    355, 1020, 
    400, 925, 
    470, 845, 
    560, 800, 
    695, 775, 
    800, 730, 
    865, 635, 
    885, 515, 
    915, 395, 
    985, 330, 
    1130, 275, 
    1250, 270, 
    1365, 280, 
    1490, 310, 
    1595, 380, 
    1640, 465, 
    1650, 580, 
    1620, 660, 
    1590, 780, 
    1595, 870, 
    1615, 995, 
    1625, 1110, 
    1600, 1215, 
    1535, 1275, 
    1450, 1295, 
    1345, 1310, 
    1270, 1340, 
    1215, 1380, 
    1185, 1495, 
    1200, 1570, 
    1155, 1645, 
    1045, 1675, 
    910, 1700, 
    715, 1720, 
    555, 1700, 
    435, 1655, 
    375, 1585, 
    360, 1505, 
    335, 1395)

    vars.anim_overlay = gfx.animation.loop.new(20, assets.overlay_fade, false)

    if save.pro_ui then
        vars.anim_hud = gfx.animator.new(500, -230, -130, pd.easingFunctions.outSine)
        vars.anim_ui_offset = gfx.animator.new(0, 88, 88)
    else
        vars.anim_hud = gfx.animator.new(500, -130, 0, pd.easingFunctions.outSine)
        vars.anim_ui_offset = gfx.animator.new(0, 0, 0)
    end

    -- Load in the appropriate images depending on what stage is called. EZ!
    assets.image_stagec = gfx.image.new('images/race/stages/stagec' .. vars.stage)
    assets.image_stage = gfx.image.new('images/race/stages/stage' .. vars.stage)
    
    -- Adjust boat's starting X and Y, checkpoint/lap coords, etc. here
    if vars.stage == 1 then
        vars.boat_x = 375
        vars.boat_y = 1400
    elseif vars.stage == 2 then
    elseif vars.stage == 3 then
    elseif vars.stage == 4 then
    elseif vars.stage == 5 then
    elseif vars.stage == 6 then
    elseif vars.stage == 7 then
    end
    assets.music = 'audio/music/stage' .. vars.stage

    if vars.mode == "story" then
    elseif vars.mode == "tt" then
        assets.image_item = gfx.image.new('images/race/item_3')
        vars.boosts_remaining = 3
    else
        print('Hey, what mode are we tryin to do here tough guy?')
        playdate.stop()
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('race_stage').extends(gfx.sprite)
    function race_stage:init()
        race_stage.super.init(self)
        self:setZIndex(5)
        self:setCenter(0, 0)
        self:setImage(assets.image_stage)
        self:add()
    end

    class('race_stage_fg').extends(gfx.sprite)
    function race_stage_fg:init()
        race_stage_fg.super.init(self)
        self:setZIndex(98)
        self:setCenter(0, 0)
    end

    class('race_hud').extends(gfx.sprite)
    function race_hud:init()
        race_hud.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(99)
        self:setSize(400, 240)
        self:setIgnoresDrawOffset(true)
        if not vars.debug then
            self:add()
        end
    end
    function race_hud:draw()
        -- If there's some kind of stage overlay anim going on, play it.
        if vars.anim_stage_overlay ~= nil then
            vars.anim_stage_overlay:draw(0, 0)
        end
        -- If there's some kind of gameplay overlay anim going on, play it.
        if vars.anim_overlay ~= nil then
            if vars.finished or not vars.started then
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                vars.anim_overlay:draw(0, 0)
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            else
                vars.anim_overlay:draw(0, 0)
            end
        end
        -- Draw the timer
        assets.image_timer:draw(vars.anim_hud:currentValue() + vars.anim_ui_offset:currentValue(), 3 - (vars.anim_ui_offset:currentValue() / 7.4))
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.times_new_rally:drawText(vars.mins .. ":" .. vars.secs .. "." .. vars.mils, 44 + vars.anim_hud:currentValue() + vars.anim_ui_offset:currentValue(), 20 - (vars.anim_ui_offset:currentValue() / 7.4))
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        -- Draw the Rocket Arms icon, when applicable
        if assets.image_item ~= nil then
            assets.image_item:draw(313 - vars.anim_hud:currentValue(), 0)
        end
        -- Draw the power meter
        assets.image_meter:draw(0, 177 - vars.anim_hud:currentValue())
        gfx.setLineWidth(8)
        if vars.rowbot > 0 then
            gfx.drawArc(200, 380 - vars.anim_hud:currentValue(), 160, math.clamp(32 - vars.player * 2.2, 3, 32), 328 + (vars.rowbot * 15))
        end
        gfx.setLineWidth(2)
    end

    class('race_debug').extends(gfx.sprite)
    function race_debug:init()
        race_debug.super.init(self)
        self:moveTo(vars.boat_x, vars.boat_y)
        self:setImage(gfx.image.new(4, 4, gfx.kColorBlack))
        self:add()
    end

    -- Set the sprites
    self.stage = race_stage()
    if vars.debug then
        self.debug = race_debug()
    else
        self.boat = boat(vars.boat_x, vars.boat_y, true)
        -- After the intro animation, start the race.
        pd.timer.performAfterDelay(2000, function()
            self:start()
        end)
    end
    self.stage_fg = race_stage_fg()
    self.hud = race_hud()
    self:add()
    
end

function race:boost()
    if vars.mode == "tt" then
        if vars.in_progress and not self.boat.boosting and vars.boosts_remaining > 0 then
            self.boat:boost()
            vars.boosts_remaining -= 1
            assets.image_item = gfx.image.new('images/race/item_active')
            vars.anim_overlay = gfx.animation.loop.new(100, assets.overlay_boost, true)
            pd.timer.performAfterDelay(50, function()
                if vars.boosts_remaining ~= 0 then
                    assets.image_item = gfx.image.new('images/race/item_' .. vars.boosts_remaining)
                else
                    assets.image_item = gfx.image.new('images/race/item_used')
                end
            end)
            pd.timer.performAfterDelay(2500, function()
                vars.anim_overlay = nil
            end)
        end
    end
end

function race:start()
    vars.started = true
    assets.sfx_countdown:play()
    vars.anim_overlay = gfx.animation.loop.new(68, assets.overlay_countdown, false)
    pd.timer.performAfterDelay(3000, function()
        vars.in_progress = true
        -- newmusic(assets.music, true) -- Adding new music
        self.boat:state(true, true, true)
        self.boat:start()
    end)
end

function race:finish(timeout)
    if vars.in_progress then
        if save.pro_ui then
            vars.anim_hud = gfx.animator.new(500, vars.anim_hud:currentValue(), -230, pd.easingFunctions.inSine)
        else
            vars.anim_hud = gfx.animator.new(500, vars.anim_hud:currentValue(), -130, pd.easingFunctions.inSine)
        end
        vars.in_progress = false
        vars.finished = true
        fademusic(1)
        self.boat:state(false, false, false)
        self.boat:finish(true)
        if timeout then -- If you ran the timer past 09:59.00...
            vars.won = false -- Beans to whatever the other thing says, YOU LOST!
            vars.anim_overlay = nil
            assets.sfx_ref:play()
        else
            vars.anim_overlay = gfx.animation.loop.new(20, assets.overlay_fade, false)
            assets.sfx_finish:play()
        end
        pd.timer.performAfterDelay(2000, function()
            scenemanager:switchscene(results, vars.stage, vars.mode, vars.current_time, vars.won, self.boat.crashes)
        end)
    end
end

-- This function takes a score number as input, and spits out the proper time in minutes, seconds, and milliseconds
-- Local copy to see if that won't make it run a bit faster
function race:timecalc(num)
    local mins = string.format("%02.f", math.floor((num/30) / 60))
    local secs = string.format("%02.f", math.floor((num/30) - mins * 60))
    local mils = string.format("%02.f", (num/30)*99 - mins * 5940 - secs * 99)
    return mins, secs, mils
end

-- Scene update loop
function race:update()
    if vars.debug then
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
        if pd.buttonJustPressed('a') then
            print(math.floor(self.debug.x) .. ', ' .. math.floor(self.debug.y) .. ', ')
        end

        gfx.setDrawOffset(-self.debug.x + 200, -self.debug.y + 120)
    else
        vars.rowbot = self.boat.turn_speedo.value
        vars.player = self.boat.crankage
        if vars.in_progress then
            vars.current_time += 1
            vars.mins, vars.secs, vars.mils = self:timecalc(vars.current_time)
            if vars.current_time == 17970 then
                self:finish(true)
            end
            save.total_racetime += 1
            if vars.mode == "story" then
                save['slot' .. save.current_story_slot .. '_racetime'] += 1
            end
        end
        if vars.started and save.total_playtime % 2 == 0 then
            self.boat:collision_check(assets.image_stagec) -- Have the boat do its collision check against the stage collide image
        end
    end
end