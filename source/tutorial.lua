local pd <const> = playdate
local gfx <const> = pd.graphics

class('tutorial').extends(gfx.sprite)
function tutorial:init(...)
    tutorial.super.init(self)
    args = {...}
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 100
        pauserand = math.random(1, 8)
        if first_pause == false then
            pauserand = 1
            first_pause = true
        end
        local paused = gfx.image.new('images/ui/paused' .. pauserand)
        gfx.pushContext(img)
            paused:draw(-200 + xoffset, 0)
        gfx.popContext()
        pd.setMenuImage(img, xoffset)
        menu:addMenuItem("skip tutorial", function()
            self:finish()
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end

    assets = {

    }

    vars = {
        arg_move = args[1] -- "story" or "options"
    }
    
    self:add()
end

function tutorial:finish()
    if vars.arg_move == "story" then
        save.ss = true
        save.cc = 2
        if save.cc > save.mc then
            save.mc = save.cc
        end
        scenemanager:transitionsceneoneway(cutscene, 2)
    else
        scenemanager:transitionscene(options)
    end
end

function tutorial:update()
end