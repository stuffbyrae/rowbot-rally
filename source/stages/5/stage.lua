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
    assets.image_stagec_cpu = assets.image_stagec
    assets.bug_1 = gfx.imagetable.new('stages/5/bug_1')
    assets.bug_2 = gfx.imagetable.new('stages/5/bug_2')
    assets.bug_3 = gfx.imagetable.new('stages/5/bug_3')
    assets.image_water_bg = gfx.image.new('stages/5/water_bg')
    assets.water = gfx.imagetable.new('stages/5/water')
    assets.caustics = gfx.imagetable.new('stages/5/caustics')
    assets.caustics_overlay = gfx.image.new('stages/5/caustics_overlay')
    assets.leap_pad = gfx.imagetable.new('stages/5/leap_pad')

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
        vars.boat_x = 2235
        vars.boat_y = 1250
        vars.cpu_x = 2165
        vars.cpu_y = 1250
        vars.cpu_current_lap = 1
        vars.cpu_current_checkpoint = 0
        vars.cpu_last_checkpoint = 0
        vars.follow_polygon = pd.geometry.polygon.new(2175, 1095, 2200, 945, 2260, 805, 2400, 675, 2520, 575, 2540, 475, 2485, 360, 2370, 300, 2225, 305, 2080, 400, 1985, 490, 1910, 520, 1855, 525, 1580, 525, 1500, 490, 1385, 380, 1295, 245, 1210, 195, 1130, 195, 1075, 240, 1020, 265, 720, 265, 625, 240, 540, 225, 390, 265, 295, 365, 270, 525, 295, 745, 385, 860, 510, 910, 755, 935, 915, 1000, 990, 1130, 985, 1275, 920, 1520, 940, 1650, 985, 1690, 1055, 1725, 1370, 1725, 1515, 1695, 1675, 1670, 1850, 1705, 2010, 1730, 2140, 1695, 2240, 1600, 2190, 1440)
    end
    vars.laps = 3 -- How many laps...
    vars.lap_string = text('lap1')
    vars.lap_string_2 = text('lap2')
    vars.lap_string_3 = text('lap3')
    vars.anim_lap_string = pd.timer.new(0, -175, -175)
    vars.anim_lap_string.discardOnCompletion = false
    -- The checkpointzzzzz™
    vars.finish = gfx.sprite.addEmptyCollisionSprite(2096, 1130, 200, 20)
    vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(1500, 355, 20, 350)
    vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(895, 1120, 200, 20)
    vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(1305, 1640, 20, 200)
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
        geo.polygon.new(0, 0, vars.stage_x, 0, vars.stage_x, vars.stage_y, 0, vars.stage_x, 0, 0, 2265, 1155, 2270, 1035, 2295, 925, 2370, 815, 2495, 690, 2555, 590, 2575, 485, 2550, 395, 2465, 305, 2355, 255, 2230, 255, 2105, 315, 2035, 370, 1965, 410, 1895, 440, 1845, 450, 1770, 455, 1695, 450, 1605, 420, 1515, 390, 1445, 345, 1395, 295, 1345, 235, 1275, 165, 1205, 135, 1105, 145, 1030, 185, 965, 205, 885, 200, 745, 135, 675, 135, 630, 145, 535, 145, 460, 165, 365, 220, 305, 275, 255, 345, 205, 480, 200, 650, 300, 855, 410, 935, 515, 965, 685, 965, 775, 990, 855, 1040, 900, 1095, 930, 1165, 930, 1215, 905, 1315, 860, 1430, 850, 1535, 870, 1645, 930, 1720, 1040, 1780, 1165, 1795, 1335, 1795, 1435, 1770, 1545, 1740, 1655, 1725, 1735, 1735, 1830, 1765, 1975, 1790, 2095, 1770, 2185, 1730, 2260, 1655, 2290, 1590, 2275, 1450, 2270, 1155, 0, 0),
        geo.polygon.new(2120, 1155, 2120, 1060, 2140, 935, 2185, 825, 2275, 715, 2355, 640, 2395, 590, 2420, 515, 2400, 450, 2355, 405, 2295, 395, 2225, 405, 2170, 430, 2015, 525, 1905, 575, 1850, 590, 1745, 595, 1675, 610, 1620, 610, 1510, 580, 1420, 525, 1395, 500, 1320, 520, 1210, 555, 1100, 610, 1015, 670, 950, 745, 920, 800, 910, 865, 925, 920, 945, 955, 990, 1000, 1045, 1080, 1060, 1145, 1065, 1245, 1055, 1295, 1010, 1415, 1000, 1480, 1010, 1565, 1045, 1615, 1090, 1645, 1160, 1655, 1230, 1655, 1450, 1640, 1600, 1615, 1675, 1610, 1755, 1625, 1845, 1655, 1905, 1665, 1995, 1660, 2070, 1630, 2125, 1570, 2140, 1530, 2145, 1505, 2135, 1455, 2130, 1340, 2120, 1155),
        geo.polygon.new(1345, 450, 1305, 365, 1260, 315, 1205, 275, 1155, 270, 1100, 280, 1070, 300, 980, 330, 910, 345, 835, 350, 730, 330, 650, 320, 565, 330, 485, 360, 410, 435, 375, 505, 355, 605, 355, 675, 380, 750, 440, 810, 515, 860, 600, 880, 720, 880, 785, 890, 830, 900, 840, 895, 835, 855, 850, 790, 890, 725, 965, 645, 1045, 585, 1140, 530, 1230, 490, 1310, 465, 1345, 450),
        geo.polygon.new(1635, 380, 1635, 670, 1730, 655, 1730, 380, 1635, 380),
        geo.polygon.new(770, 95, 770, 425, 870, 415, 870, 80, 770, 95),
        geo.polygon.new(1200, 1585, 1200, 1855, 1295, 1850, 1295, 1585, 1200, 1585)
    }
    -- Bounds for the calc'd polygons
    vars.fill_bounds = {}
    self:fill_polygons()
    vars.both_bounds = {}
    self:both_polygons()

    newmusic('audio/music/stage5', true) -- Adding new music
    music:pause()
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
    table.insert(vars.fill_bounds, {vars.checkpoint_x - 12, vars.checkpoint_y + 4, vars.checkpoint_x + vars.checkpoint_width + 11, vars.checkpoint_y + 6})
    table.insert(vars.fill_bounds, {vars.checkpoint_x + 12, vars.checkpoint_y + 12, vars.checkpoint_x + vars.checkpoint_width + 11, vars.checkpoint_y + 14})
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
    table.insert(vars.both_bounds, {vars.checkpoint_x - 12, vars.checkpoint_y + 4, vars.checkpoint_x + vars.checkpoint_width + 11, vars.checkpoint_y + 14})
end