import 'title'
import 'cutscene'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local floor <const> = math.floor
local min <const> = math.min
local max <const> = math.max

class('chase').extends(gfx.sprite) -- Create the scene's class
function chase:init(...)
    chase.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(200) -- TODO: Set this X offset
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        boat = gfx.imagetable.new('images/chase/boat'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        boat_turn = 5,
        boat_turn_min = 9,
        boat_turn_max = 1,
        boat_speed = 0,
        boat_speed_min = -10,
        boat_speed_max = 10,
    }
    vars.chaseHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.chaseHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing

    end)

    class('chase_boat').extends(gfx.sprite)
    function chase_boat:init()
        chase_boat.super.init(self)
        self:setImage(assets.boat[5])
        self:setCenter(0.5, 1)
        self:moveTo(200, 210)
        self:add()
    end
    function chase_boat:update()
    end

    -- Set the sprites
    sprites.boat = chase_boat()
    self:add()

    savegame() -- Save the game!
end

-- Scene update loop
function chase:update()
    local change = pd.getCrankChange()
    vars.boat_speed -= 0.3
    vars.boat_speed += change / 8
    vars.boat_speed = max(vars.boat_speed_min, min(vars.boat_speed_max, vars.boat_speed))
    sprites.boat:moveBy(vars.boat_speed, 0)
end