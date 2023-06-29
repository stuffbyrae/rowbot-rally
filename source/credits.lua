local pd <const> = playdate
local gfx <const> = pd.graphics

class('credits').extends(gfx.sprite)
function credits:init(...)
    credits.super.init(self)
    local args = {...}
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("skip credits", function()
            scenemanager:switchscene(title, false)
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    self:add()
end

function credits:update()
end