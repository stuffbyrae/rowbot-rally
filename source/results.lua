local pd <const> = playdate
local gfx <const> = pd.graphics

class('results').extends(gfx.sprite)
function results:init(...)
    results.super.init(self)
    local args = {...}
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 200
        pd.setMenuImage(img, xoffset)
        if vars.arg_mode == "story" then
            if vars.arg_win then
                menu:addMenuItem(gfx.getLocalizedText("onwards"), function()
                    credits:finish()
                end)
            else
                menu:addMenuItem(gfx.getLocalizedText("retry"), function()
                    credits:finish()
                end)
            end
        else
            menu:addMenuItem(gfx.getLocalizedText("changetrack"), function()
                scenemanager:transitionscene(tracks, vars.arg_boat)
            end)
            menu:addMenuItem(gfx.getLocalizedText("changeboat"), function()
                scenemanager:transitionsceneblastdoors(garage)
            end)
        end
        menu:addMenuItem(gfx.getLocalizedText("backtotitle"), function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        bg = args[7], -- last frame shown in the race
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        img_react_win = gfx.image.new('images/results/react_win'),
        img_react_lose = gfx.image.new('images/results/react_lose'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        kapel = gfx.font.new('fonts/kapel'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        double_time = gfx.font.new('fonts/double_time'),
        pedallica = gfx.font.new('fonts/pedallica'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_confetti = pd.sound.sampleplayer.new('audio/sfx/confetti'),
        sfx_win = pd.sound.sampleplayer.new('audio/sfx/win'),
        sfx_lose = pd.sound.sampleplayer.new('audio/sfx/lose')
    }
    assets.sfx_proceed:setVolume(save.vol_sfx/5)
    assets.sfx_confetti:setVolume(save.vol_sfx/5)
    assets.sfx_win:setVolume(save.vol_sfx/5)
    assets.sfx_lose:setVolume(save.vol_sfx/5)
    
    vars = {
        arg_slot = args[1], -- 1 through 3
        arg_track = args[2], -- 1 through 7
        arg_mode = args[3], -- "story" or "tt"
        arg_boat = args[4], -- 1 through 7
        arg_win = args[5], -- true or false. only matters when arg_mode is "story"
        arg_time = args[6], -- time in the race
        besttime = 0,
        plate_anim = gfx.animator.new(750, 400, 120, pd.easingFunctions.outBack),
        react_anim = gfx.animator.new(500, -200, -20, pd.easingFunctions.outSine)
    }
    if vars.arg_mode == "story" then
        if vars.arg_win then
            assets.img_plate = gfx.image.new('images/results/plate_win')
            assets.sfx_win:play()
        else
            assets.img_plate = gfx.image.new('images/results/plate_lose')
            assets.sfx_lose:play()
        end
    else
        assets.img_plate = gfx.image.new('images/results/plate_finish')
        assets.sfx_win:play()
    end

    vars.fade_anim = gfx.animator.new(500, #assets.img_fade, 10)

    if vars.arg_track == 1 then
        vars.besttime = save.stage1_best
        if vars.arg_slot == 1 then
            save.slot1_current_stage = 1
            save.slot1_current_cutscene = 3
        elseif vars.arg_slot == 2 then
            save.slot2_current_stage = 1
            save.slot2_current_cutscene = 3
        elseif vars.arg_slot == 3 then
            save.slot3_current_stage = 1
            save.slot3_current_cutscene = 3
        end
    elseif vars.arg_track == 2 then
        vars.besttime = save.stage2_best
        if vars.arg_slot == 1 then
            save.slot1_current_stage = 2
            save.slot1_current_cutscene = 4
        elseif vars.arg_slot == 2 then
            save.slot2_current_stage = 2
            save.slot2_current_cutscene = 4
        elseif vars.arg_slot == 3 then
            save.slot3_current_stage = 2
            save.slot3_current_cutscene = 4
        end
    elseif vars.arg_track == 3 then
        vars.besttime = save.stage3_best
        if vars.arg_slot == 1 then
            save.slot1_current_stage = 3
            save.slot1_current_cutscene = 5
        elseif vars.arg_slot == 2 then
            save.slot2_current_stage = 3
            save.slot2_current_cutscene = 5
        elseif vars.arg_slot == 3 then
            save.slot3_current_stage = 3
            save.slot3_current_cutscene = 5
        end
    elseif vars.arg_track == 4 then
        vars.besttime = save.stage4_best
        if vars.arg_slot == 1 then
            save.slot1_current_stage = 4
            save.slot1_current_cutscene = 6
        elseif vars.arg_slot == 2 then
            save.slot2_current_stage = 4
            save.slot2_current_cutscene = 6
        elseif vars.arg_slot == 3 then
            save.slot3_current_stage = 4
            save.slot3_current_cutscene = 6
        end
    elseif vars.arg_track == 5 then
        vars.besttime = save.stage5_best
        if vars.arg_slot == 1 then
            save.slot1_current_stage = 5
            save.slot1_current_cutscene = 8
        elseif vars.arg_slot == 2 then
            save.slot2_current_stage = 5
            save.slot2_current_cutscene = 8
        elseif vars.arg_slot == 3 then
            save.slot3_current_stage = 5
            save.slot3_current_cutscene = 8
        end
    elseif vars.arg_track == 6 then
        vars.besttime = save.stage6_best
        if vars.arg_slot == 1 then
            save.slot1_current_stage = 6
            save.slot1_current_cutscene = 9
        elseif vars.arg_slot == 2 then
            save.slot2_current_stage = 6
            save.slot2_current_cutscene = 9
        elseif vars.arg_slot == 3 then
            save.slot3_current_stage = 6
            save.slot3_current_cutscene = 9
        end
    elseif vars.arg_track == 7 then
        vars.besttime = save.stage7_best
        if vars.arg_slot == 1 then
            save.slot1_current_stage = 7
            save.slot1_current_cutscene = 10
        elseif vars.arg_slot == 2 then
            save.slot2_current_stage = 7
            save.slot2_current_cutscene = 10
        elseif vars.arg_slot == 3 then
            save.slot3_current_stage = 7
            save.slot3_current_cutscene = 10
        end
    end

    if vars.arg_track > save.unlocked_stages then
        save.unlocked_stages = vars.arg_track
    end

    gfx.setFont(assets.kapel_doubleup)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        assets.bg:draw(0, 0)
    end)

    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:moveTo(200, 120)
        self:add()
    end
    function fade:update()
        self:setImage(assets.img_fade[math.floor(vars.fade_anim:currentValue())])
    end

    class('plate').extends(gfx.sprite)
    function plate:init()
        plate.super.init(self)
        local img = gfx.image.new(400, 240)
        if vars.arg_win then
            if vars.arg_mode == "story" then
                assets.header = gfx.imageWithText(gfx.getLocalizedText("youwin"), 200, 120)
            else
                assets.header = gfx.imageWithText(gfx.getLocalizedText("finish"), 200, 120)
            end
        else
            assets.header = gfx.imageWithText(gfx.getLocalizedText("youlost"), 200, 120)
        end
        gfx.pushContext(img)
            assets.img_plate:draw(9, 10)
            assets.header:drawScaled(35, 20, 2)
            assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText("yourtime"), 340, 65, kTextAlignment.right)
            local mins = string.format("%02.f", math.floor((vars.arg_time/30) / 60))
            local secs = string.format("%02.f", math.floor((vars.arg_time/30) - mins * 60))
            local mils = string.format("%02.f", (vars.arg_time/30)*99 - mins * 5940 - secs * 99)
            assets.double_time:drawTextAligned('O ' .. mins..":"..secs.."."..mils, 340, 90, kTextAlignment.right)
            if not demo then
                if vars.arg_time < vars.besttime and vars.arg_mode == "tt" then
                    savegame()
                    assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText("newbest"), 340, 120, kTextAlignment.right)
                    if vars.arg_track == 1 then
                        save.stage1_best = vars.arg_time
                    elseif vars.arg_track == 2 then
                        save.stage2_best = vars.arg_time
                    elseif vars.arg_track == 3 then
                        save.stage3_best = vars.arg_time
                    elseif vars.arg_track == 4 then
                        save.stage4_best = vars.arg_time
                    elseif vars.arg_track == 5 then
                        save.stage5_best = vars.arg_time
                    elseif vars.arg_track == 6 then
                        save.stage6_best = vars.arg_time
                    elseif vars.arg_track == 7 then
                        save.stage7_best = vars.arg_time
                    end
                else
                    local bestmins = string.format("%02.f", math.floor((vars.besttime/30) / 60))
                    local bestsecs = string.format("%02.f", math.floor((vars.besttime/30) - bestmins * 60))
                    local bestmils = string.format("%02.f", (vars.besttime/30)*99 - bestmins * 5940 - bestsecs * 99)
                    assets.kapel:drawTextAligned(gfx.getLocalizedText("besttime"), 340, 125, kTextAlignment.right)
                    assets.times_new_rally:drawTextAligned('D ' .. bestmins..":"..bestsecs.."."..bestmils, 340, 140, kTextAlignment.right)
                end
            end
            if vars.arg_mode == "story" then
                if vars.arg_win then
                    assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText("bonwards"), 340, 157, kTextAlignment.right)
                else
                    assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText("bretry"), 340, 157, kTextAlignment.right)
                end
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText("bbacktotitle"), 340, 177, kTextAlignment.right)
            else
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText("bretry"), 340, 157, kTextAlignment.right)
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText("bnewtrack"), 340, 177, kTextAlignment.right)
            end
            gfx.setColor(gfx.kColorXOR)
            gfx.fillRect(0, 158, 347, 45)
        gfx.popContext()
        self:setImage(img)
        self:moveTo(200, 120)
        self:add()
    end
    function plate:update()
        if vars.plate_anim ~= nil then
            self:moveTo(200, vars.plate_anim:currentValue())
        end
    end

    class('react').extends(gfx.sprite)
    function react:init()
        react.super.init(self)
        self:setCenter(0, 1)
        self:moveTo(0, 240)
        if vars.arg_win then
            self:setImage(assets.img_react_win)
        else
            self:setImage(assets.img_react_lose)
        end
        self:add()
    end
    function react:update()
        if vars.react_anim ~= nil then
            self:moveTo(vars.react_anim:currentValue(), 240)
        end
    end

    class('confetti').extends(gfx.sprite)
    function confetti:init()
        confetti.super.init(self)
        self:moveTo(200, 120)
        self:setZIndex(99)
    end
    function confetti:update()
        local img = gfx.image.new(400, 240)
        gfx.pushContext(img)
        vars.confetti1:update()
        vars.confetti2:update()
        gfx.popContext()
        self:setImage(img)
        self:moveBy(0, vars.anim_confetti_grav:currentValue())
    end

    class('overlay').extends(gfx.sprite)
    function overlay:init()
        overlay.super.init(self)
        self:moveTo(200, 120)
        self:setZIndex(100)
        self:add()
    end
    function overlay:update()
        if vars.anim_overlay ~= nil then
            self:setImage(assets.img_fade[math.floor(vars.anim_overlay:currentValue())]:invertedImage())
        end
    end

    self.fade = fade()
    self.plate = plate()
    self.react = react()
    self.confetti = confetti()
    self.overlay = overlay()

    self:add()
end

function results:finish()
    assets.sfx_proceed:play()
    if vars.arg_mode == "story" then
        if vars.arg_win then
            if vars.arg_track == 1 then
                if demo then
                    scenemanager:transitionsceneoneway(notif, "demo", "title")
                else
                    if save.time_trials_unlocked == false then
                        scenemanager:transitionsceneoneway(notif, "tt", "story")
                    else
                        if save.autoskip then
                            scenemanager:transitionsceneoneway(intro, vars.arg_slot, 2)
                        else
                            scenemanager:transitionsceneoneway(cutscene, 3, "story")
                        end
                    end
                end
            elseif vars.arg_track == 2 then
                if save.autoskip then
                    scenemanager:transitionsceneoneway(intro, vars.arg_slot, 3)
                else
                    scenemanager:transitionsceneoneway(cutscene, 4, "story")
                end
            elseif vars.arg_track == 3 then
                if save.autoskip then
                    scenemanager:transitionsceneoneway(intro, vars.arg_slot, 4)
                else
                    scenemanager:transitionsceneoneway(cutscene, 5, "story")
                end
            elseif vars.arg_track == 4 then
                if save.autoskip then
                    scenemanager:transitionsceneoneway(intro, vars.arg_slot, 5)
                else
                    scenemanager:transitionsceneoneway(cutscene, 6, "story")
                end
            elseif vars.arg_track == 5 then
                if save.autoskip then
                    scenemanager:transitionsceneoneway(intro, vars.arg_slot, 6)
                else
                    scenemanager:transitionsceneoneway(cutscene, 8, "story")
                end
            elseif vars.arg_track == 6 then
                if save.autoskip then
                    scenemanager:transitionsceneoneway(intro, vars.arg_slot, 7)
                else
                    scenemanager:transitionsceneoneway(cutscene, 9, "story")
                end
            elseif vars.arg_track == 7 then
                if save.autoskip then
                    scenemanager:transitionsceneoneway(credits, "title")
                else
                    scenemanager:transitionsceneoneway(cutscene, 10, "story")
                end
            end
        else
            vars.anim_overlay = gfx.animator.new(500, #assets.img_fade, 1)
            pd.timer.performAfterDelay(550, function()
                scenemanager:switchscene(race, vars.arg_slot, vars.arg_track, "story", vars.arg_boat)
            end)
        end
    else
        vars.anim_overlay = gfx.animator.new(500, #assets.img_fade, 1)
        pd.timer.performAfterDelay(550, function()
            scenemanager:switchscene(race, 0, vars.arg_track, "tt", vars.arg_boat)
        end)
    end
end

function results:update()
    if pd.buttonJustPressed('a') then
        self:finish()
    end
    if pd.buttonJustPressed('b') then
        if vars.arg_mode == "story" then
            scenemanager:transitionsceneoneway(title, false)
        else
            scenemanager:transitionscene(tracks, vars.arg_boat)
        end
    end
end