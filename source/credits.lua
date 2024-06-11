import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local text <const> = gfx.getLocalizedText

class('credits').extends(gfx.sprite) -- Create the scene's class
function credits:init(...)
    credits.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(200) -- TODO: Set this X offset
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        credits = gfx.image.new('images/ui/credits'),
        creditscover1 = gfx.image.new('images/ui/creditscover1'),
        creditscover2 = gfx.image.new('images/ui/creditscover2'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        creditsscrolly = pd.timer.new(120000, 0, -2640),
        showcover1 = true,
        showcover2 = true,
    }
    vars.creditsHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.creditsHandlers)

    pd.timer.performAfterDelay(2000, function()
        vars.showcover1 = false
    end)
    pd.timer.performAfterDelay(4000, function()
        vars.showcover2 = false
    end)
    vars.creditsscrolly.delay = 6000

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.credits:draw(0, vars.creditsscrolly.value)
        if vars.showcover2 then assets.creditscover2:draw(0, 0) end
        if vars.showcover1 then assets.creditscover1:draw(0, 0) end
    end)

    self:add()

    savegame(true) -- Save the game!
end

-- Scene update loop
function credits:update()
end