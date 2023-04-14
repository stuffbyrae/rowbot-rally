-- Importing libraries
import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'CoreLibs/ui'
import 'CoreLibs/sprites'
import 'CoreLibs/math'
import 'CoreLibs/animation'

-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

slide_menu_000 = gfx.image.new('images/slide_menu/000')
pd.setMenuImage(slide_menu_000)

-- Setting up the scene manager
import "scenemanager"
scenemanager = scenemanager()
import "title"
import "race"

-- Setting up important stuff
pd.display.setRefreshRate(30)
race()

-- Update!
function pd.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
end