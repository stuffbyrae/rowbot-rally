-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random
local smp <const> = pd.sound.sampleplayer

function race:stage_init()
    -- assets.image_stage_flat = gfx.image.new('stages/7/stage_flat')
    if perf then
        -- assets.image_stage = assets.image_stage_flat
    else
        assets.image_stage = gfx.image.new('stages/7/stage')
    end
    assets.image_stagec = gfx.image.new('stages/7/stagec')
    assets.image_stagec_cpu = assets.image_stage
    assets.image_water_bg = gfx.image.new('stages/7/water_bg')
    assets.water = gfx.imagetable.new('stages/7/water')
    assets.caustics = gfx.imagetable.new('stages/7/caustics')
    assets.reverse_pad = gfx.imagetable.new('stages/7/reverse_pad')
    assets.sfx_cymbal = smp.new('audio/sfx/cymbal')
    assets.sfx_cymbal:setVolume(save.vol_sfx/5)
    assets.caustics = gfx.imagetable.new('stages/7/caustics')
    assets.caustics_overlay = gfx.image.new('stages/7/caustics_overlay')

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
        vars.follow_polygon = pd.geometry.polygon.new(440, 1535, 425, 1420, 260, 355, 315, 265, 470, 295, 720, 280, 1480, 295, 1505, 465, 1600, 680, 1655, 960, 1570, 1090, 1340, 1180, 1100, 1380, 1245, 2010, 1290, 2065, 1375, 2030, 1765, 1825, 1815, 1805, 1895, 1850, 2180, 2045, 2250, 2045, 2385, 1995, 2740, 1780, 2815, 1765, 3205, 2110, 3260, 2110, 3465, 2015, 3770, 1870, 3970, 1670, 4090, 1490, 4145, 1255, 4145, 880)
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
        vars.parallax_long_amount = 1.175
    end
    vars.checkpoint_x = 4050
    vars.checkpoint_y = 1100
    vars.checkpoint_width = 222
    -- Reverse pads
    vars.reverse_pads_x = {460}
    vars.reverse_pads_y = {228}
    for i = 1, #vars.reverse_pads_x do
        vars['reverse_pad_' .. i] = gfx.sprite.addEmptyCollisionSprite(vars.reverse_pads_x[i] + 45, vars.reverse_pads_y[i], 8, 123)
        vars['reverse_pad_' .. i]:setTag(42 + i)
    end
    vars.anim_reverse_pad = pd.timer.new(500, 1, 4.99)
    vars.anim_reverse_pad.repeats = true
    -- Audience members
    assets.audience3 = gfx.imagetable.new('images/race/audience/audience_rowbot')
    vars.audience_x = {}
    vars.audience_y = {}
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