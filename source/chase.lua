import 'cutscene'
import 'title'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('chase').extends(gfx.sprite)
function chase:init()
    chase.super.init(self)
    pd.ui.crankIndicator:start()
    show_crank = true

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if save.mc >= 7 then
            menu:addMenuItem("skip chase", function()
                self:win()
            end)
        end
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end

    assets = {
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        img_sky = gfx.image.new('images/chase/sky'),
        img_bg = gfx.imagetable.new('images/chase/bg'),
        img_bg_mask = gfx.image.new('images/chase/bg_mask'),
        img_water = gfx.image.new('images/chase/water'),
        img_boat = gfx.imagetable.new('images/chase/boat'),
        img_crash = gfx.image.new('images/chase/crash'),
        img_shark = gfx.image.new('images/chase/shark'),
        img_rock_1 = gfx.image.new('images/chase/rock_1'),
        img_rock_2 = gfx.image.new('images/chase/rock_2'),
        img_rock_3 = gfx.image.new('images/chase/rock_3'),
        img_rock_4 = gfx.image.new('images/chase/rock_4'),
        img_dir = gfx.image.new('images/chase/dir'),
        img_warn = gfx.imagetable.new('images/chase/warn'),
        img_chomp_1 = gfx.image.new('images/chase/chomp_1'),
        img_chomp_2 = gfx.image.new('images/chase/chomp_2'),
        img_chomp_3 = gfx.image.new('images/chase/chomp_3'),
        img_chomp_bubble = gfx.imagetable.new('images/chase/chomp_bubble'),
        img_overlay_boost = gfx.imagetable.new('images/race/boost/boost'),
        sfx_crash = pd.sound.sampleplayer.new('audio/sfx/crash'),
        sfx_air = pd.sound.sampleplayer.new('audio/sfx/air'),
        sfx_splash = pd.sound.sampleplayer.new('audio/sfx/splash'),
        sfx_chomp = pd.sound.sampleplayer.new('audio/sfx/chomp'),
        sfx_rock = pd.sound.sampleplayer.new('audio/sfx/rock'),
        sfx_blips = pd.sound.sampleplayer.new('audio/sfx/blips'),
        sfx_cymbal = pd.sound.sampleplayer.new('audio/sfx/cymbal'),
        sfx_ui = pd.sound.sampleplayer.new('audio/sfx/ui'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
        music = pd.sound.fileplayer.new('audio/music/chase')
    }
    assets.sfx_crash:setVolume(save.fx/5)
    assets.sfx_air:setVolume(save.fx/5)
    assets.sfx_splash:setVolume(save.fx/5)
    assets.sfx_chomp:setVolume(save.fx/5)
    assets.sfx_rock:setVolume(save.fx/5)
    assets.sfx_blips:setVolume(save.fx/5)
    assets.sfx_cymbal:setVolume(save.fx/5)
    assets.sfx_ui:setVolume(save.fx/5)
    assets.sfx_whoosh:setVolume(save.fx/5)
    assets.music:setVolume(save.mu/5)
    assets.music:setLoopRange(1.954)
    assets.music:play(0)

    vars = {
        fading = true,
        rowbot_multi = gfx.animator.new(1, 0, 0),
        cranked = false,
        boat_pos = 0,
        boat_min_pos = -140,
        boat_max_pos = 140,
        boat_rot = 0,
        boat_min_rot = -20,
        boat_max_rot = 20,
        boat_speed = 0,
        boat_speed_rate = 0.25,
        boat_crashed = false,
        boat_y_anim = gfx.animator.new(1500, 350, 230, pd.easingFunctions.outBack),
        shark_y_anim = gfx.animator.new(1500, 430, 405, pd.easingFunctions.outBack, 200),
        shark_pos = 0,
        rock_wait_time = 2000,
        rock_move_time = 1000,
        next_rock_time = 4000,
        crashes = 0,
        max_crashes = 3,
        passes = 0,
        max_passes = 3,
        playing = true,
        lost_actions_open = false,
        water_anim = gfx.animator.new(350, -131, 0),
    }
    
    vars.warn_anim = gfx.animation.loop.new(100, assets.img_warn, true)
    vars.water_anim.repeatCount = -1
    vars.bg_anim = gfx.animation.loop.new(15, assets.img_bg, true)
    vars.anim_overlay = gfx.animation.loop.new(115, assets.img_overlay_boost, true)

    vars.fade_anim = gfx.animator.new(500, 1, #assets.img_fade)
    pd.timer.performAfterDelay(500, function() fading = false self.fade:remove() end)

    pd.timer.performAfterDelay(vars.next_rock_time, function() self:newrock() end)
    pd.timer.performAfterDelay(1000, function()
        self.dir:add()
        assets.sfx_ui:play()
        vars.dir_anim = gfx.animator.new(500, -30, 50, pd.easingFunctions.outBack)
    end)
    pd.timer.performAfterDelay(3000, function()
        vars.dir_anim = gfx.animator.new(500, 50, -30, pd.easingFunctions.inBack)
        assets.sfx_whoosh:play()
    end)
    pd.timer.performAfterDelay(3500, function()
        self.dir:remove()
    end)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.img_sky:draw(0, 0)
    end)

    class('water').extends(gfx.sprite)
    function water:init()
        water.super.init(self)
        self:setZIndex(0)
        self:setCenter(0.5, 1)
        self:moveTo(200, 240)
        self:add()
    end
    function water:update()
        local img = gfx.image.new(369, 134)
        gfx.pushContext(img)
            assets.img_water:draw(0, vars.water_anim:currentValue())
            img:setMaskImage(assets.img_bg_mask)
        gfx.popContext()
        self:setImage(img)
    end

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setZIndex(1)
        self:setCenter(0.5, 1)
        self:moveTo(200, 240)
        self:add()
    end
    function bg:update()
        self:setImage(vars.bg_anim:image())
    end

    class('warn').extends(gfx.sprite)
    function warn:init()
        warn.super.init(self)
        self:setZIndex(2)
    end
    function warn:update()
        self:setImage(vars.warn_anim:image())
    end

    class('rock').extends(gfx.sprite)
    function rock:init()
        rock.super.init(self)
        self:setImage(assets.img_rock_1)
        self:setZIndex(3)
        self:setCenter(0.5, 1)
    end
    function rock:update()
        if vars.rock_scale_anim ~= nil then
            self:setScale(vars.rock_scale_anim:currentValue())
            self:moveTo(vars.rock_x_anim:currentValue(), vars.rock_y_anim:currentValue())
        end
    end

    class('crash_effect').extends(gfx.sprite)
    function crash_effect:init()
        crash_effect.super.init(self)
        self:setZIndex(4)
        self:setImage(assets.img_crash)
    end
    
    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setImage(assets.img_boat[1])
        self:setZIndex(5)
        self:setCenter(0.5, 0.75)
        self:add()
    end
    function boat:update()
        self:moveTo(vars.boat_pos+200, vars.boat_y_anim:currentValue()+vars.crashes*10)
    end
    
    class('shark').extends(gfx.sprite)
    function shark:init()
        shark.super.init(self)
        self:setImage(assets.img_shark)
        self:setZIndex(6)
        self:setCenter(0.5, 1)
        self:add()
    end
    function shark:update()
        self:moveTo(vars.shark_pos+200, vars.shark_y_anim:currentValue()-vars.crashes*10)
    end

    class('chomp').extends(gfx.sprite)
    function chomp:init()
        chomp.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(7)
        self:setIgnoresDrawOffset(true)
        self:setImage(assets.img_chomp_1)
    end
    
    class('overlay').extends(gfx.sprite)
    function overlay:init()
        overlay.super.init(self)
        self:moveTo(200, 120)
        self:setZIndex(8)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function overlay:update()
        if vars.anim_overlay then
            self:setImage(vars.anim_overlay:image())
        end
        if vars.overlay_scale_anim then
            self:setScale(vars.overlay_scale_anim:currentValue())
        end
    end
    
    class('dir').extends(gfx.sprite)
    function dir:init()
        self:setImage(assets.img_dir)
        self:moveTo(200, 50)
        self:setIgnoresDrawOffset(true)
        self:setZIndex(9)
    end
    function dir:update()
        if vars.dir_anim ~= nil then
            self:moveTo(200, vars.dir_anim:currentValue())
        end
    end

    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:setZIndex(99)
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function fade:update()
        if vars.fading then
            local image = gfx.image.new(400, 240)
            gfx.pushContext(image)
                assets.img_fade[math.floor(vars.fade_anim:currentValue())]:drawTiled(0, 0, 400, 240)
            gfx.popContext()
            self:setImage(image)
        end
    end
    
    self.water = water()
    self.bg = bg()
    self.warn = warn()
    self.rock = rock()
    self.crash_effect = crash_effect()
    self.boat = boat()
    self.shark = shark()
    self.chomp = chomp()
    self.overlay = overlay()
    self.dir = dir()
    self.fade = fade()
    
    self:add()
end

function chase:newrock()
    if vars.playing then
        vars.rock_setting = math.floor(math.random(1, 4))
        if vars.cranked == false then
            vars.rock_pos = 200
        else
            vars.rock_pos = math.random(140, 260)
        end
        vars.next_rock_time = math.random(vars.rock_wait_time-(vars.rock_wait_time+1), vars.rock_wait_time+vars.rock_wait_time)
        if vars.rock_pos < 200 then
            vars.rock_new_pos = vars.rock_pos - vars.rock_pos * 0.30
        elseif vars.rock_pos == 200 then
            vars.rock_new_pos = vars.rock_pos
        else
            vars.rock_new_pos = vars.rock_pos + vars.rock_pos * 0.30
        end
        self.warn:moveTo(vars.rock_pos, 60)
        assets.sfx_blips:play()
        self.warn:add()
        pd.timer.performAfterDelay(vars.rock_wait_time, function()
            if vars.rock_setting == 1 then
                self.rock:setImage(assets.img_rock_1)
                vars.rock_width = 111
            elseif vars.rock_setting == 2 then
                self.rock:setImage(assets.img_rock_2)
                vars.rock_width = 111
            elseif vars.rock_setting == 3 then
                self.rock:setImage(assets.img_rock_3)
                vars.rock_width = 78
            elseif vars.rock_setting == 4 then
                self.rock:setImage(assets.img_rock_4)
                vars.rock_width = 79
            end
            self.warn:remove()
            self.rock:add()
            assets.sfx_blips:stop()
            assets.sfx_rock:play()
            vars.rock_scale_anim = gfx.animator.new(vars.rock_move_time, 0, 1.1, pd.easingFunctions.outSine)
            vars.rock_x_anim = gfx.animator.new(vars.rock_move_time, vars.rock_pos, vars.rock_new_pos, pd.easingFunctions.inSine)
            vars.rock_y_anim = gfx.animator.new(vars.rock_move_time*0.75, 115, 355, pd.easingFunctions.inSine, vars.rock_move_time*0.25)
        end)
        pd.timer.performAfterDelay(vars.rock_wait_time+vars.rock_move_time*0.7, function() self:crashcheck() end)
        pd.timer.performAfterDelay(vars.rock_wait_time+vars.next_rock_time, function() self:newrock() end)
    end
end

function chase:crashcheck()
    if vars.playing then
        if vars.boat_pos+200 >= vars.rock_x_anim:currentValue() - vars.rock_width / 2 and vars.boat_pos+200 <= vars.rock_x_anim:currentValue() + vars.rock_width / 2 or vars.boat_pos+180 >= vars.rock_x_anim:currentValue() - vars.rock_width / 2 and vars.boat_pos+180 <= vars.rock_x_anim:currentValue() + vars.rock_width / 2 or vars.boat_pos+220 >= vars.rock_x_anim:currentValue() - vars.rock_width / 2 and vars.boat_pos+220 <= vars.rock_x_anim:currentValue() + vars.rock_width / 2 then
            self:crash()
        else
            vars.passes += 1
            if vars.passes == vars.max_passes then
                self:win()
            end
        end
    end
end

function chase:crash_small(dir)
    assets.sfx_crash:play(1, math.random()+1)
    assets.music:setRate(1+vars.crashes/9)
    if dir then
        self.crash_effect:moveTo(vars.boat_pos+235, 195)
    else
        self.crash_effect:moveTo(vars.boat_pos+165, 195)
    end
    self.crash_effect:add()
    pd.timer.performAfterDelay(50, function()
        self.crash_effect:remove()
    end)
    vars.crashes += 0.2
    if vars.crashes >= vars.max_crashes then
        self:lose()
    end
end

function chase:crash()
    shakiesx()
    assets.sfx_crash:play()
    assets.sfx_air:play()
    assets.music:setRate(1+vars.crashes/9)
    vars.boat_crashed = true
    self.boat:setCenter(0.5, 0.5)
    vars.boat_y_anim = gfx.animator.new(500, 185, 10, pd.easingFunctions.outSine)
    vars.boat_crash_rotate_anim = gfx.animator.new(1000, 0, 720)
    vars.crashes += 1
    self.crash_effect:moveTo(vars.boat_pos+200, 135)
    self.crash_effect:add()
    pd.timer.performAfterDelay(60, function()
        self.crash_effect:remove()
    end)
    pd.timer.performAfterDelay(500, function()
        vars.boat_y_anim = gfx.animator.new(500, 10, 210, pd.easingFunctions.inSine)
    end)
    if vars.crashes >= vars.max_crashes then
        self:lose()
    end
    pd.timer.performAfterDelay(1000, function()
        assets.sfx_splash:play()
        vars.boat_y_anim = gfx.animator.new(1500, 260, 230, pd.easingFunctions.outElastic)
        self.boat:setCenter(0.5, 0.75)
        vars.boat_crashed = false
        vars.boat_rot = 0
    end)
end

function chase:win()
    self.rock:remove()
    self.warn:remove()
    assets.sfx_rock:stop()
    assets.sfx_air:stop()
    assets.sfx_blips:stop()
    vars.playing = false
    assets.music:setRate(1)
    vars.boat_scale_anim = gfx.animator.new(1200, 1, 0.2, pd.easingFunctions.inSine)
    vars.boat_y_anim = gfx.animator.new(600, 230, 90, pd.easingFunctions.inOutSine)
    vars.shark_y_anim = gfx.animator.new(750, 405, 430, pd.easingFunctions.inBack)
    pd.timer.performAfterDelay(600, function()
        self.boat:setZIndex(-1)
        vars.boat_y_anim = gfx.animator.new(400,90, 230, pd.easingFunctions.inSine)
    end)
    pd.timer.performAfterDelay(1200, function()
        self.boat:remove()
        vars.fade_anim = gfx.animator.new(500, #assets.img_fade, 1)
        self.fade:add()
        assets.music:setVolume(0, 0, 499, function() assets.music:stop() end)
    end)
    pd.timer.performAfterDelay(1700, function()
        scenemanager:switchscene(cutscene, 7, "story")
    end)
end

function chase:lose()
    if vars.playing then
        vars.playing = false
        vars.shark_y_anim = gfx.animator.new(1100, 405, 305, pd.easingFunctions.inOutBack)
        pd.timer.performAfterDelay(900, function()
            self.chomp:add()
        end)
        pd.timer.performAfterDelay(920, function()
            shakiesy()
            self.chomp:setImage(assets.img_chomp_2)
            assets.music:stop()
            assets.sfx_chomp:play()
            assets.sfx_cymbal:play()
            self.boat:remove()
            self.rock:remove()
            self.warn:remove()
            show_crank = false
            vars.anim_overlay = gfx.animation.loop.new(100, assets.img_chomp_bubble, true)
        end)
        pd.timer.performAfterDelay(2000, function()
            gfx.setDrawOffset(0, 0)
            assets.music:setRate(1)
            vars.overlay_scale_anim = gfx.animator.new(350, 1, 0, pd.easingFunctions.inBack)
            self.water:remove()
            self.shark:remove()
            self.bg:remove()
            assets.sfx_rock:stop()
            assets.sfx_air:stop()
            assets.sfx_blips:stop()
            assets.sfx_crash:stop()
            self.chomp:setIgnoresDrawOffset(false)
            self.chomp:setImage(assets.img_chomp_3)
            vars.lost_actions_open = true
        end)
        pd.timer.performAfterDelay(2350, function()
            vars.anim_overlay = nil
            self.overlay:remove()
        end)
    end
end

function chase:update()
    if vars.lost_actions_open then
        if pd.buttonJustPressed('a') then
            scenemanager:transitionsceneoneway(chase)
        end
        if pd.buttonJustPressed('b') then
            scenemanager:transitionsceneoneway(title, false)
        end
    end
    local change = pd.getCrankChange()/2
    if change > 0 and vars.cranked == false then
        vars.cranked = true
        vars.boat_speed = change/4
        vars.boat_rot = change/4
        vars.rowbot_multi = gfx.animator.new(1000, 0, 1, pd.easingFunctions.inOutSine)
    end

    if vars.playing then
        gfx.setDrawOffset(-vars.boat_pos*0.5, 0)
        vars.shark_pos += (vars.boat_pos - vars.shark_pos) * 0.1
        if vars.boat_crashed then
            self.boat:setImage(assets.img_boat[math.floor((vars.boat_crash_rotate_anim:currentValue()%360) /4.5)+1])
        else
            if vars.cranked and change >= 0 then
                if vars.boat_speed <= change then vars.boat_speed += vars.boat_speed_rate/2 end
                if vars.boat_speed >= change then vars.boat_speed -= vars.boat_speed_rate/2 end
                vars.boat_pos += vars.boat_speed*4 - (vars.boat_speed_rate*28)*vars.rowbot_multi:currentValue()
                vars.boat_rot += change - 2.2*vars.rowbot_multi:currentValue()
                if vars.boat_rot <= vars.boat_min_rot then vars.boat_rot = vars.boat_min_rot end
                if vars.boat_rot >= vars.boat_max_rot then vars.boat_rot = vars.boat_max_rot end
                self.boat:setImage(assets.img_boat[math.floor(((vars.boat_rot%360)/4.5)+1)])
            end
        end
        if vars.boat_pos <= vars.boat_min_pos then
            self:crash_small(false)
            vars.boat_pos = vars.boat_min_pos
            vars.boat_speed = 3
        end
        if vars.boat_pos >= vars.boat_max_pos then
            self:crash_small(true)
            vars.boat_pos = vars.boat_max_pos
            vars.boat_speed = 0
        end
    else
        if vars.boat_pos+200 < 200 then
            vars.boat_pos += 1
        elseif vars.boat_pos+200 == 200 then
            vars.boat_pos = 0
        else
            vars.boat_pos -= 1
        end
        if vars.boat_scale_anim ~= nil then
            self.boat:setScale(vars.boat_scale_anim:currentValue())
        end
    end
end