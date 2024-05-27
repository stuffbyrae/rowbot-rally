-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local random <const> = math.random

function race:stage_init()
    assets.image_stage = gfx.image.new('stages/7/stage')
    assets.image_stagec = gfx.image.new('stages/7/stagec')
    assets.image_water_bg = gfx.image.new('stages/7/water_bg')
    assets.water = gfx.imagetable.new('stages/7/water')
    assets.caustics = gfx.imagetable.new('stages/7/caustics')

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
        vars.follow_polygon = pd.geometry.polygon.new()
    end
    vars.laps = 1 -- How many laps...
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
    -- add checkpoint stuff
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
    vars.fill_bounds = {}
    self:fill_polygons()
    vars.both_bounds = {}
    self:both_polygons()

    newmusic('audio/music/stage5', true) -- Adding new music
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
    -- add checkpoint stuff
end

function race:both_polygons()
    local stage_x = vars.stage_x
    local stage_y = vars.stage_y
    local parallax_short_amount = vars.parallax_short_amount
    local parallax_medium_amount = vars.parallax_medium_amount
    local stage_progress_short_x = vars.stage_progress_short_x
    local stage_progress_short_y = vars.stage_progress_short_y
    vars.both_polygons = {}
    -- add checkpoint stuff
end