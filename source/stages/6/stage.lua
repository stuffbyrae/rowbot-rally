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
        vars.follow_polygon = pd.geometry.polygon.new(4485, 1505, 4505, 1245, 4680, 1110, 4635, 845, 4565, 625, 4180, 540, 3860, 475, 3770, 590, 3705, 720, 3550, 935, 3430, 1055, 3255, 1015, 3150, 1055, 3170, 1180, 3230, 1350, 3230, 1595, 3145, 1640, 2815, 1620, 2630, 1580, 2350, 1605, 1965, 1610, 1790, 1690, 1420, 1665, 1310, 1510, 1205, 1270, 985, 1130, 925, 1180, 880, 1430, 755, 1500, 620, 1385, 435, 1235, 355, 1045, 465, 915, 645, 780, 645, 5)
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
    vars.fill_bounds = {}
    self:fill_polygons()
    vars.both_bounds = {}
    self:both_polygons()

    newmusic('audio/music/stage6', true) -- Adding new music
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