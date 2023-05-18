-- Handy shorthands
local pd <const> = playdate
local gfx <const> = pd.graphics

class('options').extends(gfx.sprite)
local bg = gfx.image.new('images/options/bg')
local gear_large = gfx.imagetable.new('images/options/gear_large/gear_large')
local gear_small = gfx.imagetable.new('images/options/gear_small/gear_small')
local gear_large_anim = gfx.animation.loop.new(25, gear_large, true)
local gear_small_anim = gfx.animation.loop.new(25, gear_small, true)

local hi_music = gfx.image.new('images/options/hi_music')
local hi_sfx = gfx.image.new('images/options/hi_sfx')
local hi_replay_cutscene = gfx.image.new('images/options/hi_replay_cutscene')
local hi_replay_credits = gfx.image.new('images/options/hi_replay_credits')
local hi_reset = gfx.image.new('images/options/hi_reset')

local text_music = gfx.image.new('images/options/text_music')
local text_sfx = gfx.image.new('images/options/text_sfx')
local text_replay_cutscene = gfx.image.new('images/options/text_replay_cutscene')
local text_replay_credits = gfx.image.new('images/options/text_replay_credits')
local text_reset = gfx.image.new('images/options/text_reset')

local menu_list = {"music", "sfx", "replay_cutscene", "replay_credits", "reset"}
local current_menu_item = 1

function options:init()
    options.super.init(self)
    local arrive = gfx.animator.new(100, 400, 0)
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            bg:draw(0, 0)
        end
    )

    class('gears').extends(gfx.sprite)
    function gears:init()
        gears.super.init(self)
        self:moveTo(330, 75)
        self:add()
    end
    function gears:update()
        local gears_image = gfx.image.new(135, 50)
        gfx.pushContext(gears_image)
            gear_small_anim:draw(-13, 10)
            gear_large_anim:draw(25, -20, gfx.kImageFlippedX)
        gfx.popContext()
        self:setImage(gears_image:fadedImage(0.25, gfx.image.kDitherTypeBayer8x8))
    end
    gears = gears()

    class('selection').extends(gfx.sprite)
    function selection:init()
        selection.super.init(self)
        self:setCenter(0, 0)
        local selection_image = gfx.image.new(145, 226)
        gfx.pushContext(selection_image)
            hi_music:draw(3, 6)
        gfx.popContext()
        self:setImage(selection_image)
        self:add()
    end
    selection = selection()

    class('text').extends(gfx.sprite)
    function text:init()
        text.super.init(self)
        self:setCenter(0, 0.5)
        self:moveTo(193, 167)
        self:setImage(text_music)
        self:add()
    end
    text = text()

    function change_selection(dir)
        selection:moveBy(0, dir*2)
        pd.timer.performAfterDelay(25, function() selection:moveBy(0, -dir*2) end)
        local current_name = menu_list[current_menu_item]
        local selection_image = gfx.image.new(145, 226)
        gfx.pushContext(selection_image)
            if current_name == "music" then hi_music:draw(3, 6) end
            if current_name == "sfx" then hi_sfx:draw(3, 32) end
            if current_name == "replay_cutscene" then hi_replay_cutscene:draw(10, 71) end
            if current_name == "replay_credits" then hi_replay_credits:draw(10, 112) end
            if current_name == "reset" then hi_reset:draw(18, 171) end
        gfx.popContext()
        selection:setImage(selection_image)
        if current_name == "music" then text:setImage(text_music) end
        if current_name == "sfx" then text:setImage(text_sfx) end
        if current_name == "replay_cutscene" then text:setImage(text_replay_cutscene) end
        if current_name == "replay_credits" then text:setImage(text_replay_credits) end
        if current_name == "reset" then text:setImage(text_reset) end
    end

    self:add()
end

function options:update()
    if pd.buttonJustPressed('b') then
        scenemanager:transitionscene(title, true)
    end
    if pd.buttonJustPressed('up') then
        current_menu_item = math.clamp(current_menu_item - 1, 1, #menu_list)
        change_selection(-1)
    end
    if pd.buttonJustPressed('down') then
        current_menu_item = math.clamp(current_menu_item + 1, 1, #menu_list)
        change_selection(1)
    end
    local current_name = menu_list[current_menu_item]
    if current_name == "music" then
    end
    if current_name == "sfx" then
    end
    if current_name == "replay_cutscene" then
    end
    if current_name == "replay_credits" then
    end
    if current_name == "reset" then
    end
end