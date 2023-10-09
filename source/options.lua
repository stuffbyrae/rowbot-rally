import 'title'
import 'cutscene'
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
            save.se = 3
            adjust_sfx_volume()
            self.slider:refresh()
            save.ui = false
            self.bg:button('ui', save.ui, 1)
            save.dp = false
            self.bg:button('dpad', save.dp, 1)
            save.sk = false
            self.bg:button('autoskip', save.sk, 1)
            save.pw = false
            self.bg:button('powerflip', save.pw, 1)
            savegame()
        end)
        menu:addMenuItem(gfx.getLocalizedText("backtotitle"), function()
            savegame()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        img_bg = gfx.image.new('images/options/bg'),
        gear_large = gfx.imagetable.new('images/options/gear_large/gear_large'),
        gear_small = gfx.imagetable.new('images/options/gear_small/gear_small'),
        gears = gfx.imagetable.new('images/options/gears'),
        img_music_slider = gfx.imagetable.new('images/options/music_slider'),
        img_sfx_slider = gfx.imagetable.new('images/options/sfx_slider'),
        img_sensitivity_slider = gfx.imagetable.new('images/options/sensitivity_slider'),
        img_arrow = gfx.image.new('images/ui/arrow'),
        img_button_ok = gfx.image.new('images/ui/button_ok'),
        img_button_back = gfx.image.new('images/ui/button_back'),
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
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        pedallica = gfx.font.new('fonts/pedallica'),
        music = pd.sound.fileplayer.new('audio/music/options'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
        sfx_locked = pd.sound.sampleplayer.new('audio/sfx/locked'),
        sfx_ui = pd.sound.sampleplayer.new('audio/sfx/ui'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
        sfx_menu = pd.sound.sampleplayer.new('audio/sfx/menu'),
        sfx_ping = pd.sound.sampleplayer.new('audio/sfx/ping'),
        sfx_clickon = pd.sound.sampleplayer.new('audio/sfx/clickon')
    }
    function adjust_sfx_volume()
        assets.sfx_bonk:setVolume(save.fx/5)
        assets.sfx_locked:setVolume(save.fx/5)
        assets.sfx_ui:setVolume(save.fx/5)
        assets.sfx_proceed:setVolume(save.fx/5)
        assets.sfx_whoosh:setVolume(save.fx/5)
        assets.sfx_menu:setVolume(save.fx/5)
        assets.sfx_ping:setVolume(save.fx/5)
        assets.sfx_clickon:setVolume(save.fx/5)
    end
    adjust_sfx_volume()
    assets.music:setVolume(save.mu/5)
    assets.music:setLoopRange(2.672)
    assets.music:play(0)
    
    vars = {
        gears_anim = gfx.animation.loop.new(25, assets.gears, true),
        options_menu = {'music', 'sfx', 'tutorial', 'cutscene', 'credits', 'access'},
        access_menu = {'sensitivity', 'ui', 'dpad', 'autoskip', 'powerflip'},
        scenes_menu = {},
        current_menu_item = 1,
        current_menu_name = 'music',
        last_menu_item = 1,
        currently_open_menu = "none", -- can be "none", "options", "access", or "scenes"
        selector_x = gfx.animator.new(1, 0, 0),
        selector_y = gfx.animator.new(1, 8, 8),
        slider_x = 60,
        slider_y = 2,
        anim_slider_x = gfx.animator.new(1, 0, 0)
    }
    for i = 1, save.mc do
        vars.scenes_menu[i] = tostring(i)
    end
    if vars.scenes_menu[10] == nil then
        table.insert(vars.scenes_menu, "more")
    end

    pd.timer.performAfterDelay(1001, function()
        vars.currently_open_menu = "options"
    end)

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setZIndex(-99)
        self:setCenter(0, 0)
        local img = gfx.image.new(800, 240)
        gfx.pushContext(img)
            assets.img_bg:draw(0, 0)
            assets.kapel_doubleup:drawText(gfx.getLocalizedText('music_name'), 8, 8)
            assets.kapel_doubleup:drawText(gfx.getLocalizedText('sfx_name'), 8, 35)
            if save.ss then
                assets.kapel_doubleup:drawText(gfx.getLocalizedText('replay_tutorial_name'), 8, 62)
            else
                assets.kapel_doubleup:drawText(gfx.getLocalizedText('locked_name'), 8, 62)
            end
            if save.mc >= 1 then
                assets.kapel_doubleup:drawText(gfx.getLocalizedText('replay_cutscene_name'), 8, 89)
            else
                assets.kapel_doubleup:drawText(gfx.getLocalizedText('locked_name'), 8, 89)
            end
            if save.cs then
                assets.kapel_doubleup:drawText(gfx.getLocalizedText('replay_credits_name'), 8, 116)
            else
                assets.kapel_doubleup:drawText(gfx.getLocalizedText('locked_name'), 8, 116)
            end
            assets.kapel_doubleup:drawText(gfx.getLocalizedText('access_name'), 8, 143)
            assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('sensitivity_name'), 792, 8, kTextAlignment.right)
            if save.ui then
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('ui_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 35, kTextAlignment.right)
            else
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('ui_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 35, kTextAlignment.right)
            end
            if save.dp then
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('dpad_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 62, kTextAlignment.right)
            else
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('dpad_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 62, kTextAlignment.right)
            end
            if save.sk then
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('autoskip_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 89, kTextAlignment.right)
            else
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('autoskip_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 89, kTextAlignment.right)
            end
            if save.pw then
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('powerflip_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 116, kTextAlignment.right)
            else
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('powerflip_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 116, kTextAlignment.right)
            end
        gfx.popContext()
        self:setImage(img)
        self:add()
    end
    function bg:update()
        if vars.bg_anim ~= nil then
            self:moveTo(vars.bg_anim:currentValue(), 0)
        end
    end
    function bg:button(item, on, stage)
        local img = self:getImage()
        gfx.pushContext(img)
            if stage == 1 then
                if on then
                    if item == 'ui' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('ui_name') .. ' ' .. gfx.getLocalizedText('switch_on'), 792, 35, kTextAlignment.right)
                    elseif item == 'dpad' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('dpad_name') .. ' ' .. gfx.getLocalizedText('switch_on'), 792, 62, kTextAlignment.right)
                    elseif item == 'autoskip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('autoskip_name') .. ' ' .. gfx.getLocalizedText('switch_on'), 792, 89, kTextAlignment.right)
                    elseif item == 'powerflip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('powerflip_name') .. ' ' .. gfx.getLocalizedText('switch_on'), 792, 116, kTextAlignment.right)
                    end
                else
                    if item == 'ui' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('ui_name') .. ' ' .. gfx.getLocalizedText('switch_off'), 792, 35, kTextAlignment.right)
                    elseif item == 'dpad' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('dpad_name') .. ' ' .. gfx.getLocalizedText('switch_off'), 792, 62, kTextAlignment.right)
                    elseif item == 'autoskip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('autoskip_name') .. ' ' .. gfx.getLocalizedText('switch_off'), 792, 89, kTextAlignment.right)
                    elseif item == 'powerflip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('powerflip_name') .. ' ' .. gfx.getLocalizedText('switch_off'), 792, 116, kTextAlignment.right)
                    end
                end
            elseif stage == 2 then
                if on then
                    if item == 'ui' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('ui_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 35, kTextAlignment.right)
                    elseif item == 'dpad' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('dpad_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 62, kTextAlignment.right)
                    elseif item == 'autoskip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('autoskip_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 89, kTextAlignment.right)
                    elseif item == 'powerflip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('powerflip_name') .. ' ' .. gfx.getLocalizedText('on'), 792, 116, kTextAlignment.right)
                    end
                else
                    if item == 'ui' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('ui_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 35, kTextAlignment.right)
                    elseif item == 'dpad' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('dpad_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 62, kTextAlignment.right)
                    elseif item == 'autoskip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('autoskip_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 89, kTextAlignment.right)
                    elseif item == 'powerflip' then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('powerflip_name') .. ' ' .. gfx.getLocalizedText('off'), 792, 116, kTextAlignment.right)
                    end
                end
            end
        gfx.popContext()
        self:setImage(img)
        pd.timer.performAfterDelay(50, function()
            if stage == 1 then
                self:button(item, on, 2)
            end
        end)
    end

    class('gears').extends(gfx.sprite)
    function gears:init()
        gears.super.init(self)
        self:moveTo(320, 80)
        self:add()
    end
    function gears:update()
        self:setImage(vars.gears_anim:image())
    end

    class('selector').extends(gfx.sprite)
    function selector:init()
        selector.super.init(self)
        self:setCenter(0, 0)
        local img = gfx.image.new(4, 25, gfx.kColorBlack)
        self:setImage(img)
        self:add()
    end
    function selector:update()
        self:moveTo(vars.selector_x:currentValue(), vars.selector_y:currentValue())
    end
    function selector:refresh()
        if vars.current_menu_name == 'music' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 8, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'sfx' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 35, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'tutorial' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 62, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'cutscene' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 89, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'credits' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 116, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'access' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 143, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'sensitivity' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 8, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'ui' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 35, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'dpad' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 62, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'autoskip' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 89, pd.easingFunctions.outBack)
        elseif vars.current_menu_name == 'powerflip' then
            vars.selector_y = gfx.animator.new(200, vars.selector_y:currentValue(), 116, pd.easingFunctions.outBack)
        end
    end

    class('desc_options').extends(gfx.sprite)
    function desc_options:init()
        desc_options.super.init(self)
        self:setCenter(0, 0)
        self:moveTo(195, 140)
        local img = gfx.image.new(200, 100)
        gfx.pushContext(img)
            assets.pedallica:drawText(gfx.getLocalizedText('music_desc'), 0, 0)
        gfx.popContext()
        self:setImage(img)
        self:add()
    end
    function desc_options:refresh()
        local img = gfx.image.new(200, 100)
        gfx.pushContext(img)
            if vars.current_menu_name == 'music' then
                assets.pedallica:drawText(gfx.getLocalizedText('music_desc'), 0, 0)
            elseif vars.current_menu_name == 'sfx' then
                assets.pedallica:drawText(gfx.getLocalizedText('sfx_desc'), 0, 0)
            elseif vars.current_menu_name == 'tutorial' then
                if demo then
                    assets.pedallica:drawText(gfx.getLocalizedText('demo_locked_desc'), 0, 0)
                elseif save.ss then
                    assets.pedallica:drawText(gfx.getLocalizedText('replay_tutorial_desc'), 0, 0)
                else
                    assets.pedallica:drawText(gfx.getLocalizedText('locked_desc'), 0, 0)
                end
            elseif vars.current_menu_name == 'cutscene' then
                if demo then
                    assets.pedallica:drawText(gfx.getLocalizedText('demo_locked_desc'), 0, 0)
                elseif save.mc >= 1 then
                    assets.pedallica:drawText(gfx.getLocalizedText('replay_cutscene_desc'), 0, 0)
                else
                    assets.pedallica:drawText(gfx.getLocalizedText('locked_desc'), 0, 0)
                end
            elseif vars.current_menu_name == 'credits' then
                if demo then
                    assets.pedallica:drawText(gfx.getLocalizedText('demo_locked_desc'), 0, 0)
                elseif save.cs then
                    assets.pedallica:drawText(gfx.getLocalizedText('replay_credits_desc'), 0, 0)
                else
                    assets.pedallica:drawText(gfx.getLocalizedText('locked_desc'), 0, 0)
                end
            elseif vars.current_menu_name == 'access' then
                assets.pedallica:drawText(gfx.getLocalizedText('access_desc'), 0, 0)
            end
        gfx.popContext()
        self:setImage(img)
    end

    class('desc_access').extends(gfx.sprite)
    function desc_access:init()
        desc_access.super.init(self)
        self:setCenter(0, 0)
        self:moveTo(15, 135)
        local img = gfx.image.new(200, 100)
        gfx.pushContext(img)
            assets.pedallica:drawText(gfx.getLocalizedText('ui_desc'), 0, 0)
        gfx.popContext()
        self:setImage(img)
        self:add()
    end
    function desc_access:refresh()
        local img = gfx.image.new(200, 100)
        gfx.pushContext(img)
            if vars.current_menu_name == 'ui' then
                assets.pedallica:drawText(gfx.getLocalizedText('ui_desc'), 0, 0)
            elseif vars.current_menu_name == 'dpad' then
                assets.pedallica:drawText(gfx.getLocalizedText('dpad_desc'), 0, 0)
            elseif vars.current_menu_name == 'autoskip' then
                assets.pedallica:drawText(gfx.getLocalizedText('autoskip_desc'), 0, 0)
            elseif vars.current_menu_name == 'sensitivity' then
                assets.pedallica:drawText(gfx.getLocalizedText('sensitivity_desc'), 0, 0)
            elseif vars.current_menu_name == 'powerflip' then
                assets.pedallica:drawText(gfx.getLocalizedText('powerflip_desc'), 0, 0)
            end
        gfx.popContext()
        self:setImage(img)
    end

    class('slider').extends(gfx.sprite)
    function slider:init()
        slider.super.init(self)
        self:setImage(assets.img_music_slider[6])
        self:setCenter(0, 0)
        self:moveTo(vars.slider_x, vars.slider_y)
        self:add()
    end
    function slider:refresh()
        if vars.current_menu_name == 'music' then
            vars.slider_x = 60
            vars.slider_y = 2
            self:setImage(assets.img_music_slider[save.mu+1])
            self:add()
        elseif vars.current_menu_name == 'sfx' then
            vars.slider_x = 60
            vars.slider_y = 2
            self:setImage(assets.img_sfx_slider[save.fx+1])
            self:add()
        elseif vars.current_menu_name == 'sensitivity' then
            vars.slider_x = 500
            vars.slider_y = 20
            self:setImage(assets.img_sensitivity_slider[save.se])
            self:add()
        else
            self:remove()
        end
        self:moveTo(vars.slider_x, vars.slider_y)
    end

    self.bg = bg()
    self.gears = gears()
    self.selector = selector()
    self.desc_options = desc_options()
    self.desc_access = desc_access()
    self.slider = slider()

    self:add()
end

function options:change(new)
    vars.current_menu_item = 1
    vars.last_menu_item = 1
    vars.currently_open_menu = "none"
    if new == "options" then
        vars.currently_open_menu = "options"
        vars.bg_anim = gfx.animator.new(500, self.bg.x, 0, pd.easingFunctions.outSine)
        vars.current_menu_name = 'music'
        vars.selector_x = gfx.animator.new(1, 0, 0)
        vars.selector_y = gfx.animator.new(1, 8, 8)
        self.desc_options:refresh()
        pd.timer.performAfterDelay(120, function()
            self.slider:refresh()
        end)
    elseif new == "access" then
        vars.currently_open_menu = "access"
        vars.bg_anim = gfx.animator.new(500, self.bg.x, -400, pd.easingFunctions.outSine)
        vars.current_menu_name = 'sensitivity'
        vars.selector_x = gfx.animator.new(1, 396, 396)
        vars.selector_y = gfx.animator.new(1, 8, 8)
        self.desc_access:refresh()
        self.slider:refresh()
    elseif new == "scenes" then
        vars.currently_open_menu = "scenes"
        vars.current_menu_name = '1'
    end
end

function options:update()
    self.desc_options:moveTo(self.bg.x+195, 140)
    self.desc_access:moveTo(self.bg.x+415, 135)
    self.slider:moveTo(vars.slider_x+vars.anim_slider_x:currentValue()+self.bg.x, vars.slider_y)
    self.gears:moveTo(320+self.bg.x, 80)
    if vars.currently_open_menu == "options" then
        if pd.buttonJustPressed('up') then
            if vars.current_menu_item > 1 then
                vars.current_menu_item -= 1
                vars.current_menu_name = vars.options_menu[vars.current_menu_item]
                self.desc_options:refresh()
                self.selector:refresh()
                self.slider:refresh()
            else
                shakiesy()
                assets.sfx_bonk:play()
            end
        end
        if pd.buttonJustPressed('down') then
            if vars.current_menu_item < #vars.options_menu then
                vars.current_menu_item += 1
                vars.current_menu_name = vars.options_menu[vars.current_menu_item]
                self.desc_options:refresh()
                self.selector:refresh()
                self.slider:refresh()
            else
                shakiesy()
                assets.sfx_bonk:play()
            end
        end
        if pd.buttonJustPressed('left') then
            if vars.current_menu_name == 'music' then
                if save.mu >= 1 then
                    save.mu -= 1
                    assets.music:setVolume(save.mu/5)
                    vars.anim_slider_x = gfx.animator.new(200, -7, 0, pd.easingFunctions.outSine)
                else
                    assets.sfx_bonk:play()
                    vars.anim_slider_x = gfx.animator.new(200, -3, 0, pd.easingFunctions.outBack)
                end
                self.slider:setImage(assets.img_music_slider[save.mu+1])
            end
            if vars.current_menu_name == 'sfx' then
                if save.fx >= 1 then
                    save.fx -= 1
                    adjust_sfx_volume()
                    assets.sfx_ping:play()
                    vars.anim_slider_x = gfx.animator.new(200, -7, 0, pd.easingFunctions.outSine)
                else
                    assets.sfx_bonk:play()
                    vars.anim_slider_x = gfx.animator.new(200, -3, 0, pd.easingFunctions.outBack)
                end
                self.slider:setImage(assets.img_sfx_slider[save.fx+1])
            end
        end
        if pd.buttonJustPressed('right') then
            if vars.current_menu_name == 'music' then
                if save.mu < 5 then
                    save.mu += 1
                    assets.music:setVolume(save.mu/5)
                    vars.anim_slider_x = gfx.animator.new(200, 7, 0, pd.easingFunctions.outSine)
                else
                    assets.sfx_bonk:play()
                    vars.anim_slider_x = gfx.animator.new(200, 3, 0, pd.easingFunctions.outBack)
                end
                self.slider:setImage(assets.img_music_slider[save.mu+1])
            end
            if vars.current_menu_name == 'sfx' then
                if save.fx < 5 then
                    save.fx += 1
                    adjust_sfx_volume()
                    assets.sfx_ping:play()
                    vars.anim_slider_x = gfx.animator.new(200, 7, 0, pd.easingFunctions.outSine)
                else
                    assets.sfx_bonk:play()
                    vars.anim_slider_x = gfx.animator.new(200, 3, 0, pd.easingFunctions.outBack)
                end
                self.slider:setImage(assets.img_sfx_slider[save.fx+1])
            end
        end
        if pd.buttonJustPressed('a') then
            if vars.current_menu_name == 'tutorial' then
                if save.ss then
                    savegame()
                    scenemanager:transitionsceneoneway(tutorial, "options")
                else
                    shakiesx()
                    assets.sfx_locked:play()
                end
            end
            if vars.current_menu_name == 'cutscene' then
                self:change("scenes")
            end
            if vars.current_menu_name == 'credits' then
                if save.cs then
                    savegame()
                    scenemanager:transitionsceneoneway(credits, "options")
                else
                    shakiesx()
                    assets.sfx_locked:play()
                end
            end
            if vars.current_menu_name == 'access' then
                self:change("access")
            end
            if vars.current_menu_name == 'reset' then
                self:change("reset")
            end
        end
        if pd.buttonJustPressed('b') then
            vars.currently_open_menu = "none"
            savegame()
            scenemanager:transitionsceneoneway(title, false)
        end
    elseif vars.currently_open_menu == "access" then
        if pd.buttonJustPressed('up') then
            if vars.current_menu_item > 1 then
                vars.current_menu_item -= 1
                vars.current_menu_name = vars.access_menu[vars.current_menu_item]
                self.desc_access:refresh()
                self.selector:refresh()
                self.slider:refresh()
            else
                shakiesy()
                assets.sfx_bonk:play()
            end
        end
        if pd.buttonJustPressed('down') then
            if vars.current_menu_item < #vars.access_menu then
                vars.current_menu_item += 1
                vars.current_menu_name = vars.access_menu[vars.current_menu_item]
                self.desc_access:refresh()
                self.selector:refresh()
                self.slider:refresh()
            else
                shakiesy()
                assets.sfx_bonk:play()
            end
        end
        if pd.buttonJustPressed('left') then
            if vars.current_menu_name == 'sensitivity' then
                if save.se > 1 then
                    save.se -= 1
                    vars.anim_slider_x = gfx.animator.new(200, -7, 0, pd.easingFunctions.outSine)
                else
                    assets.sfx_bonk:play()
                    vars.anim_slider_x = gfx.animator.new(200, -3, 0, pd.easingFunctions.outBack)
                end
                self.slider:setImage(assets.img_sensitivity_slider[save.se])
            end
        end
        if pd.buttonJustPressed('right') then
            if vars.current_menu_name == 'sensitivity' then
                if save.se < 5 then
                    save.se += 1
                    vars.anim_slider_x = gfx.animator.new(200, 7, 0, pd.easingFunctions.outSine)
                else
                    assets.sfx_bonk:play()
                    vars.anim_slider_x = gfx.animator.new(200, 3, 0, pd.easingFunctions.outBack)
                end
                self.slider:setImage(assets.img_sensitivity_slider[save.se])
            end
        end
        if pd.buttonJustPressed('a') then
            if vars.current_menu_name == 'ui' then
                save.ui = not save.ui
                self.bg:button(vars.current_menu_name, save.ui, 1)
                assets.sfx_clickon:play()
            end
            if vars.current_menu_name == 'dpad' then
                save.dp = not save.dp
                self.bg:button(vars.current_menu_name, save.dp, 1)
                assets.sfx_clickon:play()
            end
            if vars.current_menu_name == 'autoskip' then
                save.sk = not save.sk
                self.bg:button(vars.current_menu_name, save.sk, 1)
                assets.sfx_clickon:play()
            end
            if vars.current_menu_name == 'powerflip' then
                save.pw = not save.pw
                self.bg:button(vars.current_menu_name, save.pw, 1)
                assets.sfx_clickon:play()
            end
        end
        if pd.buttonJustPressed('b') then
            self:change("options")
        end
    elseif vars.currently_open_menu == "scenes" then
        if pd.buttonJustPressed('left') then
            if vars.current_menu_item > 1 then
                vars.current_menu_item -= 1
                vars.current_menu_name = vars.scenes_menu[vars.current_menu_item]
            else
            end
        end
        if pd.buttonJustPressed('right') then
            if vars.current_menu_item < #vars.scenes_menu then
                vars.current_menu_item += 1
                vars.current_menu_name = vars.scenes_menu[vars.current_menu_item]
            else
            end
        end
        if pd.buttonJustPressed('a') then
            if vars.current_menu_name ~= "more" then
                vars.currently_open_menu = "none"
                savegame()
                scenemanager:transitionsceneoneway(cutscene, vars.current_menu_item, "options")
            end
        end
        if pd.buttonJustPressed('b') then
            self:change("options")
        end
    end
end