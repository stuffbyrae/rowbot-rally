import 'title'
import 'credits'
import 'notif'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('options').extends(gfx.sprite)

function options:init(...)
    options.super.init(self)
    local args = {...}
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        img_bg = gfx.image.new('images/options/bg'),
        gear_large = gfx.imagetable.new('images/options/gear_large/gear_large'),
        gear_small = gfx.imagetable.new('images/options/gear_small/gear_small'),
        img_music_slider = gfx.imagetable.new('images/options/music_slider'),
        img_sfx_slider = gfx.imagetable.new('images/options/sfx_slider'),
        img_reset_warn = gfx.image.new('images/ui/reset_warn'),
        img_button_reset = gfx.image.new('images/ui/button_reset'),
        img_button_reset_pressed = gfx.image.new('images/ui/button_reset_pressed'),
        img_button_blanky = gfx.image.new('images/ui/button_blanky'),
        kapel = gfx.font.new('fonts/kapel_doubleup'),
        pedallica = gfx.font.new('fonts/pedallica'),
        music = pd.sound.fileplayer.new('audio/music/options')
    }
    assets.music:setLoopRange(2.672)
    assets.music:setVolume(save.mu/5)
    assets.music:play(0)
    
    gfx.setFont(assets.pedallica)
    assets.text_img = gfx.imageWithText('Adjust the volume of music throughout the game - this applies to gameplay and cutscenes.', 200, 75)
    vars = {
        gear_large_anim = gfx.animation.loop.new(25, assets.gear_large, true),
        gear_small_anim = gfx.animation.loop.new(25, assets.gear_small, true),
        menu_scrollable = true,
        reset_warn_open = false,
        reset_progress = 0,
        reset_max_progress = 168,
        ui_anim_in = gfx.animator.new(250, 250, 120, pd.easingFunctions.outBack),
        ui_anim_out = gfx.animator.new(100, 120, 500, pd.easingFunctions.inSine),
        selector_pos_y = gfx.animator.new(1, 8, 8),
        selector_width = gfx.animator.new(1, 72, 72),
        menu_list = {'music', 'sfx', 'replay_tutorial', 'replay_cutscene', 'replay_credits', 'ui', 'reset'},
        current_menu_item = 1
    }
    print(vars.menu_scrollable)

    vars.current_name = vars.menu_list[vars.current_menu_item]
    
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.img_bg:draw(0, 0)
    end)

    class('gears').extends(gfx.sprite)
    function gears:init()
        gears.super.init(self)
        self:moveTo(330, 75)
        self:add()
    end
    function gears:update()
        local image = gfx.image.new(135, 50)
        gfx.pushContext(image)
        vars.gear_small_anim:draw(-13, 10)
        vars.gear_large_anim:draw(25, -20, gfx.kImageFlippedX)
        gfx.popContext()
        self:setImage(image:fadedImage(0.25, gfx.image.kDitherTypeBayer8x8))
    end
    
    class('selector').extends(gfx.sprite)
    function selector:init()
        selector.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(1)
        self:add()
    end
    function selector:update()
        local img = gfx.image.new(200, 240)
        gfx.pushContext(img)
        gfx.setFont(assets.kapel)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(3, vars.selector_pos_y:currentValue(), vars.selector_width:currentValue(), 25, 5)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText('Music', 8, 10)
        gfx.drawText('SFX', 8, 32)
        if save.ss then
            gfx.drawText('Play Tutorial', 8, 67)
        else
            gfx.drawText('???', 8, 67)
        end
        if save.mc >= 1 then
            gfx.drawText('Play Cutscenes', 8, 89)
        else
            gfx.drawText('???', 8, 89)
        end
        if save.cs then
            gfx.drawText('Play Credits', 8, 111)
        else
            gfx.drawText('???', 8, 111)
        end
        if save.ui then
            gfx.drawText('Race UI: Yea', 8, 146)
        else
            gfx.drawText('Race UI: Nah', 8, 146)
        end
        gfx.drawText('Reset Data', 8, 201)
        gfx.setColor(gfx.kColorXOR)
        gfx.fillRoundRect(3, vars.selector_pos_y:currentValue(), vars.selector_width:currentValue(), 25, 5)
        gfx.popContext()
        self:setImage(img)
    end

    class('text').extends(gfx.sprite)
    function text:init()
        text.super.init(self)
        self:setImage(assets.text_img)
        self:setCenter(0, 0.5)
        self:moveTo(193, 167)
        self:add()
    end

    class('volume').extends(gfx.sprite)
    function volume:init()
        volume.super.init(self)
        self:setImage(assets.img_music_slider[save.mu+1])
        self:setZIndex(10)
        self:setCenter(0, 0.5)
        self:moveTo(90, 40)
        self:add()
    end
    
    class('ui').extends(gfx.sprite)
    function ui:init()
        ui.super.init(self)
        self:moveTo(200, 400)
        self:setZIndex(99)
    end
    function ui:update()
        local img = gfx.image.new(400, 240)
        gfx.pushContext(img)
            assets.img_reset_warn:draw(0, 0)
            if vars.reset_progress > 0 then
                assets.img_button_reset_pressed:draw(116, 170)
                gfx.setColor(gfx.kColorXOR)
                gfx.fillRoundRect(76, 170, vars.reset_progress+40, 46, 18)
                assets.img_button_blanky:draw(76, 170)
            else
                assets.img_button_reset:draw(116, 165)
            end
        gfx.popContext()
        self:setImage(img)
        if vars.ui_anim_in:ended() == false then
            self:moveTo(200, vars.ui_anim_in:currentValue())
        end
        if vars.ui_anim_out:ended() == false then
            self:moveTo(200, vars.ui_anim_out:currentValue())
        end
    end
    
    self.gears = gears()
    self.selector = selector()
    self.text = text()
    self.volume = volume()
    self.ui = ui()
    
    self:add()
end

function options:change_sel()
    if vars.current_name == 'music' then
        assets.text_img = gfx.imageWithText('Adjust the volume of music throughout the game - this applies to gameplay and cutscenes.', 200, 75)
        self.volume:setImage(assets.img_music_slider[save.mu+1])
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 8, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 72, pd.easingFunctions.outBack)
    end
    if vars.current_name == 'sfx' then
        assets.text_img = gfx.imageWithText('Adjust the volume of sound effects throughout the game - this affects gameplay and cutscenes.', 200, 75)
        self.volume:setImage(assets.img_sfx_slider[save.fx+1])
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 32, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 53, pd.easingFunctions.outBack)
    end
    if vars.current_name == 'replay_tutorial' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 67, pd.easingFunctions.outBack)
        if save.ss then
            assets.text_img = gfx.imageWithText('Replay the tutorial, and get a grip on how to steer alongside your Rowbot.', 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 163, pd.easingFunctions.outBack)
        else
            assets.text_img = gfx.imageWithText('Hm, doesn\'t seem like you\'ve unlocked this yet. Come back when you\'ve played some more story!', 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 42, pd.easingFunctions.outBack)
        end
    end
    if vars.current_name == 'replay_cutscene' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 89, pd.easingFunctions.outBack)
        if save.mc >= 1 then
            assets.text_img = gfx.imageWithText('Replay a cutscene that you\'ve seen before! You can unlock more cutscenes by playing through the story.', 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 192, pd.easingFunctions.outBack)
        else
            assets.text_img = gfx.imageWithText('Hm, doesn\'t seem like you\'ve unlocked this yet. Come back when you\'ve played some more story!', 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 42, pd.easingFunctions.outBack)
        end
    end
    if vars.current_name == 'replay_credits' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 111, pd.easingFunctions.outBack)
        if save.cs then
            assets.text_img = gfx.imageWithText('Replay the credits, and see who all made this game possible!', 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 152, pd.easingFunctions.outBack)
        else
            assets.text_img = gfx.imageWithText('Hm, doesn\'t seem like you\'ve unlocked this yet. Come back when you\'ve played some more story!', 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 42, pd.easingFunctions.outBack)
        end
    end
    if vars.current_name == 'ui' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 146, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 97, pd.easingFunctions.outBack)
        assets.text_img = gfx.imageWithText('Show or hide the detailed UI during races. You can also change this setting during races, in the Slide menu.', 200, 75)
    end
    if vars.current_name == 'reset' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 201, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 140, pd.easingFunctions.outBack)
        assets.text_img = gfx.imageWithText('Delete all your save data, including best local times, story progress, and unlocked goodies.', 200, 75)
    end
    self.text:setImage(assets.text_img)
end

function options:update()
    if vars.menu_scrollable then
        if pd.buttonJustPressed('b') then
            vars.menu_scrollable = false
            scenemanager:transitionsceneoneway(title, false)
        end
        if pd.buttonJustPressed('up') then
            vars.current_menu_item = math.clamp(vars.current_menu_item - 1, 1, #vars.menu_list)
            vars.current_name = vars.menu_list[vars.current_menu_item]
            self:change_sel()
        end
        if pd.buttonJustPressed('down') then
            vars.current_menu_item = math.clamp(vars.current_menu_item + 1, 1, #vars.menu_list)
            vars.current_name = vars.menu_list[vars.current_menu_item]
            self:change_sel()
        end
        if pd.buttonJustPressed('left') then
            if vars.current_name == 'music' then
                if save.mu > 0 then
                    save.mu -= 1
                    assets.music:setVolume(save.mu/5)
                    self.volume:setImage(assets.img_music_slider[save.mu+1])
                end
            end
            if vars.current_name == 'sfx' then
                if save.fx > 0 then
                    save.fx -= 1
                    self.volume:setImage(assets.img_sfx_slider[save.fx+1])
                end
            end
        end
        if pd.buttonJustPressed('right') then
            if vars.current_name == 'music' then
                if save.mu < 5 then
                    save.mu += 1
                    assets.music:setVolume(save.mu/5)
                    self.volume:setImage(assets.img_music_slider[save.mu+1])
                end
            end
            if vars.current_name == 'sfx' then
                if save.fx < 5 then
                    save.fx += 1
                    self.volume:setImage(assets.img_sfx_slider[save.fx+1])
                end
            end
        end
        if pd.buttonJustPressed('a') then
            if vars.current_name == 'replay_tutorial' then
            end
            if vars.current_name == 'replay_cutscene' then
            end
            if vars.current_name == 'replay_credits' then
                if save.cs then
                    scenemanager:transitionsceneoneway(credits, "options")
                end
            end
            if vars.current_name == 'ui' then
                save.ui = not save.ui
            end
            if vars.current_name == 'reset' then
                self.ui:add()
                    vars.ui_anim_in:reset()
                    pd.timer.performAfterDelay(200, function()
                        vars.reset_warn_open = true
                    end)
                    vars.menu_scrollable = false
            end
        end
    end
    if vars.reset_warn_open == true then
        if pd.buttonIsPressed('a') then
            vars.reset_progress += 1
        end
        if pd.buttonJustReleased('a') then
            vars.reset_progress = 0
        end
        if vars.reset_progress >= vars.reset_max_progress then
            scenemanager:transitionsceneoneway(notif, "reset", "title")
            vars.reset_progress = 0
            vars.reset_warn_open = false
        end
        if pd.buttonJustPressed('b') then
            vars.ui_anim_out:reset()
            pd.timer.performAfterDelay(100, function()
                self.ui:remove()
                vars.menu_scrollable = true
                vars.reset_warn_open = false
            end)
        end
    end
end