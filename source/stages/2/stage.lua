-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random

function race:stage_init()
    assets.image_stage = gfx.imagetable.new('stages/2/stage')
    assets.image_stagec = gfx.image.new('stages/2/stagec')
    assets.image_water_bg = gfx.image.new('stages/2/water_bg')
    assets.water = gfx.imagetable.new('stages/2/water')
    assets.caustics = gfx.imagetable.new('stages/2/caustics')
    assets.trees = gfx.imagetable.new('stages/2/tree')
    assets.trunks = gfx.imagetable.new('stages/2/trunk')
    assets.treetops = gfx.imagetable.new('stages/2/treetop')
    assets.bushes = gfx.imagetable.new('stages/2/bush')
    assets.bushtops = gfx.imagetable.new('stages/2/bushtop')

    vars.tiles_x, vars.tiles_y = assets.image_stage:getSize()
    vars.tile_x, vars.tile_y = assets.image_stage[1]:getSize()
    vars.stage_x = vars.tile_x * vars.tiles_x
    vars.stage_y = vars.tile_y * vars.tiles_y

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
        vars.follow_polygon = pd.geometry.polygon.new()
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
    vars.stage_progress_tippy_x = 0
    vars.stage_progress_tippy_y = 0
    vars.parallax_short_amount = 1.05
    vars.parallax_medium_amount = 1.1
    vars.parallax_long_amount = 1.175
    vars.parallax_tippy_amount = 1.25
    -- Poles
    vars.poles_short_x = {}
    vars.poles_short_y = {}
    vars.poles_medium_x = {}
    vars.poles_medium_y = {}
    -- Trees
    vars.trees_x = {}
    vars.trees_y = {}
    vars.trees_rand = {}
    for i = 1, #vars.trees_x do
        table.insert(vars.trees_rand, #assets.trees)
    end
    -- Bushes
    vars.bushes_x = {}
    vars.bushes_y = {}
    vars.bushes_rand = {}
    for i = 1, #vars.bushes_x do
        table.insert(vars.bushes_rand, random(1, #assets.bushes))
    end
    -- Audience members
    assets.audience1 = gfx.image.new('images/race/audience/audience_basic')
    assets.audience2 = gfx.image.new('images/race/audience/audience_fisher')
    assets.audience3 = gfx.imagetable.new('images/race/audience/audience_nebula')
    vars.audience_x = {}
    vars.audience_y = {}
    vars.audience_rand = {}
    for i = 1, #vars.audience_x do
        table.insert(vars.audience_rand, random(1, 3))
    end
    -- Race collision edges
    vars.edges_polygons = {
        geo.polygon.new(),
    }
    -- Bounds for the calc'd polygons
    self:fill_polygons()
    vars.fill_bounds = {
        {},
    }
    self:both_polygons()
    vars.both_bounds = {
        {},
    }
    self:draw_polygons()
    vars.draw_bounds = {
        {},
    }

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
    vars.fill_polygons = {
        geo.polygon.new(),
    }
end

function race:both_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
    vars.both_polygons = {
        geo.polygon.new(),
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
        geo.polygon.new(),
    }
end