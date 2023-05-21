import 'title'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('options').extends(gfx.sprite)

function options:init()
    options.super.init(self)
    show_crank = false
    
    options_assets = {
        img_bg = gfx.image.new('images/options/bg'),
        img_bg_credits_locked = gfx.image.new('images/options/bg_credits_locked'),
        img_bg_all_locked = gfx.image.new('images/options/bg_all_locked'),
        gear_large = gfx.imagetable.new('images/options/gear_large/gear_large'),
        gear_small = gfx.imagetable.new('images/options/gear_small/gear_small'),
        hi_music = gfx.image.new('images/options/hi_music'),
        hi_sfx = gfx.image.new('images/options/hi_sfx'),
        hi_replay_cutscene = gfx.image.new('images/options/hi_replay_cutscene'),
        hi_replay_credits = gfx.image.new('images/options/hi_replay_credits'),
        hi_reset = gfx.image.new('images/options/hi_reset'),
        hi_locked = gfx.image.new('images/options/hi_locked'),
        text_music = gfx.image.new('images/options/text_music'),
        text_sfx = gfx.image.new('images/options/text_sfx'),
        text_replay_cutscene = gfx.image.new('images/options/text_replay_cutscene'),
        text_replay_credits = gfx.image.new('images/options/text_replay_credits'),
        text_reset = gfx.image.new('images/options/text_reset')
    }

    options_vars = {
        gear_large_anim = gfx.animation.loop.new(25, options_assets.gear_large, true),
        gear_small_anim = gfx.animation.loop.new(25, options_assets.gear_small, true),
        menu_scrollable = true,
        menu_list = {'music', 'sfx', 'replay_cutscene', 'replay_credits', 'reset'},
        current_menu_item = 1
    }

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        if save.mt < 7 then
            self:setImage(options_assets.img_bg_credits_locked)
            if save.mc < 1 then
                self:setImage(options_assets.img_bg_all_locked)
            end
        else
            self:setImage(options_assets.img_bg)
        end
        self:setCenter(0, 0)
        self:add()
    end
    
    class('gears').extends(gfx.sprite)
    function gears:init()
        gears.super.init(self)
        self:moveTo(330, 75)
        self:add()
    end
    function gears:update()
        local image = gfx.image.new(135, 50)
        gfx.pushContext(image)
        options_vars.gear_small_anim:draw(-13, 10)
        options_vars.gear_large_anim:draw(25, -20, gfx.kImageFlippedX)
        gfx.popContext()
        self:setImage(image:fadedImage(0.25, gfx.image.kDitherTypeBayer8x8))
    end
    
    class('selector').extends(gfx.sprite)
    function selector:init()
        selector.super.init(self)
        local image = gfx.image.new(150, 226)
        gfx.pushContext(image)
            options_assets.hi_music:draw(3, 6)
        gfx.popContext()
        self:setImage(image)
        self:setCenter(0, 0)
        self:add()
    end
    function selector:change_sel()
        local image = gfx.image.new(150, 226)
        gfx.pushContext(image)
            if options_vars.current_name == 'music' then options_assets.hi_music:draw(3, 6) end
            if options_vars.current_name == 'sfx' then options_assets.hi_sfx:draw(3, 32) end
            if options_vars.current_name == 'replay_cutscene' then if save.mc < 1 then options_assets.hi_locked:draw(10, 71) else options_assets.hi_replay_cutscene:draw(10, 71) end end
            if options_vars.current_name == 'replay_credits' then if save.mt < 7 then options_assets.hi_locked:draw(60, 111) else options_assets.hi_replay_credits:draw(10, 112) end end
            if options_vars.current_name == 'reset' then options_assets.hi_reset:draw(18, 171) end
        gfx.popContext()
        self:setImage(image)
    end
    
    class('text').extends(gfx.sprite)
    function text:init()
        text.super.init(self)
        self:setImage(options_assets.text_music)
        self:setCenter(0, 0.5)
        self:moveTo(193, 167)
        self:add()
    end
    function text:change_sel()
        if options_vars.current_name == 'music' then self:setImage(options_assets.text_music) end
        if options_vars.current_name == 'sfx' then self:setImage(options_assets.text_sfx) end
        if options_vars.current_name == 'replay_cutscene' then self:setImage(options_assets.text_replay_cutscene) end
        if options_vars.current_name == 'replay_credits' then self:setImage(options_assets.text_replay_credits) end
        if options_vars.current_name == 'reset' then self:setImage(options_assets.text_reset) end
    end

    self.bg = bg()
    self.gears = gears()
    self.selector = selector()
    self.text = text()
    
    self:add()
end

function options:update()
    if pd.buttonJustPressed('b') then
        scenemanager:transitionscene(title, true)
    end
    if options_vars.menu_scrollable then
        if pd.buttonJustPressed('up') then
            options_vars.current_menu_item = math.clamp(options_vars.current_menu_item - 1, 1, #options_vars.menu_list)
            options_vars.current_name = options_vars.menu_list[options_vars.current_menu_item]
            self.selector:change_sel()
            self.text:change_sel()
        end
        if pd.buttonJustPressed('down') then
            options_vars.current_menu_item = math.clamp(options_vars.current_menu_item + 1, 1, #options_vars.menu_list)
            options_vars.current_name = options_vars.menu_list[options_vars.current_menu_item]
            self.selector:change_sel()
            self.text:change_sel()
        end
        if pd.buttonJustPressed('a') then
            if options_vars.current_name == 'replay_cutscene' then
                if save.mc < 1 then
                    return
                else
                end
            end
            if options_vars.current_name == 'replay_credits' then
                if save.mt < 7 then
                    return
                else
                    scenemanager:transitionscene(credits)
                end
            end
            if options_vars.current_name == 'reset' then
            end
        end
    end
end