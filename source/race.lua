import 'title'
import 'results'

local pd <const> = playdate
local gfx <const> = pd.graphics
local rect <const> = pd.geometry.rect.new

class('race').extends(gfx.sprite)
function race:init(...)
    race.super.init(self)
    local args = {...}
    pd.ui.crankIndicator:start()
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 100
        pauserand = math.random(1, 8)
        if first_pause then
            pauserand = 1
            first_pause = false
        end
        local paused = gfx.image.new('images/ui/paused' .. pauserand)
        gfx.pushContext(img)
            paused:draw(-200 + xoffset, 0)
        gfx.popContext()
        pd.setMenuImage(img, xoffset)
        if not vars.race_finished then
            menu:addCheckmarkMenuItem(gfx.getLocalizedText("proui"), save.ui, function(new)
                save.ui = new
                if save.ui then
                    self.react:remove()
                    self.meter:remove()
                    self.timer:moveTo(-42, -11)
                else
                    self.react:add()
                    self.meter:add()
                    self.timer:moveTo(0, 5)
                end
            end)
            if vars.race_in_progress then
                menu:addMenuItem(gfx.getLocalizedText("restartrace"), function()
                    self:start(true)
                end)
            end
            menu:addMenuItem(gfx.getLocalizedText("backtotitle"), function()
                scenemanager:transitionsceneoneway(title, false)
            end)
        end
    end

    assets = {
        img_item_active = gfx.image.new('images/race/item_active'),
        img_item_used = gfx.image.new('images/race/item_used'),
        anim_timer_scale = gfx.animator.new(1, 1, 1),
        img_react_idle = gfx.image.new('images/race/react_idle'),
        img_react_happy = gfx.image.new('images/race/react_happy'),
        img_react_shocked = gfx.image.new('images/race/react_shocked'),
        img_react_confused = gfx.image.new('images/race/react_confused'),
        img_react_crash = gfx.image.new('images/race/react_crash'),
        img_meter = gfx.image.new('images/race/meter'),
        img_meter_mask = gfx.image.new('images/race/meter_mask'),
        img_overlay_boost = gfx.imagetable.new('images/race/boost/boost'),
        img_water_bg = gfx.image.new('images/race/tracks/water_bg'),
        img_water = gfx.image.new('images/race/tracks/water'),
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
        race_started = false,
        race_in_progress = false,
        race_finished = false,
        elapsed_time = 0,
        laps = 1,
        checkpoints = {false, false, false},
        latest_checkpoint = 0,
        camera_offset = 0,
        camera_target_offset = -1000,
        player_turn = 0,
        boat_speed_rate = gfx.animator.new(1, 0, 0),
        boat_turn_rate = gfx.animator.new(1, 0, 0),
        boat_rotation = 0,
        boat_old_rotation = 0,
        boat_cols = {},
        boat_crashed = false,
        reacting = false,
        boost_ready = false,
        boosts_available = 0,
        boosting = false,
        losttocpu = false,
        anim_water_x = gfx.animator.new(20000, 0, -400),
        anim_water_y = gfx.animator.new(20000, 0, -240)
    }

    vars.anim_water_x.repeatCount = -1
    vars.anim_water_y.repeatCount = -1

    pd.timer.performAfterDelay(1, function() vars.camera_target_offset = 0 end)
    vars.anim_overlay = gfx.animation.loop.new(30, assets.img_fade, false)
    pd.timer.performAfterDelay(1200, function() vars.anim_overlay = nil self.overlay:setImage(nil) end)
    pd.timer.performAfterDelay(2500, function() self:start(false) end)
    
    assets.img_boat = gfx.imagetable.new('images/race/boats/boat' .. vars.arg_boat)
    local atbs = {2, 2, 2.5, 1.5, 2.5, 2, 3}
    local atbt = {2, 3, 2, 4, 3, 4, 2}
    vars.boat_speed_stat = atbs[vars.arg_boat]
    vars.boat_turn_stat = atbt[vars.arg_boat]

    if vars.arg_mode == "story" then
        local routerand = math.random(1, 3)
        if vars.arg_track == 1 then
            if routerand == 1 then
                vars.totalcpucoords = #s1r1
            elseif routerand == 2 then
                vars.totalcpucoords = #s1r2
            elseif routerand == 3 then
                vars.totalcpucoords = #s1r3
            end
        elseif vars.arg_track == 2 then
            if routerand == 1 then
                vars.totalcpucoords = #s2r1
            elseif routerand == 2 then
                vars.totalcpucoords = #s2r2
            elseif routerand == 3 then
                vars.totalcpucoords = #s2r3
            end
        elseif vars.arg_track == 3 then
            if routerand == 1 then
                vars.totalcpucoords = #s3r1
            elseif routerand == 2 then
                vars.totalcpucoords = #s3r2
            elseif routerand == 3 then
                vars.totalcpucoords = #s3r3
            end
        elseif vars.arg_track == 5 then
            if routerand == 1 then
                vars.totalcpucoords = #s5r1
            elseif routerand == 2 then
                vars.totalcpucoords = #s5r2
            elseif routerand == 3 then
                vars.totalcpucoords = #s5r3
            end
        elseif vars.arg_track == 6 then
            if routerand == 1 then
                vars.totalcpucoords = #s6r1
            elseif routerand == 2 then
                vars.totalcpucoords = #s6r2
            elseif routerand == 3 then
                vars.totalcpucoords = #s6r3
            end
        end
        vars.cpuboat_progression = 1
    end

    assets.img_track = gfx.image.new('images/race/tracks/track' .. vars.arg_track)
    assets.img_trackc = gfx.image.new('images/race/tracks/trackc' .. vars.arg_track)
    local atbsx = {300, 0, 0, 0, 0, 0, 0}
    local atbsy = {830, 0, 0, 0, 0, 0, 0}
    local attl = {false, false, false, true, false, true, true}
    local atl = {rect(169, 667, 200, 50), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0)}
    local atc1 = {rect(614, 125, 50, 200), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0)}
    local atc2 = {rect(973, 457, 200, 50), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0)}
    local atc3 = {rect(536, 989, 50, 200), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0), rect(0, 0, 0, 0)}
    vars.boat_start_x = atbsx[vars.arg_track]
    vars.boat_start_y = atbsy[vars.arg_track]
    vars.track_linear = attl[vars.arg_track]
    vars.line = gfx.sprite.addEmptyCollisionSprite(atl[vars.arg_track])
    vars.checkpoint1 = gfx.sprite.addEmptyCollisionSprite(atc1[vars.arg_track])
    vars.checkpoint2 = gfx.sprite.addEmptyCollisionSprite(atc2[vars.arg_track])
    vars.checkpoint3 = gfx.sprite.addEmptyCollisionSprite(atc3[vars.arg_track])
    if vars.arg_track == 4 then vars.checkpoints = {true, true, true} end
    
    local atbs, atbt, atbsx, atbsy, attl, atl, atc1, atc2, atc3 = nil

    if vars.track_linear then
        if vars.arg_mode == "tt" then
            assets.img_timer = gfx.image.new('images/race/timer_tt')
        else
            assets.img_timer = gfx.image.new('images/race/timer')
        end
    else
        assets.img_timer = gfx.image.new('images/race/timer_' .. vars.laps)
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.img_water_bg:draw(0, 0)
    end)

    class('water').extends(gfx.sprite)
    function water:init()
        water.super.init(self)
        self:setZIndex(-100)
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:setImage(assets.img_water)
        self:add()
    end

    class('cpuboat').extends(gfx.sprite)
    function cpuboat:init(c, d)
        cpuboat.super.init(self)
        self:setZIndex(0)
        self:setImage(assets.img_boat[1])
        self:moveTo(s1r1[1], s1r1[2])
        if vars.arg_mode == "story" then
            self:add()
        end
    end

    class('boat').extends(gfx.sprite)
    function boat:init(c, d)
        boat.super.init(self)
        self:setZIndex(0)
        self:setImage(assets.img_boat[1])
        self:moveTo(vars.boat_start_x, vars.boat_start_y)
        self:setCollideRect(0, 0, self:getSize())
        self:add()
        for n = 1, c do
            local de = (360 / c) * n
            local ra = math.rad(de)
            local off_x = math.sin(ra) * d
            local off_y = -math.cos(ra) * d
            local boat_col = gfx.sprite.new(gfx.image.new(6, 6, gfx.kColorBlack))
            boat_col:setVisible(false)
            boat_col:setCenter(0.5, 0.5)
            boat_col:moveTo(vars.boat_start_x + off_x, vars.boat_start_y + off_y)
            boat_col:add()
            vars.boat_cols[n] = {boat_col, off_x, off_y, de}
        end
    end

    class('track').extends(gfx.sprite)
    function track:init()
        track.super.init(self)
        self:setZIndex(1)
        self:setCenter(0, 0)
        self:setImage(assets.img_track)
        self:add()
    end

    class('timer').extends(gfx.sprite)
    function timer:init()
        timer.super.init(self)
        self:setZIndex(99)
        self:setCenter(0, 0)
        if save.ui then
            self:moveTo(-42, -11)
        else
            self:moveTo(0, 5)
        end
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
            assets.times_new_rally:drawText(mins..":"..secs.."."..mils, 44, 15)
        gfx.popContext()
        self:setImage(img)
        if vars.anim_timer_scale ~= nil then
            self:setScale(vars.anim_timer_scale:currentValue())
        end
    end
    
    class('react').extends(gfx.sprite)
    function react:init()
        react.super.init(self)
        self:moveTo(200, 152)
        self:setZIndex(98)
        self:setCenter(0.5, 0)
        self:setIgnoresDrawOffset(true)
        self:setImage(assets.img_react_idle)
        if not save.ui then
            self:add()
        end
    end
    function react:update()
        if vars.anim_react ~= nil then
            self:moveTo(200, vars.anim_react:currentValue())
        end
    end
    
    class('meter').extends(gfx.sprite)
    function meter:init()
        meter.super.init(self)
        self:moveTo(200, 240)
        self:setZIndex(99)
        self:setCenter(0.5, 1)
        self:setIgnoresDrawOffset(true)
        if not save.ui then
            self:add()
        end
    end
    function meter:update()
        local img = gfx.image.new(195, 38)
        gfx.pushContext(img)
            gfx.setColor(gfx.kColorWhite)
            local playerturn = math.clamp(vars.player_turn*7, 0, 100)
            gfx.fillRect(195, 0, -playerturn, 38)
            gfx.fillRect(0, 0, vars.boat_turn_rate:currentValue()*20, 38)
            img:setMaskImage(assets.img_meter_mask)
            assets.img_meter:draw(0, 0)
        gfx.popContext()
        self:setImage(img)
    end
    
    class('item').extends(gfx.sprite)
    function item:init()
        item.super.init(self)
        self:moveTo(400, 0)
        self:setZIndex(99)
        self:setCenter(1, 0)
        self:setIgnoresDrawOffset(true)
    end

    class('overlay').extends(gfx.sprite)
    function overlay:init()
        overlay.super.init(self)
        self:moveTo(200, 120)
        self:setIgnoresDrawOffset(true)
        self:setZIndex(100)
        self:add()
    end
    function overlay:update()
        if vars.anim_overlay ~= nil then
            if not vars.race_in_progress then
                self:setImage(vars.anim_overlay:image():invertedImage())
            else
                self:setImage(vars.anim_overlay:image())
            end
        end
    end

    self.water = water()
    self.boat = boat(10, 40)
    self.cpuboat = cpuboat()
    self.track = track()
    self.timer = timer()
    self.react = react()
    self.meter = meter()
    self.item = item()
    self.overlay = overlay()
    
    if vars.arg_mode == "tt" then
        vars.boost_ready = true
        if vars.track_linear then
            vars.boosts_available = 1
        else
            vars.boosts_available = 3
        end
        assets.img_item = gfx.image.new('images/race/item_' .. vars.boosts_available)
        self.item:setImage(assets.img_item)
        self.item:add()
    end

    self:add()
end

function race:start(restart)
    if restart then
        if vars.race_started then
            vars.boat_crashed = false
            self.boat:moveTo(vars.boat_start_x, vars.boat_start_y)
            vars.laps = 1
            vars.camera_target_offset = 0
            vars.checkpoints = {false, false, false}
            vars.boat_rotation = 0
            self.boat:setImage(assets.img_boat[1])
            vars.boat_speed_rate = gfx.animator.new(1, 0, 0)
            vars.boat_turn_rate = gfx.animator.new(1, 0, 0)
            vars.reacting = false
            vars.anim_react = nil
            vars.anim_overlay = nil
            self.overlay:setImage(nil)
            vars.boosting = false
            vars.elapsed_time = 0
            vars.race_started = false
            vars.race_in_progress = false
            show_crank = false
            if vars.arg_mode == "tt" then
                vars.boost_ready = true
                if vars.track_linear then
                    vars.boosts_available = 1
                else
                    vars.boosts_available = 3
                end
                assets.img_item = gfx.image.new('images/race/item_' .. vars.boosts_available)
                self.item:setImage(assets.img_item)
            else
                vars.losttocpu = false
                vars.cpuboat_progression = 1
            end
        end
    end
    print('3...')
    pd.timer.performAfterDelay(1000, function()
        print('2...')
    end)
    pd.timer.performAfterDelay(2000, function()
        print('1...')
    end)
    pd.timer.performAfterDelay(3000, function()
        if not vars.race_started then
            print('GO!!!')
            vars.race_started = true
            vars.race_in_progress = true
            show_crank = true
            vars.camera_target_offset = vars.boat_speed_stat*15
            vars.boat_speed_rate = gfx.animator.new(1000, 0, vars.boat_speed_stat, pd.easingFunctions.inOutSine)
            vars.boat_turn_rate = gfx.animator.new(2500, 0, vars.boat_turn_stat, pd.easingFunctions.inOutSine)
        end
    end)
end

function race:checkpoint(x, y)
    if x == vars.line.x and y == vars.line.y then
        allcheckpointscleared = true
        for n = 1, #vars.checkpoints do
            if not vars.checkpoints[n] then
                allcheckpointscleared = false
                return
            end
        end
        if allcheckpointscleared and vars.latest_checkpoint == 3 then
            vars.laps += 1
            vars.latest_checkpoint = 0
            if vars.laps <= 3 or vars.track_linear then
            assets.img_timer = gfx.image.new('images/race/timer_' .. vars.laps)
            vars.anim_timer_scale = gfx.animator.new(1000, 1.25, 1, pd.easingFunctions.outElastic)
            end
            vars.checkpoints = {false, false, false}
            if vars.laps > 3 or vars.track_linear then
                if vars.losttocpu then
                    self:finish(false)
                else
                    self:finish(true)
                end
            end
        end
    elseif x == vars.checkpoint1.x and y == vars.checkpoint1.y then
        if not vars.checkpoints[1] and vars.latest_checkpoint == 0 then
            vars.checkpoints[1] = true
            vars.latest_checkpoint = 1
        end
    elseif x == vars.checkpoint2.x and y == vars.checkpoint2.y then
        if not vars.checkpoints[2] and vars.latest_checkpoint == 1 then
            vars.checkpoints[2] = true
            vars.latest_checkpoint = 2
        end
    elseif x == vars.checkpoint3.x and y == vars.checkpoint3.y then
        if not vars.checkpoints[3] and vars.latest_checkpoint == 2 then
            vars.checkpoints[3] = true
            vars.latest_checkpoint = 3
        end
    end
end

function race:finish(win)
    if vars.race_in_progress then
        print("FINISH!!!")
        vars.race_in_progress = false
        vars.race_finished = true
        vars.camera_target_offset = vars.boat_speed_stat*-40
        vars.boat_speed_rate = gfx.animator.new(1000, vars.boat_speed_stat*1.5, 0, pd.easingFunctions.inOutSine)
        vars.anim_finish_turn = gfx.animator.new(1000, vars.boat_rotation, math.clamp(vars.boat_old_rotation, vars.boat_rotation-40, vars.boat_rotation+40), pd.easingFunctions.outCubic)
        self.item:remove()
        self.react:remove()
        self.meter:remove()
        self.timer:remove()
        show_crank = false
        if pd.getReduceFlashing() then
            vars.anim_overlay = nil
        else
            vars.anim_overlay = gfx.animation.loop.new(30, assets.img_fade, false)
        end
        pd.timer.performAfterDelay(1500, function()
            assets.snap = gfx.getDisplayImage()
            scenemanager:switchscene(results, vars.arg_track, vars.arg_mode, vars.arg_boat, vars.arg_mirror, win, vars.elapsed_time, assets.snap)
        end)
    end
end

function race:crash()
    local cols = {}
    local colno = 0
    for key, box in pairs(vars.boat_cols) do
        box[1]:moveTo(self.boat.x + box[2], self.boat.y + box[3])
        if gfx.checkAlphaCollision(box[1]:getImage(), self.boat.x + box[2], self.boat.y + box[3], 0, assets.img_trackc, 0, 0, 0) then
            cols[#cols + 1] = true
            if colno == 0 then
                colno = 1
            else
                colno = colno + 1
            end
        else
            cols[#cols + 1] = false
        end
    end
    if colno > 0 then
        vars.boat_crashed = true
        save.cr += 1
        if not save.sr and vars.arg_mode == "story" then
            save.sr = true
        end
        self:reaction("crash")
        shakiesx()
        local reflectdeg = (self:reflectangle(cols) + 180) % 360
        local reflectrad = math.rad(reflectdeg)
        local current_boat_speed = vars.boat_speed_rate:currentValue() or vars.boat_speed_stat
        local current_boat_turn = vars.boat_turn_rate:currentValue() or vars.boat_turn_stat
        local off_x = math.sin(reflectrad) * (current_boat_speed * 25)
        local off_y = -math.cos(reflectrad) * (current_boat_speed * 25)
        vars.boat_speed_rate = gfx.animator.new(1, current_boat_speed, 0)
        vars.boat_turn_rate = gfx.animator.new(1000, current_boat_turn, 0, pd.easingFunctions.inOutSine)
        vars.anim_boat_crash_x = gfx.animator.new(1000, self.boat.x, self.boat.x + off_x, pd.easingFunctions.outCubic)
        vars.anim_boat_crash_y = gfx.animator.new(1000, self.boat.y, self.boat.y + off_y, pd.easingFunctions.outCubic)
        vars.anim_boat_crash_r = gfx.animator.new(1000, vars.boat_rotation, math.clamp(vars.boat_old_rotation, vars.boat_rotation-40, vars.boat_rotation+40), pd.easingFunctions.outCubic)
        vars.camera_target_offset = 0
    end
    pd.timer.performAfterDelay(1000, function()
        vars.boat_crashed = false
        if vars.race_in_progress then
            self:reaction("idle")
            vars.camera_target_offset = vars.boat_speed_stat*15
            vars.boat_speed_rate = gfx.animator.new(2000, 0, vars.boat_speed_stat, pd.easingFunctions.inOutSine)
            vars.boat_turn_rate = gfx.animator.new(500, 0, vars.boat_turn_stat, pd.easingFunctions.inOutSine)
            vars.boat_turn = 0
        end
    end)
end

function race:reflectangle(c)
    local index = 1
    if c[1] and c[#c] then
        local lowindex = 0
        for i = 1, #c do
            if not (c[i]) then
                lowindex = i
            end
        end
        local highindex = 0
        for i = #c, 1, -1 do
            if not (c[i]) then
                highindex = i
            end
        end
        index = ((lowindex + highindex + #c) % #c) - 1
    else
        local indexstart
        local indexend
        for i = 1, #c do
            if c[i] and indexstart == nil then
                indexstart = i
            elseif not (c[i]) and indexstart ~= nil and indexend == nil then
                indexend = i - 1
            end
            if indexend == nil and i == #c then
                indexend = #c
            end
        end
        index = math.ceil(indexstart + (indexend - indexstart) / 2)
    end
    if index < 1 then
        index = 1
    elseif index > #vars.boat_cols then
        index = #vars.boat_cols
    end
    return vars.boat_cols[index][4]
end

function race:boost()
    if vars.boosts_available > 0 and vars.boost_ready then
        vars.boosts_available -= 1
        assets.img_item = gfx.image.new('images/race/item_' .. vars.boosts_available)
        vars.boosting = true
        vars.boost_ready = false
        vars.camera_target_offset = vars.boat_speed_stat*-25
        self.item:setImage(assets.img_item_active)
        vars.anim_overlay = gfx.animation.loop.new(115, assets.img_overlay_boost, true)
        self:reaction("happy")
        pd.timer.performAfterDelay(75, function()
            if vars.boosts_available == 0 then
                self.item:setImage(assets.img_item_used)
            else
                self.item:setImage(assets.img_item)
            end
        end)
        pd.timer.performAfterDelay(2000, function()
            vars.boosting = false
            vars.boost_ready = true
            if vars.race_in_progress then
                vars.anim_overlay = nil
                self.overlay:setImage(nil)
            end
            if not vars.boat_crashed then
                self:reaction("idle")
            end
            if vars.race_in_progress and not vars.boat_crashed then
                vars.camera_target_offset = vars.boat_speed_stat*15
            end
        end)
    end
end

function race:reaction(new)
    if new == "idle" then
        self.react:setImage(assets.img_react_idle)
        vars.reacting = false
        vars.anim_react = nil
        self.react:moveTo(200, 152)
    elseif new == "happy" then
        self.react:setImage(assets.img_react_happy)
        vars.reacting = true
        vars.anim_react = gfx.animator.new(350, 152, 142, pd.easingFunctions.outSine)
        vars.anim_react.reverses = true
        vars.anim_react.repeatCount = -1
    elseif new == "shocked" then
        self.react:setImage(assets.img_react_shocked)
        vars.reacting = true
        vars.anim_react = gfx.animator.new(250, 152, 142, pd.easingFunctions.outSine)
        vars.anim_react.reverses = true
        vars.anim_react.repeatCount = -1
    elseif new == "confused" then
        self.react:setImage(assets.img_react_confused)
        vars.reacting = true
    elseif new == "crash" then
        self.react:setImage(assets.img_react_crash)
        vars.reacting = true
        vars.anim_react = gfx.animator.new(250, 152, 142, pd.easingFunctions.outSine)
        vars.anim_react.reverses = true
        vars.anim_react.repeatCount = -1
    end
end

function race:update()
    -- if vars.race_started and vars.elapsed_time % 2 == 0 then
    --     print(self.boat.x .. ', ' .. self.boat.y .. ', ' .. vars.boat_rotation .. ', ')
    -- end
    local gfx_x, gfx_y = gfx.getDrawOffset()
    self.water:moveTo(vars.anim_water_x:currentValue()+(gfx_x%-400), vars.anim_water_y:currentValue()+(gfx_y%-240))
    vars.camera_offset += (vars.camera_target_offset - vars.camera_offset) * 0.05
    vars.boat_old_rotation += (vars.boat_rotation - vars.boat_old_rotation) * 0.20
    if not vars.race_started then
        gfx.setDrawOffset(200-self.boat.x, 120-self.boat.y+vars.camera_offset)
    else
        if vars.arg_mode == "story" then
            if vars.cpuboat_progression >= vars.totalcpucoords - 2 then
                vars.cpuboat_progression = vars.totalcpucoords - 2
            else
                vars.cpuboat_progression += 1.5
            end
            if (vars.cpuboat_progression - 1) % 3 == 0 then
                self.cpuboat:moveTo(s1r1[vars.cpuboat_progression], s1r1[vars.cpuboat_progression+1])
                self.cpuboat:setImage(assets.img_boat[math.floor((s1r1[vars.cpuboat_progression+2]) / 6)+1])
            else
                local next = math.clamp(vars.cpuboat_progression+1.5, 2.5, vars.totalcpucoords - 2)
                local prev = math.clamp(vars.cpuboat_progression-1.5, 1, vars.totalcpucoords - 5)
                self.cpuboat:moveTo(s1r1[prev] + (s1r1[next] - s1r1[prev]) * 0.5, s1r1[prev+1] + (s1r1[next+1] - s1r1[prev+1]) * 0.5)
            end
            if vars.cpuboat_progression >= vars.totalcpucoords - 21 then
                vars.losttocpu = true
            end
        end
    end
    if vars.race_in_progress then
        save.tr += 1
        vars.elapsed_time += 1
        local c = self.boat:overlappingSprites()
        if #c > 0 then
            for i = 1, #c do
                self:checkpoint(c[i].x, c[i].y)
            end
        end
        local change = pd.getCrankChange()/2
        if vars.boat_crashed then
            vars.camera_offset += (vars.camera_target_offset - vars.camera_offset) * 0.20
            self.boat:moveTo(vars.anim_boat_crash_x:currentValue(), vars.anim_boat_crash_y:currentValue())
            vars.boat_rotation = vars.anim_boat_crash_r:currentValue()
            vars.player_turn -= vars.boat_turn_stat/5
        else
            if gfx.checkAlphaCollision(self.boat:getImage(), self.boat.x - (self.boat.width / 2), self.boat.y - (self.boat.height / 2), 0, assets.img_trackc, 0, 0, 0) then
                self:crash()
            end
            if vars.player_turn < change then vars.player_turn += vars.boat_turn_stat/5 else vars.player_turn -= vars.boat_turn_stat/5 end
            vars.boat_rotation += vars.player_turn*vars.boat_turn_rate:currentValue()*0.56 -= vars.boat_turn_rate:currentValue()*3
            vars.boat_rotation = vars.boat_rotation%360
            vars.boat_radtation = math.rad(vars.boat_rotation)
            if vars.boosting then
                self.boat:moveBy(math.sin(vars.boat_radtation)*vars.boat_speed_rate:currentValue()*4.5, math.cos(vars.boat_radtation)*-vars.boat_speed_rate:currentValue()*4.5)
            else
                self.boat:moveBy(math.sin(vars.boat_radtation)*vars.boat_speed_rate:currentValue()*2.5, math.cos(vars.boat_radtation)*-vars.boat_speed_rate:currentValue()*2.5)
            end
            if pd.buttonJustPressed('b') then
                if vars.boost_ready then
                    self:boost()
                end
            end
        end
        if vars.player_turn < 0 then vars.player_turn = 0 end
        self.boat:setImage(assets.img_boat[math.floor((vars.boat_rotation%360) / 6)+1])
        gfx.setDrawOffset((200-self.boat.x)+(-math.sin(vars.boat_radtation)*vars.camera_offset), (120-self.boat.y)+(math.cos(vars.boat_radtation)*vars.camera_offset))
    end
    if vars.race_finished then
        vars.camera_offset += (vars.camera_target_offset - vars.camera_offset) * 0.025
        self.boat:moveBy(0, -vars.boat_speed_rate:currentValue()*2.5)
        self.boat:setImage(assets.img_boat[math.floor((vars.anim_finish_turn:currentValue()%360) / 6)+1])
        gfx.setDrawOffset(200-self.boat.x, 120-self.boat.y+vars.camera_offset)
    end
    if vars.elapsed_time >= 17970 then
        self:finish(false)
    end
end