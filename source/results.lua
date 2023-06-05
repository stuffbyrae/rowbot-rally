local pd <const> = playdate
local gfx <const> = pd.graphics

class('results').extends(gfx.sprite)
function results:init(...)
    results.super.init(self)
    local args = {...}
    local track = args[1]
    local mode = args[2]
    local boat = args[3]
    local time = args[4]
    local bg = args[5]
    show_crank = false
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("retry", function()

        end)
        menu:addMenuItem("change track", function()

        end)
        menu:addMenuItem("change boat", function()

        end)
        menu:addMenuItem("back to title", function()
            scenemanager:switchscene(title, true)
        end)
    end

    self:add()
end

function results:update()
end