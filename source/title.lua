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
    local do_instastart = args[1]
    show_crank = false
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end

    assets = {
        img_logo = gfx.image.new('images/ui/logo'),
        img_button_start = gfx.image.new('images/ui/button_start'),
        img_wave = gfx.image.new('images/title/wave'),
        img_bg = gfx.image.new('images/title/bg'),
        img_checker = gfx.image.new('images/title/checker'),
        img_sel_continue = gfx.image.new('images/title/sel_continue'),
        img_sel_new = gfx.image.new('images/title/sel_new'),
        img_sel_time_trials = gfx.image.new('images/title/sel_time_trials'),
        img_sel_options = gfx.image.new('images/title/sel_options'),
        img_sel_locked = gfx.image.new('images/title/sel_locked'),
        img_new_warn = gfx.image.new('images/ui/new_warn')
    }

    vars = {
        started = false,
        isstarting = false,
        menu_scrollable = false,
        selector_moving = false,
        new_warn_open = false,
        menu_list = {'new', 'time_trials', 'options'},
        current_menu_item = 1,
        last_menu_item = 1,
        checker_anim_x = gfx.animator.new(2300, 0, -124),
        checker_anim_y = gfx.animator.new(2300, 0, -32),
        wave_anim_x = gfx.animator.new(1000, 0, -72),
        selector_anim_out_left = gfx.animator.new(150, 200, -200, pd.easingFunctions.inSine),
        selector_anim_in_left = gfx.animator.new(150, -200, 200, pd.easingFunctions.outBack),
        selector_anim_out_right = gfx.animator.new(150, 200, 600, pd.easingFunctions.inSine),
        selector_anim_in_right = gfx.animator.new(150, 600, 200, pd.easingFunctions.outBack)
    }

    if save.as then
        vars.menu_list = {'continue', 'new', 'time_trials', 'options'}
    end
    vars.current_name = vars.menu_list[vars.current_menu_item]
    
    vars.checker_anim_x.repeatCount = -1
    vars.checker_anim_y.repeatCount = -1
    vars.wave_anim_x.repeatCount = -1

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
        if vars.started == false then
            self:moveTo(math.floor(vars.wave_anim_x:currentValue()/2) * 4, 185)
        else
            if vars.isstarting then
                self:moveTo(math.floor(vars.wave_anim_x:currentValue()/2) * 4, vars.wave_anim_y:currentValue())
            else
                self:moveTo(0, -12)
            end
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
        if vars.isstarting then
            self:moveTo(200, vars.startscreen_anim:currentValue())
        end
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
        if vars.last_menu_item == vars.current_menu_item then
            return
        end
        vars.selector_moving = true
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
                if save.mt < 1 then
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
        self:moveTo(200, 120)
        self:setZIndex(99)
    end
    function ui:update()
    end

    self.wave = wave()
    self.startscreen = startscreen()
    self.checker = checker()
    self.bg = bg()
    self.selector = selector()
    self.ui = ui()

    if do_instastart then
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
    self.startscreen:remove()
end

function title:start()
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
    end)
    pd.timer.performAfterDelay(1750, function()
        self.startscreen:remove()
        vars.isstarting = false
        vars.menu_scrollable = true
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
            scenemanager:transitionsceneoneway(opening)
        end
        if pd.buttonJustPressed('b') then
            self.ui:remove()
            vars.menu_scrollable = true
            vars.new_warn_open = false
        end
    end
    if vars.menu_scrollable and vars.selector_moving == false then
        if pd.buttonJustPressed('left') then
            vars.current_menu_item = math.clamp(vars.current_menu_item - 1, 1, #vars.menu_list)
            vars.current_name = vars.menu_list[vars.current_menu_item]
            self.selector:change_sel(false)
        end
        if pd.buttonJustPressed('right') then
            vars.current_menu_item = math.clamp(vars.current_menu_item + 1, 1, #vars.menu_list)
            vars.current_name = vars.menu_list[vars.current_menu_item]
            self.selector:change_sel(true)
        end
        if pd.buttonJustPressed('a') then
            if vars.current_name == 'continue' then
                if save.cc == 0 then
                    scenemanager:transitionsceneoneway(opening)
                else
                    scenemanager:transitionsceneoneway(cutscene, save.cc, "story")
                end
            end
            if vars.current_name == 'new' then
                if save.as then
                    self.ui:add()
                    vars.new_warn_open = true
                    vars.menu_scrollable = false
                else
                    scenemanager:transitionsceneoneway(opening)
                end
            end
            if vars.current_name == 'time_trials' then
                if save.mt < 1 then
                    return
                else
                    scenemanager:transitionscene(garage)
                end
            end
            if vars.current_name == 'options' then
                scenemanager:transitionscene(options)
            end
        end
    end
end