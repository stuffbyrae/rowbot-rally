local pd <const> = playdate
local gfx <const> = pd.graphics

class('tracks').extends(gfx.sprite)
function tracks:init(...)
    tracks.super.init(self)
    local args = {...}
    local boat = args[1]
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("change boat", function()
            scenemanager:switchscene(garage)
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:switchscene(title, true)
        end)
    end

    self:add()
end

function tracks:update()
end