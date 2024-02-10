-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('chase').extends(gfx.sprite) -- Create the scene's class
function chase:init(...)
    chase.super.init(self)
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
    vars.chaseHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.chaseHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        -- Draw background stuff here...
    end)

    class('chase_x1').extends(gfx.sprite)
    function chase_x1:init()
        chase_x1.super.init(self)
    end
    function chase_x1:update()
    end

    -- Set the sprites
    self.x1 = chase_x1()
    self:add()
end

-- Scene update loop
function chase:update()
end