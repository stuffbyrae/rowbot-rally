import 'results'
import 'boat'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('race').extends(gfx.sprite) -- Create the scene's class
function race:init(...)
    race.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/tracks/water_bg'),
        test = gfx.image.new('images/race/tracks/track1')
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
    }
    vars.raceHandlers = {
        AButtonDown = function()
            self.boat:leap()
        end,
        BButtonDown = function()
            self.boat:boost()
        end
    }
    pd.inputHandlers.push(vars.raceHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('test').extends(gfx.sprite)
    function test:init()
        self:setZIndex(-40)
        self:setImage(assets.test)
        self:add()
    end

    -- Set the sprites
    self.test = test()
    self.boat = boat(200, 120)
    self:add()
end

-- Scene update loop
function race:update()
    -- gfx.setDrawOffset(-self.x + 200 - (math.sin(self.radtation) * self.camera_x:currentValue()), -self.y + 120 + (math.cos(self.radtation) * self.camera_x:currentValue()))
end