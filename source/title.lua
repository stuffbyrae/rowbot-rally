-- This file contains the code for the title screen!
-- This screen lets you start or continue a Story game, take you to Time Trials (when unlocked), Play Stats, and Options.

-- Importing other scenes that we'll have to travel to:
import 'opening'
import 'cutscene'
import 'garage'
import 'stats'
import 'options'
import 'notif'

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
        image_test1 = makebutton('Press A to view stats.', "small"),
        image_test2 = makebutton('Press B to test notif scene (goes to Stats)', "small"),
        image_test3 = makebutton('Press Up to test Intro scene', "small"),
        image_test4 = makebutton('Press Down to test opening scene', "small"),
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
    }
    vars.titleHandlers = {
        AButtonDown = function()
            scenemanager:transitionsceneoneway(stats)
        end,
        BButtonDown = function()
            scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('heads_up'), gfx.getLocalizedText('popup_overwrite'), gfx.getLocalizedText('title_screen'), true, function() scenemanager:switchscene(stats) end)
        end,
        upButtonDown = function()
            fademusic()
            scenemanager:transitionsceneoneway(intro, 1)
        end,
        downButtonDown = function()
            fademusic()
            scenemanager:transitionsceneoneway(opening)
        end
    }
    pd.inputHandlers.push(vars.titleHandlers)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        -- Draw background stuff here...
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
        assets.image_test1:draw(10, 10)
        assets.image_test2:draw(10, 30)
        assets.image_test3:draw(10, 50)
        assets.image_test4:draw(10, 70)
    end)

    class('x1').extends(gfx.sprite)
    function x1:init()
        x1.super.init(self)
    end
    function x1:update()
    end

    -- Set the sprites
    self.x1 = x1()
    self:add()

    newmusic('audio/music/title', true, 1.1) -- Adding new music
end

-- Scene update loop
function title:update()
end