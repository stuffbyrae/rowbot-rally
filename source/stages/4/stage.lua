-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random

function race:stage_init()
    if perf then
        assets.image_stage = gfx.image.new('stages/4/stage_flat')
    else
        assets.image_stage = gfx.image.new('stages/4/stage')
    end
    assets.image_stagec = gfx.image.new('stages/4/stagec')
    assets.parallax_short_bake = gfx.image.new('stages/4/parallax_short_bake')
    assets.parallax_medium_bake = gfx.image.new('stages/4/parallax_medium_bake')
    assets.parallax_long_bake = gfx.image.new('stages/4/parallax_long_bake')
    assets.image_water_bg = gfx.image.new('stages/4/water_bg')
    assets.water = gfx.imagetable.new('stages/4/water')
    assets.popeyes = gfx.image.new('stages/4/popeyes')
    assets.stage_overlay = gfx.imagetable.new('stages/4/vignette')

    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

    vars.anim_stage_overlay = pd.timer.new(1, 1, 1)

    vars.boat_x = 300
    vars.boat_y = 1805
    vars.laps = 1 -- How many laps...
    -- The checkpointzzzzz™
    vars.finish = gfx.sprite.addEmptyCollisionSprite(1830, 190, 230, 20)
    vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(0, 1623, 2238, 20)
    vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(0, 1053, 2238, 20)
    vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(0, 368, 2238, 20)
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
    vars.checkpoint_x = 1830
    vars.checkpoint_y = 195
    vars.checkpoint_width = 215
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(0, 0, 1840, 0, 1840, 285, 1640, 340, 1465, 375, 1295, 400, 1165, 410, 1050, 410, 890, 395, 660, 355, 455, 305, 310, 260, 205, 210, 205, 2145, 0, 2145, 0, 0),
        geo.polygon.new(400, 2145, 400, 1760, 595, 1815, 800, 1855, 1005, 1880, 1125, 1885, 1265, 1880, 1410, 1860, 1590, 1830, 1775, 1780, 1940, 1725, 2035, 1680, 2035, 0, 2240, 0, 2240, 2145, 400, 2145),
        geo.polygon.new(185, 1565, 305, 1620, 445, 1670, 445, 1610, 330, 1575, 185, 1515, 185, 1095, 260, 1130, 360, 1170, 445, 1195, 445, 970, 400, 960, 400, 1125, 185, 1045, 185, 750, 275, 790, 365, 825, 445, 855, 445, 795, 175, 695, 185, 1565),
        geo.polygon.new(2055, 1560, 1965, 1605, 1795, 1665, 1795, 1610, 1905, 1570, 2060, 1505, 2060, 1245, 1980, 1285, 1900, 1320, 1795, 1355, 1795, 1135, 1840, 1120, 1840, 1285, 2055, 1200, 2050, 925, 1975, 960, 1850, 1005, 1795, 1025, 1795, 970, 2050, 870, 2050, 570, 1945, 620, 1835, 660, 1795, 670, 1795, 620, 2055, 520, 2055, 385, 1975, 425, 1875, 460, 1795, 485, 1795, 430, 2050, 335, 2055, 1560),
        geo.polygon.new(640, 320, 640, 540, 745, 565, 870, 585, 870, 710, 670, 680, 445, 620, 445, 435, 400, 420, 400, 660, 530, 700, 640, 730, 640, 1080, 685, 1090, 685, 740, 875, 770, 1050, 785, 1135, 785, 1135, 735, 1040, 730, 915, 720, 915, 540, 685, 495, 685, 350, 1330, 390, 1330, 535, 1180, 545, 1090, 550, 1090, 605, 1180, 605, 1330, 585, 1330, 900, 1210, 905, 1090, 910, 1090, 965, 1175, 965, 1330, 955, 1330, 1125, 1565, 1085, 1565, 1250, 1610, 1240, 1610, 1020, 1485, 1045, 1375, 1065, 1375, 770, 1565, 735, 1565, 910, 1840, 835, 1840, 780, 1610, 845, 1610, 665, 1375, 710, 1375, 365, 1570, 330, 1570, 550, 1610, 540, 1610, 305, 640, 320),
        geo.polygon.new(1090, 1950, 1090, 1725, 1200, 1725, 1325, 1705, 1325, 1455, 1120, 1470, 915, 1460, 915, 1555, 1020, 1565, 1135, 1570, 1135, 1625, 1045, 1625, 915, 1615, 915, 1765, 825, 1755, 640, 1720, 640, 1665, 870, 1705, 870, 1395, 1005, 1410, 1105, 1415, 1230, 1410, 1325, 1400, 1325, 1295, 1090, 1310, 1090, 1140, 915, 1130, 915, 1295, 790, 1280, 685, 1260, 685, 1415, 555, 1390, 445, 1360, 445, 1455, 685, 1515, 685, 1575, 400, 1500, 400, 1285, 635, 1350, 635, 1190, 870, 1235, 870, 890, 915, 900, 915, 1070, 1135, 1085, 1135, 1255, 1370, 1235, 1370, 1390, 1610, 1350, 1610, 1505, 1840, 1440, 1840, 1495, 1565, 1570, 1565, 1415, 1370, 1450, 1370, 1760, 1135, 1785, 1135, 1915, 1565, 1895, 1565, 1670, 1610, 1660, 1610, 1960, 1090, 1950),
    }
    -- Bounds for the calc'd polygons
    vars.fill_bounds = {
        {0, 0, 1, 1},
    }
    self:fill_polygons()
    vars.both_bounds = {
        {0, 0, 1, 1},
    }
    self:both_polygons()
    vars.draw_bounds = {
        {0, 0, 1, 1},
    }
    self:draw_polygons()

    newmusic('audio/music/stage4', true) -- Adding new music
    music:pause()
end

function race:fill_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
    vars.fill_polygons = {
        geo.polygon.new(0, 0, 0, 1, 1, 1, 1, 0, 0, 0),
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
    vars.both_polygons = {
        geo.polygon.new(0, 0, 0, 1, 1, 1, 1, 0, 0, 0),
    }
    table.insert(vars.both_polygons, geo.polygon.new(
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 14) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 12) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x + vars.checkpoint_width + 11) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 4) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y),
    ((vars.checkpoint_x - 12) * vars.parallax_medium_amount) + (vars.stage_x * -vars.stage_progress_medium_x), ((vars.checkpoint_y + 6) * vars.parallax_medium_amount) + (vars.stage_y * -vars.stage_progress_medium_y)))
    table.insert(vars.both_bounds, {vars.checkpoint_x - 12, vars.checkpoint_y + 4, vars.checkpoint_x + vars.checkpoint_width + 11, vars.checkpoint_y + 14})
end

function race:draw_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
    vars.draw_polygons = {
        geo.polygon.new(0, 0, 0, 1, 1, 1, 1, 0, 0, 0),
    }
end

function race:bake_parallax()
    if perf then
        gfx.pushContext(assets.image_stage)
            local checkpoint_x = vars.checkpoint_x
            local checkpoint_y = vars.checkpoint_y
            local checkpoint_width = vars.checkpoint_width
            local image_pole = assets.image_pole
            local image_pole_cap = assets.image_pole_cap

            image_pole:draw(
                (checkpoint_x - 8),
                (checkpoint_y - 8))
            image_pole_cap:draw(
                (checkpoint_x - 6),
                (checkpoint_y - 6))

            image_pole:draw(
                (checkpoint_x + checkpoint_width - 8),
                (checkpoint_y - 8))
            image_pole_cap:draw(
                (checkpoint_x + checkpoint_width - 6),
                (checkpoint_y - 6))

            gfx.setColor(gfx.kColorWhite)
            gfx.fillPolygon(geo.polygon.new(
            (checkpoint_x - 12), (checkpoint_y + 6),
            (checkpoint_x - 12), (checkpoint_y + 14),
            (checkpoint_x + checkpoint_width + 11), (checkpoint_y + 12),
            (checkpoint_x + checkpoint_width + 11), (checkpoint_y + 4),
            (checkpoint_x - 12), (checkpoint_y + 6)))
            gfx.setColor(gfx.kColorBlack)
            gfx.drawPolygon(geo.polygon.new(
            (checkpoint_x - 12), (checkpoint_y + 6),
            (checkpoint_x - 12), (checkpoint_y + 14),
            (checkpoint_x + checkpoint_width + 11), (checkpoint_y + 12),
            (checkpoint_x + checkpoint_width + 11), (checkpoint_y + 4),
            (checkpoint_x - 12), (checkpoint_y + 6)))
        gfx.popContext()
    end
end