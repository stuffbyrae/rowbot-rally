import 'title'
import 'results'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('race').extends(gfx.sprite)
function race:init(...)
    race.super.init(self)
    local args = {...}
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
            menu:addCheckmarkMenuItem("show ui", save.ui, function(new)
                save.ui = new
                if save.ui then
                    self.react:add()
                    self.meter:add()
                else
                    self.react:remove()
                    self.meter:remove()
                end
            end)
            if vars.race_in_progress then
                menu:addMenuItem("restart race", function()
                    self:restart()
                end)
            end
            menu:addMenuItem("back to title", function()
                scenemanager:transitionsceneoneway(title, false)
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
        img_water_bg = gfx.image.new('images/race/tracks/water_bg'),
        img_water_1 = gfx.image.new('images/race/tracks/water_1'),
        img_water_2 = gfx.image.new('images/race/tracks/water_2'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        times_new_rally = gfx.font.new('fonts/times_new_rally')
    }
    
    vars = {
        arg_track = args[1], -- 1, 2, 3, 4, 5, 6, or 7
        arg_mode = args[2], -- "story" or "tt"
        arg_boat = args[3], -- 1, 2, 3, 4, 5, 6, or 7
        arg_mirror = args[4], -- true or false. this is for v1.1!
        anim_camera = gfx.animator.new(2000, -150, 0, pd.easingFunctions.outSine),
        anim_overlay_boost = nil,
        anim_boat_speed = gfx.animator.new(1, 0, 0),
        boat_start_x = 0,
        boat_start_y = 0,
        boat_speed = 0,
        boat_turn = 0,
        boat_rotation = 0,
        boost_available = false,
        boosting = false,
        race_started = false,
        race_in_progress = false,
        race_finished = false,
        elapsed_time = 0,
        laps = 1,
        timer_scale_anim = gfx.animator.new(1, 1, 1),
        check_1 = false,
        check_2 = false,
        check_3 = false,
        reacting = false,
        anim_react = nil,
        anim_water_1_x = gfx.animator.new(15000, 0, -400),
        anim_water_1_y = gfx.animator.new(15000, 0, -240),
        anim_water_2_x = gfx.animator.new(30000, 0, -400),
        anim_water_2_y = gfx.animator.new(30000, 0, -240),
    }

    vars.anim_water_1_x.repeatCount = -1
    vars.anim_water_1_y.repeatCount = -1
    vars.anim_water_2_x.repeatCount = -1
    vars.anim_water_2_y.repeatCount = -1

    vars.fade_anim = gfx.animator.new(500, 1, #assets.img_fade)
    pd.timer.performAfterDelay(500, function() self.fade:remove() end)
    
    if vars.arg_boat == 1 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/1r')
        vars.boat_speed_stat = 2
        vars.boat_turn_stat = 2
    elseif vars.arg_boat == 2 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/2r')
        vars.boat_speed_stat = 2
        vars.boat_turn_stat = 3
    elseif vars.arg_boat == 3 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/3r')
        vars.boat_speed_stat = 2.5
        vars.boat_turn_stat = 2
    elseif vars.arg_boat == 4 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/4r')
        vars.boat_speed_stat = 1.5
        vars.boat_turn_stat = 4
    elseif vars.arg_boat == 5 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/5r')
        vars.boat_speed_stat = 2.5
        vars.boat_turn_stat = 3
    elseif vars.arg_boat == 6 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/6r')
        vars.boat_speed_stat = 2
        vars.boat_turn_stat = 4
    elseif vars.arg_boat == 7 then
        assets.img_boat = gfx.imagetable.new('images/race/boats/7r')
        vars.boat_speed_stat = 3
        vars.boat_turn_stat = 2
    end

    if vars.arg_track == 1 then
        assets.img_track = gfx.image.new('images/race/tracks/track_1')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_1c')
        vars.boat_start_x = 270
        vars.boat_start_y = 830
        vars.track_linear = false
        vars.line_sprite = gfx.sprite.addEmptyCollisionSprite(169, 677, 200, 50)
        vars.check_1_sprite = gfx.sprite.addEmptyCollisionSprite(614, 125, 50, 200)
        vars.check_2_sprite = gfx.sprite.addEmptyCollisionSprite(973, 457, 200, 50)
        vars.check_3_sprite = gfx.sprite.addEmptyCollisionSprite(536, 989, 50, 200)
    elseif vars.arg_track == 2 then
        assets.img_track = gfx.image.new('images/race/tracks/track_2')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_2c')
        vars.boat_start_x = 0
        vars.boat_start_y = 0
        vars.track_linear = false
        vars.line_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_1_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_2_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_3_sprite = gfx.sprite.addEmptyCollisionSprite()
    elseif vars.arg_track == 3 then
        assets.img_track = gfx.image.new('images/race/tracks/track_3')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_3c')
        vars.boat_start_x = 0
        vars.boat_start_y = 0
        vars.track_linear = false
        vars.line_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_1_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_2_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_3_sprite = gfx.sprite.addEmptyCollisionSprite()
    elseif vars.arg_track == 4 then
        assets.img_track = gfx.image.new('images/race/tracks/track_4')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_4c')
        vars.boat_start_x = 0
        vars.boat_start_y = 0
        vars.track_linear = true
        vars.line_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_1_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_2_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_3_sprite = gfx.sprite.addEmptyCollisionSprite()
    elseif vars.arg_track == 5 then
        assets.img_track = gfx.image.new('images/race/tracks/track_5')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_5c')
        vars.boat_start_x = 0
        vars.boat_start_y = 0
        vars.track_linear = false
        vars.line_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_1_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_2_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_3_sprite = gfx.sprite.addEmptyCollisionSprite()
    elseif vars.arg_track == 6 then
        assets.img_track = gfx.image.new('images/race/tracks/track_6')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_6c')
        vars.boat_start_x = 0
        vars.boat_start_y = 0
        vars.track_linear = true
        vars.line_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_1_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_2_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_3_sprite = gfx.sprite.addEmptyCollisionSprite()
    elseif vars.arg_track == 7 then
        assets.img_track = gfx.image.new('images/race/tracks/track_7')
        assets.img_track_c = gfx.image.new('images/race/tracks/track_7c')
        vars.boat_start_x = 0
        vars.boat_start_y = 0
        vars.track_linear = true
        vars.line_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_1_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_2_sprite = gfx.sprite.addEmptyCollisionSprite()
        vars.check_3_sprite = gfx.sprite.addEmptyCollisionSprite()
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.img_water_bg:draw(0, 0)
    end)

    class('water_1').extends(gfx.sprite)
    function water_1:init()
        water_1.super.init(self)
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:setImage(assets.img_water_1)
    end
    function water_1:update()
        self:moveTo(vars.anim_water_1_x:currentValue(), vars.anim_water_1_y:currentValue())
    end


    class('water_2').extends(gfx.sprite)
    function water_2:init()
        water_2.super.init(self)
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:setImage(assets.img_water_2)
        self:add()
    end
    function water_2:update()
        local testx, testy = gfx.getDrawOffset()
        self:moveTo(testx%-400, testy%-240)
    end
    
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
        self:setImage(assets.img_boat[1])
        self:moveTo(vars.boat_start_x, vars.boat_start_y)
        self:setCollideRect(0, 0, self:getSize())
        self:add()
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
        if vars.laps == 1 then
            assets.img_timer_1:draw(0, 0)
        elseif vars.laps == 2 then
            assets.img_timer_2:draw(0, 0)
        elseif vars.laps == 3 then
            assets.img_timer_3:draw(0, 0)
        else
            assets.img_timer:draw(0, 0)
        end
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.times_new_rally:drawText(mins..":"..secs.."."..mils, 44, 15)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.popContext()
        self:setImage(img)
        self:setScale(vars.timer_scale_anim:currentValue())
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
            if vars.race_finished then
                self:setImage(vars.anim_overlay:image():invertedImage())
            else
                self:setImage(vars.anim_overlay:image())
            end
        end
    end

    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:setZIndex(102)
        self:setIgnoresDrawOffset(true)
        self:moveTo(200, 120)
        self:add()
    end
    function fade:update()
        self:setImage(assets.img_fade[math.floor(vars.fade_anim:currentValue())]:invertedImage())
    end
    
    self.water_1 = water_1()
    self.water_2 = water_2()
    self.trackc = trackc()
    self.boat = boat()
    self.track = track()
    self.timer = timer()
    self.item = item()
    self.react = react()
    self.meter = meter()
    self.overlay = overlay()
    self.fade = fade()
    
    if vars.arg_mode == "tt" then
        vars.boost_available = true
        self.item:add()
    end

    if save.ui then
        self.react:add()
        self.meter:add()
    end

    self:add()
end

function race:start()
    -- Don't need these prints later
    print("3...")
    pd.timer.performAfterDelay(1000, function()
        print("2...")
    end)
    pd.timer.performAfterDelay(2000, function()
        print("1...")
    end)
    pd.timer.performAfterDelay(3000, function()
        print("GO!!!")
        if vars.race_started == false then
            vars.race_started = true
            vars.race_in_progress = true
            vars.anim_camera = gfx.animator.new(1000, 0, vars.boat_speed_stat*15)
            vars.anim_boat_speed = gfx.animator.new(1000, 0, vars.boat_speed_stat, pd.easingFunctions.inOutSine)
            vars.anim_boat_turn = gfx.animator.new(1000, 0, vars.boat_turn_stat, pd.easingFunctions.inOutSine)
        end
    end)
end

function race:finish()
    if vars.race_in_progress == true then
        vars.race_in_progress = false
        vars.race_finished = true
        vars.anim_camera = gfx.animator.new(1050, vars.boat_speed_stat*15, vars.boat_speed_stat*-15, pd.easingFunctions.outSine)
        vars.anim_boat_speed = gfx.animator.new(1250, vars.boat_speed_stat*1.5, 0, pd.easingFunctions.inOutSine)
        vars.anim_finish_turn = gfx.animator.new(1250, vars.boat_rotation, vars.boat_rotation+50, pd.easingFunctions.outSine)
        self.item:remove()
        self.react:remove()
        self.meter:remove()
        self.timer:remove()
        if pd.getReduceFlashing() then
            vars.anim_overlay = nil
        else
            vars.anim_overlay = gfx.animation.loop.new(30, assets.img_fade, false)
        end
        pd.timer.performAfterDelay(1500, function()
            assets.snap = gfx.getDisplayImage()
            scenemanager:switchscene(results, vars.arg_track, vars.arg_mode, vars.arg_boat, vars.arg_mirror, true, vars.elapsed_time, assets.snap)
        end)
    end
end

function race:restart()
    self.boat:moveTo(vars.boat_start_x, vars.boat_start_y)
    vars.laps = 1
    vars.check_1 = false
    vars.check_2 = false
    vars.check_3 = false
    vars.boat_rotation = 0
    self.boat:setImage(assets.img_boat[1])
    vars.boat_turn = 0
    vars.anim_camera = gfx.animator.new(2000, -150, 0, pd.easingFunctions.outSine)
    vars.anim_boat_speed = gfx.animator.new(1, 0, 0)
    vars.reacting = false
    vars.anim_react = nil
    vars.boosting = false
    if vars.arg_mode == "tt" then
        vars.boost_available = true
    end
    vars.anim_overlay = nil
    vars.elapsed_time = 0
    vars.race_started = false
    vars.race_in_progress = false
end

function race:boost()
    vars.boost_available = false
    vars.boosting = true
    vars.anim_camera = gfx.animator.new(500, vars.boat_speed_stat*15, vars.boat_speed_stat*-15, pd.easingFunctions.outSine)
    vars.anim_overlay = gfx.animation.loop.new(115, assets.img_overlay_boost, true)
    self.react:change("happy")
    self.item:setImage(assets.img_item_active)
    pd.timer.performAfterDelay(75, function() self.item:setImage(assets.img_item_used) end)
    pd.timer.performAfterDelay(1750, function() vars.anim_camera = gfx.animator.new(1000, vars.boat_speed_stat*-15, vars.boat_speed_stat*15, pd.easingFunctions.inOutSine) end)
    pd.timer.performAfterDelay(2000, function()
        vars.boosting = false
        vars.anim_overlay = nil
        self.react:change("idle")
        self.overlay:setImage(nil)
    end)
end

function race:checkcheck(coralx, coraly) -- 1 2 1 2
    if coralx == vars.line_sprite.x and coraly == vars.line_sprite.y then
        if vars.check_1 and vars.check_2 and vars.check_3 then
            vars.laps += 1
            vars.timer_scale_anim = gfx.animator.new(1000, 1.1, 1, pd.easingFunctions.outElastic)
            vars.check_1 = false
            vars.check_2 = false
            vars.check_3 = false
            if vars.laps > 3 or vars.track_linear then
                self:finish()
            end
        end
        return
    elseif coralx == vars.check_1_sprite.x and coraly == vars.check_1_sprite.y then
        if vars.check_1 == false then
            vars.check_1 = true
        end
        return
    elseif coralx == vars.check_2_sprite.x and coraly == vars.check_2_sprite.y then
        if vars.check_1 and vars.check_2 == false then
            vars.check_2 = true
        end
        return
    elseif coralx == vars.check_3_sprite.x and coraly == vars.check_3_sprite.y then
        if vars.check_1 and vars.check_2 and vars.check_3 == false then
            vars.check_3 = true
        end
        return
    end
end

function race:update()
    local boat_radtation = math.rad(vars.boat_rotation%360)
    vars.camera_distance = vars.anim_camera:currentValue()
    vars.boat_speed = vars.anim_boat_speed:currentValue()
    if vars.race_started == false then
        gfx.setDrawOffset(200+(-self.boat.x)+(math.sin(boat_radtation)*-vars.camera_distance), 120+(-self.boat.y)+(math.cos(boat_radtation)*vars.camera_distance))
    end
    if pd.buttonJustPressed('up') then
        self:start()
    end
    if pd.buttonJustPressed('down') then
        self:finish()
    end
    if vars.race_in_progress then
        vars.elapsed_time += 1
        local change = pd.getCrankChange()/2
        if vars.boat_turn < change then vars.boat_turn += vars.boat_turn_stat/5 else vars.boat_turn -= vars.boat_turn_stat/5 end
        if vars.boat_turn < 0 then vars.boat_turn = 0 end
        vars.boat_rotation += vars.boat_turn*vars.boat_turn_stat*0.56 -= vars.anim_boat_turn:currentValue()*3
        vars.boat_radtation = math.rad(vars.boat_rotation%360)
        if pd.buttonJustPressed('b') then
            if vars.boost_available then
                self:boost()
            end
        end
        self.boat:setImage(assets.img_boat[math.floor((vars.boat_rotation%360) / 6)+1])
        local coral = self.boat:overlappingSprites()
        if #coral > 0 then
            for i = 1, #coral do
                self:checkcheck(coral[i].x, coral[i].y)
            end
        end
        if vars.boosting then
            self.boat:moveBy(math.sin(boat_radtation)*vars.boat_speed*4.5, math.cos(boat_radtation)*-vars.boat_speed*4.5)
        else
            self.boat:moveBy(math.sin(boat_radtation)*vars.boat_speed*2.5, math.cos(boat_radtation)*-vars.boat_speed*2.5)
        end
        gfx.setDrawOffset(200+(-self.boat.x)+(math.sin(boat_radtation)*-vars.camera_distance), 120+(-self.boat.y)+(math.cos(boat_radtation)*vars.camera_distance))
    end
    if vars.race_finished then
        self.boat:moveBy(0, -vars.boat_speed*2.5)
        self.boat:setImage(assets.img_boat[math.floor((vars.anim_finish_turn:currentValue()%360) / 6)+1])
        gfx.setDrawOffset(200+(-self.boat.x), 120+(-self.boat.y)+(vars.camera_distance))
    end
end