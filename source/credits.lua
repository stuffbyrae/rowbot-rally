local pd <const> = playdate
local gfx <const> = pd.graphics

class('credits').extends(gfx.sprite)
function credits:init(...)
    credits.super.init(self)
    local args = {...}
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)
    
    assets = {
        
    }

    vars = {
        arg_move = args[1] -- "title" or "options"
    }

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 100
        pd.setMenuImage(img, xoffset)
        if save.credits_unlocked then
            menu:addMenuItem(gfx.getLocalizedText("skipcredits"), function()
                self:finish()
            end)
        end
    end
    
    self:add()
end

function credits:finiah()
    if vars.arg_move == "title" then
        scenemanager:switchscene(title, false)
        if not save.credits_unlocked then
            save.credits_unlocked = true
        end
    else
        scenemanager:switchscene(options)
    end
end

function credits:update()
end