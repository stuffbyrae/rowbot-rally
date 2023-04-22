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

-- Setting up the scene manager, and all the scenes
import "scenes/title"
import "scenes/race"
import "scenes/opening"
import "scenes/cutscene"
import "scenes/settings"
import "scenes/credits"
import "scenes/garage"
import "scenes/tracks"
import "scenes/splash"
import "scenes/scenemanager"
scenemanager = scenemanager()

-- Setting up important stuff
pd.display.setRefreshRate(30)
opening()

-- Update!
function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
end