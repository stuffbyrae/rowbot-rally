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
import 'cheats'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Cheat code setup
import "Tanuk_CodeSequence"

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

    local cheat_code_big = Tanuk_CodeSequence({pd.kButtonUp,}, function()
        scenemanager:switchscene(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_big'), gfx.getLocalizedText('title_screen'), false, function()
            scenemanager:switchscene(title)
        end)
    end, true)
    local cheat_code_small = Tanuk_CodeSequence({pd.kButtonDown,}, function()
        scenemanager:switchscene(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_small'), gfx.getLocalizedText('title_screen'), false, function()
            scenemanager:switchscene(title)
        end)
    end, true)
    local cheat_code_tiny = Tanuk_CodeSequence({pd.kButtonLeft,}, function()
        scenemanager:switchscene(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_tiny'), gfx.getLocalizedText('title_screen'), false, function()
            scenemanager:switchscene(title)
        end)
    end, true)
    local cheat_code_dents = Tanuk_CodeSequence({pd.kButtonRight,}, function()
        scenemanager:switchscene(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_dents'), gfx.getLocalizedText('title_screen'), false, function()
            scenemanager:switchscene(title)
        end)
    end, true)
    local cheat_code_retro = Tanuk_CodeSequence({pd.kButtonB,}, function()
        scenemanager:switchscene(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_retro'), gfx.getLocalizedText('title_screen'), false, function()
            scenemanager:switchscene(title)
        end)
    end, true)
    local cheat_code_all = Tanuk_CodeSequence({pd.kButtonA,}, function()
        scenemanager:switchscene(notif, gfx.getLocalizedText('cheatcode'), gfx.getLocalizedText('popup_cheat_all'), gfx.getLocalizedText('title_screen'), false, function()
            scenemanager:switchscene(title)
        end)
    end, true)
    
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