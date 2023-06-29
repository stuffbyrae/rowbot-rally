local pd <const> = playdate
local gfx <const> = pd.graphics

class('credits').extends(gfx.sprite)
function credits:init(...)
    credits.super.init(self)
    local args = {...}
    local move = args[1] -- "title" or "options"
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if save.cs then
            menu:addMenuItem("skip credits", function()
                scenemanager:transitionsceneoneway(title, false)
            end)
        end
    end
    
    self:add()
end

function credits:update()
end