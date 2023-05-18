-- Setting up scenes
import "options"

-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('title').extends(gfx.sprite)
local started = false
local menu_scrollable = false
local menu_list_story = {"continue", "new", "time_trials", "options"}
local menu_list_no_story = {"new", "time_trials", "options"}
if active_adventure then
    menu_list = menu_list_story
else
    menu_list = menu_list_no_story
end
local current_menu_item = 1

function title:init(args)
    local doinstastart = args[1]
    printTable(args)
    print(doinstastart)
    local img_bg = gfx.image.new('images/title/bg')
    local img_wave = gfx.image.new('images/title/wave')
    local img_selector = gfx.image.new('images/title/selector')
    local img_checker = gfx.image.new('images/title/checker')
    
    local checker_x_anim = gfx.animator.new(2300, 0, -124)
    local checker_y_anim = gfx.animator.new(2300, 0, -32)
    local wave_x_anim = gfx.animator.new(1000, 0, -72)
    local wave_y_anim = gfx.animator.new(10, 200, 200)
    
    wave_x_anim.repeatCount = -1
    checker_x_anim.repeatCount = -1
    checker_y_anim.repeatCount = -1

    class('wave').extends(gfx.sprite)
    function wave:init()
        wave.super.init(self)
        self:setSize(472, 260)
        self:setImage(img_wave)
        self:setCenter(0, 0)
        self:add()
    end
    function wave:update()
        if menu_scrollable == false then
            self:moveTo(math.floor(wave_x_anim:currentValue()/2) * 4, wave_y_anim:currentValue())
        end
    end
    wave = wave()

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setCenter(0, 0)
    end
    function bg:update()
        local bg_image = gfx.image.new(400, 800)
        gfx.pushContext(bg_image)
            img_checker:draw(checker_x_anim:currentValue(), checker_y_anim:currentValue())
            img_bg:draw(0, 0)
        gfx.popContext()
        self:setImage(bg_image)
        self:moveTo(0, bg_anim:currentValue())
    end
    bg = bg()

    class('selector').extends(gfx.sprite)
    function selector:init()
        selector.super.init(self)
        local current_name = menu_list[current_menu_item]
        if current_name == "continue" then
            self:moveTo(800, 165)
        end
        if current_name == "new" then
            self:moveTo(400, 165)
        end
        if current_name == "time_trials" then
            self:moveTo(0, 165)
        end
        if current_name == "options" then
            self:moveTo(-400, 165)
        end
        self:setImage(img_selector)
        self:setZIndex(999)
        function change_selection(dir)
            local current_name = menu_list[current_menu_item]
            if current_name == "continue" then
                self:moveTo(800, 165)
            end
            if current_name == "new" then
                self:moveTo(400, 165)
            end
            if current_name == "time_trials" then
                self:moveTo(0, 165)
            end
            if current_name == "options" then
                self:moveTo(-400, 165)
            end
            self:moveBy(dir*5, 0)
            pd.timer.performAfterDelay(25, function() self:moveBy(-dir*5, 0) end)
        end
    end
    selector = selector()

    function instastart()
        menu_scrollable = true
        started = true
        bg:add()
        bg_anim = gfx.animator.new(0, -800, 0, pd.easingFunctions.outSine)
        selector:add()
        wave:moveTo(0, -20)
    end

    function start()
        if started == false then
        started = true
        wave_y_anim = gfx.animator.new(800, 200, -20, pd.easingFunctions.inBack)
        pd.timer.performAfterDelay(1000, function()
            bg:add()
            bg_anim = gfx.animator.new(750, -800, 0, pd.easingFunctions.outSine)
        end)
        pd.timer.performAfterDelay(1500, function()
            wave_x_anim = nil
            wave_y_anim = nil
            selector:add()
            menu_scrollable = true
        end)
        end
    end

    self:add()
end

function title:update()
    if pd.buttonJustPressed("a") then
        instastart()
    end
    if menu_scrollable then
        if pd.buttonJustPressed('left') then
            current_menu_item = math.clamp(current_menu_item - 1, 1, #menu_list)
            change_selection(-1)
        end
        if pd.buttonJustPressed('right') then
            current_menu_item = math.clamp(current_menu_item + 1, 1, #menu_list)
            change_selection(1)
        end
        local current_name = menu_list[current_menu_item]
        if pd.buttonJustPressed("a") then
        if current_name == "continue" then
        end
        if current_name == "new" then
        end
        if current_name == "time_trials" then
        end
        if current_name == "options" then
            scenemanager:transitionscene(options)
        end
    end
    end
end