local pd <const> = playdate
local gfx <const> = pd.graphics

class('race').extends(gfx.sprite)
function race:init(...)
    race.super.init(self)
    local args = {...}
    local track_arg = args[1]
    local mode_arg = args[2]
    local boat_arg = args[3]
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
        img_boat_wooden = gfx.imagetable.new('images/race/boats/1r')
    }

    vars = {
        boat_speed = 2,
        boat_turn = 2,
        boat_rotation = 0
    }

    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setImage(assets.img_boat_wooden[1])
        self:moveTo(200, 120)
        self:add()
    end
    function boat:update()
        local change = pd.getCrankChange()
        vars.boat_rotation += math.floor(change) - 10
        self:setImage(assets.img_boat_wooden[math.floor((vars.boat_rotation % 360) / 6) + 1])
        print(vars.boat_rotation)
    end

    self.boat = boat()

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