import 'cutscene'
import 'opening'
import 'garage'
import 'options'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('title').extends(gfx.sprite)
function title:init(...)
    title.super.init(self)
    local args = {...}
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 0
        pd.setMenuImage(img, xoffset)
        if demo then
            menu:addMenuItem(gfx.getLocalizedText("fullgame"), function()
                scenemanager:transitionsceneoneway(notif, "fullgame", "title")
            end)
        end
    end
    
    assets = {
        img_button_start = gfx.image.new('images/ui/button_start'),
        img_wave = gfx.image.new('images/title/wave'),
        img_checker = gfx.image.new('images/title/checker'),
        img_new_warn = gfx.image.new('images/ui/new_warn'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        img_arrow = gfx.image.new('images/ui/arrow'),
        music = pd.sound.fileplayer.new('audio/music/title'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
        sfx_locked = pd.sound.sampleplayer.new('audio/sfx/locked'),
        sfx_ui = pd.sound.sampleplayer.new('audio/sfx/ui'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
        sfx_start = pd.sound.sampleplayer.new('audio/sfx/start'),
        sfx_menu = pd.sound.sampleplayer.new('audio/sfx/menu')
    }
    assets.sfx_bonk:setVolume(save.fx/5)
    assets.sfx_locked:setVolume(save.fx/5)
    assets.sfx_ui:setVolume(save.fx/5)
    assets.sfx_proceed:setVolume(save.fx/5)
    assets.sfx_whoosh:setVolume(save.fx/5)
    assets.sfx_start:setVolume(save.fx/5)
    assets.sfx_menu:setVolume(save.fx/5)
    assets.music:setVolume(save.mu/5)
    assets.music:setLoopRange(1.1)
    assets.music:play(0)

    if demo then
        assets.img_logo = gfx.image.new('images/ui/logo_demo')
        assets.img_bg = gfx.image.new('images/title/bg_demo')
    else
        assets.img_logo = gfx.image.new('images/ui/logo')
        assets.img_bg = gfx.image.new('images/title/bg')
    end
    
    vars = {
        arg_instastart = args[1],
        fading = true,
        started = false,
        isstarting = false,
        menu_scrollable = false,
        selector_moving = false,
        new_warn_open = false,
        menu_list = {},
        current_menu_item = 1,
        last_menu_item = 1,
        checker_anim_x = gfx.animator.new(2300, 0, -124),
        checker_anim_y = gfx.animator.new(2300, 0, -32),
        wave_anim_x = gfx.animator.new(1000, 0, -72),
        wave_anim_y = gfx.animator.new(800, 300, 185, pd.easingFunctions.outBack),
        startscreen_anim = gfx.animator.new(800, 400, 120, pd.easingFunctions.outSine),
        ui_anim_in = gfx.animator.new(250, 250, 120, pd.easingFunctions.outBack),
        ui_anim_out = gfx.animator.new(100, 120, 500, pd.easingFunctions.inSine),
        anim_arrow_l = gfx.animator.new(1, 10, 25, pd.easingFunctions.outSine),
        anim_arrow_r = gfx.animator.new(1, 390, 375, pd.easingFunctions.outSine),
        selector_anim_out_left = gfx.animator.new(150, 200, -200, pd.easingFunctions.inSine),
        selector_anim_in_left = gfx.animator.new(150, -200, 200, pd.easingFunctions.outBack),
        selector_anim_out_right = gfx.animator.new(150, 200, 600, pd.easingFunctions.inSine),
        selector_anim_in_right = gfx.animator.new(150, 600, 200, pd.easingFunctions.outBack),
        selector_anim_locked = gfx.animator.new(200, pd.geometry.polygon.new(200, 160, 180, 160, 220, 160, 190, 160, 210, 160, 190, 160, 200, 160), pd.easingFunctions.linear)
    }

    if save.as then
        vars.menu_list[#vars.menu_list+1] = 'continue'
        assets.img_sel_continue = gfx.image.new('images/title/sel_continue')
    end
    vars.menu_list[#vars.menu_list+1] = 'new'
    if not demo then
        assets.img_sel_time_trials = gfx.image.new('images/title/sel_time_trials')
        assets.img_sel_locked = gfx.image.new('images/title/sel_locked')
        vars.menu_list[#vars.menu_list+1] = 'time_trials'
        assets.img_sel_new = gfx.image.new('images/title/sel_new')
    else
        assets.img_sel_new = gfx.image.new('images/title/sel_new_demo')
    end
    assets.img_sel_options = gfx.image.new('images/title/sel_options')
    vars.menu_list[#vars.menu_list+1] = 'options'
    vars.current_name = vars.menu_list[vars.current_menu_item]
    
    vars.checker_anim_x.repeatCount = -1
    vars.checker_anim_y.repeatCount = -1
    vars.wave_anim_x.repeatCount = -1

    vars.fade_anim = gfx.animator.new(350, 1, #assets.img_fade)
    pd.timer.performAfterDelay(350, function() fading = false self.fade:remove() end)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
    end)

    class('wave').extends(gfx.sprite)
    function wave:init()
        wave.super.init(self)
        self:setSize(472, 260)
        self:setZIndex(-1)
        self:setCenter(0, 0)
        local image = gfx.image.new(576, 252)
        gfx.pushContext(image)
            assets.img_wave:drawTiled(0, 0, 576, 252)
        gfx.popContext()
        self:setImage(image)
        self:add()
    end
    function wave:update()
        if vars.started == false or vars.isstarting then    
            self:moveTo(math.floor(vars.wave_anim_x:currentValue()/2) * 4, vars.wave_anim_y:currentValue())
        end
    end

    class('startscreen').extends(gfx.sprite)
    function startscreen:init()
        startscreen.super.init(self)
        self:setZIndex(0)
        self:moveTo(200, 120)
        local image = gfx.image.new(290, 240)
        gfx.pushContext(image)
            assets.img_logo:draw(0, 20)
            assets.img_button_start:draw(30, 170)
        gfx.popContext()
        self:setImage(image)
        self:add()
    end
    function startscreen:update()
        self:moveTo(200, vars.startscreen_anim:currentValue())
    end

    class('checker').extends(gfx.sprite)
    function checker:init()
        checker.super.init(self)
        self:setImage(assets.img_checker)
        self:setSize(525, 170)
        self:setZIndex(1)
        self:setCenter(0, 0)
    end
    function checker:update()
        self:moveTo(vars.checker_anim_x:currentValue(), vars.checker_anim_y:currentValue())
    end

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setImage(assets.img_bg)
        self:setZIndex(2)
        self:setCenter(0, 0)
    end
    function bg:update()
        if vars.isstarting then
            self:moveTo(0, vars.bg_anim:currentValue())
        end
    end

    class('arrow_l').extends(gfx.sprite)
    function arrow_l:init()
        arrow_l.super.init(self)
        self:setImage(assets.img_arrow)
        self:setZIndex(50)
    end
    function arrow_l:update()
        self:moveTo(vars.anim_arrow_l:currentValue(), 180)
        if vars.current_menu_item == 1 then
            self:setImage(assets.img_arrow:fadedImage(0.5, gfx.image.kDitherTypeBayer2x2))
        else
            self:setImage(assets.img_arrow)
        end
    end
    function arrow_l:move()
        vars.anim_arrow_l:reset(150)
    end

    class('arrow_r').extends(gfx.sprite)
    function arrow_r:init()
        arrow_r.super.init(self)
        self:setImage(assets.img_arrow, gfx.kImageFlippedX)
        self:setZIndex(50)
    end
    function arrow_r:update()
        self:moveTo(vars.anim_arrow_r:currentValue(), 150)
        if vars.current_name == "options" then
            self:setImage(assets.img_arrow:fadedImage(0.5, gfx.image.kDitherTypeBayer2x2), gfx.kImageFlippedX)
        else
            self:setImage(assets.img_arrow, gfx.kImageFlippedX)
        end
    end
    function arrow_r:move()
        vars.anim_arrow_r:reset(150)
    end

    class('selector').extends(gfx.sprite)
    function selector:init()
        selector.super.init(self)
        local current_name = vars.menu_list[vars.current_menu_item]
        self:setZIndex(3)
        self:moveTo(200, 160)
        if current_name == 'continue' then
            self:setImage(assets.img_sel_continue)
        end
        if current_name == 'new' then
            self:setImage(assets.img_sel_new)
        end
    end
    function selector:update()
        if vars.selector_moving then
            self:moveTo(selector_anim:currentValue(), 160)
        end
    end
    function selector:change_sel(dir)
        vars.selector_moving = true
        if vars.last_menu_item == vars.current_menu_item then
            selector_anim = vars.selector_anim_locked
            selector_anim:reset()
            assets.sfx_bonk:play()
            pd.timer.performAfterDelay(251, function() vars.selector_moving = false end)
            return
        end
        assets.sfx_menu:play()
        if dir then
            selector_anim = vars.selector_anim_out_left
            selector_anim:reset()
            pd.timer.performAfterDelay(150, function()
                selector_anim = vars.selector_anim_in_right
                selector_anim:reset()
            end)
        else
            selector_anim = vars.selector_anim_out_right
            selector_anim:reset()
            pd.timer.performAfterDelay(150, function()
                selector_anim = vars.selector_anim_in_left
                selector_anim:reset()
            end)
        end
        pd.timer.performAfterDelay(150, function()
            if vars.current_name == 'continue' then
                self:setImage(assets.img_sel_continue)
            end
            if vars.current_name == 'new' then
                self:setImage(assets.img_sel_new)
            end
            if vars.current_name == 'time_trials' then
                if save.mt < 1 or demo then
                    self:setImage(assets.img_sel_locked)
                else
                self:setImage(assets.img_sel_time_trials)
                end
            end
            if vars.current_name == 'options' then
                self:setImage(assets.img_sel_options)
            end
        end)
        pd.timer.performAfterDelay(301, function() vars.selector_moving = false end)
        vars.last_menu_item = vars.current_menu_item
    end

    class('ui').extends(gfx.sprite)
    function ui:init()
        ui.super.init(self)
        self:setImage(assets.img_new_warn)
        self:moveTo(200, 400)
        self:setZIndex(99)
    end
    function ui:update()
        if vars.ui_anim_in:ended() == false then
            self:moveTo(200, vars.ui_anim_in:currentValue())
        end
        if vars.ui_anim_out:ended() == false then
            self:moveTo(200, vars.ui_anim_out:currentValue())
        end
    end

    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:setZIndex(99)
        self:setCenter(0, 0)
        self:add()
    end
    function fade:update()
        if vars.fading then
            self:setImage(assets.img_fade[math.floor(vars.fade_anim:currentValue())])
        end
    end
    
    
    self.wave = wave()
    self.startscreen = startscreen()
    self.checker = checker()
    self.bg = bg()
    self.arrow_l = arrow_l()
    self.arrow_r = arrow_r()
    self.selector = selector()
    self.ui = ui()
    self.fade = fade()

    if vars.arg_instastart then
        self:instastart()
    end

    self:add()
end

function title:instastart()
    vars.started = true
    vars.menu_scrollable = true
    self.bg:add()
    self.checker:add()
    self.selector:add()
    self.arrow_l:add()
    self.arrow_r:add()
    self.startscreen:remove()
    self.wave:moveTo(0, -12)
end

function title:start()
    assets.sfx_start:play()
    vars.started = true
    vars.isstarting = true
    vars.wave_anim_y = gfx.animator.new(800, 185, -12, pd.easingFunctions.inBack)
    vars.startscreen_anim = gfx.animator.new(800, 120, -120, pd.easingFunctions.inBack)
    pd.timer.performAfterDelay(1000, function()
        self.bg:add()
        vars.bg_anim = gfx.animator.new(750, -800, 0, pd.easingFunctions.outSine)
    end)
    pd.timer.performAfterDelay(1500, function()
        self.checker:add()
        self.selector:add()
        self.arrow_l:add()
        self.arrow_r:add()
    end)
    pd.timer.performAfterDelay(1750, function()
        self.startscreen:remove()
        vars.isstarting = false
        vars.menu_scrollable = true
        self.wave:moveTo(0, -12)
    end)
end

function title:update()
    if pd.buttonJustPressed('a') then
        if vars.started == false then
            self:start()
        end
    end
    if vars.new_warn_open == true then
        if pd.buttonJustPressed('a') then
            scenemanager:transitionsceneoneway(opening, "story")
            assets.sfx_proceed:play()
            if not demo then
                save.st += 1
                save.cc = 0
                save.ct = 0
                save.pr = false
                save.sr = false
            end
            vars.new_warn_open = false
        end
        if pd.buttonJustPressed('b') then
            vars.ui_anim_out:reset()
            assets.sfx_whoosh:play()
            pd.timer.performAfterDelay(100, function()
                self.ui:remove()
                vars.menu_scrollable = true
            end)
            vars.new_warn_open = false
        end
    end
    if vars.menu_scrollable and vars.selector_moving == false then
        if pd.buttonJustPressed('left') then
            vars.current_menu_item = math.clamp(vars.current_menu_item - 1, 1, #vars.menu_list)
            vars.current_name = vars.menu_list[vars.current_menu_item]
            self.selector:change_sel(false)
            arrow_l:move()
        end
        if pd.buttonJustPressed('right') then
            vars.current_menu_item = math.clamp(vars.current_menu_item + 1, 1, #vars.menu_list)
            vars.current_name = vars.menu_list[vars.current_menu_item]
            self.selector:change_sel(true)
            arrow_r:move()
        end
        if pd.buttonJustPressed('a') then
            if vars.current_name == 'continue' then
                assets.sfx_proceed:play()
                if save.cc == 0 then
                    scenemanager:transitionsceneoneway(opening, "story")
                else
                    if save.mt >= 1 and save.ts == false then
                        scenemanager:transitionsceneoneway(notif, "tt", "story")
                    else
                        scenemanager:transitionsceneoneway(cutscene, save.cc, "story")
                    end
                end
                vars.menu_scrollable = false
            end
            if vars.current_name == 'new' then
                if save.as then
                    self.ui:add()
                    assets.sfx_ui:play()
                    vars.ui_anim_in:reset()
                    vars.new_warn_open = true
                    vars.menu_scrollable = false
                else
                    if save.st == 0 then
                        scenemanager:transitionsceneoneway(cutscene, 1, "story")
                    else
                        scenemanager:transitionsceneoneway(opening, "story")
                    end
                    assets.sfx_proceed:play()
                    save.as = true
                    save.st += 1
                    vars.menu_scrollable = false
                end
            end
            if vars.current_name == 'time_trials' then
                if save.mt < 1 or demo then
                    vars.selector_moving = true
                    selector_anim = vars.selector_anim_locked
                    selector_anim:reset()
                    assets.sfx_locked:play()
                    pd.timer.performAfterDelay(251, function() vars.selector_moving = false end)
                else
                    assets.sfx_proceed:play()
                    scenemanager:transitionscene(garage)
                    vars.menu_scrollable = false
                end
            end
            if vars.current_name == 'options' then
                scenemanager:transitionscene(options)
                assets.sfx_proceed:play()
                vars.menu_scrollable = false
            end
        end
    end
end