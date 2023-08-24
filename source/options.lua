import 'title'
import 'credits'
import 'notif'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('options').extends(gfx.sprite)

function options:init()
    options.super.init(self)
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 0
        pd.setMenuImage(img, xoffset)
        menu:addMenuItem(gfx.getLocalizedText("setdefaults"), function()
            save.mu = 5
            save.fx = 5
            save.ui = false
            assets.music:setVolume(save.mu/5)
            adjust_sfx_volume()
            if vars.current_name == "music" then
                self.volume:setImage(assets.img_music_slider[save.mu+1])
            elseif vars.current_name == "sfx" then
                self.volume:setImage(assets.img_sfx_slider[save.fx+1])
            end
            vars.selector_pos_y = gfx.animator.new(1, vars.selector_pos_y:currentValue(), vars.selector_pos_y:currentValue(), pd.easingFunctions.outBack)
        end)
        menu:addMenuItem(gfx.getLocalizedText("backtotitle"), function()
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
        img_arrow = gfx.image.new('images/ui/arrow'),
        img_button_ok = gfx.image.new('images/ui/button_ok'),
        img_button_back = gfx.image.new('images/ui/button_back'),
        img_button_reset = gfx.image.new('images/ui/button_reset'),
        img_button_reset_pressed = gfx.image.new('images/ui/button_reset_pressed'),
        img_button_blanky = gfx.image.new('images/ui/button_blanky'),
        img_scenepicker = gfx.image.new('images/options/scenepicker'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        img_1 = gfx.image.new('images/options/scenepicker/1'),
        img_2 = gfx.image.new('images/options/scenepicker/2'),
        img_3 = gfx.image.new('images/options/scenepicker/3'),
        img_4 = gfx.image.new('images/options/scenepicker/4'),
        img_5 = gfx.image.new('images/options/scenepicker/5'),
        img_6 = gfx.image.new('images/options/scenepicker/6'),
        img_7 = gfx.image.new('images/options/scenepicker/7'),
        img_8 = gfx.image.new('images/options/scenepicker/8'),
        img_9 = gfx.image.new('images/options/scenepicker/9'),
        img_10 = gfx.image.new('images/options/scenepicker/10'),
        img_more = gfx.image.new('images/options/scenepicker/more'),
        img_qr1 = gfx.image.new('images/options/scenepicker/qr1'),
        img_qr2 = gfx.image.new('images/options/scenepicker/qr2'),
        img_qr3 = gfx.image.new('images/options/scenepicker/qr3'),
        img_qr4 = gfx.image.new('images/options/scenepicker/qr4'),
        img_qr5 = gfx.image.new('images/options/scenepicker/qr5'),
        img_qr6 = gfx.image.new('images/options/scenepicker/qr6'),
        img_qr7 = gfx.image.new('images/options/scenepicker/qr7'),
        img_qr8 = gfx.image.new('images/options/scenepicker/qr8'),
        img_qr9 = gfx.image.new('images/options/scenepicker/qr9'),
        img_qr10 = gfx.image.new('images/options/scenepicker/qr10'),
        kapel = gfx.font.new('fonts/kapel_doubleup'),
        pedallica = gfx.font.new('fonts/pedallica'),
        music = pd.sound.fileplayer.new('audio/music/options'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
        sfx_locked = pd.sound.sampleplayer.new('audio/sfx/locked'),
        sfx_ui = pd.sound.sampleplayer.new('audio/sfx/ui'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
        sfx_menu = pd.sound.sampleplayer.new('audio/sfx/menu'),
        sfx_ping = pd.sound.sampleplayer.new('audio/sfx/ping'),
        sfx_clickon = pd.sound.sampleplayer.new('audio/sfx/clickon'),
        sfx_clickoff = pd.sound.sampleplayer.new('audio/sfx/clickoff'),
        sfx_build = pd.sound.sampleplayer.new('audio/sfx/build'),
        sfx_cancel = pd.sound.sampleplayer.new('audio/sfx/cancel'),
        sfx_cancelsmall = pd.sound.sampleplayer.new('audio/sfx/cancelsmall')
    }
    function adjust_sfx_volume()
        assets.sfx_bonk:setVolume(save.fx/5)
        assets.sfx_locked:setVolume(save.fx/5)
        assets.sfx_ui:setVolume(save.fx/5)
        assets.sfx_proceed:setVolume(save.fx/5)
        assets.sfx_whoosh:setVolume(save.fx/5)
        assets.sfx_menu:setVolume(save.fx/5)
        assets.sfx_ping:setVolume(save.fx/5)
        if not demo then
            assets.sfx_clickon:setVolume(save.fx/5)
            assets.sfx_clickoff:setVolume(save.fx/5)
            assets.sfx_build:setVolume(save.fx/5)
            assets.sfx_cancel:setVolume(save.fx/5)
            assets.sfx_cancelsmall:setVolume(save.fx/5)
        end
    end
    adjust_sfx_volume()
    assets.music:setVolume(save.mu/5)
    assets.music:setLoopRange(2.672)
    assets.music:play(0)
    
    gfx.setFont(assets.pedallica)
    assets.text_img = gfx.imageWithText(gfx.getLocalizedText("music_desc"), 200, 75)
    vars = {
        gear_large_anim = gfx.animation.loop.new(25, assets.gear_large, true),
        gear_small_anim = gfx.animation.loop.new(25, assets.gear_small, true),
        menu_scrollable = false,
        reset_warn_open = false,
        scenepicker_open = false,
        reset_progress = 0,
        reset_max_progress = 168,
        ui_anim_in = gfx.animator.new(250, 250, 120, pd.easingFunctions.outBack),
        ui_anim_out = gfx.animator.new(100, 120, 500, pd.easingFunctions.inSine),
        slider_anim = gfx.animator.new(1, 60, 60),
        slider_scale_anim = gfx.animator.new(200, 0, 1, pd.easingFunctions.outBack),
        slider_rotate_anim = gfx.animator.new(1, 0, 0, pd.easingFunctions.outBack),
        scenepicker_fade_anim = gfx.animator.new(250, 33, 16),
        scenepicker_anim = gfx.animator.new(500, 400, 0, pd.easingFunctions.outBack),
        selector_pos_y = gfx.animator.new(1, 8, 8),
        selector_width = gfx.animator.new(1, 72, 72),
        menu_list = {'music', 'sfx', 'replay_tutorial', 'replay_cutscene', 'replay_credits', 'ui', 'reset'},
        current_menu_item = 1,
        last_menu_item = 1,
        scenepicker_list = {'1'},
        current_scenepicker_item = 1,
        last_scenepicker_item = 1,
        posneg_anim = gfx.animator.new(0.9, 1, -1)
    }
    if save.mc >= 2 then table.insert(vars.scenepicker_list, '2') end
    if save.mc >= 3 then table.insert(vars.scenepicker_list, '3') end
    if save.mc >= 4 then table.insert(vars.scenepicker_list, '4') end
    if save.mc >= 5 then table.insert(vars.scenepicker_list, '5') end
    if save.mc >= 6 then table.insert(vars.scenepicker_list, '6') end
    if save.mc >= 7 then table.insert(vars.scenepicker_list, '7') end
    if save.mc >= 8 then table.insert(vars.scenepicker_list, '8') end
    if save.mc >= 9 then table.insert(vars.scenepicker_list, '9') end
    if save.mc >= 10 then table.insert(vars.scenepicker_list, '10') else table.insert(vars.scenepicker_list, 'more') end

    pd.timer.performAfterDelay(1001, function()
        vars.menu_scrollable = true
    end)

    vars.current_name = vars.menu_list[vars.current_menu_item]
    vars.scenepicker_name = vars.scenepicker_list[vars.current_scenepicker_item]

    vars.posneg_anim.repeatCount = -1
    
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
        if vars.reset_warn_open == false and vars.scenepicker_open == false then
            local image = gfx.image.new(135, 50)
            gfx.pushContext(image)
                vars.gear_small_anim:draw(-13, 10)
                vars.gear_large_anim:draw(25, -20, gfx.kImageFlippedX)
            gfx.popContext()
            self:setImage(image:fadedImage(0.25, gfx.image.kDitherTypeBayer8x8))
        end
    end
    
    class('selector').extends(gfx.sprite)
    function selector:init()
        selector.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(1)
        self:add()
    end
    function selector:update()
        if vars.selector_pos_y:ended() == false then
            local img = gfx.image.new(200, 240)
            gfx.pushContext(img)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRoundRect(3, vars.selector_pos_y:currentValue(), vars.selector_width:currentValue(), 25, 5)
            gfx.setColor(gfx.kColorBlack)
            gfx.setFont(assets.kapel)
            gfx.drawText(gfx.getLocalizedText("music_name"), 8, 10)
            gfx.drawText(gfx.getLocalizedText("sfx_name"), 8, 32)
            if save.ss then
                gfx.drawText(gfx.getLocalizedText("replay_tutorial_name"), 8, 67)
            else
                gfx.drawText(gfx.getLocalizedText("locked_name"), 8, 67)
            end
            if save.mc >= 1 then
                gfx.drawText(gfx.getLocalizedText("replay_cutscene_name"), 8, 89)
            else
                gfx.drawText(gfx.getLocalizedText("locked_name"), 8, 89)
            end
            if save.cs then
                gfx.drawText(gfx.getLocalizedText("replay_credits_name"), 8, 111)
            else
                gfx.drawText(gfx.getLocalizedText("locked_name"), 8, 111)
            end
            if save.ui then
                gfx.drawText(gfx.getLocalizedText("ui_on_name"), 8, 146)
            else
                gfx.drawText(gfx.getLocalizedText("ui_off_name"), 8, 146)
            end
            gfx.drawText(gfx.getLocalizedText("reset_name"), 8, 201)
            gfx.setColor(gfx.kColorXOR)
            gfx.fillRoundRect(3, vars.selector_pos_y:currentValue(), vars.selector_width:currentValue(), 25, 5)
            gfx.popContext()
            self:setImage(img)
        end
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
        self:moveTo(60, 45)
        self:add()
    end
    function volume:update()
        self:setScale(vars.slider_scale_anim:currentValue())
        self:moveTo(vars.slider_anim:currentValue(), 40)
        self:setRotation(vars.slider_rotate_anim:currentValue())
    end

    class('scenepicker').extends(gfx.sprite)
    function scenepicker:init()
        scenepicker.super.init(self)
        self:setZIndex(98)
        self:setCenter(0, 0)
    end
    function scenepicker:update()
        if vars.scenepicker_anim:ended() == false or pd.buttonJustPressed('left') or pd.buttonJustPressed('right') then
            local img = gfx.image.new(400, 240)
            gfx.pushContext(img)
            assets.img_fade[math.floor(vars.scenepicker_fade_anim:currentValue())]:drawTiled(0, 0, 400, 240)
                assets.img_scenepicker:draw(0, 0+vars.scenepicker_anim:currentValue())
                assets.img_button_back:draw(285, 195+vars.scenepicker_anim:currentValue())
                if vars.scenepicker_name == 'more' then
                    assets.img_button_ok:drawFaded(57, 185+vars.scenepicker_anim:currentValue(), 0.5, gfx.image.kDitherTypeDiagonalLine)
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscenex_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_more:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscenex_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                else
                    assets.img_button_ok:draw(57, 185+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutsceneqr"), 334, 120+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                end
                if vars.scenepicker_name == '1' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene1_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene1_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '2' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene2_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene2_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '3' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene3_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene3_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '4' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene4_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene4_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '5' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene5_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene5_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '6' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene6_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene6_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '7' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene7_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene7_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '8' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene8_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene8_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '9' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene9_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene9_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                elseif vars.scenepicker_name == '10' then
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("cutscene10_name"), 142, 40+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_1:draw(50, 70+vars.scenepicker_anim:currentValue())
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText("cutscene10_desc"), 142, 145+vars.scenepicker_anim:currentValue(), kTextAlignment.center)
                    assets.img_qr1:draw(297, 30+vars.scenepicker_anim:currentValue())
                end
            gfx.popContext()
            self:setImage(img)
        end
    end
    
    class('ui').extends(gfx.sprite)
    function ui:init()
        ui.super.init(self)
        self:moveTo(200, 400)
        self:setZIndex(99)
    end
    function ui:update()
        if pd.buttonIsPressed('a') or pd.buttonJustReleased('a') then
        local img = gfx.image.new(400, 240)
            gfx.pushContext(img)
                assets.img_reset_warn:draw(0, 0)
                if vars.reset_progress > 0 then
                    assets.img_button_reset_pressed:draw(116, 170+vars.reset_progress/30)
                    gfx.setColor(gfx.kColorXOR)
                    gfx.fillRoundRect(76, 170+vars.reset_progress/30, vars.reset_progress+40, 46, 18)
                    assets.img_button_blanky:draw(76, 170+vars.reset_progress/30)
                else
                    assets.img_button_reset:draw(116, 165)
                end
            gfx.popContext()
            self:setImage(img)
        end
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
    self.scenepicker = scenepicker()
    self.ui = ui()
    
    self:add()
end

function options:change_sel(dir)
    if vars.last_menu_item == vars.current_menu_item then
        shakiesy()
        assets.sfx_bonk:play()
        if dir then
            vars.selector_pos_y = gfx.animator.new(200, 4, 8, pd.easingFunctions.outBack)
            vars.slider_rotate_anim = gfx.animator.new(250, 5, 0, pd.easingFunctions.outBack)
        else
            vars.selector_pos_y = gfx.animator.new(200, 205, 201, pd.easingFunctions.outBack)
        end
        return
    end
    assets.sfx_menu:play()
    if vars.current_name == 'music' then
        assets.text_img = gfx.imageWithText(gfx.getLocalizedText("music_desc"), 200, 75)
        self.volume:setImage(assets.img_music_slider[save.mu+1])
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 8, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 72, pd.easingFunctions.outBack)
    end
    if vars.current_name == 'sfx' then
        if dir then
            vars.slider_scale_anim = gfx.animator.new(200, 0, 1, pd.easingFunctions.outBack)
        end
        assets.text_img = gfx.imageWithText(gfx.getLocalizedText("sfx_desc"), 200, 75)
        self.volume:setImage(assets.img_sfx_slider[save.fx+1])
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 32, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 53, pd.easingFunctions.outBack)
    end
    if vars.current_name == 'replay_tutorial' then
        if dir == false then
            vars.slider_scale_anim = gfx.animator.new(200, 1, 0, pd.easingFunctions.inBack)
        end
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 67, pd.easingFunctions.outBack)
        if save.ss then
            assets.text_img = gfx.imageWithText(gfx.getLocalizedText("replay_tutorial_desc"), 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 163, pd.easingFunctions.outBack)
        else
            assets.text_img = gfx.imageWithText(gfx.getLocalizedText("locked_desc"), 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 42, pd.easingFunctions.outBack)
        end
    end
    if vars.current_name == 'replay_cutscene' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 89, pd.easingFunctions.outBack)
        if save.mc >= 1 then
            assets.text_img = gfx.imageWithText(gfx.getLocalizedText("replay_cutscene_desc"), 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 192, pd.easingFunctions.outBack)
        else
            assets.text_img = gfx.imageWithText(gfx.getLocalizedText("locked_desc"), 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 42, pd.easingFunctions.outBack)
        end
    end
    if vars.current_name == 'replay_credits' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 111, pd.easingFunctions.outBack)
        if save.cs then
            assets.text_img = gfx.imageWithText(gfx.getLocalizedText("replay_credits_desc"), 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 152, pd.easingFunctions.outBack)
        else
            assets.text_img = gfx.imageWithText(gfx.getLocalizedText("locked_desc"), 200, 75)
            vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 42, pd.easingFunctions.outBack)
        end
    end
    if vars.current_name == 'ui' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 146, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 83, pd.easingFunctions.outBack)
        assets.text_img = gfx.imageWithText(gfx.getLocalizedText("ui_desc"), 200, 75)
    end
    if vars.current_name == 'reset' then
        vars.selector_pos_y = gfx.animator.new(200, vars.selector_pos_y:currentValue(), 201, pd.easingFunctions.outBack)
        vars.selector_width = gfx.animator.new(200, vars.selector_width:currentValue(), 140, pd.easingFunctions.outBack)
        assets.text_img = gfx.imageWithText(gfx.getLocalizedText("reset_desc"), 200, 75)
    end
    self.text:setImage(assets.text_img)
    vars.last_menu_item = vars.current_menu_item
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
            self:change_sel(true)
        end
        if pd.buttonJustPressed('down') then
            vars.current_menu_item = math.clamp(vars.current_menu_item + 1, 1, #vars.menu_list)
            vars.current_name = vars.menu_list[vars.current_menu_item]
            self:change_sel(false)
        end
        if pd.buttonJustPressed('left') then
            if vars.current_name == 'music' then
                if save.mu > 0 then
                    save.mu -= 1
                    assets.music:setVolume(save.mu/5)
                    vars.slider_anim = gfx.animator.new(100, 55, 60)
                    self.volume:setImage(assets.img_music_slider[save.mu+1])
                else
                    vars.slider_anim = gfx.animator.new(100, 58, 60)
                    assets.sfx_bonk:play()
                end
            end
            if vars.current_name == 'sfx' then
                if save.fx > 0 then
                    save.fx -= 1
                    self.volume:setImage(assets.img_sfx_slider[save.fx+1])
                    vars.slider_anim = gfx.animator.new(100, 55, 60)
                    adjust_sfx_volume()
                    assets.sfx_ping:play()
                else
                    vars.slider_anim = gfx.animator.new(100, 58, 60)
                    assets.sfx_bonk:play()
                end
            end
        end
        if pd.buttonJustPressed('right') then
            if vars.current_name == 'music' then
                if save.mu < 5 then
                    save.mu += 1
                    assets.music:setVolume(save.mu/5)
                    vars.slider_anim = gfx.animator.new(100, 65, 60)
                    self.volume:setImage(assets.img_music_slider[save.mu+1])
                else
                    vars.slider_anim = gfx.animator.new(100, 62, 60)
                    assets.sfx_bonk:play()
                end
            end
            if vars.current_name == 'sfx' then
                if save.fx < 5 then
                    save.fx += 1
                    self.volume:setImage(assets.img_sfx_slider[save.fx+1])
                    vars.slider_anim = gfx.animator.new(100, 65, 60)
                    adjust_sfx_volume()
                    assets.sfx_ping:play()
                else
                    vars.slider_anim = gfx.animator.new(100, 62, 60)
                    assets.sfx_bonk:play()
                end
            end
        end
        if pd.buttonJustPressed('a') then
            if vars.current_name == 'music' or vars.current_name == 'sfx' then
                assets.sfx_bonk:play()
            end
            if vars.current_name == 'replay_tutorial' then
                if save.ss then
                    scenemanager:transitionsceneoneway(tutorial, "options")
                else
                    assets.sfx_locked:play()
                    shakiesx()
                end
            end
            if vars.current_name == 'replay_cutscene' then
                if save.mc >= 1 then
                    assets.sfx_ui:play()
                    vars.scenepicker_fade_anim = gfx.animator.new(150, 33, 16)
                    vars.scenepicker_anim = gfx.animator.new(250, 400, 0, pd.easingFunctions.outBack)
                    self.scenepicker:add()
                    pd.timer.performAfterDelay(250, function()
                        vars.scenepicker_open = true
                    end)
                    vars.menu_scrollable = false
                else
                    assets.sfx_locked:play()
                    shakiesx()
                end
            end
            if vars.current_name == 'replay_credits' then
                if save.cs then
                    scenemanager:transitionsceneoneway(credits, "options")
                else
                    assets.sfx_locked:play()
                    shakiesx()
                end
            end
            if vars.current_name == 'ui' then
                save.ui = not save.ui
                assets.sfx_proceed:play()
                vars.selector_pos_y = gfx.animator.new(1, 146, 146, pd.easingFunctions.outBack)
            end
            if vars.current_name == 'reset' then
                if not demo then
                    self.ui:add()
                    vars.ui_anim_in:reset()
                    assets.sfx_ui:play()
                    pd.timer.performAfterDelay(200, function()
                        vars.reset_warn_open = true
                    end)
                    vars.menu_scrollable = false
                else
                    shakiesx()
                    assets.sfx_bonk:play()
                end
            end
        end
    end
    if vars.scenepicker_open == true then
        if pd.buttonJustPressed('left') then
            vars.current_scenepicker_item = math.clamp(vars.current_scenepicker_item - 1, 1, #vars.scenepicker_list)
            vars.scenepicker_name = vars.scenepicker_list[vars.current_scenepicker_item]
            if vars.last_scenepicker_item == vars.current_scenepicker_item then
                assets.sfx_bonk:play()
                shakiesx()
            else
                assets.sfx_menu:play()
            end
            vars.last_scenepicker_item = vars.current_scenepicker_item
        end
        if pd.buttonJustPressed('right') then
            vars.current_scenepicker_item = math.clamp(vars.current_scenepicker_item + 1, 1, #vars.scenepicker_list)
            vars.scenepicker_name = vars.scenepicker_list[vars.current_scenepicker_item]
            if vars.last_scenepicker_item == vars.current_scenepicker_item then
                assets.sfx_bonk:play()
                shakiesx()
            else
                assets.sfx_menu:play()
            end
            vars.last_scenepicker_item = vars.current_scenepicker_item
        end
        if pd.buttonJustPressed('a') then
            if vars.scenepicker_name ~= 'more' then
                assets.sfx_proceed:play()
                scenemanager:transitionsceneoneway(cutscene, vars.current_scenepicker_item, "options")
            else
                assets.sfx_bonk:play()
            end
        end
        if pd.buttonJustPressed('b') then
            assets.sfx_whoosh:play()
            vars.scenepicker_fade_anim = gfx.animator.new(150, 16, 33)
            vars.scenepicker_anim = gfx.animator.new(500, 0, 400, pd.easingFunctions.outBack)
            pd.timer.performAfterDelay(150, function()
            self.scenepicker:remove()
            vars.scenepicker_open = false
            vars.menu_scrollable = true
            end)
        end
    end
    if vars.reset_warn_open == true then
        if pd.buttonJustPressed('a') then
            assets.sfx_clickon:play()
            assets.sfx_build:play()
        end
        if pd.buttonIsPressed('a') then
            vars.reset_progress += 1.35
            if pd.getReduceFlashing() then
                return
            else
                gfx.setDrawOffset(vars.reset_progress/25*vars.posneg_anim:currentValue(), vars.reset_progress/25*vars.posneg_anim:currentValue())
            end
        end
        if pd.buttonJustReleased('a') then
            if vars.reset_progress > 90 then
                assets.sfx_cancel:play()
            else
                assets.sfx_cancelsmall:play()
            end
            pd.display.setOffset(0, 0)
            vars.reset_progress = 0
            assets.sfx_clickoff:play()
            assets.sfx_build:stop()
        end
        if vars.reset_progress >= vars.reset_max_progress then
            scenemanager:transitionsceneoneway(notif, "reset", "opening")
            vars.reset_progress = 0
            vars.reset_warn_open = false
        end
        if pd.buttonJustPressed('b') then
            vars.ui_anim_out:reset()
            assets.sfx_whoosh:play()
            pd.timer.performAfterDelay(100, function()
                self.ui:remove()
                vars.menu_scrollable = true
                vars.reset_warn_open = false
            end)
        end
    end
end