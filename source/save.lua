-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- We're gonna move to this scene later, so call it now!
import "title"

-- Let's set this thing up.
class('save').extends(gfx.sprite)
function save:init()
    save.super.init(self)
    
    -- Define the font...
    local reelistic_handwriting = gfx.font.new('fonts/reelistic_handwriting')
    gfx.setFont(reelistic_handwriting)

    -- ...and draw the screen. This whole thing's pretty simple
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        gfx.fillRect(0, 0, 400, 240)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextAligned("Creating save data, hang tight...", 200, 110, kTextAlignment.center)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end)

    -- Grab the save template, and shove it into a data file!
    local freshsave = json.decode('{"aa":false,"ct":0,"mt":0,"t1":5999,"t2":5999,"t3":5999,"t4":5999,"t5":5999,"t6":5999,"t7":5999}')
    pd.datastore.write(freshsave)

    -- After a couple of seconds (so it feels like it's doing something bigger), switch away from this scene.
    pd.timer.performAfterDelay(2000, function() scenemanager:switchscene(race) end)
    self:add()
end