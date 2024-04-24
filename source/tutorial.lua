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

class('tutorial').extends(gfx.sprite) -- Create the scene's class
function tutorial:init(...)
    tutorial.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem(gfx.getLocalizedText('skiptutorial'), function()
            self:leave()
        end)
        menu:addMenuItem(gfx.getLocalizedText('quitfornow'), function()
            self.boat.sfx_row:stop()
            scenemanager:transitionsceneonewayback(title)
        end)
        setpauseimage(200) -- TODO: Set this X offset
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_pole_cap = gfx.image.new('images/race/pole_cap'),
        image_water_bg = gfx.image.new('images/race/stages/stage1/water_bg'),
        water = gfx.imagetable.new('images/race/stages/stage1/water'),
        caustics = gfx.imagetable.new('images/race/stages/stage1/caustics'),
        image_meter_r = gfx.imagetable.new('images/race/meter/meter_r'),
        image_meter_p = gfx.imagetable.new('images/race/meter/meter_p'),
        image_stage = gfx.imagetable.new('images/race/stages/tutorial/stage'),
        image_stagec = gfx.image.new('images/race/stages/tutorial/stagec'),
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
        trees = gfx.imagetable.new('images/race/stages/stage1/tree'),
        trunks = gfx.imagetable.new('images/race/stages/stage1/trunk'),
        treetops = gfx.imagetable.new('images/race/stages/stage1/treetop'),
        bushes = gfx.imagetable.new('images/race/stages/stage1/bush'),
        bushtops = gfx.imagetable.new('images/race/stages/stage1/bushtop'),
        audience1 = gfx.image.new('images/race/audience/audience_basic'),
        audience2 = gfx.image.new('images/race/audience/audience_fisher'),
        audience3 = gfx.imagetable.new('images/race/audience/audience_nebula'),
        umbrella = gfx.image.new('images/race/stages/tutorial/umbrella'),
    }
    assets.sfx_ref:setVolume(save.vol_sfx/5)
    assets.sfx_ui:setVolume(save.vol_sfx/5)
    assets.sfx_clickon:setVolume(save.vol_sfx/5)
    assets.sfx_clickoff:setVolume(save.vol_sfx/5)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        current_step = 1,
        progressable = false,
        hud_open = false,
        progress_delay = 1500,
        gameplay_progress = 0,
        up = pd.timer.new(500, 0, 10, pd.easingFunctions.inSine),
        water = pd.timer.new(2000, 1, 16),
        edges = pd.timer.new(1000, 0, 1),
        anim_hud = pd.timer.new(0, -130, -130),
        leaving = false,
        down = false,
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
    vars.edges.repeats = true
    vars.up.repeats = true
    vars.up.reverses = true
    vars.up.reverseEasingFunction = pd.easingFunctions.outBack
    vars.anim_hud.discardOnCompletion = false

    vars.tiles_x, vars.tiles_y = assets.image_stage:getSize()
    vars.tile_x, vars.tile_y = assets.image_stage[1]:getSize()
    vars.stage_x = vars.tile_x * vars.tiles_x
    vars.stage_y = vars.tile_y * vars.tiles_y

    vars.anim_overlay = pd.timer.new(1000, 1, #assets.overlay_fade)
    vars.anim_overlay.discardOnCompletion = false
    vars.finish = gfx.sprite.addEmptyCollisionSprite(1, 1, 1, 1)

    -- Chillin' out, parallaxin', relaxin' all cool
    vars.base_parallax_short_amount = 1.05
    vars.base_parallax_medium_amount = 1.1
    vars.base_parallax_long_amount = 1.175
    vars.base_parallax_tippy_amount = 1.25
    vars.parallax_short_amount = 1.05
    vars.parallax_medium_amount = 1.1
    vars.parallax_long_amount = 1.175
    vars.parallax_tippy_amount = 1.25
    -- Poles
    vars.poles_short_x = {625, 690, 690, 625, 625, 690, 690, 625}
    vars.poles_short_y = {230, 230, 175, 175, 120, 120, 65, 65}
    -- Trees
    vars.trees_x = {530, 620, 740, 180, 115, 510, 500, 865, 535, 890, 1215, 855}
    vars.trees_y = {2120, 1960, 1645, 1225, 1060, 470, 245, 630, 920, 1330, 1630, 2395}
    vars.trees_rand = {}
    for i = 1, #vars.trees_x do
        table.insert(vars.trees_rand, #assets.trees)
    end
    -- Bushes
    vars.bushes_x = {845, 865, 610, 135, 170, 420, 865, 890, 560, 510, 1010, 1225, 1180, 1140, 1215}
    vars.bushes_y = {1740, 1795, 1540, 905, 845, 570, 380, 195, 1080, 1045, 1405, 1830, 1955, 2010, 1895}
    vars.bushes_rand = {}
    for i = 1, #vars.bushes_x do
        table.insert(vars.bushes_rand, random(1, #assets.bushes))
    end
    -- Umbrellas
    vars.umbrellas_x = {160, 450, 570, 900, 1105}
    vars.umbrellas_y = {2575, 2650, 2570, 2635, 2745}
    -- Audience members
    assets.audience1 = gfx.image.new('images/race/audience/audience_basic')
    assets.audience2 = gfx.image.new('images/race/audience/audience_fisher')
    assets.audience3 = gfx.imagetable.new('images/race/audience/audience_nebula')
    vars.audience_x = {125, 320, 360, 500, 845, 990, 1075, 1240, 835, 1070, 1125, 1105, 700, 600, 845, 835, 550, 565, 600, 725, 765, 790, 690, 535, 495, 180, 165, 325, 365}
    vars.audience_y = {2670, 2630, 2645, 2565, 2585, 2700, 2650, 2695, 2300, 2035, 1550, 1510, 1225, 1155, 505, 460, 2380, 2340, 2060, 1940, 1920, 1820, 1550, 1450, 1435, 1130, 970, 670, 645}
    vars.audience_rand = {}
    for i = 1, #vars.audience_x do
        table.insert(vars.audience_rand, random(1, 3))
    end
    vars.edges_polygons = {
        geo.polygon.new(0, 0, 595, 0, 595, 45, 595, 110, 595, 145, 595, 175, 600, 195, 595, 205, 600, 230, 595, 275, 595, 305, 600, 345, 595, 380, 600, 435, 595, 480, 575, 520, 555, 550, 535, 570, 500, 600, 445, 640, 405, 665, 345, 710, 300, 750, 265, 790, 240, 825, 220, 865, 205, 905, 195, 955, 190, 990, 195, 1045, 210, 1105, 225, 1140, 250, 1175, 310, 1230, 370, 1270, 430, 1315, 655, 1470, 800, 1575, 860, 1625, 890, 1660, 910, 1695, 930, 1770, 925, 1815, 920, 1835, 895, 1865, 845, 1910, 790, 1950, 735, 1985, 680, 2035, 640, 2080, 615, 2130, 605, 2175, 600, 2215, 600, 2330, 600, 2430, 600, 2500, 595, 2500, 595, 2560, 585, 2610, 570, 2645, 545, 2685, 520, 2710, 480, 2740, 440, 2755, 395, 2770, 350, 2775, 305, 2770, 275, 2765, 235, 2775, 190, 2780, 135, 2775, 90, 2760, 60, 2750, 15, 2745, 0, 2745, 0, 0),
        geo.polygon.new(805, 0, 1410, 0, 1410, 2780, 1350, 2780, 1295, 2775, 1245, 2770, 1150, 2780, 1095, 2770, 1085, 2770, 1060, 2760, 1030, 2755, 955, 2750, 920, 2740, 885, 2715, 855, 2685, 830, 2650, 815, 2615, 805, 2580, 805, 2515, 805, 2380, 810, 2295, 810, 2230, 830, 2180, 855, 2145, 890, 2115, 935, 2085, 985, 2045, 1030, 2015, 1070, 1985, 1105, 1945, 1125, 1915, 1145, 1870, 1155, 1820, 1160, 1775, 1160, 1750, 1150, 1705, 1130, 1640, 1130, 1635, 1095, 1580, 1055, 1530, 1015, 1495, 910, 1415, 840, 1365, 735, 1295, 725, 1290, 650, 1230, 570, 1180, 490, 1120, 455, 1090, 435, 1065, 425, 1020, 425, 975, 445, 920, 470, 875, 510, 830, 565, 785, 635, 740, 720, 670, 760, 630, 780, 595, 795, 560, 805, 500, 810, 435, 810, 335, 805, 190, 805, 0),
        geo.polygon.new(0, 2725, 0, 3645, 1405, 3665, 1405, 2715, 1180, 2760, 1180, 3470, 230, 3470, 230, 2680, 0, 2725)
    }
    vars.edges_polygons_0 = {
        geo.polygon.new(0, 0, 595, 0, 595, 45, 595, 110, 595, 145, 595, 175, 600, 195, 595, 205, 600, 230, 595, 275, 595, 305, 600, 345, 595, 380, 600, 435, 595, 480, 575, 520, 555, 550, 535, 570, 500, 600, 445, 640, 405, 665, 345, 710, 300, 750, 265, 790, 240, 825, 220, 865, 205, 905, 195, 955, 190, 990, 195, 1045, 210, 1105, 225, 1140, 250, 1175, 310, 1230, 370, 1270, 430, 1315, 655, 1470, 800, 1575, 860, 1625, 890, 1660, 910, 1695, 930, 1770, 925, 1815, 920, 1835, 895, 1865, 845, 1910, 790, 1950, 735, 1985, 680, 2035, 640, 2080, 615, 2130, 605, 2175, 600, 2215, 600, 2330, 600, 2430, 600, 2500, 595, 2500, 595, 2560, 585, 2610, 570, 2645, 545, 2685, 520, 2710, 480, 2740, 440, 2755, 395, 2770, 350, 2775, 305, 2770, 275, 2765, 235, 2775, 190, 2780, 135, 2775, 90, 2760, 60, 2750, 15, 2745, 0, 2745, 0, 0),
        geo.polygon.new(805, 0, 1410, 0, 1410, 2780, 1350, 2780, 1295, 2775, 1245, 2770, 1150, 2780, 1095, 2770, 1085, 2770, 1060, 2760, 1030, 2755, 955, 2750, 920, 2740, 885, 2715, 855, 2685, 830, 2650, 815, 2615, 805, 2580, 805, 2515, 805, 2380, 810, 2295, 810, 2230, 830, 2180, 855, 2145, 890, 2115, 935, 2085, 985, 2045, 1030, 2015, 1070, 1985, 1105, 1945, 1125, 1915, 1145, 1870, 1155, 1820, 1160, 1775, 1160, 1750, 1150, 1705, 1130, 1640, 1130, 1635, 1095, 1580, 1055, 1530, 1015, 1495, 910, 1415, 840, 1365, 735, 1295, 725, 1290, 650, 1230, 570, 1180, 490, 1120, 455, 1090, 435, 1065, 425, 1020, 425, 975, 445, 920, 470, 875, 510, 830, 565, 785, 635, 740, 720, 670, 760, 630, 780, 595, 795, 560, 805, 500, 810, 435, 810, 335, 805, 190, 805, 0),
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('tutorial_caustics').extends(gfx.sprite)
    function tutorial_caustics:init()
        tutorial_caustics.super.init(self)
        self:setImage(assets.caustics[1])
        self:setIgnoresDrawOffset(true)
        self:setZIndex(-5)
        self:add()
    end
    function tutorial_caustics:update()
        self:setImage(assets.caustics[floor(vars.water.value)])
    end

    class('tutorial_water').extends(gfx.sprite)
    function tutorial_water:init()
        tutorial_water.super.init(self)
        self:setImage(assets.water[1])
        self:setIgnoresDrawOffset(true)
        self:setZIndex(-4)
        self:add()
    end
    function tutorial_water:update()
        self:setImage(assets.water[floor(vars.water.value)])
    end

    class('tutorial_stage').extends(gfx.sprite)
    function tutorial_stage:init()
        tutorial_stage.super.init(self)
        self:setZIndex(1)
        self:setCenter(0, 0)
        self:setSize(vars.stage_x, vars.stage_y)
    end
    function tutorial_stage:draw()
        local x, y = gfx.getDrawOffset() -- Gimme the draw offset
        local stage_x = vars.stage_x
        local stage_y = vars.stage_y
        local tiles_x = vars.tiles_x
        local tiles_y = vars.tiles_y
        local tile_x = vars.tile_x
        local tile_y = vars.tile_y
        local parallax_short_amount = vars.parallax_short_amount
        local parallax_medium_amount = vars.parallax_medium_amount
        local parallax_long_amount = vars.parallax_long_amount
        local parallax_tippy_amount = vars.parallax_tippy_amount
        local stage_progress_short_x = vars.stage_progress_short_x
        local stage_progress_short_y = vars.stage_progress_short_y
        local stage_progress_medium_x = vars.stage_progress_medium_x
        local stage_progress_medium_y = vars.stage_progress_medium_y
        local stage_progress_long_x = vars.stage_progress_long_x
        local stage_progress_long_y = vars.stage_progress_long_y
        local stage_progress_tippy_x = vars.stage_progress_tippy_x
        local stage_progress_tippy_y = vars.stage_progress_tippy_y

        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(vars.edges.value, gfx.image.kDitherTypeBayer4x4)
        local edges_polygons
        local edges_value = 40 * vars.edges.value
        gfx.setLineWidth(edges_value)
        for i = 1, #vars.edges_polygons_0 do
            edges_polygons = vars.edges_polygons_0[i]
            gfx.drawPolygon(edges_polygons)
        end
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(2)

        local image_stage
        local draw_x
        local draw_y
        local calc_x
        local calc_y
        for i = 1, tiles_x * tiles_y do
            draw_x = ((i-1) % tiles_x)
            draw_y = ceil(i / tiles_y) - 1
            calc_x = tile_x * draw_x
            calc_y = tile_y * draw_y
            if (calc_x > -x-tile_x and calc_x < -x+400) and (calc_y > -y-tile_y and calc_y < -y+240) then
                image_stage = assets.image_stage[i]
                image_stage:draw(calc_x, calc_y)
            end
        end

        local audience_x
        local audience_y
        local audience_rand
        local tightened_rand
        local audience_angle
        local audience_image
        for i = 1, #vars.audience_x do
            audience_x = vars.audience_x[i]
            audience_y = vars.audience_y[i]
            audience_rand = vars.audience_rand[i]
            tightened_rand = (audience_rand % 3) + 1
            if (audience_x > -x-10 and audience_x < -x+410) and (audience_y > -y-10 and audience_y < -y+250) then
                audience_image = assets['audience' .. audience_rand]
                if audience_image[1] ~= nil then
                    audience_angle = (deg(atan(-y + 120 - audience_y, -x + 200 - audience_x))) % 360
                    audience_image[(floor(audience_angle / 8)) + 1]:draw(
                        (audience_x - 21) * parallax_short_amount + (stage_x * -stage_progress_short_x),
                        (audience_y - 21) * parallax_short_amount + (stage_y * -stage_progress_short_y)
                    )
                else
                    audience_image:draw(
                        (audience_x - 21) * parallax_short_amount + (stage_x * -stage_progress_short_x),
                        (audience_y - 21) * parallax_short_amount + (stage_y * -stage_progress_short_y)
                    )
                end
            end
        end

        local bushes_x
        local bushes_y
        local bushes_rand
        local bushes = assets.bushes
        local bushtops = assets.bushtops
        for i = 1, #vars.bushes_x do
            bushes_x = vars.bushes_x[i]
            bushes_y = vars.bushes_y[i]
            bushes_rand = vars.bushes_rand[i]
            if (bushes_x > -x-40 and bushes_x < -x+440) and (bushes_y > -y-40 and bushes_y < -y+280) then
                bushes:drawImage(
                    bushes_rand,
                    (bushes_x - 41) * parallax_short_amount + (stage_x * -stage_progress_short_x),
                    (bushes_y - 39) * parallax_short_amount + (stage_y * -stage_progress_short_y))
                bushtops:drawImage(
                    bushes_rand,
                    (bushes_x - 41) * parallax_medium_amount + (stage_x * -stage_progress_medium_x),
                    (bushes_y - 39) * parallax_medium_amount + (stage_y * -stage_progress_medium_y))
            end
        end

        gfx.setLineWidth(18) -- Make the lines phat

        local poles_short_x
        local poles_short_y
        local image_pole_cap = assets.image_pole_cap
        for i = 1, #vars.poles_short_x do -- For every short pole,
            poles_short_x = vars.poles_short_x[i]
            poles_short_y = vars.poles_short_y[i]
            -- Draw it from the base point to the short parallax point
            if (poles_short_x > -x-10 and poles_short_x < -x+410) and (poles_short_y > -y-10 and poles_short_y < -y+250) then
                gfx.drawLine(
                    poles_short_x,
                    poles_short_y,
                    (poles_short_x * parallax_short_amount) + (stage_x * -stage_progress_short_x),
                    (poles_short_y * parallax_short_amount) + (stage_y * -stage_progress_short_y))
                image_pole_cap:draw(
                    (poles_short_x - 6) * parallax_short_amount + (stage_x * -stage_progress_short_x),
                    (poles_short_y - 6) * parallax_short_amount + (stage_y * -stage_progress_short_y))
            end
        end

        gfx.setLineWidth(2)

        local umbrellas_x
        local umbrellas_y
        local umbrellas = assets.umbrella
        for i = 1, #vars.umbrellas_x do
            umbrellas_x = vars.umbrellas_x[i]
            umbrellas_y = vars.umbrellas_y[i]
            if (umbrellas_x > -x-45 and umbrellas_x < -x+445) and (umbrellas_y > -y-45 and umbrellas_y < -y+285) then
                umbrellas:draw(
                    (umbrellas_x - 66) * parallax_medium_amount + (stage_x * -stage_progress_medium_x),
                    (umbrellas_y - 66) * parallax_medium_amount + (stage_y * -stage_progress_medium_y))
            end
        end

        local trees_x
        local trees_y
        local trees_rand
        local trunks = assets.trunks
        local trees = assets.trees
        local treetops = assets.treetops
        for i = 1, #vars.trees_x do
            trees_x = vars.trees_x[i]
            trees_y = vars.trees_y[i]
            trees_rand = vars.trees_rand[i]
            if (trees_x > -x-45 and trees_x < -x+445) and (trees_y > -y-45 and trees_y < -y+285) then
                trunks:drawImage(
                    trees_rand,
                    (trees_x - 66),
                    (trees_y - 66))
                trees:drawImage(
                    trees_rand,
                    (trees_x - 66) * parallax_long_amount + (stage_x * -stage_progress_long_x),
                    (trees_y - 66) * parallax_long_amount + (stage_y * -stage_progress_long_y))
                treetops:drawImage(
                    trees_rand,
                    (trees_x - 66) * parallax_tippy_amount + (stage_x * -stage_progress_tippy_x),
                    (trees_y - 66) * parallax_tippy_amount + (stage_y * -stage_progress_tippy_y))
            end
        end
    end

    class('tutorial_hud').extends(gfx.sprite)
    function tutorial_hud:init()
        tutorial_hud.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:setSize(400, 240)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function tutorial_hud:draw()
        if vars.hud_open then
            assets.image_popup_banner:draw(0, 0)
            if vars.current_step == 6 then
                if not save.button_controls and pd.isSimulator ~= 1 then
                    if pd.isCrankDocked() then
                        assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_6c'), 200, 14, kTextAlignment.center)
                    else
                        assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_6a'), 200, 14, kTextAlignment.center)
                    end
                else
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_6b'), 200, 14, kTextAlignment.center)
                end
            elseif vars.current_step == 14 then
                assets.image_tutorial_up:draw(10, 80 + vars.up.value)
                assets.kapel_doubleup:drawText('Up!!', 30, 103 + vars.up.value)
                if not save.button_controls and pd.isSimulator ~= 1 then
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_14a'), 200, 14, kTextAlignment.center)
                else
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_14b'), 200, 14, kTextAlignment.center)
                end
            else
                assets.pedallica:drawTextAligned(gfx.getLocalizedText('tutorial_step_' .. vars.current_step), 200, 14, kTextAlignment.center)
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
    end

    -- Set the sprites
    self.caustics = tutorial_caustics()
    self.water = tutorial_water()
    self.stage = tutorial_stage()
    self.boat = boat("tutorial", 0, 0, 0, vars.stage_x, vars.stage_y, vars.edges_polygons, assets.image_stagec)
    self.hud = tutorial_hud()
    self:add()

    pd.timer.performAfterDelay(1500, function()
        vars.hud_open = true
        pd.timer.performAfterDelay(vars.progress_delay, function()
            vars.progressable = true
        end)
    end)

    newmusic('audio/sfx/sea', true)
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
            local x, y = gfx.getDrawOffset()
            self.stage:moveTo(-x - (vars.stage_x / 2) + 170, -y - (vars.stage_y) + 900)
            vars.finish = gfx.sprite.addEmptyCollisionSprite(self.stage.x + 577, self.stage.y + 334, 250, 20)
            vars.finish:setTag(0)
            self.stage:add()
            for i = 1, #vars.edges_polygons do
                vars.edges_polygons[i]:translate(self.stage.x, self.stage.y)
            end
            -- Add in course just above player
            -- Drop in peach's staircase logic
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
    vars.rowbot = self.boat.turn_speedo.value
    vars.player = self.boat.crankage_divvied
    if vars.current_step == 6 and vars.player > 0 then
        vars.gameplay_progress += 1
        if vars.gameplay_progress >= 90 then
            vars.progressable = true
            self:progress()
        end
    end
    if vars.current_step == 14 and vars.player > 0 then
        if self.boat.rotation >= 340 or self.boat.rotation <= 20 then
            vars.gameplay_progress += 1
            if vars.gameplay_progress >= 180 then
                vars.progressable = true
                self:progress()
            end
        end
    end
    if vars.current_step > 14 then
        self:checkpointcheck()
        if self.boat.crashable then self.boat:collision_check(vars.edges_polygons, assets.image_stagec, self.stage.x, self.stage.y) end
    end
    local x, y = gfx.getDrawOffset() -- Gimme the draw offset
    self.caustics:moveTo(floor(x / 4) * 2 % 400, floor(y / 4) * 2 % 240) -- Move the water sprite to keep it in frame
    self.water:moveTo(x%400, y%240) -- Move the water sprite to keep it in frame
    -- Set up the parallax!
    vars.stage_progress_short_x = (((-x + 200 - self.stage.x) / vars.stage_x) * (vars.parallax_short_amount - 1))
    vars.stage_progress_short_y = (((-y + 120 - self.stage.y) / vars.stage_y) * (vars.parallax_short_amount - 1))
    vars.stage_progress_medium_x = (((-x + 200 - self.stage.x) / vars.stage_x) * (vars.parallax_medium_amount - 1))
    vars.stage_progress_medium_y = (((-y + 120 - self.stage.y) / vars.stage_y) * (vars.parallax_medium_amount - 1))
    vars.stage_progress_long_x = (((-x + 135 - self.stage.x) / vars.stage_x) * (vars.parallax_long_amount - 1))
    vars.stage_progress_long_y = (((-y + 60 - self.stage.y) / vars.stage_y) * (vars.parallax_long_amount - 1))
    vars.stage_progress_tippy_x = (((-x + 135 - self.stage.x) / vars.stage_x) * (vars.parallax_tippy_amount - 1))
    vars.stage_progress_tippy_y = (((-y + 60 - self.stage.y) / vars.stage_y) * (vars.parallax_tippy_amount - 1))
end