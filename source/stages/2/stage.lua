-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random
local text <const> = gfx.getLocalizedText

function race:stage_init()
    assets.image_stagec_cpu = gfx.image.new('stages/2/stagec')
    if perf then
        assets.image_stage_1 = gfx.image.new('stages/2/stage_flat_1')
        assets.image_stage_2 = gfx.image.new('stages/2/stage_flat_2')
        assets.image_stagec_1 = gfx.image.new('stages/2/stagec_1')
        assets.image_stagec_2 = gfx.image.new('stages/2/stagec_2')
    else
        assets.image_stage_1 = gfx.image.new('stages/2/stage_1')
        assets.image_stage_2 = gfx.image.new('stages/2/stage_2')
        assets.parallax_short_bake = gfx.image.new('stages/2/parallax_short_bake')
        assets.parallax_long_bake = gfx.image.new('stages/2/parallax_long_bake')
        assets.image_stagec_1 = assets.image_stage_1
        assets.image_stagec_2 = assets.image_stage_2
    end
    assets.bug_1 = gfx.imagetable.new('stages/2/bug_1')
    assets.bug_2 = gfx.imagetable.new('stages/2/bug_2')
    assets.bug_3 = gfx.imagetable.new('stages/2/bug_3')
    assets.image_water_bg = gfx.image.new('stages/2/water_bg')
    assets.water = gfx.imagetable.new('stages/2/water')
    assets.caustics = gfx.imagetable.new('stages/2/caustics')
    assets.caustics_overlay = gfx.image.new('stages/2/caustics_overlay')
    assets.whirlpool = gfx.imagetable.new('stages/2/whirlpool')

    assets.image_stage = assets.image_stage_1

    vars.lever = 1
    assets.image_stagec = assets.image_stagec_1
    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

    assets.stage_overlay = assets['bug_' .. random(1, 3)]
    vars.anim_stage_overlay = pd.timer.new(6500, 1, 91)
    vars.anim_stage_overlay.timerEndedCallback = function()
        assets.stage_overlay = nil
        assets.stage_overlay = assets['bug_' .. random(1, 3)]
    end
    vars.anim_stage_overlay.repeats = true

    if vars.mode == "tt" then
        vars.boat_x = 375
        vars.boat_y = 1800
    else
        vars.boat_x = 410
        vars.boat_y = 1800
        vars.cpu_x = 335
        vars.cpu_y = 1800
        vars.cpu_current_lap = 1
        vars.cpu_current_checkpoint = 0
        vars.cpu_last_checkpoint = 0
        vars.follow_polygon = pd.geometry.polygon.new(310, 1745,
            280, 1660,
            310, 1545,
            350, 1405,
            440, 1330,
            575, 1250,
            790, 1195,
            1015, 1145,
            1125, 1075,
            1205, 995,
            1285, 875,
            1305, 790,
            1310, 665,
            1280, 550,
            1200, 460,
            1095, 390,
            980, 340,
            855, 335,
            745, 345,
            625, 380,
            520, 450,
            450, 520,
            390, 615,
            350, 720,
            375, 890,
            465, 1020,
            575, 1090,
            675, 1125,
            820, 1160,
            950, 1195,
            1070, 1285,
            1145, 1375,
            1175, 1465,
            1195, 1590,
            1185, 1705,
            1145, 1810,
            1100, 1880,
            1035, 1960,
            920, 2045,
            775, 2085,
            645, 2070,
            515, 2005,
            400, 1925)
    end
    vars.laps = 3 -- How many laps...
    vars.lap_string = text('lap1')
    vars.lap_string_2 = text('lap2')
    vars.lap_string_3 = text('lap3')
    vars.anim_lap_string = pd.timer.new(0, -175, -175)
    vars.anim_lap_string.discardOnCompletion = false
    -- The checkpointzzzzz™
    vars.finish = gfx.sprite.addEmptyCollisionSprite(230, 1635, 230, 20)
    vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(795, 195, 20, 250)
    vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(245, 745, 230, 20)
    vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(795, 1985, 20, 250)
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
        vars.parallax_long_amount = 1.5
    end
    -- Poles
    vars.checkpoint_x = 230
    vars.checkpoint_y = 1645
    vars.checkpoint_width = 230
    -- Whirlpools
    vars.whirlpools_x = {381, 866, 1296, 891, 411, 1136, 906, 426}
    vars.whirlpools_y = {1286, 1246, 674, 211, 536, 1561, 2111, 1996}
    for i = 1, #vars.whirlpools_x do
        vars['whirlpool_' .. i] = gfx.sprite.addEmptyCollisionSprite(vars.whirlpools_x[i] + 16, vars.whirlpools_y[i] + 16, 42, 42)
        vars['whirlpool_' .. i]:setTag(42 + i)
    end
    vars.anim_whirlpool = pd.timer.new(750, 1, 8.99)
    vars.anim_whirlpool.repeats = true
    -- Audience members
    assets.audience1 = gfx.image.new('images/race/audience/audience_basic')
    assets.audience2 = gfx.image.new('images/race/audience/audience_fisher')
    assets.audience3 = gfx.imagetable.new('images/race/audience/audience_nebula')
    assets.audience4 = gfx.imagetable.new('images/race/audience/audience_bird')
    assets.audience5 = gfx.imagetable.new('images/race/audience/audience_cap')
    assets.audience6 = gfx.imagetable.new('images/race/audience/audience_eyes')
    assets.audience7 = gfx.imagetable.new('images/race/audience/audience_luci')
    assets.audience8 = gfx.imagetable.new('images/race/audience/audience_orc')
    assets.audience9 = gfx.imagetable.new('images/race/audience/audience_rowbot')
    assets.audience10 = gfx.imagetable.new('images/race/audience/audience_specs')
    assets.audience11 = gfx.imagetable.new('images/race/audience/audience_spring')
    vars.audience_x = {490, 480, 495, 520, 580, 865, 950, 1090, 1110, 855, 820, 595, 755, 535, 515, 530, 1065, 1090, 1095, 975, 1030, 335, 310, 220, 275, 390, 355, 220, 490, 525, 1205, 1385, 1355, 1345, 1315, 1280, 1300, 1390, 1395, 1390}
    vars.audience_y = {1720, 1685, 1535, 1505, 1415, 1340, 1380, 1625, 1655, 1960, 1965, 1900, 1060, 920, 885, 585, 580, 615, 865, 920, 965, 405, 440, 770, 965, 1230, 1235, 1610, 2150, 2165, 2080, 1670, 1445, 1405, 1130, 1110, 1075, 890, 850, 655}
    vars.audience_rand = {}
    for i = 1, #vars.audience_x do
        table.insert(vars.audience_rand, random(1, 11))
    end
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(450, 1655, 450, 1630, 455, 1595, 465, 1555, 490, 1495, 525, 1435, 560, 1400, 585, 1375, 630, 1350, 680, 1325, 715, 1315, 760, 1310, 795, 1310, 840, 1310, 885, 1320, 940, 1340, 980, 1360, 1015, 1390, 1055, 1430, 1090, 1480, 1110, 1520, 1125, 1550, 1135, 1595, 1135, 1650, 1135, 1700, 1120, 1750, 1115, 1775, 1095, 1820, 1070, 1850, 1040, 1890, 1010, 1920, 980, 1940, 930, 1970, 875, 1985, 820, 1995, 755, 1995, 690, 1980, 640, 1960, 600, 1940, 570, 1915, 530, 1875, 505, 1840, 480, 1795, 460, 1745, 455, 1695),
        geo.polygon.new(795, 1090, 745, 1085, 695, 1075, 640, 1050, 585, 1015, 535, 965, 500, 910, 475, 860, 460, 805, 455, 740, 465, 675, 480, 625, 510, 560, 535, 525, 580, 480, 625, 450, 670, 425, 725, 410, 780, 400, 860, 405, 915, 420, 950, 435, 990, 455, 1025, 480, 1060, 515, 1090, 555, 1115, 610, 1130, 650, 1140, 700, 1145, 755, 1135, 820, 1120, 875, 1100, 915, 1060, 975, 1015, 1015, 985, 1035, 930, 1065, 880, 1080, 835, 1085),
        geo.polygon.new(0, 0, vars.stage_x, 0, vars.stage_x, vars.stage_y, 0, vars.stage_x, 0, 0, 460, 1210, 460, 1170, 415, 1135, 375, 1090, 335, 1030, 310, 980, 280, 910, 260, 830, 255, 745, 265, 645, 280, 575, 310, 500, 340, 445, 375, 400, 420, 345, 480, 295, 540, 255, 600, 225, 690, 195, 775, 185, 850, 185, 920, 195, 975, 205, 1030, 225, 1085, 250, 1130, 280, 1185, 320, 1215, 345, 1245, 380, 1275, 425, 1315, 490, 1335, 530, 1350, 580, 1370, 650, 1375, 725, 1375, 790, 1365, 850, 1350, 905, 1325, 975, 1295, 1025, 1270, 1075, 1230, 1120, 1190, 1155, 1165, 1175, 1160, 1185, 1160, 1220, 1170, 1230, 1200, 1250, 1235, 1290, 1260, 1320, 1290, 1370, 1320, 1425, 1345, 1490, 1360, 1555, 1365, 1615, 1365, 1690, 1355, 1750, 1340, 1810, 1325, 1860, 1290, 1930, 1255, 1980, 1210, 2035, 1165, 2075, 1115, 2115, 1050, 2155, 980, 2180, 885, 2205, 805, 2210, 725, 2205, 655, 2185, 580, 2165, 530, 2135, 480, 2105, 405, 2045, 365, 1995, 320, 1930, 295, 1880, 275, 1830, 255, 1760, 250, 1690, 245, 1625, 250, 1560, 270, 1485, 295, 1420, 335, 1345, 375, 1290, 420, 1245, 445, 1220, 460, 1205, 0, 0),
        geo.polygon.new(405, 1195, 805, 960, 1230, 1195, 795, 1430),
    }
    -- Bounds for the calc'd polygons
    self:fill_polygons()
    self:both_polygons()

    newmusic('audio/music/stage2', true) -- Adding new music
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

function race:lever()
    assets.image_stagec = assets['image_stagec_' .. vars.lever]
    assets.image_stage = assets['image_stage_' .. vars.lever]
end