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

stage_1_best_time = 0
stage_2_best_time = 0
stage_3_best_time = 0
stage_4_best_time = 0
stage_5_best_time = 0
stage_6_best_time = 0
stage_7_best_time = 0
active_adventure = false
current_track = 0
max_track = 0

-- Setting up the scene manager, and all the scenes
import "scenemanager"
import "save"
import "race"
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
  scenemanager:switchscene(title)
end
-- Setting up important stuff
pd.display.setRefreshRate(30)

-- Update!
function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
end