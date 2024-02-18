import 'title'
import 'cutscene'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry

class('tutorial').extends(gfx.sprite) -- Create the scene's class
function tutorial:init(...)
    tutorial.super.init(self)
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
    vars.tutorialHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.tutorialHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        -- Draw background stuff here...
    end)

    class('tutorial_x1').extends(gfx.sprite)
    function tutorial_x1:init()
        tutorial_x1.super.init(self)
    end
    function tutorial_x1:update()
    end

    -- Set the sprites
    self.x1 = tutorial_x1()
    self:add()
end

-- Scene update loop
function tutorial:update()
end