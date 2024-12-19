-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random
local text <const> = gfx.getLocalizedText

function race:stage_init()
    if perf then
        assets.image_stage = gfx.image.new('stages/3/stage_flat')
    else
        assets.image_stage = gfx.image.new('stages/3/stage')
        assets.parallax_medium_bake = gfx.image.new('stages/3/parallax_medium_bake')
    end
    assets.image_stagec = gfx.image.new('stages/3/stagec')
    assets.image_water_bg = gfx.image.new('stages/3/water_bg')
    assets.caustics = gfx.imagetable.new('stages/3/caustics')
    assets.caustics_overlay = gfx.image.new('stages/3/caustics_overlay')
    assets.boost_pad = gfx.imagetable.new('stages/3/boost_pad')
    assets.minimap = gfx.image.new('stages/3/minimap')

    vars.stage_x, vars.stage_y = assets.image_stage:getSize()

    if vars.mode == "tt" then
        vars.boat_x = 260
        vars.boat_y = 685
    else
        vars.boat_x = 285
        vars.boat_y = 685
        vars.cpu_x = 225
        vars.cpu_y = 685
        vars.cpu_current_lap = 1
        vars.cpu_current_checkpoint = 0
        vars.cpu_last_checkpoint = 0
        if save['slot' .. save.current_story_slot .. '_circuit'] == 1 then
            vars.follow_polygon = pd.geometry.polygon.new(225, 610,
                260, 515,
                240, 425,
                185, 385,
                260, 385,
                355, 335,
                475, 250,
                565, 195,
                710, 210,
                825, 185,
                910, 230,
                1050, 180,
                1140, 240,
                1235, 195,
                1325, 235,
                1415, 185,
                1405, 310,
                1390, 420,
                1340, 550,
                1290, 650,
                1255, 585,
                1165, 560,
                1105, 570,
                990, 595,
                890, 555,
                795, 590,
                705, 555,
                615, 595,
                520, 560,
                555, 610,
                575, 705,
                550, 815,
                615, 915,
                680, 900,
                665, 985,
                770, 1050,
                865, 1005,
                1010, 1020,
                1115, 1040,
                1220, 1025,
                1340, 1045,
                1400, 1115,
                1410, 1255,
                1330, 1340,
                1225, 1415,
                1205, 1470,
                1175, 1405,
                1115, 1360,
                985, 1400,
                870, 1385,
                765, 1355,
                710, 1410,
                650, 1355,
                595, 1400,
                545, 1335,
                440, 1375,
                395, 1425,
                395, 1370,
                355, 1250,
                260, 1175,
                235, 1100)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 2 then
            vars.follow_polygon = pd.geometry.polygon.new(225, 535,
                270, 400,
                345, 285,
                420, 195,
                475, 130,
                540, 180,
                650, 205,
                750, 220,
                890, 205,
                955, 240,
                1040, 200,
                1105, 235,
                1195, 215,
                1260, 240,
                1350, 255,
                1410, 315,
                1400, 465,
                1325, 545,
                1210, 570,
                1105, 570,
                995, 550,
                930, 595,
                860, 550,
                780, 605,
                700, 585,
                640, 630,
                570, 695,
                560, 860,
                610, 980,
                710, 1025,
                845, 1010,
                960, 940,
                1015, 1010,
                1145, 1045,
                1295, 1065,
                1400, 1130,
                1425, 1260,
                1315, 1330,
                1215, 1370,
                1030, 1385,
                865, 1380,
                745, 1350,
                665, 1395,
                575, 1360,
                485, 1360,
                415, 1280,
                275, 1235,
                315, 1125,
                235, 1065,
                265, 975)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 3 then
            vars.follow_polygon = pd.geometry.polygon.new(225, 615,
                245, 490,
                275, 365,
                355, 255,
                480, 200,
                595, 190,
                735, 190,
                875, 210,
                975, 190,
                1065, 200,
                1155, 185,
                1280, 205,
                1385, 270,
                1440, 365,
                1395, 510,
                1300, 590,
                1175, 595,
                1110, 595,
                1010, 570,
                930, 605,
                830, 580,
                760, 595,
                660, 625,
                570, 665,
                525, 755,
                520, 890,
                585, 955,
                675, 1005,
                760, 1035,
                885, 1010,
                1075, 1000,
                1255, 1015,
                1385, 1060,
                1455, 1165,
                1415, 1295,
                1335, 1360,
                1205, 1405,
                1025, 1405,
                870, 1390,
                725, 1375,
                645, 1410,
                550, 1355,
                450, 1380,
                380, 1310,
                300, 1295,
                270, 1185,
                245, 1065,
                235, 980)
        elseif save['slot' .. save.current_story_slot .. '_circuit'] == 4 then
            vars.follow_polygon = pd.geometry.polygon.new(225, 590,
				240, 465,
				200, 340,
				260, 375,
				365, 305,
				510, 240,
				735, 220,
				1125, 220,
				1265, 240,
				1365, 275,
				1440, 345,
				1460, 470,
				1430, 675,
				1430, 1045,
				1450, 1150,
				1410, 1275,
				1275, 1350,
				1100, 1375,
				865, 1375,
				410, 1355,
				305, 1370,
				335, 1290,
				245, 1095,
				225, 900,
				225, 665)
        end
    end
    vars.laps = 3 -- How many laps...
    vars.lap_string = text('lap1')
    vars.lap_string_2 = text('lap2')
    vars.lap_string_3 = text('lap3')
    vars.anim_lap_string = pd.timer.new(0, -175, -175)
    vars.anim_lap_string.discardOnCompletion = false
    -- The checkpointzzzzz™
    vars.finish = gfx.sprite.addEmptyCollisionSprite(160, 580, 200, 20)
    vars.checkpoint_1 = gfx.sprite.addEmptyCollisionSprite(1075, 125, 20, 250)
    vars.checkpoint_2 = gfx.sprite.addEmptyCollisionSprite(470, 765, 1035, 20)
    vars.checkpoint_3 = gfx.sprite.addEmptyCollisionSprite(670, 1290, 20, 250)
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
    vars.checkpoint_x = 170
    vars.checkpoint_y = 595
    vars.checkpoint_width = 165
    -- Trees
    vars.trees_x = {}
    vars.trees_y = {}
    vars.trees_rand = {}
    for i = 1, #vars.trees_x do
        table.insert(vars.trees_rand, #assets.trees)
    end
    -- Umbrella
    vars.umbrellas_x = {600, 300, 170, 100, 105, 65, 125, 70, 165, 290, 515}
    vars.umbrellas_y = {85, 125, 165, 415, 670, 805, 1025, 1215, 1275, 1490, 1505}
    -- Boost pads
    vars.boost_pads_x = {685, 1060, 820}
    vars.boost_pads_y = {155, 510, 1320}
    vars.boost_pads_flip = {gfx.kImageUnflipped, gfx.kImageFlippedX, gfx.kImageFlippedX}
    for i = 1, #vars.boost_pads_x do
        vars['boost_pad_' .. i] = gfx.sprite.addEmptyCollisionSprite(vars.boost_pads_x[i] + 45, vars.boost_pads_y[i], 8, 123)
        vars['boost_pad_' .. i]:setTag(42 + i)
    end
    vars.anim_boost_pad = pd.timer.new(500, 1, 4.99)
    vars.anim_boost_pad.repeats = true
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
    vars.audience_x = {530, 355, 295, 180, 110, 115, 155, 155, 135, 145, 95, 230, 350, 395, 580, 685}
    vars.audience_y = {80, 175, 205, 235, 305, 485, 550, 715, 925, 965, 1290, 1315, 1425, 1445, 1475, 1500}
    vars.audience_rand = {}
    for i = 1, #vars.audience_x do
        table.insert(vars.audience_rand, random(1, 11))
    end
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(0, 0, vars.stage_x, 0, vars.stage_x, vars.stage_y, 0, vars.stage_x, 0, 0, 270, 280, 305, 245, 340, 215, 390, 190, 435, 170, 485, 155, 540, 145, 670, 145, 1170, 145, 1225, 145, 1280, 155, 1335, 175, 1390, 200, 1430, 230, 1480, 275, 1505, 325, 1520, 405, 1505, 455, 1490, 500, 1475, 545, 1470, 570, 1470, 1015, 1475, 1040, 1510, 1140, 1515, 1180, 1515, 1225, 1505, 1270, 1480, 1310, 1440, 1355, 1395, 1390, 1345, 1415, 1295, 1435, 1240, 1445, 1160, 1450, 655, 1450, 515, 1445, 450, 1430, 405, 1410, 355, 1385, 315, 1355, 270, 1315, 235, 1275, 210, 1220, 190, 1175, 185, 1115, 180, 465, 195, 400, 215, 350, 250, 300, 270, 280, 0, 0),
        geo.polygon.new(625, 750, 625, 845, 665, 915, 730, 960, 760, 960, 1305, 960, 1375, 975, 1400, 975, 1405, 805, 1400, 625, 1380, 610, 1320, 630, 735, 635, 660, 685, 620, 750),
        geo.polygon.new(340, 590, 350, 530, 370, 475, 420, 415, 470, 360, 535, 320, 610, 295, 670, 290, 1200, 290, 1240, 295, 1300, 330, 1335, 360, 1340, 400, 1330, 435, 1300, 470, 1260, 490, 1215, 500, 1165, 505, 645, 505, 615, 515, 580, 535, 540, 570, 505, 625, 495, 665, 490, 730, 490, 850, 495, 925, 505, 965, 535, 1015, 575, 1055, 620, 1080, 670, 1090, 1200, 1090, 1255, 1100, 1300, 1125, 1330, 1150, 1335, 1175, 1340, 1210, 1320, 1245, 1290, 1270, 1245, 1295, 1195, 1305, 650, 1305, 590, 1290, 515, 1260, 455, 1220, 410, 1175, 375, 1115, 355, 1075, 340, 1025, 335, 960, 340, 590),
    }
    -- Bounds for the calc'd polygons
    self:fill_polygons()
    self:both_polygons()

    vars.shades = true
    assets.shades = gfx.image.new('images/race/meter/shades')
    vars.anim_shades_x = pd.timer.new(0, 0, 0)
    vars.anim_shades_x.discardOnCompletion = false
    vars.anim_shades_y = pd.timer.new(0, 0, 0)
    vars.anim_shades_y.discardOnCompletion = false

    newmusic('audio/music/stage3', true, 0.508) -- Adding new music
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