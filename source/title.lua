-- This file contains the code for the title screen!
-- This screen lets you start or continue a Story game, take you to Time Trials (when unlocked), Play Stats, and Options.

-- Importing other scenes that we'll have to travel to:
import 'opening'
import 'cutscene'
import 'intro'
import 'stages'
import 'stats'
import 'options'
import 'notif'
import 'chapters'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
    title.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
    }
    vars.titleHandlers = {
    }
    pd.inputHandlers.push(vars.titleHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        -- Draw background stuff here...
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
    end)

    class('title_x1').extends(gfx.sprite)
    function title_x1:init()
        title_x1.super.init(self)
    end
    function title_x1:update()
    end

    -- Set the sprites
    self.x1 = title_x1()
    self:add()

    newmusic('audio/music/title', true, 1.1) -- Adding new music
end

-- Scene update loop
function title:update()
end