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

show_crank = false

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
current_cutscene = 0
max_cutscene = 0
music_volume = 5
sound_volume = 5

-- Setting up the scene manager, and all the scenes
import "scenemanager"
import "race"
import "title"
import "options"
scenemanager = scenemanager()

checksave = pd.datastore.read()
if checksave == nil then
    local freshsave = json.decode('{"as":false,"mu":5,"fx":5,"ct":0,"mt":0,"cc":0,"mc":0,"t1":17970,"t2":17970,"t3":17970,"t4":17970,"t5":17970,"t6":17970,"t7":17970}')
    pd.datastore.write(freshsave)
else
    stage_1_best_time = checksave["t1"] -- Best time. Default is 17970
    stage_2_best_time = checksave["t2"] -- Best time. Default is 17970
    stage_3_best_time = checksave["t3"] -- Best time. Default is 17970
    stage_4_best_time = checksave["t4"] -- Best time. Default is 17970
    stage_5_best_time = checksave["t5"] -- Best time. Default is 17970
    stage_6_best_time = checksave["t6"] -- Best time. Default is 17970
    stage_7_best_time = checksave["t7"] -- Best time. Default is 17970
    active_story = checksave["as"] -- Is there an active story?
    current_track = checksave["ct"] -- What's the current track on the active story? Min 0, Max 7
    max_track = checksave["mt"] -- What's the farthest track the player's gotten to all-time? Min 0, Max 7
    current_cutscene = checksave["cc"] -- What's the current last fully-played cutscene? Min 0, Max 10
    max_cutscene = checksave["mc"] -- What's the farthest fully-played cutscene? Min 0, Max 10
    music_volume = checksave["mu"] -- Music volume. Min 0, Max 5
    sound_volume = checksave["fx"] -- SFX volume. Min 0, Max 5
end

-- Setting up important stuff
pd.display.setRefreshRate(30)
pd.ui.crankIndicator:start()

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

scenemanager:switchscene(title, false)

-- Update!
function pd.update()
    gfx.sprite.update()
    if pd.isCrankDocked() and show_crank then
        pd.ui.crankIndicator:update()
    end
    pd.timer.updateTimers()
    pd.drawFPS(0, 0)
end