local pd <const> = playdate
local gfx <const> = pd.graphics

class('chase').extends(gfx.sprite)
function chase:init()
    chase.super.init(self)
    pd.ui.crankIndicator:start()
    show_crank = true

    assets = {
        img_sky = gfx.image.new('images/chase/sky'),
        img_bg = gfx.imagetable.new('images/chase/bg'),
        img_bg_mask = gfx.image.new('images/chase/bg_mask'),
        img_water = gfx.image.new('images/chase/water'),
        img_boat = gfx.image.new('images/chase/boat'),
        img_crash_s = gfx.image.new('images/chase/crash_s'),
        img_crash_l = gfx.image.new('images/chase/crash_l'),
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
        music = pd.sound.fileplayer.new('audio/music/chase')
    }
    assets.sfx_crash:setVolume(save.fx/5)
    assets.sfx_air:setVolume(save.fx/5)
    assets.sfx_splash:setVolume(save.fx/5)
    assets.sfx_chomp:setVolume(save.fx/5)
    assets.sfx_rock:setVolume(save.fx/5)
    assets.sfx_blips:setVolume(save.fx/5)
    assets.sfx_cymbal:setVolume(save.fx/5)
    assets.music:setVolume(save.mu/5)
    assets.music:setLoopRange(1.954)
    assets.music:play(0)

    vars = {
        boat_pos = 0,
        boat_min_pos = -140,
        boat_max_pos = 140,
        boat_pos_cache = {},
        boat_rot = 0,
        boat_min_rot = -20,
        boat_max_rot = 20,
        boat_speed = 0,
        boat_speed_rate = 0.25,
        boat_crashed = false,
        boat_y_anim = gfx.animator.new(1500, 350, 230, pd.easingFunctions.outBack),
        shark_y_anim = gfx.animator.new(1500, 430, 385, pd.easingFunctions.outBack, 200),
        shark_pos = 0,
        shark_follow_boat = false,
        rock_moving = false,
        rock_wait_time = 2000,
        rock_move_time = 1000,
        next_rock_time = 4000,
        crashes = 0,
        max_crashes = 3,
        passes = 0,
        max_passes = 100,
        playing = true,
        lost_actions_open = false,
        water_anim = gfx.animator.new(350, -131, 0)
    }
    
    vars.warn_anim = gfx.animation.loop.new(100, assets.img_warn, true)
    vars.water_anim.repeatCount = -1
    vars.bg_anim = gfx.animation.loop.new(15, assets.img_bg, true)
    vars.anim_overlay = gfx.animation.loop.new(115, assets.img_overlay_boost, true)

    pd.timer.performAfterDelay(vars.next_rock_time, function() self:newrock() end)
    pd.timer.performAfterDelay(1000, function()
        self.dir:add()
        vars.dir_anim = gfx.animator.new(500, -30, 50, pd.easingFunctions.outBack)
        pd.timer.performAfterDelay(2000, function()
            vars.dir_anim = gfx.animator.new(500, 50, -30, pd.easingFunctions.inBack)
            pd.timer.performAfterDelay(500, function()
                self.dir:remove()
            end)
        end)
    end)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.img_sky:draw(0, 0)
    end)

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setZIndex(1)
        self:setCenter(0.5, 1)
        self:moveTo(200, 240)
        self:add()
    end
    function bg:update()
        local img = gfx.image.new(566, 153)
        gfx.pushContext(img)
            assets.img_water:draw(100, vars.water_anim:currentValue())
            img:setMaskImage(assets.img_bg_mask)
            vars.bg_anim:draw(0, 0)
        gfx.popContext()
        self:setImage(img)
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
        self:add()
    end
    function rock:update()
        if vars.rock_moving then
            self:setScale(vars.rock_scale_anim:currentValue())
            self:moveTo(vars.rock_x_anim:currentValue(), vars.rock_y_anim:currentValue())
        end
    end

    class('crash_effect').extends(gfx.sprite)
    function crash_effect:init()
        crash_effect.super.init(self)
        self:setZIndex(4)
    end
    
    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setImage(assets.img_boat)
        self:setZIndex(5)
        self:setCenter(0.5, 1)
        self:add()
    end
    function boat:update()
        self:moveTo(vars.boat_pos+200, vars.boat_y_anim:currentValue())
        if vars.boat_crashed == false then
            if vars.playing then
                local change = pd.getCrankChange()/2
                if vars.boat_speed <= change then vars.boat_speed += vars.boat_speed_rate/2 end
                if vars.boat_speed >= change then vars.boat_speed -= vars.boat_speed_rate/2 end
                vars.boat_pos += vars.boat_speed*4 - vars.boat_speed_rate*28
                if vars.boat_pos <= vars.boat_min_pos then assets.sfx_crash:play(1, 1.5) vars.boat_pos = vars.boat_min_pos vars.boat_speed = 3 end
                if vars.boat_pos >= vars.boat_max_pos then assets.sfx_crash:play(1, 1.5) vars.boat_pos = vars.boat_max_pos vars.boat_speed = 0 end
                vars.boat_rot += change - 2.2
                if vars.boat_rot <= vars.boat_min_rot then vars.boat_rot = vars.boat_min_rot end
                if vars.boat_rot >= vars.boat_max_rot then vars.boat_rot = vars.boat_max_rot end
                self:setRotation(vars.boat_rot)
            else
                if vars.boat_pos+200 < 200 then
                    vars.boat_pos += 1
                elseif vars.boat_pos+200 == 200 then
                    vars.boat_pos = 0
                else
                    vars.boat_pos -= 1
                end
            end
        else
            self:setRotation(vars.boat_crash_rotate_anim:currentValue())
        end
        if vars.boat_scale_anim ~= nil then
            self:setScale(vars.boat_scale_anim:currentValue())
        end
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
        self:moveTo(vars.shark_pos+200, vars.shark_y_anim:currentValue())
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
    
    self.bg = bg()
    self.warn = warn()
    self.rock = rock()
    self.crash_effect = crash_effect()
    self.boat = boat()
    self.shark = shark()
    self.chomp = chomp()
    self.overlay = overlay()
    self.dir = dir()
    
    self:add()
end

function chase:newrock()
    if vars.playing then
        vars.rock_setting = math.floor(math.random(1, 4))
        vars.rock_pos = math.random(140, 260)
        vars.next_rock_time = math.random(vars.rock_wait_time-(vars.rock_wait_time+1), vars.rock_wait_time+vars.rock_wait_time)
        if vars.rock_pos <= 200 then
            vars.rock_new_pos = vars.rock_pos - vars.rock_pos * 0.30
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
            assets.sfx_blips:stop()
            assets.sfx_rock:play()
            vars.rock_moving = true
            vars.rock_scale_anim = gfx.animator.new(vars.rock_move_time, 0, 1.1, pd.easingFunctions.outSine)
            vars.rock_x_anim = gfx.animator.new(vars.rock_move_time, vars.rock_pos, vars.rock_new_pos, pd.easingFunctions.inSine)
            vars.rock_y_anim = gfx.animator.new(vars.rock_move_time*0.75, 115, 355, pd.easingFunctions.inSine, vars.rock_move_time*0.25)
            pd.timer.performAfterDelay(vars.rock_move_time*0.7, function() self:crashcheck() end)
            pd.timer.performAfterDelay(vars.rock_move_time, function() vars.rock_moving = false end)
            pd.timer.performAfterDelay(vars.next_rock_time, function() self:newrock() end)
        end)
    end
end

function chase:crashcheck()
    if vars.boat_pos+200 >= vars.rock_x_anim:currentValue() - vars.rock_width / 2 and vars.boat_pos+200 <= vars.rock_x_anim:currentValue() + vars.rock_width / 2 or vars.boat_pos+180 >= vars.rock_x_anim:currentValue() - vars.rock_width / 2 and vars.boat_pos+180 <= vars.rock_x_anim:currentValue() + vars.rock_width / 2 or vars.boat_pos+220 >= vars.rock_x_anim:currentValue() - vars.rock_width / 2 and vars.boat_pos+220 <= vars.rock_x_anim:currentValue() + vars.rock_width / 2 then
        self:crash()
    else
        vars.passes += 1
        if vars.passes == vars.max_passes then
            self:win()
        end
    end
end

function chase:crash_effect_small(dir)
    self:setImage(assets.img_crash_s)
    if dir then
        self:moveTo(vars.boat_pos+220, 230)
    else
        self:moveTo(vars.boat_pos+180, 230)
    end
    self:add()
    pd.timer.performAfterDelay(20, function()
        self:remove()
    end)
end

function chase:crash()
    shakiesx()
    assets.sfx_crash:play()
    assets.sfx_air:play()
    vars.boat_crashed = true
    self.boat:setCenter(0.5, 0.5)
    vars.boat_y_anim = gfx.animator.new(500, 185, 10, pd.easingFunctions.outSine)
    vars.boat_crash_rotate_anim = gfx.animator.new(1000, 0, 720)
    vars.crashes += 1
    self.crash_effect:setScale(1.5)
    self.crash_effect:setImage(assets.img_crash_l)
    self.crash_effect:moveTo(vars.boat_pos+200, 125)
    self.crash_effect:add()
    pd.timer.performAfterDelay(30, function()
        self.crash_effect:setScale(1)
    end)
    pd.timer.performAfterDelay(60, function()
        self.crash_effect:remove()
    end)
    pd.timer.performAfterDelay(500, function()
        vars.boat_y_anim = gfx.animator.new(500, 10, 210, pd.easingFunctions.inSine)
    end)
    if vars.crashes == vars.max_crashes then
        self:lose()
    end
    pd.timer.performAfterDelay(1000, function()
        assets.sfx_splash:play()
        vars.boat_y_anim = gfx.animator.new(1500, 260, 230, pd.easingFunctions.outElastic)
        self.boat:setCenter(0.5, 1)
        vars.boat_crashed = false
        vars.boat_rot = 0
    end)
end

function chase:win()
    vars.playing = false
    vars.boat_scale_anim = gfx.animator.new(1200, 1, 0.2, pd.easingFunctions.inSine)
    vars.boat_y_anim = gfx.animator.new(600, 230, 90, pd.easingFunctions.inOutSine)
    vars.shark_y_anim = gfx.animator.new(750, 385, 430, pd.easingFunctions.inBack)
    pd.timer.performAfterDelay(600, function()
        self.boat:setZIndex(0)
        vars.boat_y_anim = gfx.animator.new(400,90, 230, pd.easingFunctions.inSine)
    end)
    pd.timer.performAfterDelay(1200, function()
        self.boat:remove()
    end)
end

function chase:lose()
    vars.shark_y_anim = gfx.animator.new(1100, 385, 285, pd.easingFunctions.inOutBack)
    vars.playing = false
    pd.timer.performAfterDelay(900, function()
        self.chomp:add()
        pd.timer.performAfterDelay(20, function()
            assets.music:stop()
            assets.sfx_chomp:play()
            assets.sfx_cymbal:play()
            gfx.setDrawOffset(0, 0)
            show_crank = false
            vars.overlay_scale_anim = gfx.animator.new(700, 0.5, 1, pd.easingFunctions.outElastic)
            self.chomp:setImage(assets.img_chomp_2)
            vars.anim_overlay = gfx.animation.loop.new(100, assets.img_chomp_bubble, true)
            shakiesy()
        end)
    end)
    pd.timer.performAfterDelay(2000, function()
        vars.overlay_scale_anim = gfx.animator.new(350, 1, 0, pd.easingFunctions.inBack)
        pd.timer.performAfterDelay(350, function()
            vars.anim_overlay = nil
            self.overlay:remove()
        end)
        self.bg:remove()
        self.boat:remove()
        self.shark:remove()
        self.rock:remove()
        self.warn:remove()
        self.chomp:setImage(assets.img_chomp_3)
        self.chomp:setIgnoresDrawOffset(false)
        vars.lost_actions_open = true
    end)
end

function chase:update()
    if vars.lost_actions_open then
        if pd.buttonJustPressed('a') then
            scenemanager:transitionscene(chase)
        end
        if pd.buttonJustPressed('b') then
            scenemanager:transitionsceneoneway(title, false)
        end
    end
    if vars.playing then
        gfx.setDrawOffset(-vars.boat_pos*0.5, 0)
    end
    if vars.shark_follow_boat then
        vars.shark_pos = vars.boat_pos_cache[1]
        table.remove(vars.boat_pos_cache, 1)
    end
    table.insert(vars.boat_pos_cache, vars.boat_pos)
    pd.timer.performAfterDelay(75, function() vars.shark_follow_boat = true end)
end