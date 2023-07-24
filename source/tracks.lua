local pd <const> = playdate
local gfx <const> = pd.graphics

class('tracks').extends(gfx.sprite)
function tracks:init(...)
    tracks.super.init(self)
    local args = {...}
    show_crank = false
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("change boat", function()
            scenemanager:transitionscene(garage)
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {

    }
    
    vars = {
        arg_boat = args[1] -- 1 through 7
    }

    self:add()
end

function tracks:update()
end