-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random
local smp <const> = pd.sound.sampleplayer

function race:stage_init()
    if perf then
        assets.image_stage = gfx.image.new('stages/7/stage_flat')
        assets.image_stagec = gfx.image.new('stages/7/stagec')
    else
        assets.image_stage = gfx.image.new('stages/7/stage')
        assets.parallax_short_bake = gfx.image.new('stages/7/parallax_short_bake')
        assets.image_stagec = assets.image_stage
    end
    assets.image_water_bg = gfx.image.new('stages/7/water_bg')
    assets.water = gfx.imagetable.new('stages/7/water')
    assets.popeyes = gfx.image.new('stages/7/popeyes')
    assets.reverse_pad = gfx.imagetable.new('stages/7/reverse_pad')
    assets.sfx_cymbal = smp.new('audio/sfx/cymbal')
    assets.sfx_cymbal:setVolume(save.vol_sfx/5)
    assets.minimap = gfx.image.new('stages/7/minimap')

    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

    if vars.mode == "tt" then
        vars.boat_x = 460
        vars.boat_y = 1610
    else
        vars.boat_x = 500
        vars.boat_y = 1610
        vars.cpu_x = 420
        vars.cpu_y = 1610
        vars.cpu_current_lap = 1
        vars.cpu_current_checkpoint = 0
        vars.cpu_last_checkpoint = 0
        if save['slot' .. save.current_story_slot .. '_circuit'] == 1 then
            vars.follow_polygon = pd.geometry.polygon.new(420, 1565,
				365, 1485,
				315, 1390,
				335, 1270,
				390, 1200,
				465, 1070,
				480, 970,
				430, 855,
				355, 760,
				275, 665,
				210, 570,
				190, 485,
				210, 375,
				275, 295,
				375, 235,
				460, 210,
				635, 250,
				745, 300,
				855, 355,
				965, 390,
				1130, 370,
				1245, 315,
				1370, 265,
				1525, 265,
				1610, 375,
				1580, 480,
				1520, 610,
				1500, 725,
				1555, 850,
				1615, 975,
				1620, 1105,
				1550, 1215,
				1435, 1255,
				1300, 1245,
				1130, 1260,
				1035, 1360,
				990, 1455,
				1030, 1560,
				1095, 1690,
				1160, 1835,
				1225, 1975,
				1315, 2190,
				1395, 2240,
				1460, 2205,
				1500, 2110,
				1605, 1945,
				1690, 1795,
				1760, 1660,
				1800, 1595,
				1845, 1620,
				1900, 1715,
				1965, 1855,
				2015, 2010,
				2065, 2145,
				2135, 2220,
				2195, 2240,
				2265, 2200,
				2340, 2080,
				2415, 1935,
				2515, 1785,
				2635, 1610,
				2735, 1585,
				2855, 1630,
				2930, 1750,
				3025, 1925,
				3095, 2040,
				3225, 2215,
				3300, 2280,
				3435, 2205,
				3535, 2165,
				3655, 2040,
				3800, 1915,
				3940, 1755,
				4035, 1550,
				4095, 1370,
				4155, 1165,
				4155, 1005)
		elseif save['slot' .. save.current_story_slot .. '_circuit'] == 2 then
			vars.follow_polygon = pd.geometry.polygon.new(380, 1545,
				315, 1435,
				335, 1300,
				390, 1180,
				445, 1065,
				465, 965,
				445, 830,
				370, 730,
				280, 605,
				210, 460,
				195, 330,
				265, 250,
				385, 190,
				520, 165,
				650, 230,
				725, 265,
				870, 335,
				985, 370,
				1125, 350,
				1235, 290,
				1325, 245,
				1410, 225,
				1630, 255,
				1675, 370,
				1640, 530,
				1590, 665,
				1525, 785,
				1505, 905,
				1500, 1070,
				1480, 1245,
				1405, 1355,
				1265, 1415,
				1120, 1395,
				985, 1455,
				925, 1555,
				980, 1685,
				1070, 1755,
				1220, 1845,
				1330, 1905,
				1440, 1965,
				1565, 2025,
				1720, 2020,
				1830, 1955,
				1965, 1910,
				2095, 1850,
				2300, 1810,
				2475, 1875,
				2630, 1940,
				2830, 2025,
				3000, 2070,
				3160, 2125,
				3345, 2125,
				3540, 2055,
				3700, 1985,
				3835, 1910,
				3945, 1820,
				4010, 1665,
				4060, 1500,
				4105, 1355,
				4135, 1175,
				4135, 905)
		elseif save['slot' .. save.current_story_slot .. '_circuit'] == 3 then
			vars.follow_polygon = pd.geometry.polygon.new(420, 1565,
				370, 1485,
				315, 1400,
				335, 1335,
				385, 1275,
				455, 1180,
				475, 1115,
				440, 1015,
				365, 930,
				285, 850,
				240, 770,
				210, 660,
				250, 560,
				305, 435,
				375, 350,
				480, 260,
				565, 205,
				620, 185,
				685, 210,
				800, 285,
				900, 355,
				995, 400,
				1120, 400,
				1220, 340,
				1310, 310,
				1435, 335,
				1525, 395,
				1605, 450,
				1650, 565,
				1655, 705,
				1615, 820,
				1555, 930,
				1520, 1060,
				1445, 1195,
				1380, 1305,
				1270, 1360,
				1160, 1415,
				1060, 1485,
				1020, 1570,
				1030, 1695,
				1075, 1825,
				1145, 1955,
				1240, 2090,
				1320, 2165,
				1440, 2165,
				1555, 2055,
				1610, 1945,
				1715, 1835,
				1825, 1765,
				1925, 1765,
				2050, 1855,
				2155, 1950,
				2245, 2070,
				2360, 2145,
				2460, 2080,
				2530, 2020,
				2675, 1880,
				2755, 1775,
				2835, 1730,
				2945, 1775,
				3020, 1880,
				3090, 2005,
				3135, 2115,
				3180, 2230,
				3300, 2260,
				3405, 2185,
				3520, 2045,
				3625, 1920,
				3710, 1785,
				3810, 1665,
				3930, 1530,
				4020, 1420,
				4115, 1280,
				4165, 1185,
				4190, 1075,
				4150, 935)
		elseif save['slot' .. save.current_story_slot .. '_circuit'] == 4 then
			vars.follow_polygon = pd.geometry.polygon.new(400, 1545,
				345, 1475,
				370, 1355,
				460, 1250,
				475, 1165,
				420, 1085,
				330, 995,
				270, 900,
				250, 815,
				300, 735,
				325, 645,
				350, 545,
				375, 450,
				420, 360,
				495, 285,
				590, 220,
				665, 195,
				755, 235,
				830, 290,
				935, 315,
				1030, 340,
				1125, 370,
				1220, 370,
				1315, 385,
				1380, 425,
				1430, 510,
				1500, 595,
				1570, 695,
				1630, 790,
				1680, 890,
				1685, 1000,
				1610, 1095,
				1495, 1165,
				1355, 1245,
				1225, 1270,
				1135, 1355,
				1050, 1440,
				1040, 1540,
				1085, 1685,
				1155, 1835,
				1235, 1990,
				1295, 2125,
				1335, 2170,
				1410, 2150,
				1515, 2020,
				1670, 1820,
				1785, 1725,
				1875, 1700,
				2080, 1905,
				2235, 2060,
				2330, 2120,
				2435, 2070,
				2590, 1925,
				2710, 1805,
				2795, 1720,
				2880, 1690,
				2940, 1735,
				3020, 1815,
				3090, 1890,
				3155, 2005,
				3235, 2115,
				3295, 2210,
				3395, 2225,
				3495, 2150,
				3595, 2080,
				3715, 1980,
				3840, 1870,
				3945, 1755,
				4045, 1580,
				4120, 1375,
				4180, 1125,
				4180, 1005)
		end
    end
    vars.laps = 1 -- How many laps...
    -- The checkpointzzzzz™
    vars.finish = gfx.sprite.addEmptyCollisionSprite(4050, 1080, 250, 20)
    vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(1450, 530, 225, 20)
    vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(2070, 785, 20, 1500)
    vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(3320, 1970, 20, 300)
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
    vars.checkpoint_x = 4050
    vars.checkpoint_y = 1100
    vars.checkpoint_width = 222
    -- Reverse pads
    vars.reverse_pads_x = {850}
    vars.reverse_pads_y = {228}
    for i = 1, #vars.reverse_pads_x do
        vars['reverse_pad_' .. i] = gfx.sprite.addEmptyCollisionSprite(vars.reverse_pads_x[i] + 45, vars.reverse_pads_y[i], 8, 123)
        vars['reverse_pad_' .. i]:setTag(42 + i)
    end
    vars.anim_reverse_pad = pd.timer.new(500, 1, 4.99)
    vars.anim_reverse_pad.repeats = true
    -- Audience members
    assets.audience1 = gfx.imagetable.new('images/race/audience/audience_rowbot')
    vars.audience_x = {265, 270, 300, 590, 640, 680, 645, 710, 550, 200, 175, 155, 190, 330, 780, 1010, 995, 795, 1215, 1270, 1395, 1695, 1810, 2200, 2240, 2520, 2670, 2845, 3045, 3375, 3415, 3620, 3660, 3900, 4015, 3770, 3650, 3995, 3905, 3775, 3535, 3660, 3315, 1370, 1045, 1100, 1205, 1350, 1390, 1925, 1940, 2325, 2585, 3005, 3145, 3105, 3505, 3855, 4065, 4220, 4285, 4285, 4255, 1505, 1830, 2315, 2610, 3025, 3115, 3510, 3455, 3355, 3175, 2780, 2615, 2425, 1955, 1710, 1620, 1485}
    vars.audience_y = {1610, 1520, 1495, 1755, 1680, 1665, 1550, 1545, 1435, 740, 375, 205, 180, 195, 380, 375, 195, 130, 400, 200, 380, 715, 720, 765, 755, 540, 715, 690, 655, 485, 555, 605, 710, 665, 905, 890, 1165, 1370, 1435, 1560, 1575, 1785, 1815, 1055, 1915, 2120, 2195, 2155, 2125, 1970, 2125, 2190, 1960, 2060, 2150, 2140, 2115, 1970, 1705, 1450, 1195, 875, 840, 1755, 1720, 1820, 1675, 1630, 1705, 1155, 990, 825, 905, 925, 1015, 900, 1025, 1080, 1215, 1295}
    vars.audience_rand = {}
    for i = 1, #vars.audience_x do
        table.insert(vars.audience_rand, 1)
    end
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(385, 1470, 355, 1485, 315, 1540, 295, 1595, 310, 1680, 355, 1735, 395, 1760, 470, 1775, 545, 1750, 595, 1700, 620, 1645, 620, 1595, 595, 1525, 540, 1475, 500, 1455, 475, 1455, 340, 355, 1420, 355, 1600, 965, 1030, 1345, 1225, 2170, 1815, 1860, 2210, 2125, 2790, 1820, 3225, 2180, 3780, 1900, 3885, 1830, 3995, 1730, 4075, 1635, 4145, 1520, 4205, 1395, 4250, 1235, 4265, 1115, 4260, 975, 4240, 875, 4210, 785, 4125, 635, 4080, 560, 4035, 470, 3990, 345, 3960, 230, 3945, 125, 3945, 35, 3950, 0, 4590, 0, 4590, 2465, 0, 2465, 0, 0, 3780, 0, 3770, 65, 3770, 175, 3790, 275, 3815, 380, 3875, 545, 3945, 670, 3995, 770, 4030, 865, 4050, 970, 4060, 1060, 4060, 1185, 4045, 1280, 4010, 1415, 3950, 1535, 3855, 1670, 3770, 1750, 3670, 1815, 3405, 1965, 3240, 2055, 3015, 1870, 3085, 1840, 3185, 1785, 3280, 1710, 3375, 1615, 3460, 1510, 3530, 1390, 3600, 1240, 3640, 1080, 3655, 965, 3650, 835, 3615, 650, 1700, 845, 1510, 230, 180, 225, 385, 1470),
        geo.polygon.new(1725, 920, 1755, 1015, 1155, 1385, 1310, 2000, 1810, 1740, 2215, 1995, 2800, 1695, 2945, 1810, 3025, 1785, 3110, 1740, 3185, 1690, 3265, 1615, 3345, 1530, 3430, 1405, 3485, 1295, 3540, 1150, 3560, 1025, 3565, 870, 3550, 780, 1725, 920),
    }
    -- Bounds for the calc'd polygons
    self:fill_polygons()
    self:both_polygons()

    newmusic('audio/music/stage7', true, 7.373) -- Adding new music
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