-- Importing libraries
import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'CoreLibs/ui'
import 'CoreLibs/sprites'
import 'CoreLibs/math'
import 'CoreLibs/animation'
import 'pdParticles'

-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Setting up the scene manager
import "scenemanager"
scenemanager = scenemanager()
import "title"
import "race"
import "opening"

-- Setting up important stuff
pd.display.setRefreshRate(30)
opening()

-- Update!
function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
end