-- Setting up scenes
import "options"

-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('title').extends(gfx.sprite)
function title:init(...)
    title.super.init(self)
    args = {...} -- Very heated argument
    do_instastart = args[1] -- do_instastart: a boolean checking if it should instastart or not

    -- Defining variables
    started = false -- Whether the 'start' menu has been passed or not
    isstarting = false -- Whether the thing is actively animating
    menu_scrollable = false -- Can you peruse the menu right now?
    menu_list_story = {"continue", "new", "time_trials", "options"} -- Menu list, if you've got an active story going on
    menu_list_no_story = {"new", "time_trials", "options"} -- Menu list if you haven't done a game
    menu_list = menu_list_no_story -- Fall back to the no-story menu
    if active_adventure then -- If you've got an active adventure...
        menu_list = menu_list_story -- Use the story one instead.
    end
    current_menu_item = 1 -- Set the menu item to the start
    
    -- Defining images
    img_logo = gfx.image.new('images/ui/logo') -- Logo image
    img_button_start = gfx.image.new('images/ui/button_start') -- Start button image
    img_bg = gfx.image.new('images/title/bg') -- Background image
    img_wave = gfx.image.new('images/title/wave') -- Wave image
    img_checker = gfx.image.new('images/title/checker') -- Checkerboard loop image
    img_selector = gfx.image.new('images/title/selector') -- Items to select
    if max_track == 0 then -- Wait!! If there's no progress in the story yet...
        img_selector = gfx.image.new('images/title/selector_locked') -- Then use the locked image instead.
    end

    checker_anim_x = gfx.animator.new(2300, 0, -124)
    checker_anim_x.repeatCount = -1
    checker_anim_y = gfx.animator.new(2300, 0, -32)
    checker_anim_y.repeatCount = -1

    wave_anim_x = gfx.animator.new(1000, 0, -72)
    wave_anim_x.repeatCount = -1

    class('wave').extends(gfx.sprite)
    function wave:init()
        wave.super.init(self)
        self:setSize(472, 260)
        self:setImage(img_wave)
        self:setCenter(0, 0)
        self:setZIndex(-1)
        self:add()
    end
    function wave:update()
        if started == false then
            self:moveTo(math.floor(wave_anim_x:currentValue()/2) * 4, 185)
        else
            if isstarting then
                self:moveTo(math.floor(wave_anim_x:currentValue()/2) * 4, wave_anim_y:currentValue())
            end
        end
    end

    class('startscreen').extends(gfx.sprite)
    function startscreen:init()
        startscreen.super.init(self)
        startscreen_image = gfx.image.new(290, 200)
        gfx.pushContext(startscreen_image)
            img_logo:draw(0, 0)
            img_button_start:draw(25, 150)
        gfx.popContext()
        self:setImage(startscreen_image)
        self:moveTo(200, 120)
        self:setZIndex(0)
        self:add()
    end
    function startscreen:update()
        if isstarting then
            self:moveTo(200, startscreen_anim:currentValue())
        end
    end

    class('checker').extends(gfx.sprite)
    function checker:init()
        checker.super.init(self)
        self:setImage(img_checker)
        self:setSize(525, 170)
        self:setZIndex(1)
        self:setCenter(0, 0)
    end
    function checker:update()
        self:moveTo(checker_anim_x:currentValue(), checker_anim_y:currentValue())
    end

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:setImage(img_bg)
    end
    function bg:update()
        if isstarting then
            self:moveTo(0, bg_anim:currentValue())
        end
    end

    class('selector').extends(gfx.sprite)
    function selector:init()
        selector.super.init(self)
        current_name = menu_list[current_menu_item]
        if current_name == "continue" then
            self:moveTo(800, 165)
        end
        if current_name == "new" then
            self:moveTo(400, 165)
        end
        self:setImage(img_selector)
        self:setZIndex(3)
    end
    function selector:change_selection()
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
    end

    wave = wave()
    startscreen = startscreen()
    checker = checker()
    bg = bg()
    selector = selector()

    -- If the thing tells the thing to do the thing, then...do the...thing.
    if do_instastart then
        self:instastart()
    end
    -- 🏆 GUYS I JUST WON THIS AWARD FOR "BEST COMMENT" IM SO EXCITED!!!!

    self:add()
end

-- Instastart: for if you wanna skip the kerfuffle™
function title:instastart()
    started = true
    menu_scrollable = true
    bg:add()
    checker:add()
    selector:add()
    wave:moveTo(0, -20)
    startscreen:remove()
end

-- Regular start: for normal people™™™™™™™™
function title:start()
    started = true
    isstarting = true
    wave_anim_y = gfx.animator.new(800, 185, -20, pd.easingFunctions.inBack)
    startscreen_anim = gfx.animator.new(800, 120, -120, pd.easingFunctions.inBack)
    pd.timer.performAfterDelay(1000, function()
        bg:add()
        bg_anim = gfx.animator.new(750, -800, 0, pd.easingFunctions.outSine)
    end)
    pd.timer.performAfterDelay(1500, function()
        checker:add()
        selector:add()
    end)
    pd.timer.performAfterDelay(1750, function()
        startscreen:remove()
        isstarting = false
        wave:moveTo(0, -20)
        menu_scrollable = true
    end)
end

function title:update()
    if pd.buttonJustPressed("a") then
        if started == false then
            self:start()
        end
    end
    if menu_scrollable then
        if pd.buttonJustPressed('left') then
            current_menu_item = math.clamp(current_menu_item - 1, 1, #menu_list)
            current_name = menu_list[current_menu_item]
            selector:change_selection(-1)
        end
        if pd.buttonJustPressed('right') then
            current_menu_item = math.clamp(current_menu_item + 1, 1, #menu_list)
            current_name = menu_list[current_menu_item]
            selector:change_selection(1)
        end
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

function title:cleanup()
    started = nil
    isstarting = nil
    menu_scrollable = nil
    menu_list_story = nil
    menu_list_no_story = nil
    menu_list = nil
    current_menu_item = nil
    current_name = nil

    img_logo = nil
    img_button_start = nil
    img_bg = nil
    img_wave = nil
    img_checker = nil
    img_selector = nil
    
    checker_anim_x = nil
    checker_anim_y = nil

    wave_anim_x = nil
    wave_anim_y = nil
    
    bg_anim = nil

    startscreen_image = nil
    
    wave = nil
    startscreen = nil
    checker = nil
    bg = nil
    selector = nil
end