import 'title'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('cheevos').extends(gfx.sprite)

function cheevos:init()
    cheevos.super.init(self)
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 0
        pd.setMenuImage(img, xoffset)
        menu:addMenuItem(gfx.getLocalizedText("backtotitle"), function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        
    }

    vars = {
        
    }
end

function cheevos:update()

end