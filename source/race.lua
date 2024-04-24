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
        edges = pd.timer.new(1000, 0, 1),
        audience_1 = pd.timer.new(5000, 10, -10),
        audience_2 = pd.timer.new(15000, 10, -10),
        audience_3 = pd.timer.new(25000, 10, -10),
        anim_parallax = pd.timer.new(0, 0, 0),
    }

    vars.water.repeats = true
    vars.edges.repeats = true
    vars.anim_parallax.discardOnCompletion = false
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
        AButtonDown = function()
            -- Keeping for debug.
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

    -- Load in the appropriate images depending on what stage is called. EZ!
    assets.image_stage = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/stage')
    assets.image_stagec = gfx.image.new('images/race/stages/stage' .. vars.stage .. '/stagec')
    assets.image_water_bg = gfx.image.new('images/race/stages/stage' .. vars.stage .. '/water_bg')
    assets.water = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/water')
    assets.caustics = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/caustics')
    assets.trees = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/tree')
    assets.trunks = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/trunk')
    assets.treetops = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/treetop')
    assets.bushes = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/bush')
    assets.bushtops = gfx.imagetable.new('images/race/stages/stage' .. vars.stage .. '/bushtop')

    vars.tiles_x, vars.tiles_y = assets.image_stage:getSize()
    vars.tile_x, vars.tile_y = assets.image_stage[1]:getSize()
    vars.stage_x = vars.tile_x * vars.tiles_x
    vars.stage_y = vars.tile_y * vars.tiles_y
    
    -- Adjust boat's starting X and Y, checkpoint/lap coords, etc. here
    if vars.stage == 1 then
        -- Where to start the boat? (This should probably change depending on story/TT mode)
        if vars.mode == "tt" then
            vars.boat_x = 375
            vars.boat_y = 1400
        else
            vars.boat_x = 410
            vars.boat_y = 1400
            vars.cpu_x = 335
            vars.cpu_y = 1400
            vars.cpu_current_lap = 1
            vars.cpu_current_checkpoint = 0
            vars.cpu_last_checkpoint = 0
            vars.follow_polygon = pd.geometry.polygon.new(335, 1305, 
            355, 1015, 
            575, 845, 
            820, 730, 
            835, 455, 
            1130, 245, 
            1520, 270, 
            1705, 500, 
            1630, 765, 
            1545, 1040, 
            1490, 1235, 
            1240, 1310, 
            1195, 1560, 
            915, 1745, 
            630, 1755, 
            360, 1545)
        end
        vars.laps = 3 -- How many laps...
        vars.lap_string = gfx.getLocalizedText('lap1')
        vars.lap_string_2 = gfx.getLocalizedText('lap2')
        vars.lap_string_3 = gfx.getLocalizedText('lap3')
        vars.anim_lap_string = pd.timer.new(0, -30, -30)
        vars.anim_lap_string.discardOnCompletion = false
        -- The checkpointzzzzz™
        vars.finish = gfx.sprite.addEmptyCollisionSprite(270, 1290, 200, 20)
        vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(725, 530, 225, 20)
        vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(1465, 815, 200, 20)
        vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(730, 1620, 20, 200)
        vars.finish:setTag(0)
        vars.checkpoint_1:setTag(1)
        vars.checkpoint_2:setTag(2)
        vars.checkpoint_3:setTag(3)
        vars.music_loop = 0.701 -- When to start the music loop
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
        vars.poles_short_x = {485, 497, 529, 575, 631, 681, 739, 793, 845, 881, 707, 715, 727, 743, 769, 803, 845, 891, 941, 997, 1053, 1111, 1167, 1455, 1455, 1457, 1451, 1421, 1373, 1317, 1261, 1207, 1163, 1135, 1129, 1129, 1133, 1127}
        vars.poles_short_y = {1122, 1062, 1012, 982, 958, 938, 920, 900, 874, 832, 556, 502, 444, 388, 338, 288, 246, 216, 192, 174, 156, 158, 152, 920, 972, 1024, 1076, 1118, 1144, 1160, 1172, 1190, 1220, 1270, 1324, 1380, 1436, 1488}
        vars.poles_medium_x = {267, 469}
        vars.poles_medium_y = {1306, 1306}
        -- Trees
        vars.trees_x = {869, 521, 191, 259, 359, 641, 611, 953, 1035, 1265, 1421, 1415, 1573, 1797, 1827, 1739, 1773, 1693, 1439, 1039, 1093, 493, 343, 177, 555}
        vars.trees_y = {146, 1210, 1050, 880, 726, 636, 472, 770, 626, 114, 444, 618, 118, 254, 402, 740, 1142, 1268, 1522, 1512, 1824, 1866, 1802, 1598, 1530}
        vars.trees_rand = {}
        for i = 1, #vars.trees_x do
            table.insert(vars.trees_rand, #assets.trees)
        end
        -- Bushes
        vars.bushes_x = {175, 575, 607, 519, 683, 735, 1011, 956, 1163, 1155, 1267, 1215, 1095, 1391, 1451, 1839, 1823, 1851, 1399, 1399, 1387, 1767, 1799, 1775, 1587, 1359, 1051, 947, 1011, 839, 699, 767}
        vars.bushes_y = {1188, 1060, 1116, 636, 292, 264, 108, 82, 96, 424, 412, 408, 424, 120, 140, 524, 632, 584, 816, 940, 876, 1016, 900, 956, 1396, 1700, 1328, 1408, 1384, 1868, 1868, 1856}
        vars.bushes_rand = {}
        for i = 1, #vars.bushes_x do
            table.insert(vars.bushes_rand, random(1, #assets.bushes))
        end
        -- Audience members
        assets.audience1 = gfx.image.new('images/race/audience/audience_basic')
        assets.audience2 = gfx.image.new('images/race/audience/audience_fisher')
        assets.audience3 = gfx.imagetable.new('images/race/audience/audience_nebula')
        vars.audience_x = {219, 191, 219, 199, 219, 235, 223, 329, 371, 479, 571, 667, 695, 687, 1083, 955, 1623, 1663, 1763, 1707, 1727, 1703, 1615, 1519, 1419, 1391, 1375, 1287, 1239, 975, 931, 599, 435, 299, 247, 267, 535, 579, 563, 555, 523, 519, 887, 951, 1007, 1035, 1331, 1515, 1491, 1439, 1423, 1427, 1119, 1087, 1083, 927, 895, 795, 675, 639}
        vars.audience_y = {1520, 1472, 1432, 1360, 1320, 1244, 1144, 830, 798, 704, 708, 540, 416, 364, 120, 152, 204, 208, 652, 844, 884, 1012, 1332, 1424, 1404, 1436, 1636, 1760, 1760, 1860, 1836, 1844, 1792, 1692, 1672, 1620, 1436, 1432, 1392, 1340, 1300, 1108, 872, 672, 476, 440, 392, 464, 532, 712, 752, 1004, 1220, 1256, 1424, 1564, 1516, 1588, 1564, 1588}
        vars.audience_rand = {}
        for i = 1, #vars.audience_x do
            table.insert(vars.audience_rand, random(1, 3))
        end
        -- Race collision edges
        vars.edges_polygons = {
            geo.polygon.new(0, 0, vars.stage_x, 0, vars.stage_x, vars.stage_y, 0, vars.stage_x, 0, 0, 270, 1315, 265, 1130, 265, 1095, 270, 1040, 275, 1030, 285, 990, 290, 970, 295, 945, 305, 925, 310, 910, 325, 885, 355, 850, 405, 805, 445, 780, 480, 765, 520, 750, 585, 725, 630, 710, 670, 685, 705, 655, 715, 635, 720, 580, 730, 515, 730, 500, 735, 470, 740, 450, 745, 420, 755, 400, 765, 365, 805, 310, 825, 285, 850, 260, 870, 245, 905, 225, 920, 215, 965, 200, 1035, 180, 1095, 170, 1160, 165, 1280, 165, 1350, 170, 1390, 175, 1415, 180, 1430, 180, 1470, 190, 1525, 200, 1580, 220, 1615, 235, 1655, 250, 1690, 280, 1715, 305, 1740, 330, 1755, 360, 1770, 395, 1780, 425, 1785, 480, 1780, 530, 1770, 570, 1755, 600, 1735, 640, 1705, 685, 1685, 725, 1665, 785, 1660, 835, 1665, 925, 1670, 1020, 1675, 1060, 1675, 1140, 1670, 1190, 1660, 1220, 1630, 1270, 1590, 1315, 1550, 1340, 1515, 1355, 1475, 1360, 1440, 1370, 1405, 1375, 1375, 1395, 1365, 1420, 1360, 1460, 1360, 1545, 1355, 1580, 1345, 1610, 1330, 1640, 1315, 1660, 1280, 1695, 1240, 1725, 1195, 1745, 1115, 1770, 1010, 1790, 930, 1800, 845, 1805, 670, 1805, 585, 1805, 520, 1790, 460, 1770, 405, 1745, 370, 1720, 335, 1685, 315, 1655, 295, 1615, 285, 1570, 275, 1490, 270, 1395, 270, 1315, 0, 0),
            geo.polygon.new(470, 1305, 465, 1170, 470, 1120, 475, 1090, 475, 1060, 485, 1050, 485, 1045, 495, 1025, 525, 995, 550, 975, 595, 955, 600, 950, 665, 925, 680, 920, 690, 915, 775, 890, 785, 885, 820, 870, 860, 830, 885, 800, 895, 780, 905, 745, 925, 675, 925, 665, 935, 615, 945, 555, 950, 530, 960, 495, 965, 480, 980, 450, 1010, 415, 1030, 405, 1055, 385, 1090, 375, 1185, 365, 1225, 360, 1325, 355, 1360, 355, 1410, 365, 1435, 370, 1480, 385, 1505, 400, 1535, 435, 1545, 465, 1550, 495, 1550, 530, 1540, 565, 1515, 610, 1495, 650, 1475, 690, 1465, 740, 1465, 835, 1470, 895, 1470, 945, 1470, 975, 1475, 1055, 1460, 1105, 1435, 1135, 1395, 1155, 1315, 1175, 1245, 1190, 1210, 1205, 1165, 1240, 1150, 1275, 1145, 1300, 1145, 1370, 1145, 1460, 1140, 1495, 1120, 1530, 1085, 1555, 1030, 1575, 985, 1590, 860, 1610, 805, 1615, 710, 1620, 625, 1615, 590, 1605, 535, 1575, 500, 1535, 480, 1495, 480, 1460, 475, 1385, 470, 1330, 470, 1305)
        }
    elseif vars.stage == 2 then
        vars.laps = 3
        vars.music_loop = 0
    elseif vars.stage == 3 then
        vars.laps = 3
        vars.music_loop = 0
        vars.shades = true
        assets.shades = gfx.image.new('images/race/meter/shades')
        vars.anim_shades_x = pd.timer.new(0, 0, 0)
        vars.anim_shades_x.discardOnCompletion = false
        vars.anim_shades_y = pd.timer.new(0, 0, 0)
        vars.anim_shades_y.discardOnCompletion = false
    elseif vars.stage == 4 then
        vars.laps = 1
        vars.music_loop = 0
    elseif vars.stage == 5 then
        vars.laps = 3
        vars.music_loop = 0
    elseif vars.stage == 6 then
        vars.laps = 3
        vars.music_loop = 0
    elseif vars.stage == 7 then
        vars.laps = 1
        vars.music_loop = 0
    end

    newmusic('audio/music/stage' .. vars.stage, true, vars.music_loop) -- Adding new music
    music:pause()

    
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

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)
    
    class('race_caustics').extends(gfx.sprite)
    function race_caustics:init()
        race_caustics.super.init(self)
        self:setImage(assets.caustics[1])
        self:setIgnoresDrawOffset(true)
        self:setZIndex(-5)
        self:add()
    end
    function race_caustics:update()
        self:setImage(assets.caustics[floor(vars.water.value)])
    end

    class('race_water').extends(gfx.sprite)
    function race_water:init()
        race_water.super.init(self)
        self:setImage(assets.water[1])
        self:setIgnoresDrawOffset(true)
        self:setZIndex(-4)
        self:add()
    end
    function race_water:update()
        self:setImage(assets.water[floor(vars.water.value)])
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

        vars.fill_polygons = {
            geo.polygon.new(
            (255 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1312 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (255 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1312 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (480 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1310 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (480 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1310 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (255 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1312 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y)),
            geo.polygon.new(
            (255 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1320 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (255 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1320 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (480 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1318 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (480 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1318 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (255 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1320 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y)),
            geo.polygon.new(
            259, 1458,
            262, 1558,
            (252 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1558 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (249 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1458 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            259, 1458),
        }

        vars.both_polygons = {
            geo.polygon.new(
            257, 1336,
            260,1436,
            (250 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1436 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (247 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1336 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            257, 1336),
            geo.polygon.new(
            485, 1348,
            487, 1448,
            (497 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1448 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (495 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1348 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            485, 1348),
            geo.polygon.new(
            (255 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1312 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (255 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1320 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (480 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1318 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (480 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x),(1310 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y),
            (255 * parallax_medium_amount) + (stage_x * -stage_progress_medium_x), (1312 * parallax_medium_amount) + (stage_y * -stage_progress_medium_y)),
        }

        vars.draw_polygons = {
            geo.polygon.new(
            (484 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1120 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (495 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1064 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (527 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1012 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (575 * parallax_short_amount) + (stage_x * -stage_progress_short_x),  (984 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (631 * parallax_short_amount) + (stage_x * -stage_progress_short_x),  (956 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (679 * parallax_short_amount) + (stage_x * -stage_progress_short_x),  (940 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (739 * parallax_short_amount) + (stage_x * -stage_progress_short_x),  (920 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (795 * parallax_short_amount) + (stage_x * -stage_progress_short_x),  (900 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (843 * parallax_short_amount) + (stage_x * -stage_progress_short_x),  (874 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (883 * parallax_short_amount) + (stage_x * -stage_progress_short_x),  (832 * parallax_short_amount) + (stage_y * -stage_progress_short_y)),
            geo.polygon.new(
            (707 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (556 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (715 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (500 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (727 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (444 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (743 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (388 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (767 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (340 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (803 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (288 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (847 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (248 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (891 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (216 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (943 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (192 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (995 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (172 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1055 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (156 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1111 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (160 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1167 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (152 * parallax_short_amount) + (stage_y * -stage_progress_short_y)),
            geo.polygon.new(
            (1455 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (920 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1455 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (972 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1459 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1024 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1451 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1076 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1423 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1116 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1375 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1144 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1315 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1160 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1259 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1172 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1207 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1192 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1163 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1220 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1135 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1272 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1127 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1324 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1127 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1380 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1135 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1436 * parallax_short_amount) + (stage_y * -stage_progress_short_y),
            (1127 * parallax_short_amount) + (stage_x * -stage_progress_short_x), (1488 * parallax_short_amount) + (stage_y * -stage_progress_short_y)),
        }

        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(vars.edges.value, gfx.image.kDitherTypeBayer4x4)
        local edges_polygons
        local edges_value = 40 * vars.edges.value
        gfx.setLineWidth(edges_value)
        for i = 1, #vars.edges_polygons do
            edges_polygons = vars.edges_polygons[i]
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

        gfx.setLineWidth(5)

        local draw_polygons
        for i = 1, #vars.draw_polygons do
            draw_polygons = vars.draw_polygons[i]
            gfx.drawPolygon(draw_polygons)
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

        -- Draw the medium poles too
        local poles_medium_x
        local poles_medium_y
        for i = 1, #vars.poles_medium_x do
            poles_medium_x = vars.poles_medium_x[i]
            poles_medium_y = vars.poles_medium_y[i]
            if (poles_medium_x > -x-10 and poles_medium_x < -x+410) and (poles_medium_y > -y-10 and poles_medium_y < -y+250) then
                gfx.drawLine(
                    poles_medium_x,
                    poles_medium_y,
                    (poles_medium_x * parallax_medium_amount) + (stage_x * -stage_progress_medium_x),
                    (poles_medium_y * parallax_medium_amount) + (stage_y * -stage_progress_medium_y))
                image_pole_cap:draw(
                    (poles_medium_x - 6) * parallax_medium_amount + (stage_x * -stage_progress_medium_x),
                    (poles_medium_y - 6) * parallax_medium_amount + (stage_y * -stage_progress_medium_y))
            end
        end

        gfx.setLineWidth(2) -- Set the line width back

        local fill_polygons
        for i = 1, #vars.fill_polygons do
            fill_polygons = vars.fill_polygons[i]
            gfx.fillPolygon(fill_polygons)
        end
        local both_polygons
        gfx.setColor(gfx.kColorWhite)
        for i = 1, #vars.both_polygons do
            both_polygons = vars.both_polygons[i]
            gfx.fillPolygon(both_polygons)
        end
        gfx.setColor(gfx.kColorBlack)
        for i = 1, #vars.both_polygons do
            both_polygons = vars.both_polygons[i]
            gfx.drawPolygon(both_polygons)
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

    class('race_hud').extends(gfx.sprite)
    function race_hud:init()
        race_hud.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:setSize(400, 240)
        self:setIgnoresDrawOffset(true)
        if vars.mode ~= "debug" then
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
            assets['overlay_' .. vars.overlay]:drawImage(floor(vars.anim_overlay.value), 0, 0)
        end
        assets.kapel_doubleup_outline:drawTextAligned(vars.lap_string, 200, vars.anim_lap_string.value, kTextAlignment.center)
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
    self.caustics = race_caustics()
    self.water = race_water()
    self.stage = race_stage()
    if vars.mode == "debug" then -- If there's debug mode, add the dot.
        self.debug = race_debug()
    else -- If not, then add the boat.
        if vars.mode == "story" then
            self.cpu = boat("cpu", vars.cpu_x, vars.cpu_y, vars.stage, vars.stage_x, vars.stage_y, vars.edges_polygons, assets.image_stagec, vars.follow_polygon)
        end
        self.boat = boat("race", vars.boat_x, vars.boat_y, vars.stage, vars.stage_x, vars.stage_y, vars.edges_polygons, assets.image_stagec)
        -- After the intro animation, start the race.
        pd.timer.performAfterDelay(2000, function()
            self:start()
        end)
    end
    self.hud = race_hud()
    self:add()
end

-- BOOOOOOOOOOOOOOOOSH!!! This is for rocket arms in the time trials, and boost pads in the race courses.
-- If rocketarms (bool) is true, then the player activated this at will in a time trial.
function race:boost(rocketarms)
    -- AND THEN AND THEN AND THEN AND THEN AND THEN
    -- If the race is happening, AND the boat's not already boosting, AND you still have boosts left,
    if vars.in_progress and not self.boat.boosting and vars.boosts_remaining > 0 then
        -- ... then boost! :3
        self.boat:boost() -- The boat does most of this, of course.
        vars.anim_parallax:resetnew(750, 0.1, 0, pd.easingFunctions.outSine)
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

-- The function what makes the boat leap up high in the air
function race:leap()
    -- If you're not already leaping,
    if vars.in_progress and not self.boat.leaping then
        self.boat:leap() -- The boat.lua code handles most of this.
        self.stage:setZIndex(-2) -- Put the stage under the boat
        pd.timer.performAfterDelay(1450, function()
            if vars.in_progress then -- If the race hasn't ended (e.g. if you haven't been beached,)
                self.stage:setZIndex(1) -- Put the stage back over the boat
            end
        end)
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
        music:play()
        self.boat:state(true, true, true)
        self.boat:start()
        if vars.mode == "story" then
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
                        if not self.cpu.in_wall then
                            if self.boat.in_wall then
                                self.cpu:moveBy(sin(angle) * 3.8, -cos(angle) * 3.8)
                            else
                                self.cpu:moveBy(sin(angle) * 1.9, -cos(angle) * 1.9)
                            end
                        end
                        if not self.boat.in_wall then
                            if self.cpu.in_wall then
                                self.boat:moveBy(-sin(angle) * (3.8 * player_scale), cos(angle) * (3.8 * player_scale))
                            else
                                self.boat:moveBy(-sin(angle) * (1.9 * player_scale), cos(angle) * (1.9 * player_scale))
                            end
                        end
                    end
                end
            end
        end
    else
        local _, _, boat_collisions, boat_count = self.boat:checkCollisions(self.boat.x, self.boat.y)
        for i = 1, boat_count do
            local tag = boat_collisions[i].other:getTag()
            if tag >= 1 and tag <= 3 then
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
            end
        end
    end
end

-- Scene update loop
function race:update()
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
        vars.parallax_short_amount = vars.base_parallax_short_amount + (abs(vars.player - vars.rowbot) * 0.025) + vars.anim_parallax.value
        vars.parallax_medium_amount = vars.base_parallax_medium_amount + (abs(vars.player - vars.rowbot) * 0.025) + vars.anim_parallax.value
        vars.parallax_long_amount = vars.base_parallax_long_amount + (abs(vars.player - vars.rowbot) * 0.025) + vars.anim_parallax.value
        vars.parallax_tippy_amount = vars.base_parallax_tippy_amount + (abs(vars.player - vars.rowbot) * 0.025) + vars.anim_parallax.value
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
        if self.boat.crashable then self.boat:collision_check(vars.edges_polygons, assets.image_stagec, self.stage.x, self.stage.y) end
        if self.cpu ~= nil and self.cpu.crashable then self.cpu:collision_check(vars.edges_polygons, assets.image_stagec, self.stage.x, self.stage.y) end
        if self.boat.beached and vars.in_progress then -- Oh. If it's beached, then
            self:finish(true, 400) -- end the race. Ouch.
        end
    end
    if self.cpu then self:checkpointcheck(true) end
    local x, y = gfx.getDrawOffset() -- Gimme the draw offset
    self.caustics:moveTo(floor(x / 4) * 2 % 400, floor(y / 4) * 2 % 240) -- Move the water sprite to keep it in frame
    self.water:moveTo((x * 0.8) % 400, (y * 0.8) % 240) -- Move the water sprite to keep it in frame
    -- Set up the parallax!
    vars.stage_progress_short_x = (((-x + 200) / vars.stage_x) * (vars.parallax_short_amount - 1))
    vars.stage_progress_short_y = (((-y + 120) / vars.stage_y) * (vars.parallax_short_amount - 1))
    vars.stage_progress_medium_x = (((-x + 200) / vars.stage_x) * (vars.parallax_medium_amount - 1))
    vars.stage_progress_medium_y = (((-y + 120) / vars.stage_y) * (vars.parallax_medium_amount - 1))
    vars.stage_progress_long_x = (((-x + 135) / vars.stage_x) * (vars.parallax_long_amount - 1))
    vars.stage_progress_long_y = (((-y + 60) / vars.stage_y) * (vars.parallax_long_amount - 1))
    vars.stage_progress_tippy_x = (((-x + 135) / vars.stage_x) * (vars.parallax_tippy_amount - 1))
    vars.stage_progress_tippy_y = (((-y + 60) / vars.stage_y) * (vars.parallax_tippy_amount - 1))
end