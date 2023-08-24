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
        if save.cs then
            menu:addMenuItem(gfx.getLocalizedText("skipcredits"), function()
                self:finish()
            end)
        end
    end
    
    self:add()
end

function credits:finiah()
    if vars.arg_move == "title" then
        --this below stuff is for v1.1, hi sneaky
        --if save.ms == false then
            --scenemanager:switchscene(notif, "mirror", "title")
        --else
            scenemanager:switchscene(title, false)
        --end
    else
        scenemanager:switchscene(options)
    end
end

function credits:update()
end