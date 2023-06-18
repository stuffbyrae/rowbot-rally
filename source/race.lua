local pd <const> = playdate
local gfx <const> = pd.graphics

class('race').extends(gfx.sprite)
function race:init(...)
    race.super.init(self)
    local args = {...}
    local track = args[1]
    local mode = args[2]
    local boat = args[3]
    show_crank = true
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("restart race", function()
            
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:switchscene(title, true)
        end)
    end

    assets = {

    }

    vars = {

    }


    self:add()
end

function race:start()
end

function race:finish()
end

function race:restart()
end

function race:update()
end