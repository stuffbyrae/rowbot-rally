-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('credits').extends(gfx.sprite) -- Create the scene's class
function credits:init(...)
    credits.super.init(self)
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
    vars.creditsHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.creditsHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        -- Draw background stuff here...
    end)

    class('credits_x1').extends(gfx.sprite)
    function credits_x1:init()
        credits_x1.super.init(self)
    end
    function credits_x1:update()
    end

    -- Set the sprites
    self.x1 = credits_x1()
    self:add()
end

-- Scene update loop
function credits:update()
end