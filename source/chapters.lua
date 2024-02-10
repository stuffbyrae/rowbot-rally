-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('chapters').extends(gfx.sprite) -- Create the scene's class
function chapters:init(...)
    chapters.super.init(self)
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
    vars.chaptersHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.chaptersHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        -- Draw background stuff here...
    end)

    class('chapters_x1').extends(gfx.sprite)
    function chapters_x1:init()
        chapters_x1.super.init(self)
    end
    function chapters_x1:update()
    end

    -- Set the sprites
    self.x1 = chapters_x1()
    self:add()
end

-- Scene update loop
function chapters:update()
end