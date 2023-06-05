local pd <const> = playdate
local gfx <const> = pd.graphics

class('tutorial').extends(gfx.sprite)
function tutorial:init()
    tutorial.super.init(self)
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("skip tutorial", function()
            scenemanager:switchscene(title, false)
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:switchscene(title, true)
        end)
    end
    
    self:add()
end

function tutorial:update()
end