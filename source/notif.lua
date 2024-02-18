import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('notif').extends(gfx.sprite) -- Create the scene's class
function notif:init(...)
    notif.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    vars = { -- This scene takes the same args as the makepopup() function, just displays it in its own bespoke scene.
        head_text = args[1],
        body_text = args[2],
        button_text = args[3],
        b_close = args[4],
        callback = args[5]
    }
    vars.notifHandlers = {
        -- No handlers necessary! All the work here is done with the UI pop-up.
    }
    pd.inputHandlers.push(vars.notifHandlers)

    makepopup(vars.head_text, vars.body_text, vars.button_text, vars.b_close, vars.callback)

    self:add()
end