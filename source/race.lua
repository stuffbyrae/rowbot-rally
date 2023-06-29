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
    local mirror_arg = args[4]
    pd.ui.crankIndicator:start()
    show_crank = true
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if vars.race_ongoing then
            menu:addMenuItem("restart race", function()
            end)
        end
        if vars.race_finished == false then
            menu:addMenuItem("back to title", function()
                scenemanager:transitionsceneoneway(title, false)
            end)
            menu:addCheckmarkMenuItem("show ui", save.ui, function()
                save.ui = not save.ui
                if save.ui then
                    self.react:add()
                    self.meter:add()
                else
                    self.react:remove()
                    self.meter:remove()
                end
            end)
        end
    end
    
    assets = {
        img_timer = gfx.image.new('images/race/timer'),
        img_timer_tt = gfx.image.new('images/race/timer_tt'),
        img_timer_1 = gfx.image.new('images/race/timer_1'),
        img_timer_2 = gfx.image.new('images/race/timer_2'),
        img_timer_3 = gfx.image.new('images/race/timer_3'),
        img_item = gfx.image.new('images/race/item'),
        img_item_active = gfx.image.new('images/race/item_active'),
        img_item_used = gfx.image.new('images/race/item_used'),
        img_react_idle = gfx.image.new('images/race/react_idle'),
        img_react_happy = gfx.image.new('images/race/react_happy'),
        img_react_shocked = gfx.image.new('images/race/react_shocked'),
        img_react_confused = gfx.image.new('images/race/react_confused'),
        img_react_crash = gfx.image.new('images/race/react_crash'),
        img_meter = gfx.image.new('images/race/meter'),
        img_meter_mask = gfx.image.new('images/race/meter_mask'),
        img_wake = gfx.image.new('images/race/wake'),
        img_overlay_boost = gfx.imagetable.new('images/race/boost/boost'),
        img_water = gfx.image.new('images/race/tracks/water'),
        times_new_rally = gfx.font.new('fonts/times_new_rally')
    }
    gfx.setFont(assets.times_new_rally)

    vars = {
        anim_camera = gfx.animator.new(1, 30, 30),
        anim_overlay_boost = nil,
        boat_speed = 0,
        boat_turn = 0,
        boat_rotation = 0,
        boost_available = true,
        boosting = false,
        race_started = false,
        race_in_progress = false,
        race_finished = false,
        elapsed_time = 0,
        laps = 0,
        reacting = false,
        anim_react = nil
    }
    
    if boat_arg == 1 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/1r')
        vars.boat_speed_stat = 2
        vars.boat_turn_stat = 2
    elseif boat_arg == 2 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/2r')
        vars.boat_speed_stat = 2
        vars.boat_turn_stat = 3
    elseif boat_arg == 3 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/3r')
        vars.boat_speed_stat = 2.5
        vars.boat_turn_stat = 2
    elseif boat_arg == 4 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/4r')
        vars.boat_speed_stat = 1.5
        vars.boat_turn_stat = 4
    elseif boat_arg == 5 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/5r')
        vars.boat_speed_stat = 2.5
        vars.boat_turn_stat = 3
    elseif boat_arg == 6 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/6r')
        vars.boat_speed_stat = 2
        vars.boat_turn_stat = 4
    elseif boat_arg == 7 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/7r')
        vars.boat_speed_stat = 3
        vars.boat_turn_stat = 2
    else
        print("hey, we didn't get told which boat to use. something is CATASTROPHIC!! use the wooden one to save face, but figure out what the hell's going wrong pronto")
        assets.img_boat = gfx.imagetable.new('images/race/boats/1r')
        vars.boat_speed_stat = 2
        vars.boat_turn_stat = 2
    end

    if track_arg == 1 then
        assets.img_track = gfx.image.new('images/race/tracks/track_1')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_1c')
    elseif track_arg == 2 then
    elseif track_arg == 3 then
    elseif track_arg == 4 then
    elseif track_arg == 5 then
    elseif track_arg == 6 then
    elseif track_arg == 7 then
    else
    end
    
    vars.anim_boat_speed = gfx.animator.new(1000, 0, vars.boat_speed_stat, pd.easingFunctions.inOutSine)
    vars.anim_boat_turn = gfx.animator.new(1000, 0, vars.boat_turn_stat, pd.easingFunctions.inOutSine)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.img_water:draw(0, 0)
    end)
    
    class('trackc').extends(gfx.sprite)
    function trackc:init()
        trackc.super.init(self)
        self:setImage(assets.img_track_c)
        self:add()
        self:setZIndex(-99)
        self:setCenter(0, 0)
    end

    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setZIndex(0)
        self:moveTo(200, 120)
        self:add()
    end
    function boat:update()
        change = pd.getCrankChange()/2
        if vars.boat_turn < change then vars.boat_turn += vars.boat_turn_stat/5 else vars.boat_turn -= vars.boat_turn_stat/5 end
        if vars.boat_turn < 0 then vars.boat_turn = 0 end
        vars.boat_rotation += vars.boat_turn*vars.boat_turn_stat*0.56 -= vars.anim_boat_turn:currentValue()*3
        vars.boat_radtation = math.rad(vars.boat_rotation%360)
        self:setImage(assets.img_boat[math.floor((vars.boat_rotation%360) / 6)+1])
        if vars.boosting then
            self:moveBy(math.sin(vars.boat_radtation)*vars.boat_speed*4.5, math.cos(vars.boat_radtation)*-vars.boat_speed*4.5)
        else
            self:moveBy(math.sin(vars.boat_radtation)*vars.boat_speed*2.5, math.cos(vars.boat_radtation)*-vars.boat_speed*2.5)
        end
    end

    class('track').extends(gfx.sprite)
    function track:init()
        track.super.init(self)
        self:setImage(assets.img_track)
        self:add()
        self:setZIndex(1)
        self:setCenter(0, 0)
    end

    class('timer').extends(gfx.sprite)
    function timer:init()
        timer.super.init(self)
        self:setCenter(0, 0)
        self:moveTo(0, 5)
        self:setZIndex(99)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function timer:update()
        local mins = string.format("%02.f", math.floor((vars.elapsed_time/30) / 60))
        local secs = string.format("%02.f", math.floor((vars.elapsed_time/30) - mins * 60))
        local mils = string.format("%02.f", (vars.elapsed_time/30)*99 - mins * 5940 - secs * 99)
        local img = gfx.image.new(121, 60)
        gfx.pushContext(img)
        assets.img_timer:draw(0, 0)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(mins..":"..secs.."."..mils, 44, 15)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.popContext()
        self:setImage(img)
    end

    class('item').extends(gfx.sprite)
    function item:init()
        item.super.init(self)
        self:setImage(assets.img_item)
        self:moveTo(400, 0)
        self:setZIndex(99)
        self:setIgnoresDrawOffset(true)
        self:setCenter(1, 0)
    end

    class('react').extends(gfx.sprite)
    function react:init()
        react.super.init(self)
        self:setImage(assets.img_react_idle)
        self:setZIndex(98)
        self:setIgnoresDrawOffset(true)
        self:setCenter(0.5, 0)
        self:moveTo(200, 152)
    end
    function react:update()
        if vars.reacting == true then
            self:moveTo(200, vars.anim_react:currentValue())
        end
    end
    function react:change(a)
        if a == "idle" then
            self:setImage(assets.img_react_idle)
            vars.reacting = false
            vars.anim_react = nil
            self:moveTo(200, 152)
            return
        end
        if a == "happy" then
            self:setImage(assets.img_react_happy)
            vars.anim_react = gfx.animator.new(350, 152, 142, pd.easingFunctions.outSine)
            vars.anim_react.reverses = true
            vars.anim_react.repeatCount = -1
            vars.reacting = true
            return
        end
        if a == "shocked" then
            self:setImage(assets.img_react_shocked)
            return
        end
        if a == "curious" then
            self:setImage(assets.img_react_curious)
            return
        end
        if a == "crash" then
            self:setImage(assets.img_react_crash)
            return
        end
    end

    class('meter').extends(gfx.sprite)
    function meter:init()
        meter.super.init(self)
        self:setZIndex(99)
        self:setCenter(0.5, 1)
        self:moveTo(200, 240)
        self:setIgnoresDrawOffset(true)
    end
    function meter:update()
        local img = gfx.image.new(195, 38)
        gfx.pushContext(img)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(195, 0, -vars.boat_turn*7, 38)
            gfx.fillRect(0, 0, vars.boat_speed_stat*20, 38)
            img:setMaskImage(assets.img_meter_mask)
            assets.img_meter:draw(0, 0)
        gfx.popContext()
        self:setImage(img)
    end

    class('overlay').extends(gfx.sprite)
    function overlay:init()
        overlay.super.init(self)
        self:moveTo(200, 120)
        self:setIgnoresDrawOffset(true)
        self:setZIndex(97)
        self:add()
    end
    function overlay:update()
        if vars.anim_overlay then
            self:setImage(vars.anim_overlay:image())
        end
    end
    
    self.trackc = trackc()
    self.boat = boat()
    self.track = track()
    self.timer = timer()
    self.item = item()
    self.react = react()
    self.meter = meter()
    self.overlay = overlay()
    
    if vars.boost_available then self.item:add() end
    if save.ui then self.react:add() self.meter:add() end

    self:add()
end

function race:start()
end

function race:finish()
end

function race:restart()
end

function race:boost()
    vars.boost_available = false
    vars.boosting = true
    vars.anim_camera = gfx.animator.new(500, 30, -30, pd.easingFunctions.outSine)
    vars.anim_overlay = gfx.animation.loop.new(115, assets.img_overlay_boost, true)
    self.react:change("happy")
    self.item:setImage(assets.img_item_active)
    pd.timer.performAfterDelay(75, function() self.item:setImage(assets.img_item_used) end)
    pd.timer.performAfterDelay(1750, function() vars.anim_camera = gfx.animator.new(1000, -30, 30, pd.easingFunctions.inOutSine) end)
    pd.timer.performAfterDelay(2000, function()
        vars.boosting = false
        vars.anim_overlay = nil
        self.react:change("idle")
        self.overlay:setImage(nil)
    end)
end

function race:update()
    vars.elapsed_time += 1
    vars.camera_distance = vars.anim_camera:currentValue()
    vars.boat_speed = vars.anim_boat_speed:currentValue()
    gfx.setDrawOffset(200+(-self.boat.x)+(math.sin(vars.boat_radtation)*-vars.camera_distance), 120+(-self.boat.y)+(math.cos(vars.boat_radtation)*vars.camera_distance))
    if pd.buttonJustPressed('b') then
        if vars.boost_available then
            self:boost()
        end
    end
end