import 'title'
import 'cutscene'
import 'boat'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local min <const> = math.min
local max <const> = math.max
local ceil <const> = math.ceil
local floor <const> = math.floor
local random <const> = math.random
local deg <const> = math.deg
local atan <const> = math.atan2
local abs <const> = math.abs
local text <const> = gfx.getLocalizedText

class('tutorial').extends(gfx.sprite) -- Create the scene's class
function tutorial:init(...)
    tutorial.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem(text('skiptutorial'), function()
            self:leave()
        end)
        menu:addMenuItem(text('quitfornow'), function()
            self.boat.sfx_row:stop()
            scenemanager:transitionsceneonewayback(title)
        end)
        setpauseimage(200) -- TODO: Set this X offset
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('stages/tutorial/water_bg'),
        water = gfx.imagetable.new('stages/tutorial/water'),
        caustics = gfx.imagetable.new('stages/tutorial/caustics'),
        caustics_overlay = gfx.image.new('stages/tutorial/caustics_overlay'),
        image_meter_r = gfx.imagetable.new('images/race/meter/meter_r'),
        image_meter_p = gfx.imagetable.new('images/race/meter/meter_p'),
        image_popup_banner = gfx.image.new('images/ui/popup_banner'),
        pedallica = gfx.font.new('fonts/pedallica'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        overlay_fade = gfx.imagetable.new('images/ui/fade/fade'),
        sfx_ref = smp.new('audio/sfx/ref'),
        sfx_ui = smp.new('audio/sfx/ui'),
        sfx_clickon = smp.new('audio/sfx/clickon'),
        sfx_clickoff = smp.new('audio/sfx/clickoff'),
        image_a = gfx.image.new('images/ui/a'),
        image_tutorial_crank = gfx.image.new('images/ui/tutorial_crank'),
        image_tutorial_up = gfx.image.new('images/ui/tutorial_up'),
        image_stagec = gfx.image.new('stages/tutorial/stagec'),
    }
    assets.sfx_ref:setVolume(save.vol_sfx/5)
    assets.sfx_ui:setVolume(save.vol_sfx/5)
    assets.sfx_clickon:setVolume(save.vol_sfx/5)
    assets.sfx_clickoff:setVolume(save.vol_sfx/5)

    if perf then
        assets.image_stage = gfx.image.new('stages/tutorial/stage_flat')
    else
        assets.image_stage = gfx.image.new('stages/tutorial/stage')
        assets.parallax_short_bake = gfx.image.new('stages/tutorial/parallax_short_bake')
        assets.parallax_medium_bake = gfx.image.new('stages/tutorial/parallax_medium_bake')
        assets.parallax_long_bake = gfx.image.new('stages/tutorial/parallax_long_bake')
    end

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        current_step = 1,
        progressable = false,
        hud_open = false,
        progress_delay = 1500,
        gameplay_progress = 0,
        up = pd.timer.new(500, 0, 10, pd.easingFunctions.inSine),
        water = pd.timer.new(2000, 1, 16),
        anim_hud = pd.timer.new(0, -130, -130),
        leaving = false,
        down = false,
        showstage = false,
        boundsx = 0,
        boundsy = 0,
    }
    vars.tutorialHandlers = {
        AButtonDown = function()
            vars.down = true
        end,
        AButtonUp = function()
            self:progress()
            vars.down = false
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
    pd.inputHandlers.push(vars.tutorialHandlers)

    vars.water.repeats = true
    vars.up.repeats = true
    vars.up.reverses = true
    vars.up.reverseEasingFunction = pd.easingFunctions.outBack
    vars.anim_hud.discardOnCompletion = false

    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

    vars.anim_overlay = pd.timer.new(1000, 1, #assets.overlay_fade)
    vars.anim_overlay.discardOnCompletion = false

    -- Chillin' out, parallaxin', relaxin' all cool
    vars.stage_progress_short_x = 0
    vars.stage_progress_short_y = 0
    vars.stage_progress_medium_x = 0
    vars.stage_progress_medium_y = 0
    vars.stage_progress_long_x = 0
    vars.stage_progress_long_y = 0
    if perf then
        vars.parallax_short_amount = 1
        vars.parallax_medium_amount = 1
        vars.parallax_long_amount = 1
    else
        vars.parallax_short_amount = 1.05
        vars.parallax_medium_amount = 1.1
        vars.parallax_long_amount = 1.175
    end
    vars.edges_polygons = {
        geo.polygon.new(0, 0, 595, 0, 595, 45, 595, 110, 595, 145, 595, 175, 600, 195, 595, 205, 600, 230, 595, 275, 595, 305, 600, 345, 595, 380, 600, 435, 595, 480, 575, 520, 555, 550, 535, 570, 500, 600, 445, 640, 405, 665, 345, 710, 300, 750, 265, 790, 240, 825, 220, 865, 205, 905, 195, 955, 190, 990, 195, 1045, 210, 1105, 225, 1140, 250, 1175, 310, 1230, 370, 1270, 430, 1315, 655, 1470, 800, 1575, 860, 1625, 890, 1660, 910, 1695, 930, 1770, 925, 1815, 920, 1835, 895, 1865, 845, 1910, 790, 1950, 735, 1985, 680, 2035, 640, 2080, 615, 2130, 605, 2175, 600, 2215, 600, 2330, 600, 2430, 600, 2500, 595, 2500, 595, 2560, 585, 2610, 570, 2645, 545, 2685, 520, 2710, 480, 2740, 440, 2755, 395, 2770, 350, 2775, 305, 2770, 275, 2765, 235, 2775, 190, 2780, 135, 2775, 90, 2760, 60, 2750, 15, 2745, 0, 2745, 0, 0),
        geo.polygon.new(805, 0, 1410, 0, 1410, 2780, 1350, 2780, 1295, 2775, 1245, 2770, 1150, 2780, 1095, 2770, 1085, 2770, 1060, 2760, 1030, 2755, 955, 2750, 920, 2740, 885, 2715, 855, 2685, 830, 2650, 815, 2615, 805, 2580, 805, 2515, 805, 2380, 810, 2295, 810, 2230, 830, 2180, 855, 2145, 890, 2115, 935, 2085, 985, 2045, 1030, 2015, 1070, 1985, 1105, 1945, 1125, 1915, 1145, 1870, 1155, 1820, 1160, 1775, 1160, 1750, 1150, 1705, 1130, 1640, 1130, 1635, 1095, 1580, 1055, 1530, 1015, 1495, 910, 1415, 840, 1365, 735, 1295, 725, 1290, 650, 1230, 570, 1180, 490, 1120, 455, 1090, 435, 1065, 425, 1020, 425, 975, 445, 920, 470, 875, 510, 830, 565, 785, 635, 740, 720, 670, 760, 630, 780, 595, 795, 560, 805, 500, 810, 435, 810, 335, 805, 190, 805, 0),
        geo.polygon.new(0, 2725, 0, 3645, 1405, 3665, 1405, 2715, 1180, 2760, 1180, 3470, 230, 3470, 230, 2680, 0, 2725),
        geo.polygon.new(0, 0, 595, 0, 595, 45, 595, 110, 595, 145, 595, 175, 600, 195, 595, 205, 600, 230, 595, 275, 595, 305, 600, 345, 595, 380, 600, 435, 595, 480, 575, 520, 555, 550, 535, 570, 500, 600, 445, 640, 405, 665, 345, 710, 300, 750, 265, 790, 240, 825, 220, 865, 205, 905, 195, 955, 190, 990, 195, 1045, 210, 1105, 225, 1140, 250, 1175, 310, 1230, 370, 1270, 430, 1315, 655, 1470, 800, 1575, 860, 1625, 890, 1660, 910, 1695, 930, 1770, 925, 1815, 920, 1835, 895, 1865, 845, 1910, 790, 1950, 735, 1985, 680, 2035, 640, 2080, 615, 2130, 605, 2175, 600, 2215, 600, 2330, 600, 2430, 600, 2500, 595, 2500, 595, 2560, 585, 2610, 570, 2645, 545, 2685, 520, 2710, 480, 2740, 440, 2755, 395, 2770, 350, 2775, 305, 2770, 275, 2765, 235, 2775, 190, 2780, 135, 2775, 90, 2760, 60, 2750, 15, 2745, 0, 2745, 0, 0),
        geo.polygon.new(805, 0, 1410, 0, 1410, 2780, 1350, 2780, 1295, 2775, 1245, 2770, 1150, 2780, 1095, 2770, 1085, 2770, 1060, 2760, 1030, 2755, 955, 2750, 920, 2740, 885, 2715, 855, 2685, 830, 2650, 815, 2615, 805, 2580, 805, 2515, 805, 2380, 810, 2295, 810, 2230, 830, 2180, 855, 2145, 890, 2115, 935, 2085, 985, 2045, 1030, 2015, 1070, 1985, 1105, 1945, 1125, 1915, 1145, 1870, 1155, 1820, 1160, 1775, 1160, 1750, 1150, 1705, 1130, 1640, 1130, 1635, 1095, 1580, 1055, 1530, 1015, 1495, 910, 1415, 840, 1365, 735, 1295, 725, 1290, 650, 1230, 570, 1180, 490, 1120, 455, 1090, 435, 1065, 425, 1020, 425, 975, 445, 920, 470, 875, 510, 830, 565, 785, 635, 740, 720, 670, 760, 630, 780, 595, 795, 560, 805, 500, 810, 435, 810, 335, 805, 190, 805, 0),
        geo.polygon.new(626, 0, 691, 0, 691, 245, 626, 245, 626, 0)
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.image_water_bg:draw(0, 0)
        assets.caustics[floor(vars.water.value)]:draw((floor(vars.x / 4) * 2 % 400) - 400, (floor(vars.y / 4) * 2 % 240) - 240) -- Move the water sprite to keep it in frame
        assets.caustics_overlay:draw(0, 0)
        assets.water[floor(vars.water.value)]:draw(((vars.x * 0.8) % 400) - 400, ((vars.y * 0.8) % 240) - 240) -- Move the water sprite to keep it in frame
    end)

    class('tutorial_stage').extends(gfx.sprite)
    function tutorial_stage:init()
        tutorial_stage.super.init(self)
        self:setZIndex(1)
        self:setCenter(0, 0)
        self:setSize(vars.stage_x, vars.stage_y)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function tutorial_stage:draw()
        if vars.showstage then
            assets.image_stage:draw(0, 0)

            if not perf then
                local x = vars.x
                local y = vars.y
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

                assets.parallax_short_bake:draw(stage_progress_short_x, stage_progress_short_y)
                assets.parallax_medium_bake:draw(stage_progress_medium_x, stage_progress_medium_y)
                assets.parallax_long_bake:draw(stage_progress_long_x, stage_progress_long_y)
            end
        end

        gfx.setDrawOffset(0, 0)
        if vars.hud_open then
            assets.image_popup_banner:draw(0, 0)
            if vars.current_step == 6 then
                if not save.button_controls and pd.isSimulator ~= 1 then
                    if pd.isCrankDocked() then
                        assets.pedallica:drawTextAligned(text('tutorial_step_6c'), 200, 14, kTextAlignment.center)
                    else
                        assets.pedallica:drawTextAligned(text('tutorial_step_6a'), 200, 14, kTextAlignment.center)
                    end
                else
                    assets.pedallica:drawTextAligned(text('tutorial_step_6b'), 200, 14, kTextAlignment.center)
                end
            elseif vars.current_step == 14 then
                assets.image_tutorial_up:draw(10, 80 + vars.up.value)
                assets.kapel_doubleup:drawText('Up!!', 30, 103 + vars.up.value)
                if not save.button_controls and pd.isSimulator ~= 1 then
                    assets.pedallica:drawTextAligned(text('tutorial_step_14a'), 200, 14, kTextAlignment.center)
                else
                    assets.pedallica:drawTextAligned(text('tutorial_step_14b'), 200, 14, kTextAlignment.center)
                end
            else
                assets.pedallica:drawTextAligned(text('tutorial_step_' .. vars.current_step), 200, 14, kTextAlignment.center)
            end
            if vars.progressable then
                if vars.down then
                    assets.image_a:draw(340, 55)
                else
                    assets.image_a:draw(340, 50)
                end
            end
        end
        -- Draw the power meter
        assets.image_meter_r:drawImage(floor((vars.rowbot * 14.5)) + 1, 0, 177 - vars.anim_hud.value)
        assets.image_meter_p:drawImage(min(30, max(1, 30 - floor(vars.player * 14.5))), 200, 177 - vars.anim_hud.value)
        -- If there's some kind of gameplay overlay anim going on, play it.
        if vars.anim_overlay ~= nil then
            assets['overlay_fade']:drawImage(math.floor(vars.anim_overlay.value), 0, 0)
        end

        gfx.setDrawOffset(vars.x, vars.y)
    end
    -- Set the sprites
    self.stage = tutorial_stage()
    self.boat = boat("tutorial", 0, 0, 0, vars.stage_x, vars.stage_y, nil, false, "story")
    self:add()

    pd.timer.performAfterDelay(1500, function()
        vars.hud_open = true
        pd.timer.performAfterDelay(vars.progress_delay, function()
            vars.progressable = true
        end)
    end)

    newmusic('audio/sfx/sea', true)
end

-- fast atan2. Thanks, nnnn!
function tutorial:fastatan(y, x)
    local a = min(abs(x), abs(y)) / max(abs(x), abs(y))
    local s = a * a
    local r = ((-0.0464964749 * s + 0.15931422) * s - 0.327622764) * s * a + a
    if abs(y) > abs(x) then r = 1.57079637 - r end
    if x < 0 then r = 3.14159274 - r end
    if y < 0 then r = -r end
    return r
end

function tutorial:progress()
    if vars.progressable then
        assets.sfx_clickon:play()
        vars.hud_open = false
        vars.current_step += 1
        vars.progressable = false
        if vars.current_step == 3 then
            self.boat:state(true, true, false)
            self.boat:start()
        elseif vars.current_step == 6 then
            self.boat:state(true, true, true)
        elseif vars.current_step == 7 then
            self.boat:state(true, true, false)
        elseif vars.current_step == 8 then
            vars.anim_hud:resetnew(750, -130, 0, pd.easingFunctions.outSine)
            assets.sfx_ui:play()
        elseif vars.current_step == 14 then
            -- Turn player turning back on, check for straight line
            self.boat:state(true, true, true)
        elseif vars.current_step == 15 then
            vars.boundsx = -vars.x - (vars.stage_x / 2) + 170
            vars.boundsy = -vars.y - (vars.stage_y) + 900
            self.stage:setIgnoresDrawOffset(false)
            self.stage:moveTo(vars.boundsx, vars.boundsy)
            vars.finish = gfx.sprite.addEmptyCollisionSprite(self.stage.x + 577, self.stage.y + 334, 250, 20)
            vars.finish:setTag(0)
            vars.showstage = true
            for i = 1, #vars.edges_polygons do
                vars.edges_polygons[i]:translate(self.stage.x, self.stage.y)
            end
        end
        if vars.current_step <= 15 then -- If there's more progression, then show the new UI.
            if vars.current_step == 3 or vars.current_step == 8 then -- If you're just turning the Rowbot on, then give it some more time.
                pd.timer.performAfterDelay(vars.progress_delay, function()
                    assets.sfx_clickoff:play()
                    vars.hud_open = true
                    pd.timer.performAfterDelay(vars.progress_delay, function()
                        vars.progressable = true
                    end)
                end)
            else -- Otherwise, just get to it.
                pd.timer.performAfterDelay(vars.progress_delay / 3, function()
                    assets.sfx_clickoff:play()
                    vars.hud_open = true
                    if vars.current_step ~= 6 and vars.current_step ~= 14 then -- Only turn on A-button progression if it's not a gameplay-based skill.
                        pd.timer.performAfterDelay(vars.progress_delay, function()
                            vars.progressable = true
                        end)
                    end
                end)
            end
        end
    end
end

function tutorial:checkpointcheck()
    local _, _, boat_collisions, boat_count = self.boat:checkCollisions(self.boat.x, self.boat.y)
    for i = 1, boat_count do
        local tag = boat_collisions[i].other:getTag()
        if tag == 0 then -- Finish line hit ...
            self:leave()
        end
    end
end

function tutorial:leave()
    if not vars.leaving then
        vars.leaving = true
        save['slot' .. save.current_story_slot .. '_progress'] = "cutscene2"
        fademusic(999)
        vars.anim_overlay:resetnew(1000, math.floor(vars.anim_overlay.value), 1)
        self.boat:state(false, false, false)
        self.boat:finish(1500, false)
        pd.timer.performAfterDelay(1000, function()
            scenemanager:switchstory()
        end)
    end
end

function tutorial:update()
    local delta = pd.getElapsedTime()
    print(delta)
    pd.resetElapsedTime()
    vars.x, vars.y = gfx.getDrawOffset() -- Gimme the draw offset
    local x = vars.x + vars.boundsx
    local y = vars.y + vars.boundsy
    if vars.current_step == 6 and vars.player > 0 then
        vars.gameplay_progress += 1
        if vars.gameplay_progress >= 130 then
            vars.progressable = true
            self:progress()
        end
    end
    if vars.current_step == 14 and vars.player > 0 then
        if self.boat.rotation >= 340 or self.boat.rotation <= 20 then
            vars.gameplay_progress += 1
            if vars.gameplay_progress >= 260 then
                vars.progressable = true
                self:progress()
            end
        end
    end
    if vars.current_step > 14 then
        self:checkpointcheck()
        if self.boat.crashable then self.boat:collision_check(vars.edges_polygons, assets.image_stagec, self.stage.x, self.stage.y) end
    end
    -- Set up the parallax!
    if not perf then
        vars.stage_progress_short_x = (((-x + 200) / (vars.stage_x)) * (vars.parallax_short_amount - 1))
        vars.stage_progress_short_y = (((-y + 120) / (vars.stage_y)) * (vars.parallax_short_amount - 1))
        vars.stage_progress_medium_x = (((-x + 200) / (vars.stage_x)) * (vars.parallax_medium_amount - 1))
        vars.stage_progress_medium_y = (((-y + 120) / (vars.stage_y)) * (vars.parallax_medium_amount - 1))
        vars.stage_progress_long_x = (((-x + 135) / (vars.stage_x)) * (vars.parallax_long_amount - 1))
        vars.stage_progress_long_y = (((-y + 60) / (vars.stage_y)) * (vars.parallax_long_amount - 1))
    end
    self.boat:update(delta)
    vars.rowbot = self.boat.turn_speedo.value
    vars.player = self.boat.crankage_divvied
end