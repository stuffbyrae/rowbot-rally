local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)
function cutscene:init(...)
    cutscene.super.init(self)
    local args = {...}
    local play = args[1]
    local move = args[2]
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("skip scene", function()
            
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:switchscene(title, true)
        end)
    end

    self:add()
end

function cutscene:update()
end