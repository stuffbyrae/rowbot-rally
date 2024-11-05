-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random

function race:stage_init()
    if perf then
        assets.image_stage = gfx.image.new('stages/6/stage_flat')
        assets.image_stagec = gfx.image.new('stages/6/stagec')
    else
        assets.image_stage = gfx.image.new('stages/6/stage')
        assets.parallax_long_bake = gfx.image.new('stages/6/parallax_long_bake')
        assets.image_stagec = assets.image_stage
    end
    assets.image_water_bg = gfx.image.new('stages/6/water_bg')
    assets.water = gfx.imagetable.new('stages/6/water')
    assets.popeyes = gfx.image.new('stages/6/popeyes')
    assets.stage_overlay = gfx.imagetable.new('stages/6/stage_overlay')

    vars.anim_stage_overlay = pd.timer.new(500, 1, 4.99)
    vars.anim_stage_overlay.repeats = true

    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

    if vars.mode == "tt" then
        vars.boat_x = 4505
        vars.boat_y = 1630
    else
        vars.boat_x = 4540
        vars.boat_y = 1630
        vars.cpu_x = 4480
        vars.cpu_y = 1630
        vars.cpu_current_lap = 1
        vars.cpu_current_checkpoint = 0
        vars.cpu_last_checkpoint = 0
        if save['slot' .. save.current_story_slot .. '_circuit'] == 1 then
            vars.follow_polygon = pd.geometry.polygon.new(4490, 1530,
                4470, 1370,
                4535, 1215,
                4545, 1100,
                4620, 1140,
                4665, 1065,
                4630, 920,
                4585, 720,
                4530, 595,
                4515, 535,
                4450, 580,
                4280, 560,
                4065, 510,
                3885, 460,
                3800, 545,
                3720, 630,
                3670, 630,
                3680, 725,
                3585, 905,
                3510, 1080,
                3385, 1055,
                3250, 1015,
                3040, 1060,
                2845, 990,
                2675, 985,
                2510, 950,
                2450, 885,
                2380, 950,
                2220, 885,
                2135, 740,
                2100, 565,
                1990, 520,
                1895, 455,
                1790, 540,
                1650, 595,
                1555, 595,
                1440, 685,
                1325, 710,
                1170, 775,
                1140, 850,
                1085, 925,
                1035, 1025,
                960, 1150,
                880, 1310,
                795, 1470,
                670, 1425,
                560, 1290,
                445, 1215,
                365, 1100,
                385, 875,
                440, 795,
                505, 835,
                610, 800,
                660, 665,
                620, 515,
                635, 340)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 2 then
            vars.follow_polygon = pd.geometry.polygon.new(4480, 1520,
                4495, 1340,
                4585, 1165,
                4640, 1055,
                4605, 895,
                4540, 610,
                4480, 535,
                4400, 575,
                4185, 530,
                4025, 500,
                3850, 480,
                3740, 635,
                3675, 755,
                3570, 895,
                3475, 1025,
                3365, 1050,
                3125, 1010,
                2890, 1010,
                2550, 975,
                2270, 940,
                2150, 940,
                2185, 845,
                2115, 640,
                1985, 530,
                1650, 595,
                1490, 685,
                1350, 675,
                1205, 745,
                1060, 940,
                935, 1135,
                880, 1325,
                815, 1420,
                750, 1390,
                680, 1425,
                590, 1260,
                435, 1170,
                350, 1075,
                410, 925,
                595, 765,
                635, 645,
                645, 360)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 3 then
            vars.follow_polygon = pd.geometry.polygon.new(4495, 1530,
                4500, 1305,
                4585, 1200,
                4670, 1105,
                4635, 970,
                4590, 840,
                4610, 720,
                4525, 610,
                4390, 625,
                4260, 555,
                4085, 510,
                3945, 480,
                3800, 555,
                3710, 700,
                3640, 885,
                3660, 1030,
                3710, 1270,
                3670, 1395,
                3545, 1440,
                3445, 1510,
                3285, 1530,
                3135, 1620,
                2850, 1595,
                2590, 1545,
                2390, 1600,
                2225, 1570,
                2115, 1605,
                1950, 1595,
                1855, 1680,
                1725, 1695,
                1620, 1670,
                1465, 1690,
                1355, 1540,
                1250, 1360,
                1160, 1225,
                1020, 1150,
                945, 1210,
                855, 1345,
                785, 1470,
                680, 1435,
                620, 1330,
                510, 1220,
                395, 1145,
                365, 1040,
                465, 870,
                595, 775,
                665, 635,
                655, 305)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 4 then
            vars.follow_polygon = pd.geometry.polygon.new(4495, 1485,
                4510, 1305,
                4620, 1145,
                4650, 1025,
                4590, 860,
                4250, 690,
                4230, 555,
                4060, 510,
                3895, 465,
                3795, 550,
                3700, 715,
                3570, 890,
                3450, 1025,
                3290, 1015,
                3025, 1020,
                2740, 990,
                2305, 955,
                2195, 835,
                2105, 645,
                2000, 550,
                1770, 550,
                1425, 695,
                1205, 715,
                1045, 950,
                980, 1100,
                900, 1310,
                740, 1505,
                630, 1370,
                440, 1180,
                370, 1020,
                550, 825,
                635, 670,
                640, 290)
        end
    end
    vars.laps = 1 -- How many laps...
    -- The checkpointzzzzz™
    vars.finish = gfx.sprite.addEmptyCollisionSprite(550, 460, 200, 20)
    vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(4525, 905, 225, 20)
    vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(2840, 210, 20, 1750)
    vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(1540, 310, 20, 1750)
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
    vars.checkpoint_x = 550
    vars.checkpoint_y = 480
    vars.checkpoint_width = 180
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(0, 0, 580, 0, 550, 280, 570, 350, 565, 445, 580, 670, 500, 785, 365, 850, 260, 980, 260, 1105, 295, 1135, 325, 1240, 485, 1315, 755, 1615, 920, 1430, 1010, 1200, 1180, 1345, 1250, 1540, 1375, 1735, 1860, 1775, 2070, 1660, 2445, 1685, 2625, 1635, 2840, 1685, 3290, 1695, 3315, 1585, 3510, 1545, 3600, 1465, 3795, 1390, 3755, 1285, 3765, 1070, 3700, 810, 3775, 730, 3835, 575, 3920, 530, 4195, 605, 4205, 715, 4545, 885, 4540, 990, 4595, 1085, 4415, 1230, 4415, 1415, 4440, 1530, 4420, 1650, 4440, 1880, 4435, 1955, 4610, 1955, 4610, 2000, 0, 2000, 0, 0),
        geo.polygon.new(690, 0, 5000, 0, 5000, 2000, 4580, 2000, 4560, 1780, 4595, 1595, 4565, 1360, 4590, 1265, 4695, 1205, 4765, 1110, 4700, 970, 4690, 795, 4610, 570, 4190, 485, 3910, 390, 3775, 415, 3675, 660, 3580, 715, 3385, 575, 3160, 515, 2865, 250, 2690, 575, 2680, 655, 2485, 635, 2130, 530, 2105, 465, 1730, 480, 1410, 625, 1160, 660, 895, 1050, 885, 1155, 750, 1415, 590, 1195, 445, 1095, 465, 1015, 620, 925, 740, 740, 715, 515, 740, 265, 690, 0),
        geo.polygon.new(4285, 615, 4290, 675, 4530, 800, 4520, 680, 4285, 615),
        geo.polygon.new(3610, 995, 3655, 1335, 3560, 1360, 3475, 1450, 3295, 1480, 3280, 1305, 3195, 1105, 3295, 1080, 3525, 1130, 3610, 995),
        geo.polygon.new(3405, 985, 3440, 905, 3510, 825, 3340, 700, 3115, 640, 2905, 445, 2800, 625, 2775, 785, 2525, 775, 2170, 680, 2310, 890, 2775, 930, 2830, 915, 2980, 965, 3285, 940, 3405, 985),
        geo.polygon.new(1060, 1065, 1210, 790, 1460, 750, 1755, 610, 2005, 610, 2105, 865, 2260, 1040, 2755, 1085, 2830, 1060, 3000, 1115, 3085, 1090, 3160, 1320, 3180, 1550, 2845, 1540, 2625, 1480, 2425, 1530, 2055, 1505, 1795, 1625, 1480, 1615, 1385, 1505, 1250, 1195, 1120, 1095, 1060, 1065)
    }
    -- Bounds for the calc'd polygons
    self:fill_polygons()
    self:both_polygons()

    newmusic('audio/music/stage6', true) -- Adding new music
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