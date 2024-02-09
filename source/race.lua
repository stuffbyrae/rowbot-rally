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
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_water_bg = gfx.image.new('images/race/tracks/water_bg'),
        test = gfx.image.new('images/race/tracks/track1'),
        testc1 = gfx.image.new('images/race/tracks/trackc1')
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
    }
    vars.raceHandlers = {
        BButtonDown = function()
            self.boat:boost()
        end,
        upButtonDown = function()
            self.boat.straight = true
        end,
        upButtonUp = function()
            self.boat.straight = false
        end,
        rightButtonDown = function()
            self.boat.right = true
        end,
        rightButtonUp = function()
            self.boat.right = false
        end
    }
    pd.inputHandlers.push(vars.raceHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_water_bg:draw(0, 0)
    end)

    class('test').extends(gfx.sprite)
    function test:init()
        self:setZIndex(5)
        self:setCenter(0, 0)
        self:setImage(assets.test)
        x, y = assets.test:getSize()
        self:setCollideRect(0, 0, x, y)
        self:add()
    end

    -- Set the sprites
    self.test = test()
    self.boat = boat(275, 800, true, false)
    self:add()
    
    pd.timer.performAfterDelay(4000, function()
        self.boat:state(true, true, true)
    end)
end

-- Scene update loop
function race:update()
    self.boat:collision_check(assets.testc1)
end