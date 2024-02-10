import 'results'
import 'boat'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('race').extends(gfx.sprite) -- Create the scene's class
function race:init(...)
    race.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
     -- Should the crank indicator be shown?
    if save.button_controls or pd.isSimulator == 1 then
        show_crank = false
    else
        show_crank = true
    end
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/stages/water_bg'),
        timer = gfx.image.new('images/race/timer'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        overlay_boost = gfx.imagetable.new('images/race/boost'),
        overlay_fade = gfx.imagetable.new('images/ui/fade/fade'),
        overlay_countdown = gfx.imagetable.new('images/race/countdown'),
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        stage = args[1], -- A number, 1 through 7, to determine which stage to play.
        mode = args[2], -- A string, either "story" or "tt", to determine which mode to choose.
        current_time = 0,
        started = false,
        in_progress = false,
        finished = false,
        anim_in = gfx.animator.new(500, -130, 0, pd.easingFunctions.outSine),
    }
    vars.raceHandlers = {
        BButtonDown = function() -- TODO: add rocket boost code here.
            self:boost()
        end,
        AButtonDown = function()
            self:finish() -- Temp to test out the function
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
    pd.inputHandlers.push(vars.raceHandlers)

    vars.anim_overlay = gfx.animation.loop.new(20, assets.overlay_fade, false)

    -- Load in the appropriate images depending on what stage is called. EZ!
    assets.image_stagec = gfx.image.new('images/race/stages/stagec' .. vars.stage)
    assets.image_stage = gfx.image.new('images/race/stages/stage' .. vars.stage)
    
    -- Adjust boat's starting X and Y, checkpoint/lap coords, etc. here
    if vars.stage == 1 then
        vars.boat_x = 275
        vars.boat_y = 800
    elseif vars.stage == 2 then
    elseif vars.stage == 3 then
    elseif vars.stage == 4 then
    elseif vars.stage == 5 then
    elseif vars.stage == 6 then
    elseif vars.stage == 7 then
    end

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
        self:add()
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
        if not vars.finished then -- Only draw HUD stuff when the race isn't finished
            -- Draw the timer
            assets.timer:draw(vars.anim_in:currentValue(), 5)
            local mins, secs, mils = timecalc(vars.current_time)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            assets.times_new_rally:drawText(mins .. ":" .. secs .. "." .. mils, 44 + vars.anim_in:currentValue(), 20)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            -- Draw the Rocket Arms icon, when applicable
            if assets.image_item ~= nil then
                assets.image_item:drawAnchored(400, 0, 1, 0)
            end
            -- Draw the power meter
        end
    end

    -- Set the sprites
    self.stage = race_stage()
    self.boat = boat(vars.boat_x, vars.boat_y, true)
    self.stage_fg = race_stage_fg()
    self.hud = race_hud()
    self:add()
    
    -- After the intro animation, start the race.
    pd.timer.performAfterDelay(2500, function()
        self:start()
    end)
end

function race:boost()
    if vars.started and not self.boat.boosting and vars.boosts_remaining > 0 then
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

function race:start()
    vars.started = true
    vars.anim_overlay = gfx.animation.loop.new(68, assets.overlay_countdown, false)
    pd.timer.performAfterDelay(3000, function()
        vars.started = true
        vars.in_progress = true
        self.boat:state(true, true, true)
    end)
end

function race:finish(timeout)
    vars.in_progress = false
    vars.finished = true
    self.boat:finish(true)
    if timeout then -- If you ran the timer past 09:59.00...
        vars.won = false -- Beans to whatever the other thing says, YOU LOST!
        -- TODO: referee whistle SFX
    else
        vars.anim_overlay = gfx.animation.loop.new(20, assets.overlay_fade, false)
        -- TODO: finish applause SFX
        -- TODO: calculate vars.won right here and right now.
        vars.won = true -- Placeholder, just for now
    end
    pd.timer.performAfterDelay(2000, function()
        scenemanager:switchscene(results, vars.stage, vars.mode, vars.current_time, vars.won)
    end)
end

-- Scene update loop
function race:update()
    if vars.in_progress then
        vars.current_time += 1
    end
    if vars.started then
        self.boat:collision_check(assets.image_stagec) -- Have the boat do its collision check against the stage collide image
    end
end