-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random
local text <const> = gfx.getLocalizedText
local abs <const> = math.abs

function race:stage_init()
    if perf then
        assets.image_stage = gfx.image.new('stages/1/stage_flat')
        assets.image_stagec = gfx.image.new('stages/1/stagec')
    else
        assets.parallax_short_bake = gfx.image.new('stages/1/parallax_short_bake')
        assets.parallax_long_bake = gfx.image.new('stages/1/parallax_long_bake')
        assets.image_stage = gfx.image.new('stages/1/stage')
        assets.image_stagec = assets.image_stage
    end
    assets.image_water_bg = gfx.image.new('stages/1/water_bg')
    assets.water = gfx.imagetable.new('stages/1/water')
    assets.caustics = gfx.imagetable.new('stages/1/caustics')
    assets.caustics_overlay = gfx.image.new('stages/1/caustics_overlay')
    assets.minimap = gfx.image.new('stages/1/minimap')

    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

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
        if save['slot' .. save.current_story_slot .. '_circuit'] == 1 then
            vars.follow_polygon = pd.geometry.polygon.new(335, 1340,
            310, 1200,
            260, 1100,
            330, 1055,
            395, 945,
            515, 805,
            555, 730,
            645, 760,
            765, 730,
            850, 600,
            945, 515,
            975, 475,
            975, 405,
            1060, 305,
            1190, 255,
            1295, 205,
            1355, 160,
            1400, 245,
            1480, 315,
            1605, 355,
            1690, 450,
            1665, 605,
            1615, 740,
            1640, 885,
            1675, 955,
            1630, 1050,
            1590, 1175,
            1510, 1250,
            1395, 1305,
            1380, 1400,
            1315, 1400,
            1270, 1460,
            1185, 1625,
            1090, 1680,
            945, 1725,
            850, 1775,
            815, 1815,
            765, 1725,
            600, 1735,
            455, 1685,
            375, 1585,
            415, 1450)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 2 then
            vars.follow_polygon = pd.geometry.polygon.new(335, 1310,
            375, 1195,
            425, 1050,
            505, 935,
            605, 870,
            680, 800,
            800, 625,
            910, 455,
            1035, 370,
            1140, 285,
            1260, 265,
            1375, 310,
            1510, 355,
            1620, 415,
            1720, 490,
            1600, 590,
            1645, 685,
            1535, 770,
            1600, 875,
            1530, 1015,
            1580, 1125,
            1535, 1200,
            1420, 1280,
            1300, 1330,
            1260, 1410,
            1205, 1600,
            1145, 1675,
            1060, 1705,
            955, 1640,
            850, 1770,
            740, 1655,
            630, 1775,
            540, 1630,
            450, 1590,
            370, 1510,
            335, 1440)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 3 then
            vars.follow_polygon = pd.geometry.polygon.new(335, 1225,
            395, 1050,
            520, 925,
            680, 825,
            760, 715,
            790, 580,
            875, 410,
            1090, 285,
            1420, 300,
            1590, 380,
            1635, 515,
            1585, 700,
            1550, 1000,
            1600, 1105,
            1480, 1225,
            1305, 1275,
            1255, 1415,
            1175, 1580,
            1025, 1645,
            755, 1725,
            655, 1665,
            395, 1600,
            335, 1400)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 4 then
            vars.follow_polygon = pd.geometry.polygon.new(335, 1330,
            365, 1215,
            395, 1085,
            565, 925,
            695, 855,
            830, 745,
            865, 605,
            925, 420,
            1040, 345,
            1195, 320,
            1355, 320,
            1515, 345,
            1625, 460,
            1610, 610,
            1570, 755,
            1570, 925,
            1560, 1130,
            1470, 1215,
            1305, 1260,
            1230, 1375,
            1210, 1540,
            1135, 1635,
            1040, 1670,
            880, 1700,
            670, 1710,
            570, 1675,
            450, 1595,
            380, 1435)
        end
    end
    vars.laps = 3 -- How many laps...
    vars.lap_string = text('lap1')
    vars.lap_string_2 = text('lap2')
    vars.lap_string_3 = text('lap3')
    vars.anim_lap_string = pd.timer.new(0, -175, -175)
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
    -- Poles
    vars.poles_short_x = {485, 497, 529, 575, 631, 681, 739, 793, 845, 881, 707, 715, 727, 743, 769, 803, 845, 891, 941, 997, 1053, 1111, 1167, 1455, 1455, 1457, 1451, 1421, 1373, 1317, 1261, 1207, 1163, 1135, 1129, 1129, 1133, 1127}
    vars.poles_short_y = {1122, 1062, 1012, 982, 958, 938, 920, 900, 874, 832, 556, 502, 444, 388, 338, 288, 246, 216, 192, 174, 156, 158, 152, 920, 972, 1024, 1076, 1118, 1144, 1160, 1172, 1190, 1220, 1270, 1324, 1380, 1436, 1488}
    vars.checkpoint_x = 267
    vars.checkpoint_y = 1306
    vars.checkpoint_width = 202
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
    vars.audience_x = {219, 191, 219, 199, 219, 235, 223, 329, 371, 479, 571, 667, 695, 687, 1083, 955, 1623, 1663, 1763, 1707, 1727, 1703, 1615, 1519, 1419, 1391, 1375, 1287, 1239, 975, 931, 599, 435, 299, 247, 267, 535, 579, 563, 555, 523, 519, 887, 951, 1007, 1035, 1331, 1515, 1491, 1439, 1423, 1427, 1119, 1087, 1083, 927, 895, 795, 675, 639}
    vars.audience_y = {1520, 1472, 1432, 1360, 1320, 1244, 1144, 830, 798, 704, 708, 540, 416, 364, 120, 152, 204, 208, 652, 844, 884, 1012, 1332, 1424, 1404, 1436, 1636, 1760, 1760, 1860, 1836, 1844, 1792, 1692, 1672, 1620, 1436, 1432, 1392, 1340, 1300, 1108, 872, 672, 476, 440, 392, 464, 532, 712, 752, 1004, 1220, 1256, 1424, 1564, 1516, 1588, 1564, 1588}
    vars.audience_rand = {}
    for i = 1, #vars.audience_x do
        table.insert(vars.audience_rand, random(1, 11))
    end
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(0, 0, vars.stage_x, 0, vars.stage_x, vars.stage_y, 0, vars.stage_x, 0, 0, 270, 1315, 265, 1130, 265, 1095, 270, 1040, 275, 1030, 285, 990, 290, 970, 295, 945, 305, 925, 310, 910, 325, 885, 355, 850, 405, 805, 445, 780, 480, 765, 520, 750, 585, 725, 630, 710, 670, 685, 705, 655, 715, 635, 720, 580, 730, 515, 730, 500, 735, 470, 740, 450, 745, 420, 755, 400, 765, 365, 805, 310, 825, 285, 850, 260, 870, 245, 905, 225, 920, 215, 965, 200, 1035, 180, 1095, 170, 1160, 165, 1280, 165, 1350, 170, 1390, 175, 1415, 180, 1430, 180, 1470, 190, 1525, 200, 1580, 220, 1615, 235, 1655, 250, 1690, 280, 1715, 305, 1740, 330, 1755, 360, 1770, 395, 1780, 425, 1785, 480, 1780, 530, 1770, 570, 1755, 600, 1735, 640, 1705, 685, 1685, 725, 1665, 785, 1660, 835, 1665, 925, 1670, 1020, 1675, 1060, 1675, 1140, 1670, 1190, 1660, 1220, 1630, 1270, 1590, 1315, 1550, 1340, 1515, 1355, 1475, 1360, 1440, 1370, 1405, 1375, 1375, 1395, 1365, 1420, 1360, 1460, 1360, 1545, 1355, 1580, 1345, 1610, 1330, 1640, 1315, 1660, 1280, 1695, 1240, 1725, 1195, 1745, 1115, 1770, 1010, 1790, 930, 1800, 845, 1805, 670, 1805, 585, 1805, 520, 1790, 460, 1770, 405, 1745, 370, 1720, 335, 1685, 315, 1655, 295, 1615, 285, 1570, 275, 1490, 270, 1395, 270, 1315, 0, 0),
        geo.polygon.new(470, 1305, 465, 1170, 470, 1120, 475, 1090, 475, 1060, 485, 1050, 485, 1045, 495, 1025, 525, 995, 550, 975, 595, 955, 600, 950, 665, 925, 680, 920, 690, 915, 775, 890, 785, 885, 820, 870, 860, 830, 885, 800, 895, 780, 905, 745, 925, 675, 925, 665, 935, 615, 945, 555, 950, 530, 960, 495, 965, 480, 980, 450, 1010, 415, 1030, 405, 1055, 385, 1090, 375, 1185, 365, 1225, 360, 1325, 355, 1360, 355, 1410, 365, 1435, 370, 1480, 385, 1505, 400, 1535, 435, 1545, 465, 1550, 495, 1550, 530, 1540, 565, 1515, 610, 1495, 650, 1475, 690, 1465, 740, 1465, 835, 1470, 895, 1470, 945, 1470, 975, 1475, 1055, 1460, 1105, 1435, 1135, 1395, 1155, 1315, 1175, 1245, 1190, 1210, 1205, 1165, 1240, 1150, 1275, 1145, 1300, 1145, 1370, 1145, 1460, 1140, 1495, 1120, 1530, 1085, 1555, 1030, 1575, 985, 1590, 860, 1610, 805, 1615, 710, 1620, 625, 1615, 590, 1605, 535, 1575, 500, 1535, 480, 1495, 480, 1460, 475, 1385, 470, 1330, 470, 1305)
    }
    self:fill_polygons()
    self:both_polygons()

    newmusic('audio/music/stage1', true, 0.701) -- Adding new music
    if music ~= nil then music:pause() end
end

function race:fill_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
    local stage_progress_medium_x = vars.stage_progress_medium_x
    local stage_progress_medium_y = vars.stage_progress_medium_y
    vars.fill_polygons = {
    }
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
    local stage_progress_medium_x = vars.stage_progress_medium_x
    local stage_progress_medium_y = vars.stage_progress_medium_y
    vars.both_polygons = {
    }
    table.insert(vars.both_polygons, geo.polygon.new(
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 14) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 12) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 4) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)))
end