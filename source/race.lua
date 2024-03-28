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
                if vars.in_progress then
                    if new then
                        vars.anim_hud = pd.timer.new(200, vars.anim_hud.value, -130, pd.easingFunctions.inOutSine)
                        vars.anim_ui_offset = pd.timer.new(200, vars.anim_ui_offset.value, 88, pd.easingFunctions.inOutSine)
                    else
                        vars.anim_hud = pd.timer.new(200, vars.anim_hud.value, 0, pd.easingFunctions.inOutSine)
                        vars.anim_ui_offset = pd.timer.new(200, vars.anim_ui_offset.value, 0, pd.easingFunctions.inOutSine)
                    end
                end
            end)
        end
        setpauseimage(200) -- TODO: Set this X offset
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/stages/water_bg'),
        image_water = gfx.image.new('images/race/stages/water'),
        image_meter = gfx.image.new('images/race/meter'),
        image_pole_cap = gfx.image.new('images/race/pole_cap'),
        trees = gfx.imagetable.new('images/race/stages/tree'),
        trunks = gfx.imagetable.new('images/race/stages/trunk'),
        treetops = gfx.imagetable.new('images/race/stages/treetop'),
        bushes = gfx.imagetable.new('images/race/stages/bush'),
        bushtops = gfx.imagetable.new('images/race/stages/bushtop'),
        audience = gfx.imagetable.new('images/race/stages/audience'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        overlay_boost = gfx.imagetable.new('images/race/boost'),
        overlay_fade = gfx.imagetable.new('images/ui/fade/fade'),
        overlay_countdown = gfx.imagetable.new('images/race/countdown'),
        sfx_countdown = smp.new('audio/sfx/countdown'),
        sfx_start = smp.new('audio/sfx/start'),
        sfx_finish = smp.new('audio/sfx/finish'),
        sfx_ref = smp.new('audio/sfx/ref'),
        image_meter_r = gfx.imagetable.new('images/race/meter/meter_r'),
        image_meter_p = gfx.imagetable.new('images/race/meter/meter_p'),
    }
    assets.sfx_countdown:setVolume(save.vol_sfx/5)
    assets.sfx_start:setVolume(save.vol_sfx/5)
    assets.sfx_finish:setVolume(save.vol_sfx/5)
    assets.sfx_ref:setVolume(save.vol_sfx/5)
   
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
        audience_1 = pd.timer.new(5000, 10, -10),
        audience_2 = pd.timer.new(15000, 10, -10),
        audience_3 = pd.timer.new(25000, 10, -10),
    }
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
    vars.overlay = "fade"

    if save.pro_ui then
        vars.anim_hud = pd.timer.new(500, -230, -130, pd.easingFunctions.outSine)
        vars.anim_ui_offset = pd.timer.new(0, 88, 88)
    else
        vars.anim_hud = pd.timer.new(500, -130, 0, pd.easingFunctions.outSine)
        vars.anim_ui_offset = pd.timer.new(0, 0, 0)
    end

    -- Load in the appropriate images depending on what stage is called. EZ!
    assets.image_stagec = gfx.image.new('images/race/stages/stagec' .. vars.stage)
    assets.image_stage = gfx.imagetable.new('images/race/stages/stage' .. vars.stage)

    vars.stage_x, vars.stage_y = assets.image_stage[1]:getSize()
    vars.stage_x *= 2
    vars.stage_y *= 2
    
    -- Adjust boat's starting X and Y, checkpoint/lap coords, etc. here
    if vars.stage == 1 then
        -- Where to start the boat? (This should probably change depending on story/TT mode)
        vars.boat_x = 375
        vars.boat_y = 1400
        vars.laps = 3 -- How many laps...
        -- The checkpointzzzzz™
        vars.finish = gfx.sprite.addEmptyCollisionSprite(270, 1285, 200, 20)
        vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(725, 530, 225, 20)
        vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(1465, 815, 200, 20)
        vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(730, 1620, 20, 200)
        vars.finish:setTag(0)
        vars.checkpoint_1:setTag(1)
        vars.checkpoint_2:setTag(2)
        vars.checkpoint_3:setTag(3)
        vars.music_loop = 0.701 -- When to start the music loop
        -- Chillin' out, parallaxin', relaxin' all cool
        vars.parallax_short_amount = 1.05
        vars.parallax_medium_amount = 1.1
        vars.parallax_long_amount = 1.175
        vars.parallax_tippy_amount = 1.225
        -- Shootin' some B-ball outside of the school
        vars.poles_short_x = {485, 497, 529, 575, 631, 681, 739, 793, 845, 881, 707, 715, 727, 743, 769, 803, 845, 891, 941, 997, 1053, 1111, 1167, 1455, 1455, 1457, 1451, 1421, 1373, 1317, 1261, 1207, 1163, 1135, 1129, 1129, 1133, 1127}
        vars.poles_short_y = {1122, 1062, 1012, 982, 958, 938, 920, 900, 874, 832, 556, 502, 444, 388, 338, 288, 246, 216, 192, 174, 156, 158, 152, 920, 972, 1024, 1076, 1118, 1144, 1160, 1172, 1190, 1220, 1270, 1324, 1380, 1436, 1488}
        vars.poles_medium_x = {267, 469}
        vars.poles_medium_y = {1306, 1306}
        vars.trees_x = {869, 521, 191, 259, 359, 641, 611, 953, 1035, 1265, 1421, 1415, 1573, 1797, 1827, 1739, 1773, 1693, 1439, 1039, 1093, 493, 343, 177, 555}
        vars.trees_y = {146, 1210, 1050, 880, 726, 636, 472, 770, 626, 114, 444, 618, 118, 254, 402, 740, 1142, 1268, 1522, 1512, 1824, 1866, 1802, 1598, 1530}
        vars.trees_rand = {}
        for i = 1, #vars.trees_x do
            table.insert(vars.trees_rand, 1)
        end
        vars.bushes_x = {175, 575, 607, 519, 683, 735, 1011, 956, 1163, 1155, 1267, 1215, 1095, 1391, 1451, 1839, 1823, 1851, 1399, 1399, 1387, 1767, 1799, 1775, 1587, 1359, 1051, 947, 1011, 839, 699, 767}
        vars.bushes_y = {1188, 1060, 1116, 636, 292, 264, 108, 82, 96, 424, 412, 408, 424, 120, 140, 524, 632, 584, 816, 940, 876, 1016, 900, 956, 1396, 1700, 1328, 1408, 1384, 1868, 1868, 1856}
        vars.bushes_rand = {}
        for i = 1, #vars.bushes_x do
            table.insert(vars.bushes_rand, math.random(1, 8))
        end
        vars.audience_x = {219, 191, 219, 199, 219, 235, 223, 329, 371, 479, 571, 667, 695, 687, 1083, 955, 1623, 1663, 1763, 1707, 1727, 1703, 1615, 1519, 1419, 1391, 1375, 1287, 1239, 975, 931, 599, 435, 299, 247, 267, 535, 579, 563, 555, 523, 519, 887, 951, 1007, 1035, 1331, 1515, 1491, 1439, 1423, 1427, 1119, 1087, 1083, 927, 895, 795, 675, 639}
        vars.audience_y = {1520, 1472, 1432, 1360, 1320, 1244, 1144, 830, 798, 704, 708, 540, 416, 364, 120, 152, 204, 208, 652, 844, 884, 1012, 1332, 1424, 1404, 1436, 1636, 1760, 1760, 1860, 1836, 1844, 1792, 1692, 1672, 1620, 1436, 1432, 1392, 1340, 1300, 1108, 872, 672, 476, 440, 392, 464, 532, 712, 752, 1004, 1220, 1256, 1424, 1564, 1516, 1588, 1564, 1588}
        vars.audience_rand = {}
        for i = 1, #vars.audience_x do
            table.insert(vars.audience_rand, math.random(1, 2))
        end
    elseif vars.stage == 2 then
        vars.laps = 3
        vars.music_loop = 0
    elseif vars.stage == 3 then
        vars.laps = 3
        vars.music_loop = 0
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
    assets.music = 'audio/music/stage' .. vars.stage -- Set the music

    if vars.laps > 1 then -- Set the timer graphic
        assets.image_timer = gfx.image.new('images/race/timer_1')
    else
        assets.image_timer = gfx.image.new('images/race/timer')
    end

    if vars.mode == "tt" then -- If time trials is here, then add in some boosts.
        assets.image_item = gfx.image.new('images/race/item_3')
        vars.boosts_remaining = 3
    end
    
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('race_water').extends(gfx.sprite)
    function race_water:init()
        race_water.super.init(self)
        self:setImage(assets.image_water)
        self:setIgnoresDrawOffset(true)
        self:setZIndex(-4)
        self:add()
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
        vars.fill_polygons = {
            geo.polygon.new(
            (255 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1312 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (255 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1312 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (480 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1310 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (480 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1310 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (255 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1312 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)),
            geo.polygon.new(
            (255 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1320 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (255 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1320 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (480 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1318 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (480 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1318 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (255 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1320 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)),
            geo.polygon.new(
            259, 1458,
            262, 1558,
            (252 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1558 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (249 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1458 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            259, 1458),
        }
        vars.both_polygons = {
            geo.polygon.new(
            257, 1336,
            260,1436,
            (250 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1436 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (247 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1336 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            257, 1336),
            geo.polygon.new(
            485, 1348,
            487, 1448,
            (497 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1448 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (495 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1348 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            485, 1348),
            geo.polygon.new(
            (255 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1312 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (255 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1320 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (480 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1318 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (480 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x),(1310 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
            (255 * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), (1312 * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)),
        }
        vars.draw_polygons = {
            geo.polygon.new(
            (484 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1120 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (495 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1064 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (527 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1012 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (575 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (984 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (631 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (956 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (679 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (940 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (739 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (920 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (795 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (900 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (843 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (874 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (883 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (832 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y)),
            geo.polygon.new(
            (707 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (556 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (715 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (500 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (727 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (444 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (743 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (388 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (767 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (340 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (803 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (288 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (847 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (248 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (891 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (216 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (943 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (192 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (995 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (172 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1055 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (156 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1111 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (160 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1167 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (152 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y)),
            geo.polygon.new(
            (1455 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (920 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1455 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (972 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1459 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1024 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1451 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1076 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1423 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1116 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1375 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1144 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1315 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1160 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1259 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1172 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1207 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1192 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1163 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1220 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1135 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1272 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1127 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1324 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1127 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1380 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1135 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1436 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
            (1127 * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), (1488 * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y)),
        }
        for i = 1, #vars.drawq do
            drawq = vars.drawq[i]
            if drawq == 1 then
                assets.image_stage[1]:draw(0, 0)
            elseif drawq == 2 then
                assets.image_stage[2]:draw(vars.stage_x / 2, 0)
            elseif drawq == 3 then
                assets.image_stage[3]:draw(0, vars.stage_y / 2)
            elseif drawq == 4 then
                assets.image_stage[4]:draw(vars.stage_x / 2, vars.stage_y / 2)
            end
            gfx.setStencilPattern(0.25, gfx.image.kDitherTypeDiagonalLine)
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
            if drawq == 1 then
                assets.image_stage[1]:draw(0, 0)
            elseif drawq == 2 then
                assets.image_stage[2]:draw(vars.stage_x / 2, 0)
            elseif drawq == 3 then
                assets.image_stage[3]:draw(0, vars.stage_y / 2)
            elseif drawq == 4 then
                assets.image_stage[4]:draw(vars.stage_x / 2, vars.stage_y / 2)
            end
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.clearStencil()
        end
        for i = 1, #vars.audience_x do
            if max(-x-10, min(-x+410, vars.audience_x[i])) == vars.audience_x[i] then
                if max(-y-10, min(-y+250, vars.audience_y[i])) == vars.audience_y[i] then
                    assets.audience:drawImage(
                        vars.audience_rand[i],
                        (vars.audience_x[i] - 25) * vars.parallax_short_amount + (vars.stage_x * -vars.stage_progress_short_x),
                        (vars.audience_y[i] - 25) * vars.parallax_short_amount + (vars.stage_y * -vars.stage_progress_short_y) + vars['audience_' .. (vars.audience_rand[i] % 3)].value)
                end
            end
        end
        for i = 1, #vars.bushes_x do
            if max(-x-40, min(-x+440, vars.bushes_x[i])) == vars.bushes_x[i] then
                if max(-y-40, min(-y+280, vars.bushes_y[i])) == vars.bushes_y[i] then
                    assets.bushes:drawImage(
                        vars.bushes_rand[i],
                        (vars.bushes_x[i] - 41),
                        (vars.bushes_y[i] - 39))
                    assets.bushtops:drawImage(
                        vars.bushes_rand[i],
                        (vars.bushes_x[i] - 41) * vars.parallax_short_amount + (vars.stage_x * -vars.stage_progress_short_x),
                        (vars.bushes_y[i] - 39) * vars.parallax_short_amount + (vars.stage_y * -vars.stage_progress_short_y))
                    gfx.setStencilPattern(0.50, gfx.image.kDitherTypeDiagonalLine)
                    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
                    assets.bushes:drawImage(
                        vars.bushes_rand[i],
                        (vars.bushes_x[i] - 41),
                        (vars.bushes_y[i] - 39))
                    gfx.setImageDrawMode(gfx.kDrawModeCopy)
                    gfx.clearStencil()
                end
            end
        end
        gfx.setLineWidth(5)
        for i = 1, #vars.draw_polygons do
            gfx.drawPolygon(vars.draw_polygons[i])
        end
        gfx.setLineWidth(18) -- Make the lines phat
        for i = 1, #vars.poles_short_x do -- For every short pole,
            -- Draw it from the base point to the short parallax point
            if max(-x-10, min(-x+410, vars.poles_short_x[i])) == vars.poles_short_x[i] then
                if max(-y-10, min(-y+250, vars.poles_short_y[i])) == vars.poles_short_y[i] then
                    gfx.drawLine(
                        vars.poles_short_x[i],
                        vars.poles_short_y[i],
                        (vars.poles_short_x[i] * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x),
                        (vars.poles_short_y[i] * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y))
                    assets.image_pole_cap:draw(
                        (vars.poles_short_x[i] - 6) * vars.parallax_short_amount + (vars.stage_x * -vars.stage_progress_short_x),
                        (vars.poles_short_y[i] - 6) * vars.parallax_short_amount + (vars.stage_y * -vars.stage_progress_short_y))
                end
            end
        end
        -- Draw the medium poles too
        for i = 1, #vars.poles_medium_x do
            if max(-x-10, min(-x+410, vars.poles_medium_x[i])) == vars.poles_medium_x[i] then
                if max(-y-10, min(-y+250, vars.poles_medium_y[i])) == vars.poles_medium_y[i] then
                    gfx.drawLine(
                        vars.poles_medium_x[i],
                        vars.poles_medium_y[i],
                        (vars.poles_medium_x[i] * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x),
                        (vars.poles_medium_y[i] * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y))
                    assets.image_pole_cap:draw(
                        (vars.poles_medium_x[i] - 6) * vars.parallax_medium_amount + (vars.stage_x * -vars.stage_progress_medium_x),
                        (vars.poles_medium_y[i] - 6) * vars.parallax_medium_amount + (vars.stage_y * -vars.stage_progress_medium_y))
                end
            end
        end
        gfx.setLineWidth(2) -- Set the line width back
        for i = 1, #vars.fill_polygons do
            gfx.fillPolygon(vars.fill_polygons[i])
        end
        gfx.setColor(gfx.kColorWhite)
        for i = 1, #vars.both_polygons do
            gfx.fillPolygon(vars.both_polygons[i])
        end
        gfx.setColor(gfx.kColorBlack)
        for i = 1, #vars.both_polygons do
            gfx.drawPolygon(vars.both_polygons[i])
        end
        for i = 1, #vars.trees_x do
            if max(-x-45, min(-x+445, vars.trees_x[i])) == vars.trees_x[i] then
                if max(-y-45, min(-y+285, vars.trees_y[i])) == vars.trees_y[i] then
                    assets.trunks:drawImage(
                        vars.trees_rand[i],
                        (vars.trees_x[i] - 66),
                        (vars.trees_y[i] - 66))
                    assets.trees:drawImage(
                        vars.trees_rand[i],
                        (vars.trees_x[i] - 66) * vars.parallax_long_amount + (vars.stage_x * -vars.stage_progress_long_x),
                        (vars.trees_y[i] - 66) * vars.parallax_long_amount + (vars.stage_y * -vars.stage_progress_long_y))
                    assets.treetops:drawImage(
                        vars.trees_rand[i],
                        (vars.trees_x[i] - 66) * vars.parallax_tippy_amount + (vars.stage_x * -vars.stage_progress_tippy_x),
                        (vars.trees_y[i] - 66) * vars.parallax_tippy_amount + (vars.stage_y * -vars.stage_progress_tippy_y))
                    gfx.setStencilPattern(0.50, gfx.image.kDitherTypeDiagonalLine)
                    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
                    assets.trees:drawImage(
                        vars.trees_rand[i],
                        (vars.trees_x[i] - 66) * vars.parallax_long_amount + (vars.stage_x * -vars.stage_progress_long_x),
                        (vars.trees_y[i] - 66) * vars.parallax_long_amount + (vars.stage_y * -vars.stage_progress_long_y))
                    gfx.setImageDrawMode(gfx.kDrawModeCopy)
                    gfx.clearStencil()
                end
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
            if vars.finished or not vars.started then
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                assets['overlay_' .. vars.overlay]:drawImage(math.floor(vars.anim_overlay.value), 0, 0)
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            else
                assets['overlay_' .. vars.overlay]:drawImage(math.floor(vars.anim_overlay.value), 0, 0)
            end
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
        assets.image_meter_r:drawImage(math.floor((vars.rowbot * 15)) + 1, 0, 177 - vars.anim_hud.value)
        assets.image_meter_p:drawImage(math.floor(math.clamp(32 - vars.player * 2.2, 3, 32)) + 1, 200, 177 - vars.anim_hud.value)
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
    self.water = race_water()
    self.stage = race_stage()
    if vars.mode == "debug" then -- If there's debug mode, add the dot.
        self.debug = race_debug()
    else -- If not, then add the boat.
        self.boat = boat(vars.boat_x, vars.boat_y, true)
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
        vars.anim_overlay = pd.timer.new(500, 1, #assets.overlay_boost) -- Setting the WOOOOSH overlay
        vars.overlay = "boost"
        vars.anim_overlay.repeats = true
        pd.timer.performAfterDelay(2500, function() -- and taking it away after a while.
            vars.anim_overlay = nil
        end)
        if rocketarms then
            vars.boosts_remaining -= 1
            assets.image_item = gfx.image.new('images/race/item_active')
            pd.timer.performAfterDelay(50, function()
                if vars.boosts_remaining ~= 0 then
                    assets.image_item = gfx.image.new('images/race/item_' .. vars.boosts_remaining)
                else
                    assets.image_item = gfx.image.new('images/race/item_used')
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
    vars.anim_overlay = pd.timer.new(3900, 1, #assets.overlay_countdown)
    vars.overlay = "countdown"
    pd.timer.performAfterDelay(3000, function()
        vars.in_progress = true
        newmusic(assets.music, true, vars.music_loop) -- Adding new music
        self.boat:state(true, true, true)
        self.boat:start()
    end)
end

-- Finish the race
-- Timeout's a boolean for if you finished normally or by running the clock.
-- Duration is a number for the amount of time the boat should take to stop.
function race:finish(timeout, duration)
    if vars.in_progress then
        if save.pro_ui then
            vars.anim_hud = pd.timer.new(500, vars.anim_hud.value, -230, pd.easingFunctions.inSine)
        else
            vars.anim_hud = pd.timer.new(500, vars.anim_hud.value, -130, pd.easingFunctions.inSine)
        end
        vars.in_progress = false
        vars.finished = true
        fademusic(1) -- I gotta see if 0 works on this thing LOL
        self.boat:state(false, false, false)
        if timeout then -- If you ran the timer past 09:59.00...
            vars.won = false -- Beans to whatever the other thing says, YOU LOST!
            self.boat:finish(false, duration) -- This true/false is for the turning peel-out, btw.
            vars.anim_overlay = nil
            assets.sfx_ref:play() -- TWEEEEEEEEEEEEET!!!
        else
            self.boat:finish(true, duration)
            vars.anim_overlay = pd.timer.new(1000, 1, #assets.overlay_fade) -- Flash!
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
    vars.mins = math.floor((num/30) / 60)
    vars.secs = math.floor((num/30) - vars.mins * 60)
    vars.mils = math.floor((num/30)*99 - vars.mins * 5940 - vars.secs * 99)
end

-- Scene update loop
function race:update()
    if vars.mode == "debug" then -- If debug mode is enabled,
        vars.drawq = {1, 2, 3, 4}
        -- These have to be in the update loop because there's no way to just check if a button's held on every frame using an input handler. Weird.
        if pd.buttonIsPressed('up') then
            self.debug:moveBy(0, -4)
        end
        if pd.buttonIsPressed('down') then
            self.debug:moveBy(0, 4)
        end
        if pd.buttonIsPressed('left') then
            self.debug:moveBy(-4, 0)
        end
        if pd.buttonIsPressed('right') then
            self.debug:moveBy(4, 0)
        end
        if pd.buttonJustPressed('a') then -- If A is pressed, print out the coords that the debug dot is sitting on.
            print(math.floor(self.debug.x) .. ', ' .. math.floor(self.debug.y) .. ', ')
            -- table.insert(vars.trees_x, self.debug.x)
            -- table.insert(vars.trees_y, self.debug.y)
            -- table.insert(vars.trees_rand, 1)
        end
        gfx.setDrawOffset(-self.debug.x + 200, -self.debug.y + 120) -- Move the camera to wherever the debug dot is.
    else
        vars.rowbot = self.boat.turn_speedo.value
        vars.player = self.boat.crankage
        -- self.hud:moveTo((math.clamp(vars.player, 0, self.boat.turn * 2) - (vars.rowbot * self.boat.turn)) * 10, 0)
        if vars.in_progress then -- If the race is happenin', then
            vars.current_time += 1 -- Up that timer, babyyyyyyyyy!
            self:timecalc(vars.current_time) -- Calc this thing out for the timer
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
            local _, _, collisions, count = self.boat:checkCollisions(self.boat.x, self.boat.y)
            for i = 1, count do
                local tag = collisions[i].other:getTag()
                if tag > 0 then
                    if vars.current_checkpoint == tag - 1 and vars.last_checkpoint == tag - 1 then
                        vars.current_checkpoint = tag
                    end
                else
                    if vars.current_checkpoint == 3 and vars.last_checkpoint == 3 then
                        vars.current_checkpoint = 0
                        vars.current_lap += 1
                        if vars.current_lap > vars.laps then -- The race is done.
                            self:finish(false)
                        else
                            if vars.current_lap == 2 then
                                assets.sfx_start:play()
                                -- TODO: visual feedback on timer
                            elseif vars.current_lap == 3 then
                                -- TODO: visual feedback on timer
                                -- TODO: "final lap" audio que
                                -- TODO: figure out how to speed up music
                            end
                            assets.image_timer = gfx.image.new('images/race/timer_' .. vars.current_lap)
                        end
                    end
                end
                vars.last_checkpoint = tag
            end
        end
        vars.drawq = {}
        if self.boat.x < (vars.stage_x / 2) + 400 and self.boat.y < (vars.stage_y / 2) + 240 then
            table.insert(vars.drawq, 1)
        end
        if self.boat.x > (vars.stage_x / 2) - 400 and self.boat.y < (vars.stage_y / 2) + 240 then
            table.insert(vars.drawq, 2)
        end
        if self.boat.x < (vars.stage_x / 2) + 400 and self.boat.y > (vars.stage_y / 2) - 240 then
            table.insert(vars.drawq, 3)
        end
        if self.boat.x > (vars.stage_x / 2) - 400 and self.boat.y > (vars.stage_y / 2) - 240 then
            table.insert(vars.drawq, 4)
        end
        if self.boat.crashable then -- If the boat's crashable, then do a collision check.
            self.boat:collision_check(assets.image_stagec, 0, 0)
            if self.boat.beached and vars.in_progress then -- Oh. If it's beached, then
                self:finish(true, 400) -- end the race. Ouch.
            end
        end
    end
    local x, y = gfx.getDrawOffset() -- Gimme the draw offset
    self.water:moveTo(x%400, y%240) -- Move the water sprite to keep it in frame
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