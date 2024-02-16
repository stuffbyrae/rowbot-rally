import 'title'
import 'stages'
import 'race'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('results').extends(gfx.sprite) -- Create the scene's class
function results:init(...)
    results.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        image_plate = gfx.image.new('images/ui/popup'),
        image_react_win = gfx.image.new('images/results/react_win'),
        image_react_lose = gfx.image.new('images/results/react_lose'),
        kapel = gfx.font.new('fonts/kapel'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        double_time = gfx.font.new('fonts/double_time'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        image_bg = gfx.getDisplayImage(),
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        stage = args[1], -- number, 1 through 7
        mode = args[2], -- string; "story" or "tt"
        time = args[3], -- number. send in the time!
        win = args[4], -- boolean, true or false. Only affects anything if in story mode.
        crashes = args[5], -- number. how many times did the boat crash while the race was active?
        anim_fade = gfx.animator.new(750, 34, 11, pd.easingFunctions.outSine),
        anim_plate = gfx.animator.new(350, 240, 0, pd.easingFunctions.outBack),
        anim_react = gfx.animator.new(450, 420, 240, pd.easingFunctions.outCubic, 200),
        speedy = false,
    }
    vars.resultsHandlers = {
        AButtonDown = function()
            fademusic()
            if vars.mode == "story" then
                if vars.win then
                    if demo then
                        scenemanager:transitionsceneoneway(notif, gfx.getLocalizedText('demo_complete'), gfx.getLocalizedText('popup_demo'), gfx.getLocalizedText('title_screen'), false, function() scenemanager:switchscene(title) end)
                    else
                        scenemanager:transitionstoryoneway()
                    end
                else
                    scenemanager:transitionsceneoneway(race, vars.stage, "story")
                end
            elseif vars.mode == "tt" then
                scenemanager:transitionsceneoneway(race, vars.stage, "tt")
            end
        end,

        BButtonDown = function()
            fademusic()
            if vars.mode == "story" then
                scenemanager:transitionsceneonewayback(title)
            elseif vars.mode == "tt" then
                scenemanager:transitionsceneback(stages)
            end
        end
    }
    pd.inputHandlers.push(vars.resultsHandlers)

    if vars.win then
        newmusic('audio/sfx/win')
        if vars.mode == "story" then
            save.stages_unlocked = vars.stage
            if save.current_story_slot == 1 then
                if vars.stage == 1 then
                    save.slot1_progress = "cutscene3"
                elseif vars.stage == 2 then
                    save.slot1_progress = "cutscene4"
                elseif vars.stage == 3 then
                    save.slot1_progress = "cutscene5"
                elseif vars.stage == 4 then
                    save.slot1_progress = "cutscene6"
                elseif vars.stage == 5 then
                    save.slot1_progress = "cutscene8"
                elseif vars.stage == 6 then
                    save.slot1_progress = "cutscene9"
                elseif vars.stage == 7 then
                    save.slot1_progress = "cutscene10"
                end
            elseif save.current_story_slot == 2 then
                if vars.stage == 1 then
                    save.slot2_progress = "cutscene3"
                elseif vars.stage == 2 then
                    save.slot2_progress = "cutscene4"
                elseif vars.stage == 3 then
                    save.slot2_progress = "cutscene5"
                elseif vars.stage == 4 then
                    save.slot2_progress = "cutscene6"
                elseif vars.stage == 5 then
                    save.slot2_progress = "cutscene8"
                elseif vars.stage == 6 then
                    save.slot2_progress = "cutscene9"
                elseif vars.stage == 7 then
                    save.slot2_progress = "cutscene10"
                end
            elseif save.current_story_slot == 3 then
                if vars.stage == 1 then
                    save.slot3_progress = "cutscene3"
                elseif vars.stage == 2 then
                    save.slot3_progress = "cutscene4"
                elseif vars.stage == 3 then
                    save.slot3_progress = "cutscene5"
                elseif vars.stage == 4 then
                    save.slot3_progress = "cutscene6"
                elseif vars.stage == 5 then
                    save.slot3_progress = "cutscene8"
                elseif vars.stage == 6 then
                    save.slot3_progress = "cutscene9"
                elseif vars.stage == 7 then
                    save.slot3_progress = "cutscene10"
                end
            end
        elseif vars.mode == "tt" then
            if vars.stage == 1 then
                if vars.time < save.stage1_best and not cheats then
                    save.stage1_best = vars.time
                    corner('sendscore')
                    pd.scoreboards.addScore('stage1', vars.time, function(status, result)
                        printTable(status)
                        print(result)
                        if status.code == "ERROR" then
                            makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                        end
                    end)
                end
                -- TODO: Set the par time here.
                if vars.time < 100 and not cheats then
                    save.stage1_speedy = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not cheats then
                    save.stage1_flawless = true
                end
            elseif vars.stage == 2 then
                if vars.time < save.stage2_best and not cheats then
                    save.stage2_best = vars.time
                    corner('sendscore')
                    pd.scoreboards.addScore('stage2', vars.time, function(status, result)
                        if status.code == "ERROR" then
                            makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                        end
                    end)
                end
                -- TODO: Set the par time here.
                if vars.time < 0 and not cheats then
                    save.stage2_speedy = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not cheats then
                    save.stage2_flawless = true
                end
            elseif vars.stage == 3 then
                if vars.time < save.stage3_best and not cheats then
                    save.stage3_best = vars.time
                    corner('sendscore')
                    pd.scoreboards.addScore('stage3', vars.time, function(status, result)
                        if status.code == "ERROR" then
                            makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                        end
                    end)
                end
                -- TODO: Set the par time here.
                if vars.time < 0 and not cheats then
                    save.stage3_speedy = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not cheats then
                    save.stage3_flawless = true
                end
            elseif vars.stage == 4 then
                if vars.time < save.stage4_best and not cheats then
                    save.stage4_best = vars.time
                    corner('sendscore')
                    pd.scoreboards.addScore('stage4', vars.time, function(status, result)
                        if status.code == "ERROR" then
                            makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                        end
                    end)
                end
                -- TODO: Set the par time here.
                if vars.time < 0 and not cheats then
                    save.stage4_speedy = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not cheats then
                    save.stage4_flawless = true
                end
            elseif vars.stage == 5 then
                if vars.time < save.stage5_best and not cheats then
                    save.stage5_best = vars.time
                    corner('sendscore')
                    pd.scoreboards.addScore('stage5', vars.time, function(status, result)
                        if status.code == "ERROR" then
                            makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                        end
                    end)
                end
                -- TODO: Set the par time here.
                if vars.time < 0 and not cheats then
                    save.stage5_speedy = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not cheats then
                    save.stage5_flawless = true
                end
            elseif vars.stage == 6 then
                if vars.time < save.stage1_best and not cheats then
                    save.stage6_best = vars.time
                    corner('sendscore')
                    pd.scoreboards.addScore('stage6', vars.time, function(status, result)
                        if status.code == "ERROR" then
                            makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                        end
                    end)
                end
                -- TODO: Set the par time here.
                if vars.time < 0 and not cheats then
                    save.stage6_speedy = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not cheats then
                    save.stage6_flawless = true
                end
            elseif vars.stage == 7 then
                if vars.time < save.stage7_best and not cheats then
                    save.stage7_best = vars.time
                    corner('sendscore')
                    pd.scoreboards.addScore('stage7', vars.time, function(status, result)
                        if status.code == "ERROR" then
                            makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                        end
                    end)
                end
                -- TODO: Set the par time here.
                if vars.time < 0 and not cheats then
                    save.stage7_speedy = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not cheats then
                    save.stage7_flawless = true
                end
            end
        end
    else
        newmusic('audio/sfx/lose')
    end

    gfx.pushContext(assets.image_plate)
        local mins, secs, mils = timecalc(vars.time)
        gfx.setFont(assets.kapel_doubleup)
        if vars.win then
            if vars.mode == "story" then
                gfx.imageWithText(gfx.getLocalizedText('youwin'), 200, 120):drawScaled(40, 20, 2)
                makebutton(gfx.getLocalizedText('onwards')):drawAnchored(355, 185, 1, 0.5)
                makebutton(gfx.getLocalizedText('back'), 'small'):drawAnchored(395, 235, 1, 1)
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('yourtime'), 355, 85, kTextAlignment.right)
                assets.double_time:drawTextAligned(mins .. ":" .. secs .. "." .. mils, 355, 110, kTextAlignment.right)
            elseif vars.mode == "tt" then
                makebutton(gfx.getLocalizedText('retry')):drawAnchored(355, 185, 1, 0.5)
                makebutton(gfx.getLocalizedText('newtrack'), 'small'):drawAnchored(395, 235, 1, 1)
                assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('yourtime'), 355, 65, kTextAlignment.right)
                assets.double_time:drawTextAligned(mins .. ":" .. secs .. "." .. mils, 355, 90, kTextAlignment.right)
                if vars.stage == 1 then
                    if vars.time < save.stage1_best and not cheats then
                        save.stage1_best = vars.time
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('newbest'), 355, 125, kTextAlignment.right)
                        corner('sendscore')
                        pd.scoreboards.addScore('stage1', vars.time, function(status, result)
                            printTable(status)
                            print(result)
                            if status.code == "ERROR" then
                                makepopup(gfx.getLocalizedText('whoops'), gfx.getLocalizedText('popup_leaderboard_failed'), gfx.getLocalizedText('ok'), false)
                            end
                        end)
                    else
                        local bestmins, bestsecs, bestmils = timecalc(save.stage1_best)
                        assets.kapel:drawTextAligned(gfx.getLocalizedText('besttime'), 355, 125, kTextAlignment.right)
                        assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                    end
                elseif vars.stage == 2 then
                    if vars.time < save.stage2_best and not cheats then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('newbest'), 355, 125, kTextAlignment.right)
                    else
                        local bestmins, bestsecs, bestmils = timecalc(save.stage2_best)
                        assets.kapel:drawTextAligned(gfx.getLocalizedText('besttime'), 355, 125, kTextAlignment.right)
                        assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                    end
                elseif vars.stage == 3 then
                    if vars.time < save.stage3_best and not cheats then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('newbest'), 355, 125, kTextAlignment.right)
                    else
                        local bestmins, bestsecs, bestmils = timecalc(save.stage3_best)
                        assets.kapel:drawTextAligned(gfx.getLocalizedText('besttime'), 355, 125, kTextAlignment.right)
                        assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                    end
                elseif vars.stage == 4 then
                    if vars.time < save.stage4_best and not cheats then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('newbest'), 355, 125, kTextAlignment.right)
                    else
                        local bestmins, bestsecs, bestmils = timecalc(save.stage4_best)
                        assets.kapel:drawTextAligned(gfx.getLocalizedText('besttime'), 355, 125, kTextAlignment.right)
                        assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                    end
                elseif vars.stage == 5 then
                    if vars.time < save.stage5_best and not cheats then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('newbest'), 355, 125, kTextAlignment.right)
                    else
                        local bestmins, bestsecs, bestmils = timecalc(save.stage5_best)
                        assets.kapel:drawTextAligned(gfx.getLocalizedText('besttime'), 355, 125, kTextAlignment.right)
                        assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                    end
                elseif vars.stage == 6 then
                    if vars.time < save.stage1_best and not cheats then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('newbest'), 355, 125, kTextAlignment.right)
                    else
                        local bestmins, bestsecs, bestmils = timecalc(save.stage6_best)
                        assets.kapel:drawTextAligned(gfx.getLocalizedText('besttime'), 355, 125, kTextAlignment.right)
                        assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                    end
                elseif vars.stage == 7 then
                    if vars.time < save.stage7_best and not cheats then
                        assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('newbest'), 355, 125, kTextAlignment.right)
                    else
                        local bestmins, bestsecs, bestmils = timecalc(save.stage7_best)
                        assets.kapel:drawTextAligned(gfx.getLocalizedText('besttime'), 355, 125, kTextAlignment.right)
                        assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                    end
                end
                if vars.crashes == 0 and vars.speedy then
                    gfx.imageWithText(gfx.getLocalizedText('perfect'), 200, 120):drawScaled(40, 20, 2)
                elseif vars.crashes == 0 then
                    gfx.imageWithText(gfx.getLocalizedText('flawless'), 200, 120):drawScaled(40, 20, 2)
                elseif vars.speedy then
                    gfx.imageWithText(gfx.getLocalizedText('speedy'), 200, 120):drawScaled(40, 20, 2)
                else
                    gfx.imageWithText(gfx.getLocalizedText('finish'), 200, 120):drawScaled(40, 20, 2)
                end
            end
        else
            gfx.imageWithText(gfx.getLocalizedText('youlost'), 200, 120):drawScaled(40, 20, 2)
            makebutton(gfx.getLocalizedText('retry')):drawAnchored(355, 185, 1, 0.5)
            if vars.mode == "story" then
                makebutton(gfx.getLocalizedText('back'), 'small'):drawAnchored(395, 235, 1, 1)
            elseif vars.mode == "tt" then
                makebutton(gfx.getLocalizedText('newtrack'), 'small'):drawAnchored(395, 235, 1, 1)
            end
            assets.kapel_doubleup:drawTextAligned(gfx.getLocalizedText('yourtime'), 355, 85, kTextAlignment.right)
            assets.double_time:drawTextAligned(mins .. ":" .. secs .. "." .. mils, 355, 110, kTextAlignment.right)
        end
    gfx.popContext()

    save.total_races_completed += 1
    if vars.stage == 1 then
        save.stage1_plays += 1
    elseif vars.stage == 2 then
        save.stage2_plays += 1
    elseif vars.stage == 3 then
        save.stage3_plays += 1
    elseif vars.stage == 4 then
        save.stage4_plays += 1
    elseif vars.stage == 5 then
        save.stage5_plays += 1
    elseif vars.stage == 6 then
        save.stage6_plays += 1
    elseif vars.stage == 7 then
        save.stage7_plays += 1
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_bg:draw(0, 0)
    end)

    class('results_fade').extends(gfx.sprite)
    function results_fade:init()
        results_fade.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(0)
        self:add()
    end
    function results_fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade:currentValue())])
        end
    end

    class('results_plate').extends(gfx.sprite)
    function results_plate:init()
        results_plate.super.init(self)
        self:setImage(assets.image_plate)
        self:setCenter(0, 0)
        self:moveTo(0, 0)
        self:setZIndex(1)
        self:add()
    end
    function results_plate:update()
        if vars.anim_plate ~= nil then
            self:moveTo(0, vars.anim_plate:currentValue())
        end
    end

    class('results_react').extends(gfx.sprite)
    function results_react:init(win)
        results_react.super.init(self)
        if win then
            self:setImage(assets.image_react_win)
        else
            self:setImage(assets.image_react_lose)
        end
        self:setCenter(0, 1)
        self:moveTo(-15, 420)
        self:setZIndex(2)
        self:add()
    end
    function results_react:update()
        if vars.anim_react ~= nil then
            self:moveTo(-15, vars.anim_react:currentValue())
        end
    end

    -- Set the sprites
    self.fade = results_fade()
    self.plate = results_plate()
    self.react = results_react(vars.win)
    self:add()
end