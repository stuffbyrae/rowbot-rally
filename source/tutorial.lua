local pd <const> = playdate
local gfx <const> = pd.graphics

class('tutorial').extends(gfx.sprite)
function tutorial:init(...)
    tutorial.super.init(self)
    args = {...}
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("skip tutorial", function()
            if vars.arg_move == "story" then
                scenemanager:transitionsceneoneway(cutscene, 2)
            else
                scenemanager:transitionscene(options)
            end
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end

    assets = {

    }

    vars = {
        arg_move = args[1] -- "story" or "options"
    }
    
    self:add()
end

function tutorial:update()
end