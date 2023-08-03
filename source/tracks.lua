local pd <const> = playdate
local gfx <const> = pd.graphics

class('tracks').extends(gfx.sprite)
function tracks:init(...)
    tracks.super.init(self)
    local args = {...}
    show_crank = false
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("change boat", function()
            scenemanager:transitionsceneblastdoors(garage)
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        img_bg = gfx.image.new('images/tracks/bg'),
        img_timer = gfx.image.new('images/race/timer'),
        img_prompt = gfx.imagetable.new('images/intro/prompt_icons'),
        img_boat = gfx.imagetable.new('images/tracks/boat'),
        img_button_ok = gfx.image.new('images/ui/button_ok'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        img_wave = gfx.image.new('images/tracks/wave'),
        img_stage = gfx.imagetable.new('images/tracks/stage'),
        kapel = gfx.font.new('fonts/kapel'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        pedallica = gfx.font.new('fonts/pedallica'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
        sfx_locked = pd.sound.sampleplayer.new('audio/sfx/locked'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
        music = pd.sound.fileplayer.new('audio/music/tracks')
    }
    assets.sfx_bonk:setVolume(save.fx/5)
    assets.sfx_locked:setVolume(save.fx/5)
    assets.sfx_proceed:setVolume(save.fx/5)
    assets.sfx_whoosh:setVolume(save.fx/5)
    assets.music:setVolume(save.mu/5)
    assets.music:play(0)
    
    vars = {
        arg_boat = args[1], -- 1 through 7
        menu_list = {1, 2, 3, 4, 5, 6, 7},
        current_menu_item = 1,
        stage_transitioning = false,
        boat_x_anim = gfx.animator.new(1000, -150, 100, pd.easingFunctions.outSine),
        boat_y_anim = gfx.animator.new(2000, 0, 10, pd.easingFunctions.inOutQuad),
        wave_anim = gfx.animator.new(1000, 0, -50)
    }
    
    vars.besttime = save.t1
    vars.boat_y_anim.reverses = true
    vars.boat_y_anim.repeatCount = -1
    vars.wave_anim.repeatCount = -1

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.img_bg:draw(0, 0)
    end)
    
    class('stage').extends(gfx.sprite)
    function stage:init()
        stage.super.init(self)
        self:setZIndex(1)
        self:moveTo(285, 218)
        self:setCenter(0.5, 1)
        self:setImage(assets.img_stage[1])
        self:add()
    end
    function stage:update()
        if vars.stage_x_anim then
            self:moveTo(vars.stage_x_anim:currentValue(), 218)
        end
    end
    
    class('stage_info').extends(gfx.sprite)
    function stage_info:init()
        stage_info.super.init(self)
        self:setZIndex(4)
        local img = gfx.image.new(400, 240)
        local mins = string.format("%02.f", math.floor((vars.besttime/30) / 60))
        local secs = string.format("%02.f", math.floor((vars.besttime/30) - mins * 60))
        local mils = string.format("%02.f", (vars.besttime/30)*99 - mins * 5940 - secs * 99)
        gfx.pushContext(img)
            assets.img_prompt:drawImage(1, -13, -1)
            assets.kapel:drawText(gfx.getLocalizedText("stage1_num"), 57, 3)
            assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage1_name"), 53, 12)
            assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage1_vs"), 49, 35)
            assets.pedallica:drawText(gfx.getLocalizedText("stage1_desc"), 10, 60)
            assets.kapel:drawTextAligned(gfx.getLocalizedText("besttime"), 365, 5, kTextAlignment.right)
            assets.img_button_ok:draw(205, 180)
            assets.img_timer:draw(279, 7, gfx.kImageFlippedX)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            assets.times_new_rally:drawTextAligned(mins..":"..secs.."."..mils, 356, 23, kTextAlignment.right)
        gfx.popContext()
        self:moveTo(200, 120)
        self:setImage(img)
        local img = nil
        self:add()
    end

    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setZIndex(2)
        self:setImage(assets.img_boat[vars.arg_boat])
        self:add()
    end
    function boat:update()
        self:moveTo(vars.boat_x_anim:currentValue(), 170+vars.boat_y_anim:currentValue())
    end

    class('wave').extends(gfx.sprite)
    function wave:init()
        wave.super.init(self)
        self:setZIndex(3)
        local img = gfx.image.new(500, 31)
        gfx.pushContext(img)
            assets.img_wave:drawTiled(0, 0, 500, 31)
        gfx.popContext()
        self:setImage(img)
        local img = nil
        self:setCenter(0, 1)
        self:moveTo(0, 240)
        self:add()
    end
    function wave:update()
        self:moveTo(math.floor(vars.wave_anim:currentValue() / 2) * 4, 240)
    end

    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:moveTo(200, 120)
        self:setZIndex(9)
    end
    function fade:update()
        self:setImage(assets.img_fade[math.floor(vars.fade_anim:currentValue())]:invertedImage())
    end

    self.stage = stage()
    self.stage_info = stage_info()
    self.boat = boat()
    self.wave = wave()
    self.fade = fade()

    self:add()
end

function tracks:changetrack(dir)
    vars.stage_transitioning = true
    if dir then
        vars.stage_x_anim = gfx.animator.new(200, 285, 550, pd.easingFunctions.inSine)
    else
        vars.stage_x_anim = gfx.animator.new(200, 285, -150, pd.easingFunctions.inSine)
    end
    pd.timer.performAfterDelay(200, function()
        assets.sfx_whoosh:play()
        if dir then
            vars.stage_x_anim = gfx.animator.new(300, -150, 285, pd.easingFunctions.outSine)
        else
            vars.stage_x_anim = gfx.animator.new(300, 550, 285, pd.easingFunctions.outSine)
        end
        local img = gfx.image.new(400, 240)
        gfx.pushContext(img)
            if vars.current_menu_item <= save.mt then
                assets.img_prompt:drawImage(vars.current_menu_item, -13, -1)
                if vars.current_menu_item == 1 then
                    vars.besttime = save.t1
                    assets.kapel:drawText(gfx.getLocalizedText("stage1_num"), 57, 3)
                    assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage1_name"), 53, 12)
                    assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage1_vs"), 49, 35)
                    assets.pedallica:drawText(gfx.getLocalizedText("stage1_desc"), 10, 60)    
                elseif vars.current_menu_item == 2 then
                    vars.besttime = save.t2
                    assets.kapel:drawText(gfx.getLocalizedText("stage2_num"), 57, 3)
                    assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage2_name"), 53, 12)
                    assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage2_vs"), 49, 35)
                    assets.pedallica:drawText(gfx.getLocalizedText("stage2_desc"), 10, 60)
                elseif vars.current_menu_item == 3 then
                    vars.besttime = save.t3
                    assets.kapel:drawText(gfx.getLocalizedText("stage3_num"), 57, 3)
                    assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage3_name"), 53, 12)
                    assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage3_vs"), 49, 35)
                    assets.pedallica:drawText(gfx.getLocalizedText("stage3_desc"), 10, 60)
                elseif vars.current_menu_item == 4 then
                    vars.besttime = save.t4
                    assets.kapel:drawText(gfx.getLocalizedText("stage4_num"), 57, 3)
                    assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage4_name"), 53, 12)
                    assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage4_vs"), 49, 35)
                    assets.pedallica:drawText(gfx.getLocalizedText("stage4_desc"), 10, 60)
                elseif vars.current_menu_item == 5 then
                    vars.besttime = save.t5
                    assets.kapel:drawText(gfx.getLocalizedText("stage5_num"), 57, 3)
                    assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage5_name"), 53, 12)
                    assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage5_vs"), 49, 35)
                    assets.pedallica:drawText(gfx.getLocalizedText("stage5_desc"), 10, 60)
                elseif vars.current_menu_item == 6 then
                    vars.besttime = save.t6
                    assets.kapel:drawText(gfx.getLocalizedText("stage6_num"), 57, 3)
                    assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage6_name"), 53, 12)
                    assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage6_vs"), 49, 35)
                    assets.pedallica:drawText(gfx.getLocalizedText("stage6_desc"), 10, 60)
                elseif vars.current_menu_item == 7 then
                    vars.besttime = save.t7
                    assets.kapel:drawText(gfx.getLocalizedText("stage7_num"), 57, 3)
                    assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage7_name"), 53, 12)
                    assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage7_vs"), 49, 35)
                    assets.pedallica:drawText(gfx.getLocalizedText("stage7_desc"), 10, 60)
                end
                assets.img_button_ok:draw(205, 180)
                assets.img_timer:draw(279, 7, gfx.kImageFlippedX)
                local mins = string.format("%02.f", math.floor((vars.besttime/30) / 60))
                local secs = string.format("%02.f", math.floor((vars.besttime/30) - mins * 60))
                local mils = string.format("%02.f", (vars.besttime/30)*99 - mins * 5940 - secs * 99)
                assets.kapel:drawTextAligned(gfx.getLocalizedText("besttime"), 365, 5, kTextAlignment.right)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                assets.times_new_rally:drawTextAligned(mins..":"..secs.."."..mils, 356, 23, kTextAlignment.right)
                self.stage:setImage(assets.img_stage[vars.current_menu_item])
            else
                assets.img_prompt:drawImage(8, -13, -1)
                assets.kapel:drawText(gfx.getLocalizedText("stagex_num"), 57, 3)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stagex_name"), 53, 12)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stagex_vs"), 49, 35)
                assets.pedallica:drawText(gfx.getLocalizedText("stagex_desc"), 10, 60)
                assets.img_button_ok:drawFaded(205, 180, 0.5, gfx.image.kDitherTypeDiagonalLine)
                assets.img_timer:draw(279, 7, gfx.kImageFlippedX)
                assets.kapel:drawTextAligned(gfx.getLocalizedText("besttime"), 365, 5, kTextAlignment.right)
                self.stage:setImage(assets.img_stage[vars.current_menu_item]:fadedImage(0.25, gfx.image.kDitherTypeDiagonalLine))
            end
        gfx.popContext()
        self.stage_info:setImage(img)
        local img = nil
        pd.timer.performAfterDelay(300, function()
            vars.stage_transitioning = false
        end)
    end)
end

function tracks:select()
    assets.sfx_proceed:play()
    vars.boat_x_anim = gfx.animator.new(1000, self.boat.x, 500, pd.easingFunctions.inBack)
    vars.stage_x_anim = gfx.animator.new(750, 285, 255, pd.easingFunctions.inSine, 250)
    vars.fade_anim = gfx.animator.new(250, #assets.img_fade, 1, pd.easingFunctions.linear, 750)
    self.fade:add()
    pd.timer.performAfterDelay(1000, function()
        scenemanager:switchscene(race, vars.current_menu_item, "tt", vars.arg_boat, false)
    end)
end

function tracks:update()
    if pd.buttonJustPressed('a') then
        if vars.stage_transitioning == false then
            if vars.current_menu_item <= save.mt then
                self:select()
            else
                assets.sfx_locked:play()
                shakiesx()
            end
        end
    end
    if pd.buttonJustPressed('b') then
        scenemanager:transitionsceneblastdoors(garage)
    end
    if pd.buttonJustPressed('left') then
        if vars.stage_transitioning == false then
            if vars.current_menu_item == 1 then
                shakiesx()
                assets.sfx_bonk:play()
                return
            else
                vars.current_menu_item = math.clamp(vars.current_menu_item - 1, 1, #vars.menu_list)
                self:changetrack(true)
            end
        end
    end
    if pd.buttonJustPressed('right') then
        if vars.stage_transitioning == false then
            if vars.stage_transitioning == false then
                if vars.current_menu_item == 7 then
                    shakiesx()
                    assets.sfx_bonk:play()
                    return
                else
                    vars.current_menu_item = math.clamp(vars.current_menu_item + 1, 1, #vars.menu_list)
                    self:changetrack(false)
                end
            end
        end
    end
end