-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random

function race:stage_init()
    assets.image_stage = gfx.image.new('stages/1/stage')
    assets.image_stagec = gfx.image.new('stages/1/stagec')
    assets.image_water_bg = gfx.image.new('stages/1/water_bg')
    assets.water = gfx.imagetable.new('stages/1/water')
    assets.caustics = gfx.imagetable.new('stages/1/caustics')
    assets.trees = gfx.imagetable.new('stages/1/tree')
    assets.trunks = gfx.imagetable.new('stages/1/trunk')
    assets.treetops = gfx.imagetable.new('stages/1/treetop')
    assets.bushes = gfx.imagetable.new('stages/1/bush')
    assets.bushtops = gfx.imagetable.new('stages/1/bushtop')

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
    -- Bounds for the calc'd polygons
    self:fill_polygons()
    vars.fill_bounds = {
        {255, 1310, 480, 1312},
        {255, 1318, 480, 1320},
        {249, 1458, 262, 1558},
    }
    self:both_polygons()
    vars.both_bounds = {
        {247, 1336, 260, 1436},
        {485, 1348, 497, 1448},
        {255, 1310, 480, 1320},
    }
    self:draw_polygons()
    vars.draw_bounds = {
        {484, 832, 883, 1120},
        {707, 152, 1167, 556},
        {1127, 920, 1459, 1488},
    }

    newmusic('audio/music/stage1', true, 0.701) -- Adding new music
    music:pause()
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
        geo.polygon.new(
        257, 1336,
        260, 1436,
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
end

function race:draw_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
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

    if perf then
        gfx.pushContext(assets.image_stage)
            local bushes_x
            local bushes_y
            local bushes_rand
            local bushes = assets.bushes
            local bushtops = assets.bushtops
            for i = 1, #vars.bushes_x do
                bushes_x = vars.bushes_x[i]
                bushes_y = vars.bushes_y[i]
                bushes_rand = vars.bushes_rand[i]
                    bushes:drawImage(
                        bushes_rand,
                        (bushes_x - 41),
                        (bushes_y - 39))
                    bushtops:drawImage(
                        bushes_rand,
                        (bushes_x - 41),
                        (bushes_y - 39))
            end

            gfx.setLineWidth(5)

            local draw_polygons
            for i = 1, #vars.draw_polygons do
                draw_polygons = vars.draw_polygons[i]
                gfx.drawPolygon(draw_polygons)
            end

            local poles_short_x
            local poles_short_y
            local image_pole = assets.image_pole
            local image_pole_cap = assets.image_pole_cap
            for i = 1, #vars.poles_short_x do
                poles_short_x = vars.poles_short_x[i]
                poles_short_y = vars.poles_short_y[i]
                image_pole:draw(
                    (poles_short_x - 8),
                    (poles_short_y - 8))
                image_pole_cap:draw(
                    (poles_short_x - 6),
                    (poles_short_y - 6))
            end

            local audience_x
            local audience_y
            local audience_rand
            local audience_image
            for i = 1, #vars.audience_x do
                audience_x = vars.audience_x[i]
                audience_y = vars.audience_y[i]
                audience_rand = vars.audience_rand[i]
                audience_image = assets['audience' .. audience_rand]
                if audience_image[1] ~= nil then
                    audience_image[1]:draw(
                        (audience_x - 21),
                        (audience_y - 21))
                else
                    audience_image:draw(
                        (audience_x - 21),
                        (audience_y - 21))
                end
            end

            local poles_medium_x
            local poles_medium_y
            for i = 1, #vars.poles_medium_x do
                poles_medium_x = vars.poles_medium_x[i]
                poles_medium_y = vars.poles_medium_y[i]
                image_pole:draw(
                    (poles_medium_x - 8),
                    (poles_medium_y - 8))
                image_pole_cap:draw(
                    (poles_medium_x - 6),
                    (poles_medium_y - 6))
            end

            gfx.setLineWidth(2) -- Set the line width back

            local fill_polygons
            for i = 1, #vars.fill_polygons do
                fill_polygons = vars.fill_polygons[i]
                gfx.fillPolygon(fill_polygons)
            end

            local both_polygons
            for i = 1, #vars.both_polygons do
                both_polygons = vars.both_polygons[i]
                gfx.setColor(gfx.kColorWhite)
                gfx.fillPolygon(both_polygons)
                gfx.setColor(gfx.kColorBlack)
                gfx.drawPolygon(both_polygons)
            end

            local trees_x
            local trees_y
            local trees_rand
            local trees = assets.trees
            local treetops = assets.treetops
            for i = 1, #vars.trees_x do
                trees_x = vars.trees_x[i]
                trees_y = vars.trees_y[i]
                trees_rand = vars.trees_rand[i]
                trees:drawImage(
                        trees_rand,
                        (trees_x - 66),
                        (trees_y - 66))
                    treetops:drawImage(
                        trees_rand,
                        (trees_x - 66),
                        (trees_y - 66))
            end
        gfx.popContext()
    end
end

function race:bake_parallax()
    assets.parallax_short_bake = gfx.image.new(vars.stage_x * vars.parallax_short_amount, vars.stage_y * vars.parallax_short_amount)
    gfx.pushContext(assets.parallax_short_bake)
        local stage_x = vars.stage_x
        local stage_y = vars.stage_y
        local bushes_x
        local bushes_y
        local bushes_rand
        local bushes = assets.bushes
        local bushtops = assets.bushtops
        for i = 1, #vars.bushes_x do
            bushes_x = vars.bushes_x[i]
            bushes_y = vars.bushes_y[i]
            bushes_rand = vars.bushes_rand[i]
                bushes:drawImage(
                    bushes_rand,
                    (bushes_x - 41) * vars.parallax_short_amount + (stage_x * -vars.stage_progress_short_x),
                    (bushes_y - 39) * vars.parallax_short_amount + (stage_y * -vars.stage_progress_short_y))
                bushtops:drawImage(
                    bushes_rand,
                    (bushes_x - 41) * vars.parallax_short_amount + (stage_x * -vars.stage_progress_short_x),
                    (bushes_y - 39) * vars.parallax_short_amount + (stage_y * -vars.stage_progress_short_y))
        end

        local poles_short_x
        local poles_short_y
        local image_pole = assets.image_pole
        local image_pole_cap = assets.image_pole_cap
        for i = 1, #vars.poles_short_x do
            poles_short_x = vars.poles_short_x[i]
            poles_short_y = vars.poles_short_y[i]
            image_pole:draw(
                (poles_short_x - 8) * vars.parallax_short_amount + (stage_x * -vars.stage_progress_short_x),
                (poles_short_y - 8) * vars.parallax_short_amount + (stage_y * -vars.stage_progress_short_y))
            image_pole_cap:draw(
                (poles_short_x - 6) * vars.parallax_short_amount + (stage_x * -vars.stage_progress_short_x),
                (poles_short_y - 6) * vars.parallax_short_amount + (stage_y * -vars.stage_progress_short_y))
        end
    gfx.popContext()

    assets.parallax_long_bake = gfx.image.new(vars.stage_x * vars.parallax_long_amount, vars.stage_y * vars.parallax_long_amount)
    gfx.pushContext(assets.parallax_long_bake)
        local stage_x = vars.stage_x
        local stage_y = vars.stage_y
        local trees_x
        local trees_y
        local trees_rand
        local trees = assets.trees
        local treetops = assets.treetops
        for i = 1, #vars.trees_x do
            trees_x = vars.trees_x[i]
            trees_y = vars.trees_y[i]
            trees_rand = vars.trees_rand[i]
            trees:drawImage(
                    trees_rand,
                    (trees_x - 66) * vars.parallax_long_amount + (stage_x * -vars.stage_progress_long_x),
                    (trees_y - 66) * vars.parallax_long_amount + (stage_y * -vars.stage_progress_long_y))
                treetops:drawImage(
                    trees_rand,
                    (trees_x - 66) * vars.parallax_long_amount + (stage_x * -vars.stage_progress_long_x),
                    (trees_y - 66) * vars.parallax_long_amount + (stage_y * -vars.stage_progress_long_y))
        end
    gfx.popContext()
end