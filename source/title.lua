-- Setting up scenes
import "cutscene"
import "opening"
import "garage"
import "options"

-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Defining images
title_img_logo = gfx.image.new('images/ui/logo') -- Logo image
title_img_button_start = gfx.image.new('images/ui/button_start') -- Start button image
title_img_wave = gfx.image.new('images/title/wave') -- Wave image
title_img_bg = gfx.image.new('images/title/bg') -- Background image
title_img_checker = gfx.image.new('images/title/checker') -- Checkerboard loop image
title_img_sel_continue = gfx.image.new('images/title/sel_continue')
title_img_sel_new = gfx.image.new('images/title/sel_new')
title_img_sel_time_trials = gfx.image.new('images/title/sel_time_trials')
title_img_sel_options = gfx.image.new('images/title/sel_options')
title_img_sel_locked = gfx.image.new('images/title/sel_locked')

class('title').extends(gfx.sprite)
function title:init(...)
    title.super.init(self)
    args = {...} -- Very heated argument
    do_instastart = args[1] -- do_instastart: a boolean checking if it should instastart or not
    show_crank = false -- Show the crank indicator?

    -- Defining variables
    started = false -- Whether the 'start' menu has been passed or not
    isstarting = false -- Whether the thing is actively animating
    menu_scrollable = false -- Can you peruse the menu right now?
    menu_list_story = {"continue", "new", "time_trials", "options"} -- Menu list, if you've got an active story going on
    menu_list_no_story = {"new", "time_trials", "options"} -- Menu list if you haven't done a game
    menu_list = menu_list_no_story -- Fall back to the no-story menu
    if active_story then -- If you've got an active adventure...
        menu_list = menu_list_story -- Use the story one instead.
    end
    current_menu_item = 1 -- Set the menu item to the start

    checker_anim_x = gfx.animator.new(2300, 0, -124) -- Checker animation on the X-axis
    checker_anim_x.repeatCount = -1 -- make sure it loops forever
    checker_anim_y = gfx.animator.new(2300, 0, -32) -- Checker animation on the Y-axis
    checker_anim_y.repeatCount = -1 -- Make sure that loops forever as well

    wave_anim_x = gfx.animator.new(1000, 0, -72) -- Wave animation on the X-axis
    wave_anim_x.repeatCount = -1 -- Man, it's like these COMMENTS are looping forever! [laugh track]

    class('wave').extends(gfx.sprite) -- Wave sprite
    function wave:init()
        wave.super.init(self)
        self:setSize(472, 260)
        local image = gfx.image.new(576, 252)
        gfx.pushContext(image)
            title_img_wave:drawTiled(0, 0, 576, 252)
        gfx.popContext()
        self:setImage(image)
        local image = nil
        self:setCenter(0, 0)
        self:setZIndex(-1)
        self:add()
    end
    function wave:update()
        if started == false then -- If it hasn't started yet...
            self:moveTo(math.floor(wave_anim_x:currentValue()/2) * 4, 185) -- ...keep it in a place.
        else
            if isstarting then -- If it's currently starting,
                self:moveTo(math.floor(wave_anim_x:currentValue()/2) * 4, wave_anim_y:currentValue()) -- move it somewhere else!
            else
                self:moveTo(0, -12) -- Actually, never mind.
            end
        end
    end

    class('startscreen').extends(gfx.sprite) -- Start screen!
    function startscreen:init()
        startscreen.super.init(self)
        local image = gfx.image.new(290, 200)
        gfx.pushContext(image)
            title_img_logo:draw(0, 0)
            title_img_button_start:draw(30, 150)
        gfx.popContext()
        self:setImage(image)
        local image = nil
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
        self:setImage(title_img_checker)
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
        self:setImage(title_img_bg)
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
            self:setImage(title_img_sel_continue)
        end
        if current_name == "new" then
            self:setImage(title_img_sel_new)
        end
        self:moveTo(200, 160)
        self:setZIndex(3)
    end
    function selector:change_selection()
        if current_name == "continue" then
            self:setImage(title_img_sel_continue)
        end
        if current_name == "new" then
            self:setImage(title_img_sel_new)
        end
        if current_name == "time_trials" then
            if max_track < 1 then
                self:setImage(title_img_sel_locked)
            else
            self:setImage(title_img_sel_time_trials)
            end
        end
        if current_name == "options" then
            self:setImage(title_img_sel_options)
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
    startscreen:remove()
end

-- Regular start: for normal people™™™™™™™™
function title:start()
    started = true
    isstarting = true
    wave_anim_y = gfx.animator.new(800, 185, -12, pd.easingFunctions.inBack)
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
                if active_story then
                    return
                else
                    scenemanager:transitionsceneoneway(opening)
                end
            end
            if current_name == "time_trials" then
                if max_track < 1 then
                    return
                else
                    scenemanager:transitionscene(garage)
                end
            end
            if current_name == "options" then
                scenemanager:transitionscene(options)
            end
        end
    end
end