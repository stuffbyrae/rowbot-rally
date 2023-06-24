import 'title'
import 'results'

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
        img_boat_wooden = gfx.imagetable.new('images/race/boats/1r'),
        img_boat_pro = gfx.imagetable.new('images/race/boats/2r'),
        img_boat_surf = gfx.imagetable.new('images/race/boats/3r'),
        img_boat_raft = gfx.imagetable.new('images/race/boats/4r'),
        img_boat_swan = gfx.imagetable.new('images/race/boats/5r'),
        img_boat_gold = gfx.imagetable.new('images/race/boats/6r'),
        img_boat_hover = gfx.imagetable.new('images/race/boats/7r'),
        img_meter = gfx.image.new('images/race/meter'),
        img_meter_mask = gfx.image.new('images/race/meter_mask'),
        img_item = gfx.image.new('images/race/item'),
        img_item_active = gfx.image.new('images/race/item_active'),
        img_item_used = gfx.image.new('images/race/item_used'),
        img_test = gfx.image.new('images/race/test')
    }

    vars = {
        boat_speed_stat = 2,
        boat_turn_stat = 2,
        boat_speed = 0,
        boat_turn = 0,
        boat_rotation = 0,
        boost_available = true,
        boost_active = true,
        boosting = false,
        race_started = false,
        race_in_progress = false,
        race_finished = false,
        elapsed_time = 0,
        laps = 0
    }

    class('track').extends(gfx.sprite)
    function track:init()
        track.super.init(self)
        self:setImage(assets.img_test)
        self:add()
    end
    function track:update()
    end

    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setImage(assets.img_boat_wooden[1])
        self:moveTo(200, 120)
        self:add()
    end
    function boat:update()
        change = pd.getCrankChange()/2
        if vars.boat_turn < change then vars.boat_turn += vars.boat_turn_stat/5 else vars.boat_turn -= vars.boat_turn_stat/5 end
        if vars.boat_turn < 0 then vars.boat_turn = 0 end
        vars.boat_rotation += vars.boat_turn -= vars.boat_turn_stat*3
        vars.boat_radtation = math.rad(vars.boat_rotation%360)
        self:setImage(assets.img_boat_wooden[math.floor((vars.boat_rotation%360) / 6)+1])

        local speedMultiplier = 2
        if vars.boosting then
            speedMultiplier = 5
        end

        self:moveBy(math.sin(vars.boat_radtation)*vars.boat_speed_stat*speedMultiplier, math.cos(vars.boat_radtation)*-vars.boat_speed_stat*speedMultiplier)
        
    end

    class('meter').extends(gfx.sprite)
    function meter:init()
        meter.super.init(self)
        self:moveTo(200, 120)
        self:setIgnoresDrawOffset(true)
        self:setImage(img_meter)
        self:add()
    end
    function meter:update()
    end

    class('item').extends(gfx.sprite)
    function item:init()
        item.super.init(self)
        self:setImage(assets.img_item)
        self:moveTo(400, 0)
        self:setIgnoresDrawOffset(true)
        self:setCenter(1, 0)
    end
    
    self.track = track()
    self.boat = boat()
    self.meter = meter()
    self.item = item()
    
    if vars.boost_available then self.item:add() end

    self:add()
end

function race:start()
end

function race:finish()
end

function race:restart()
end

function race:update()
    local cameraDistance = 20
    gfx.setDrawOffset(200+(-self.boat.x)+(math.sin(vars.boat_radtation)*-cameraDistance), 120+(-self.boat.y)+(math.cos(vars.boat_radtation)*cameraDistance))
    if pd.buttonJustPressed('a') then
        if vars.boost_available and vars.boost_active then
            vars.boost_active = false
            vars.boosting = true
            self.item:setImage(assets.img_item_active)
            pd.timer.performAfterDelay(75, function() self.item:setImage(assets.img_item_used) end)
            pd.timer.performAfterDelay(2000, function() vars.boosting = false end)
        end
    end
end