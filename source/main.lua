-- Importing libraries
import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'CoreLibs/ui'
import 'CoreLibs/sprites'
import 'CoreLibs/math'
import 'CoreLibs/animation'
import 'libraries/pdParticles'

-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

showcrankindicator = false

stage_1_best_time = 17970
stage_2_best_time = 17970
stage_3_best_time = 17970
stage_4_best_time = 17970
stage_5_best_time = 17970
stage_6_best_time = 17970
stage_7_best_time = 17970
active_adventure = false
current_track = 0
max_track = 0

-- Setting up the scene manager, and all the scenes
import "scenemanager"
import "save"
import "title"
import "options"
scenemanager = scenemanager()

checksave = pd.datastore.read()
if checksave == nil then
    scenemanager:switchscene(save)
else
    stage_1_best_time = checksave["t1"]
    stage_2_best_time = checksave["t2"]
    stage_3_best_time = checksave["t3"]
    stage_4_best_time = checksave["t4"]
    stage_5_best_time = checksave["t5"]
    stage_6_best_time = checksave["t6"]
    stage_7_best_time = checksave["t7"]
    active_adventure = checksave["aa"]
    current_track = checksave["ct"]
    max_track = checksave["mt"]
    scenemanager:switchscene(options)
end
-- Setting up important stuff
pd.display.setRefreshRate(30)
pd.ui.crankIndicator:start()

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

-- Update!
function pd.update()
    gfx.sprite.update()
    if pd.isCrankDocked() and showcrankindicator then
        pd.ui.crankIndicator:update()
    end
    pd.timer.updateTimers()
end
function pd.debugDraw()
    pd.drawFPS(0, 0)
end