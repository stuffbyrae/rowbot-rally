import 'title'
import 'results'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('tutorial').extends(gfx.sprite)
function tutorial:init(...)
    tutorial.super.init(self)
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
        menu:addMenuItem("skip tutorial", function()
            self:finish()
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end

    assets = {
        img_react_idle = gfx.image.new('images/race/react_idle'),
        img_react_happy = gfx.image.new('images/race/react_happy'),
        img_react_shocked = gfx.image.new('images/race/react_shocked'),
        img_react_confused = gfx.image.new('images/race/react_confused'),
        img_react_crash = gfx.image.new('images/race/react_crash'),
        img_meter = gfx.image.new('images/race/meter'),
        img_meter_mask = gfx.image.new('images/race/meter_mask'),
        img_water_bg = gfx.image.new('images/race/tracks/water_bg'),
        img_water = gfx.image.new('images/race/tracks/water'),
        img_tutui = gfx.image.new('images/ui/tutui'),
        img_tutuia = gfx.image.new('images/ui/tutuia'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        img_boat = gfx.imagetable.new('images/race/boats/boat1'),
        img_track = gfx.image.new('images/race/tracks/trackt'),
        img_trackc = gfx.image.new('images/race/tracks/trackct'),
        pedallica = gfx.font.new('fonts/pedallica')
    }

    vars = {
        arg_move = args[1], -- "story" or "options"
        race_started = false,
        race_in_progress = false,
        race_finished = false,
        camera_offset = 0,
        camera_target_offset = 0,
        player_turn = 0,
        boat_speed_rate = gfx.animator.new(1, 0, 0),
        boat_turn_rate = gfx.animator.new(1, 0, 0),
        boat_rotation = 0,
        boat_old_rotation = 0,
        boat_radtation = 0,
        boat_cols = {},
        boat_crashed = false,
        reacting = false,
        anim_water_x = gfx.animator.new(20000, 0, -400),
        anim_water_y = gfx.animator.new(20000, 0, -240),
        boat_speed_stat = 2,
        boat_turn_stat = 2,
        current_step = 0,
        ui_open = false,
        ui_progressable = false,
        hang_time = 0,
        line_time = 0,
        boat_controllable = false,
        boat_moving = false,
        boat_land_y = 0,
        finishing = false,
        waittime = 1
    }

    vars.anim_water_x.repeatCount = -1
    vars.anim_water_y.repeatCount = -1

    vars.anim_overlay = gfx.animator.new(1200, 1, #assets.img_fade)
    pd.timer.performAfterDelay(1200, function() vars.anim_overlay = nil self.overlay:setImage(nil) end)

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

    class('boat').extends(gfx.sprite)
    function boat:init(c, d)
        boat.super.init(self)
        self:setZIndex(0)
        self:setImage(assets.img_boat[1])
        self:moveTo(0, 0)
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
            boat_col:moveTo(off_x, off_y)
            boat_col:add()
            vars.boat_cols[n] = {boat_col, off_x, off_y, de}
        end
    end

    class('track').extends(gfx.sprite)
    function track:init()
        track.super.init(self)
        self:setZIndex(1)
        self:setCenter(0.5, 1)
        self:moveTo(10000, 10000)
        self:setImage(assets.img_track)
    end

    class('ui').extends(gfx.sprite)
    function ui:init()
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:setZIndex(97)
    end
    
    class('react').extends(gfx.sprite)
    function react:init()
        react.super.init(self)
        self:moveTo(200, 400)
        self:setZIndex(98)
        self:setCenter(0.5, 0)
        self:setIgnoresDrawOffset(true)
        self:setImage(assets.img_react_idle)
    end
    function react:update()
        if vars.anim_power_in ~= nil then
            self:moveTo(200, 152+vars.anim_power_in:currentValue())
        end
    end
    
    class('meter').extends(gfx.sprite)
    function meter:init()
        meter.super.init(self)
        self:moveTo(200, 400)
        self:setZIndex(99)
        self:setCenter(0.5, 1)
        self:setIgnoresDrawOffset(true)
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
        if vars.anim_power_in ~= nil then
            self:moveTo(200, 240+vars.anim_power_in:currentValue())
        end
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
            self:setImage(assets.img_fade[math.floor(vars.anim_overlay:currentValue())])
        end
    end

    self.water = water()
    self.boat = boat(10, 40)
    self.track = track()
    self.ui = ui()
    self.react = react()
    self.meter = meter()
    self.overlay = overlay()

    pd.timer.performAfterDelay(1000, function()
        self:progress()
    end)

    self:add()
end

function tutorial:checkpoint(x, y)
    if x == vars.line.x and y == vars.line.y then
        self:finish()
    end
end

function tutorial:progress()
    assets.img_ui = next
    vars.current_step += 1
    if vars.current_step == 1 then
        assets.img_ui = gfx.image.new(400, 75)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut1"), 200, 35, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 240)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut1"), 200, 35, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 2 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut2"), 200, 35, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 75)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut2"), 200, 35, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 3 then
        vars.boat_moving = true
        vars.camera_target_offset = vars.boat_speed_stat*15
        vars.boat_speed_rate = gfx.animator.new(1000, 0, vars.boat_speed_stat, pd.easingFunctions.inOutSine)
        vars.boat_turn_rate = gfx.animator.new(2500, 0, vars.boat_turn_stat, pd.easingFunctions.inOutSine)
        pd.timer.performAfterDelay(2000, function()
            assets.img_ui = gfx.image.new(400, 240)
            gfx.pushContext(assets.img_ui)
                assets.img_tutui:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut3"), 200, 28, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
            self.ui:add()
            vars.ui_open = true
            pd.timer.performAfterDelay(vars.waittime, function()
                vars.ui_progressable = true
                assets.img_ui = gfx.image.new(400, 75)
                gfx.pushContext(assets.img_ui)
                    assets.img_tutuia:draw(11, 10)
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut3"), 200, 28, kTextAlignment.center)
                gfx.popContext()
                self.ui:setImage(assets.img_ui)
            end)
        end)
    elseif vars.current_step == 4 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut4"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 75)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut4"), 200, 28, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 5 then
        if pd.isCrankDocked() then
            assets.img_ui = gfx.image.new(400, 240)
            gfx.pushContext(assets.img_ui)
                assets.img_tutui:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut5"), 200, 35, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
            self.ui:add()
            vars.ui_open = true
            show_crank = true
        else
            self:progress()
        end
    elseif vars.current_step == 6 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut6"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        vars.boat_controllable = true
    elseif vars.current_step == 7 then
        vars.boat_controllable = false
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut7"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 75)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut7"), 200, 28, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 8 then
        vars.anim_power_in = gfx.animator.new(1000, 75, 0, pd.easingFunctions.outCubic)
        self.meter:add()
        self.react:add()
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut8"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 75)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut8"), 200, 28, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 9 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut9"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 75)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut9"), 200, 28, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 10 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut10"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 75)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut10"), 200, 28, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 11 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut11"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        pd.timer.performAfterDelay(vars.waittime, function()
            vars.ui_progressable = true
            assets.img_ui = gfx.image.new(400, 75)
            gfx.pushContext(assets.img_ui)
                assets.img_tutuia:draw(11, 10)
                assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut11"), 200, 28, kTextAlignment.center)
            gfx.popContext()
            self.ui:setImage(assets.img_ui)
        end)
    elseif vars.current_step == 12 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut12"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        vars.boat_controllable = true
    elseif vars.current_step == 13 then
        assets.img_ui = gfx.image.new(400, 240)
        gfx.pushContext(assets.img_ui)
            assets.img_tutui:draw(11, 10)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText("tut13"), 200, 28, kTextAlignment.center)
        gfx.popContext()
        self.ui:setImage(assets.img_ui)
        self.ui:add()
        vars.ui_open = true
        self.track:moveTo(self.boat.x, self.boat.y - 250)
        vars.boat_land_y = self.boat.y
        local trackx, tracky = self.track:getSize()
        vars.line = gfx.sprite.addEmptyCollisionSprite((self.track.x - (trackx / 2)) + 462, (self.track.y - tracky) + 150, 166, 45)
        self.track:add()
    end
end

function tutorial:finish()
    if not vars.finishing then
        vars.finishing = true
        vars.boat_controllable = false
        vars.anim_overlay = gfx.animator.new(1200, #assets.img_fade, 1)
        vars.boat_speed_rate = gfx.animator.new(1000, vars.boat_speed_stat*1.5, 0, pd.easingFunctions.inOutSine)
        vars.anim_finish_turn = gfx.animator.new(1000, vars.boat_rotation, math.clamp(vars.boat_old_rotation, vars.boat_rotation-40, vars.boat_rotation+40), pd.easingFunctions.outCubic)
        pd.timer.performAfterDelay(1200, function()
            vars.anim_overlay = nil
            self.overlay:setImage(nil)
            scenemanager:switchscene(cutscene, 2, "story")
        end)
    end
end

function tutorial:crash()
    local cols = {}
    local colno = 0
    for key, box in pairs(vars.boat_cols) do
        box[1]:moveTo(self.boat.x + box[2], self.boat.y + box[3])
        if gfx.checkAlphaCollision(box[1]:getImage(), self.boat.x + box[2], self.boat.y + box[3], 0, assets.img_trackc, self.track.x - (self.track.width / 2), self.track.y - self.track.height, 0) then
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
        self:reaction("idle")
        vars.camera_target_offset = vars.boat_speed_stat*15
        vars.boat_speed_rate = gfx.animator.new(2000, 0, vars.boat_speed_stat, pd.easingFunctions.inOutSine)
        vars.boat_turn_rate = gfx.animator.new(500, 0, vars.boat_turn_stat, pd.easingFunctions.inOutSine)
        vars.boat_turn = 0
    end)
end

function tutorial:reflectangle(c)
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

function tutorial:reaction(new)
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

function tutorial:update()
    local gfx_x, gfx_y = gfx.getDrawOffset()
    self.water:moveTo(vars.anim_water_x:currentValue()+(gfx_x%-400), vars.anim_water_y:currentValue()+(gfx_y%-240))
    vars.camera_offset += (vars.camera_target_offset - vars.camera_offset) * 0.05
    vars.boat_old_rotation += (vars.boat_rotation - vars.boat_old_rotation) * 0.20
    if vars.current_step == 5 then
        function pd.crankUndocked()
            self:progress()
        end
    end
    if vars.ui_progressable then
        if pd.buttonJustPressed('a') then
            self.ui:remove()
            vars.ui_open = false
            vars.ui_progressable = false
            self:progress()
        end
    end
    if vars.boat_moving then
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
            if gfx.checkAlphaCollision(self.boat:getImage(), self.boat.x - (self.boat.width / 2), self.boat.y - (self.boat.height / 2), 0, assets.img_trackc, self.track.x - (self.track.width / 2), self.track.y - self.track.height, 0) then
                self:crash()
            end
            if vars.boat_controllable then
                if vars.player_turn < change then vars.player_turn += vars.boat_turn_stat/5 else vars.player_turn -= vars.boat_turn_stat/5 end
                if vars.current_step == 6 then
                    if vars.player_turn >= 0 then
                        vars.hang_time += 1
                    end
                    if vars.hang_time >= 150 then
                        self:progress()
                    end
                end
                if vars.current_step == 12 then
                    if vars.boat_rotation%360 <= 15 or vars.boat_rotation%360 >= 345 then
                        vars.line_time += 1
                    end
                    if vars.line_time >= 150 then
                        self:progress()
                    end
                end
                if vars.current_step == 13 then
                    if self.boat.y <= vars.boat_land_y - 800 then
                        self.ui:remove()
                    end
                end
            else
                vars.player_turn -= vars.boat_turn_stat/5
            end
            vars.boat_rotation += vars.player_turn*vars.boat_turn_rate:currentValue()*0.56 -= vars.boat_turn_rate:currentValue()*3
            vars.boat_rotation = vars.boat_rotation%360
            vars.boat_radtation = math.rad(vars.boat_rotation)
            self.boat:moveBy(math.sin(vars.boat_radtation)*vars.boat_speed_rate:currentValue()*2.5, math.cos(vars.boat_radtation)*-vars.boat_speed_rate:currentValue()*2.5)
        end
    end
    if vars.player_turn < 0 then vars.player_turn = 0 end
    if not vars.finishing then
        self.boat:setImage(assets.img_boat[math.floor((vars.boat_rotation%360) / 6)+1])
        gfx.setDrawOffset((200-self.boat.x)+(-math.sin(vars.boat_radtation)*vars.camera_offset), (120-self.boat.y)+(math.cos(vars.boat_radtation)*vars.camera_offset))
    else
        self.boat:moveBy(0, -vars.boat_speed_rate:currentValue()*2.5)
        self.boat:setImage(assets.img_boat[math.floor((vars.anim_finish_turn:currentValue()%360) / 6)+1])
    end
end
