-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random
local text <const> = gfx.getLocalizedText

function race:stage_init()
    if perf then
        assets.image_stage = gfx.image.new('stages/5/stage_flat')
    else
        assets.image_stage = gfx.image.new('stages/5/stage')
        assets.parallax_short_bake = gfx.image.new('stages/5/parallax_short_bake')
        assets.parallax_medium_bake = gfx.image.new('stages/5/parallax_medium_bake')
        assets.parallax_long_bake = gfx.image.new('stages/5/parallax_long_bake')
    end
    assets.image_stagec = gfx.image.new('stages/5/stagec')
    assets.bug_1 = gfx.imagetable.new('stages/5/bug_1')
    assets.bug_2 = gfx.imagetable.new('stages/5/bug_2')
    assets.bug_3 = gfx.imagetable.new('stages/5/bug_3')
    assets.image_water_bg = gfx.image.new('stages/5/water_bg')
    assets.water = gfx.imagetable.new('stages/5/water')
    assets.caustics = gfx.imagetable.new('stages/5/caustics')
    assets.caustics_overlay = gfx.image.new('stages/5/caustics_overlay')
    assets.leap_pad = gfx.imagetable.new('stages/5/leap_pad')
    assets.minimap = gfx.image.new('stages/5/minimap')

    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

    assets.stage_overlay = assets['bug_' .. random(1, 3)]
    vars.anim_stage_overlay = pd.timer.new(6500, 1, 91)
    vars.anim_stage_overlay.timerEndedCallback = function()
        assets.stage_overlay = nil
        assets.stage_overlay = assets['bug_' .. random(1, 3)]
    end
    vars.anim_stage_overlay.repeats = true

    if vars.mode == "tt" then
        vars.boat_x = 2200
        vars.boat_y = 1250
    else
        vars.boat_x = 2230
        vars.boat_y = 1250
        vars.cpu_x = 2165
        vars.cpu_y = 1250
        vars.cpu_current_lap = 1
        vars.cpu_current_checkpoint = 0
        vars.cpu_last_checkpoint = 0
        if save['slot' .. save.current_story_slot .. '_circuit'] == 1 then
            vars.follow_polygon = pd.geometry.polygon.new(2165, 1180,
                2185, 1060,
                2230, 985,
                2315, 925,
                2275, 850,
                2330, 730,
                2425, 660,
                2510, 625,
                2515, 470,
                2410, 400,
                2345, 425,
                2300, 335,
                2190, 315,
                2110, 385,
                1975, 460,
                1845, 510,
                1760, 530,
                1550, 510,
                1470, 480,
                1355, 380,
                1280, 230,
                1190, 210,
                1115, 265,
                1100, 315,
                1025, 250,
                955, 275,
                730, 240,
                640, 230,
                545, 265,
                390, 275,
                325, 355,
                315, 470,
                375, 595,
                290, 665,
                305, 680,
                345, 810,
                435, 875,
                595, 915,
                740, 900,
                830, 950,
                935, 1080,
                985, 1205,
                985, 1345,
                1025, 1425,
                940, 1480,
                930, 1580,
                1000, 1685,
                1065, 1730,
                1380, 1710,
                1530, 1670,
                1705, 1695,
                1760, 1760,
                1855, 1735,
                1995, 1745,
                2120, 1700,
                2205, 1600,
                2185, 1415)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 2 then
            vars.follow_polygon = pd.geometry.polygon.new(2165, 1130,
                2190, 1020,
                2220, 955,
                2215, 875,
                2280, 790,
                2335, 800,
                2440, 720,
                2440, 640,
                2465, 575,
                2420, 425,
                2340, 385,
                2290, 420,
                2235, 345,
                2155, 375,
                2050, 445,
                1980, 425,
                1890, 500,
                1795, 525,
                1580, 485,
                1505, 440,
                1435, 465,
                1355, 365,
                1330, 260,
                1230, 200,
                1120, 240,
                915, 260,
                745, 240,
                615, 250,
                490, 285,
                360, 320,
                300, 415,
                250, 535,
                180, 610,
                255, 680,
                300, 770,
                500, 880,
                605, 915,
                795, 940,
                950, 1040,
                990, 1195,
                940, 1385,
                960, 1540,
                1045, 1570,
                1000, 1645,
                1100, 1720,
                1360, 1730,
                1485, 1685,
                1580, 1705,
                1700, 1665,
                1835, 1710,
                1975, 1735,
                2120, 1675,
                2205, 1570,
                2180, 1425)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 3 then
            vars.follow_polygon = pd.geometry.polygon.new(2165, 1130,
                2195, 985,
                2250, 815,
                2345, 705,
                2455, 595,
                2485, 475,
                2430, 375,
                2315, 290,
                2160, 355,
                2010, 450,
                1905, 500,
                1790, 520,
                1575, 485,
                1455, 430,
                1355, 350,
                1270, 220,
                1140, 185,
                1040, 240,
                920, 275,
                725, 240,
                525, 225,
                365, 290,
                275, 425,
                250, 600,
                295, 760,
                345, 845,
                520, 905,
                700, 930,
                885, 980,
                955, 1085,
                965, 1250,
                930, 1395,
                900, 1545,
                945, 1660,
                1070, 1725,
                1400, 1725,
                1530, 1680,
                1710, 1695,
                1895, 1720,
                2125, 1680,
                2250, 1595,
                2255, 1500,
                2210, 1375,
                2170, 1275)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 4 then
            vars.follow_polygon = pd.geometry.polygon.new(2165, 1130,
                2195, 985,
                2250, 815,
                2345, 705,
                2455, 595,
                2485, 475,
                2430, 375,
                2315, 290,
                2160, 355,
                2010, 450,
                1905, 500,
                1790, 520,
                1575, 485,
                1455, 430,
                1355, 350,
                1270, 220,
                1140, 185,
                1040, 240,
                920, 275,
                725, 240,
                525, 225,
                365, 290,
                275, 425,
                250, 600,
                295, 760,
                345, 845,
                520, 905,
                700, 930,
                885, 980,
                955, 1085,
                965, 1250,
                930, 1395,
                900, 1545,
                945, 1660,
                1070, 1725,
                1400, 1725,
                1530, 1680,
                1710, 1695,
                1895, 1720,
                2125, 1680,
                2250, 1595,
                2255, 1500,
                2210, 1375,
                2170, 1275)
        end
    end
    vars.laps = 3 -- How many laps...
    vars.lap_string = text('lap1')
    vars.lap_string_2 = text('lap2')
    vars.lap_string_3 = text('lap3')
    vars.anim_lap_string = pd.timer.new(0, -175, -175)
    vars.anim_lap_string.discardOnCompletion = false
    -- The checkpointzzzzz™
    vars.finish = gfx.sprite.addEmptyCollisionSprite(2096, 1130, 200, 20)
    vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(1500, 0, 20, 700)
    vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(895, 1120, 200, 20)
    vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(1105, 1500, 20, 400)
    vars.finish:setTag(0)
    vars.checkpoint_1:setTag(1)
    vars.checkpoint_2:setTag(2)
    vars.checkpoint_3:setTag(3)
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
        vars.parallax_long_amount = 1.25
    end
    -- Poles
    vars.checkpoint_x = 2115
    vars.checkpoint_y = 1150
    vars.checkpoint_width = 160
    -- leap_pads
    vars.leap_pads_x = {1740, 880, 1090}
    vars.leap_pads_y = {465, 210, 1665}
    for i = 1, #vars.leap_pads_x do
        vars['leap_pad_' .. i] = gfx.sprite.addEmptyCollisionSprite(vars.leap_pads_x[i] + 45, vars.leap_pads_y[i], 8, 123)
        vars['leap_pad_' .. i]:setTag(42 + i)
    end
    vars.anim_leap_pad = pd.timer.new(500, 1, 4.99)
    vars.anim_leap_pad.repeats = true
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(2125, 1160, 2125, 1010, 2150, 885, 2220, 775, 2315, 680, 2370, 630, 2410, 570, 2420, 505, 2400, 445, 2355, 415, 2325, 400, 2250, 400, 2210, 415, 1990, 540, 1875, 585, 1695, 590, 1635, 610, 1540, 590, 1445, 545, 1410, 520, 1345, 515, 1260, 545, 1135, 600, 1045, 655, 985, 715, 955, 765, 935, 845, 930, 920, 945, 950, 995, 1005, 1040, 1070, 1065, 1150, 1060, 1265, 1025, 1375, 1000, 1475, 1000, 1530, 1055, 1625, 1105, 1650, 1175, 1655, 1370, 1645, 1495, 1625, 1620, 1610, 1700, 1610, 1745, 1620, 1825, 1650, 1875, 1665, 1985, 1665, 2060, 1640, 2115, 1585, 2135, 1550, 2140, 1510, 2130, 1435, 2125, 1160),
        geo.polygon.new(1335, 430, 1300, 450, 1200, 485, 1095, 540, 985, 610, 880, 725, 825, 875, 820, 895, 755, 885, 610, 885, 525, 865, 450, 820, 395, 770, 370, 725, 355, 685, 350, 625, 365, 545, 385, 480, 420, 420, 465, 375, 535, 340, 620, 325, 710, 330, 780, 340, 875, 350, 970, 335, 1075, 300, 1125, 275, 1185, 270, 1240, 300, 1290, 355, 1335, 430),
        geo.polygon.new(1735, 395, 1635, 395, 1635, 650, 1735, 650, 1735, 395),
        geo.polygon.new(870, 120, 770, 120, 770, 385, 870, 385, 870, 120),
        geo.polygon.new(1205, 1600, 1205, 1850, 1300, 1850, 1300, 1595, 1205, 1600),
        geo.polygon.new(0, 0, vars.stage_x, 0, vars.stage_x, vars.stage_y, 0, vars.stage_x, 0, 0, 280, 305, 410, 190, 510, 150, 620, 145, 650, 145, 720, 130, 785, 155, 850, 190, 885, 205, 985, 205, 1075, 165, 1135, 135, 1220, 135, 1270, 160, 1345, 230, 1420, 325, 1485, 360, 1570, 410, 1645, 435, 1740, 450, 1840, 450, 1925, 430, 2015, 380, 2120, 300, 2205, 260, 2280, 250, 2365, 255, 2470, 300, 2535, 365, 2570, 455, 2570, 530, 2525, 655, 2465, 720, 2375, 815, 2310, 905, 2290, 960, 2270, 1050, 2270, 1400, 2280, 1480, 2290, 1550, 2270, 1640, 2220, 1700, 2140, 1755, 2020, 1785, 1910, 1785, 1780, 1750, 1685, 1725, 1560, 1735, 1430, 1775, 1320, 1795, 1100, 1795, 1000, 1765, 900, 1695, 855, 1595, 845, 1500, 895, 1340, 925, 1240, 930, 1220, 930, 1170, 905, 1105, 830, 1025, 755, 980, 690, 965, 530, 970, 455, 955, 365, 910, 275, 825, 230, 740, 195, 615, 200, 510, 235, 375, 200, 305, 0, 0)
    }
    -- Bounds for the calc'd polygons
    self:fill_polygons()
    self:both_polygons()

    newmusic('audio/music/stage5', true) -- Adding new music
    if music ~= nil then music:pause() end
end

function race:fill_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
    vars.fill_polygons = {}
    table.insert(vars.fill_polygons, geo.polygon.new(
        ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
        ((vars.checkpoint_x - 12) * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), ((vars.checkpoint_y + 6) * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
        ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), ((vars.checkpoint_y + 4) * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
        ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 4) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
        ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)))
    table.insert(vars.fill_polygons, geo.polygon.new(
        ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 14) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
        ((vars.checkpoint_x - 12) * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), ((vars.checkpoint_y + 14) * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
        ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_short_amount) + (vars.stage_x * -vars.stage_progress_short_x), ((vars.checkpoint_y + 12) * vars.parallax_short_amount) + (vars.stage_y * -vars.stage_progress_short_y),
        ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 12) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
        ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 14) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)))
end

function race:both_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
    vars.both_polygons = {}
    table.insert(vars.both_polygons, geo.polygon.new(
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 14) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 12) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 4) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)))
end