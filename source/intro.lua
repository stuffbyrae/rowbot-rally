local pd <const> = playdate
local gfx <const> = pd.graphics

class('intro').extends(gfx.sprite)
function intro:init(...)
    intro.super.init(self)
    args = {...}
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 200
        pd.setMenuImage(img, xoffset)
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        img_prompt = gfx.image.new('images/intro/prompt'),
        img_prompt_icons = gfx.imagetable.new('images/intro/prompt_icons'),
        img_a = gfx.image.new('images/intro/a'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        kapel = gfx.font.new('fonts/kapel'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        pedallica = gfx.font.new('fonts/pedallica'),
        sfx_intro = pd.sound.sampleplayer.new('audio/sfx/intro'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh')
    }
    assets.sfx_intro:setVolume(save.fx/5)
    assets.sfx_whoosh:setVolume(save.fx/5)
    assets.sfx_intro:play()
    
    vars = {
        arg_track = args[1], -- 1 through 7
        transitioning = true,
        anim_fade = gfx.animator.new(100, 1, 1),
        anim_bg = gfx.animator.new(350, -12, 1, pd.easingFunctions.outBack),
        anim_preview = gfx.animator.new(350, -1.5, 1, pd.easingFunctions.outBack),
        anim_prompt = gfx.animator.new(350, 320, 230, pd.easingFunctions.outBack, 250)
    }

    if vars.arg_track == 1 then
        assets.img_preview = gfx.imagetable.new('images/intro/preview1')
    elseif vars.arg_track == 2 then
        assets.img_preview = gfx.imagetable.new('images/intro/preview2')
    elseif vars.arg_track == 3 then
        assets.img_preview = gfx.imagetable.new('images/intro/preview3')
    elseif vars.arg_track == 4 then
        assets.img_preview = gfx.imagetable.new('images/intro/preview4')
    elseif vars.arg_track == 5 then
        assets.img_preview = gfx.imagetable.new('images/intro/preview5')
    elseif vars.arg_track == 6 then
        assets.img_preview = gfx.imagetable.new('images/intro/preview6')
    elseif vars.arg_track == 7 then
        assets.img_preview = gfx.imagetable.new('images/intro/preview7')
    end
    vars.img_preview_anim = gfx.animation.loop.new(250, assets.img_preview, true)

    pd.timer.performAfterDelay(600, function()
        vars.transitioning = false
    end)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
    end)
    
    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setZIndex(0)
        self:setCenter(0, 0)
        self:add()
    end
    function bg:update()
        local img = gfx.image.new(400, 240)
        gfx.pushContext(img)
            assets.img_fade:drawImage(math.floor(vars.anim_fade:currentValue()), 0, 0)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(0, 75, 5*vars.anim_bg:currentValue(), 60)
            if vars.arg_track == 1 then
                assets.kapel:drawText('STAGE 1', 15*vars.anim_bg:currentValue(), 10)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage1_name"), 15*vars.anim_bg:currentValue(), 20)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage1_vs"), 15*vars.anim_bg:currentValue(), 45)
                assets.pedallica:drawText(gfx.getLocalizedText("stage1_desc"), 25*vars.anim_bg:currentValue(), 75)
            elseif vars.arg_track == 2 then
                assets.kapel:drawText('STAGE 2', 15*vars.anim_bg:currentValue(), 10)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage2_name"), 15*vars.anim_bg:currentValue(), 20)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage2_vs"), 15*vars.anim_bg:currentValue(), 45)
                assets.pedallica:drawText(gfx.getLocalizedText("stage2_desc"), 25*vars.anim_bg:currentValue(), 75)
            elseif vars.arg_track == 3 then
                assets.kapel:drawText('STAGE 3', 15*vars.anim_bg:currentValue(), 10)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage3_name"), 15*vars.anim_bg:currentValue(), 20)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage3_vs"), 15*vars.anim_bg:currentValue(), 45)
                assets.pedallica:drawText(gfx.getLocalizedText("stage3_desc"), 25*vars.anim_bg:currentValue(), 75)
            elseif vars.arg_track == 4 then
                assets.kapel:drawText('STAGE 4', 15*vars.anim_bg:currentValue(), 10)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage4_name"), 15*vars.anim_bg:currentValue(), 20)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage4_vs"), 15*vars.anim_bg:currentValue(), 45)
                assets.pedallica:drawText(gfx.getLocalizedText("stage4_desc"), 25*vars.anim_bg:currentValue(), 75)
            elseif vars.arg_track == 5 then
                assets.kapel:drawText('STAGE 5', 15*vars.anim_bg:currentValue(), 10)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage5_name"), 15*vars.anim_bg:currentValue(), 20)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage5_vs"), 15*vars.anim_bg:currentValue(), 45)
                assets.pedallica:drawText(gfx.getLocalizedText("stage5_desc"), 25*vars.anim_bg:currentValue(), 75)
            elseif vars.arg_track == 6 then
                assets.kapel:drawText('STAGE 6', 15*vars.anim_bg:currentValue(), 10)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage6_name"), 15*vars.anim_bg:currentValue(), 20)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage6_vs"), 15*vars.anim_bg:currentValue(), 45)
                assets.pedallica:drawText(gfx.getLocalizedText("stage6_desc"), 25*vars.anim_bg:currentValue(), 75)
            elseif vars.arg_track == 7 then
                assets.kapel:drawText('FINAL STAGE', 15*vars.anim_bg:currentValue(), 10)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("stage7_name"), 15*vars.anim_bg:currentValue(), 20)
                assets.kapel:drawText('VS. ' .. gfx.getLocalizedText("stage7_vs"), 15*vars.anim_bg:currentValue(), 45)
                assets.pedallica:drawText(gfx.getLocalizedText("stage7_desc"), 25*vars.anim_bg:currentValue(), 75)
            end
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            vars.img_preview_anim:draw(211*vars.anim_preview:currentValue(), 0)
        gfx.popContext()
        self:setImage(img)
    end

    class('prompt').extends(gfx.sprite)
    function prompt:init()
        prompt.super.init(self)
        self:setZIndex(1)
        local img = gfx.image.new(257, 73)
        gfx.pushContext(img)
            assets.img_prompt:draw(0, 0)
            if vars.arg_track == 1 then
                assets.img_prompt_icons:drawImage(1, 13, 7)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("gimmick1_name"), 85, 9)
                assets.pedallica:drawText('  ' .. gfx.getLocalizedText("gimmick1_desc"), 75, 32)
            elseif vars.arg_track == 2 then
                assets.img_prompt_icons:drawImage(2, 13, 7)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("gimmick2_name"), 85, 9)
                assets.pedallica:drawText('  ' .. gfx.getLocalizedText("gimmick2_desc"), 75, 32)
            elseif vars.arg_track == 3 then
                assets.img_prompt_icons:drawImage(3, 13, 7)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("gimmick3_name"), 85, 9)
                assets.pedallica:drawText('  ' .. gfx.getLocalizedText("gimmick3_desc"), 75, 32)
            elseif vars.arg_track == 4 then
                assets.img_prompt_icons:drawImage(4, 13, 7)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("gimmick4_name"), 85, 9)
                assets.pedallica:drawText('  ' .. gfx.getLocalizedText("gimmick4_desc"), 75, 32)
            elseif vars.arg_track == 5 then
                assets.img_prompt_icons:drawImage(5, 13, 7)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("gimmick5_name"), 85, 9)
                assets.pedallica:drawText('  ' .. gfx.getLocalizedText("gimmick5_desc"), 75, 32)
            elseif vars.arg_track == 6 then
                assets.img_prompt_icons:drawImage(6, 13, 7)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("gimmick6_name"), 85, 9)
                assets.pedallica:drawText('  ' .. gfx.getLocalizedText("gimmick6_desc"), 75, 32)
            elseif vars.arg_track == 7 then
                assets.img_prompt_icons:drawImage(7, 13, 7)
                assets.kapel_doubleup:drawText(gfx.getLocalizedText("gimmick7_name"), 85, 9)
                assets.pedallica:drawText('  ' .. gfx.getLocalizedText("gimmick7_desc"), 75, 32)
            end
        gfx.popContext()
        self:setImage(img)
        self:setCenter(0, 1)
        self:add()
    end
    function prompt:update()
        self:moveTo(10, vars.anim_prompt:currentValue())
    end

    class('a').extends(gfx.sprite)
    function a:init()
        a.super.init(self)
        self:setZIndex(2)
        self:setImage(assets.img_a)
        self:setCenter(1, 1)
        self:add()
    end
    function a:update()
        self:moveTo(390, vars.anim_prompt:currentValue())
    end

    self.bg = bg()
    self.prompt = prompt()
    self.a = a()

    self:add()
end

function intro:transition()
    vars.transitioning = true
    vars.anim_fade = gfx.animator.new(350, 1, #assets.img_fade)
    vars.anim_bg = gfx.animator.new(350, 1, -12, pd.easingFunctions.outBack)
    vars.anim_preview = gfx.animator.new(350, 1, 2, pd.easingFunctions.outBack)
    vars.anim_prompt = gfx.animator.new(200, 230, 320, pd.easingFunctions.outBack, 50)
    assets.sfx_whoosh:play()
    pd.timer.performAfterDelay(355, function()
        if vars.arg_track == 1 then
            scenemanager:switchscene(race, 1, "story", 1, false)
        elseif vars.arg_track == 2 then
            scenemanager:switchscene(race, 2, "story", 2, false)
        elseif vars.arg_track == 3 then
            scenemanager:switchscene(race, 3, "story", 3, false)
        elseif vars.arg_track == 4 then
            scenemanager:switchscene(race, 4, "story", 4, false)
        elseif vars.arg_track == 5 then
            scenemanager:switchscene(race, 5, "story", 5, false)
        elseif vars.arg_track == 6 then
            scenemanager:switchscene(race, 6, "story", 6, false)
        elseif vars.arg_track == 7 then
            scenemanager:switchscene(race, 7, "story", 7, false)
        end
    end)
end

function intro:update()
    if pd.buttonJustPressed('a') and vars.transitioning == false then
        self:transition()
    end
end