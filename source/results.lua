import 'notif'
import 'race'
if not demo then
    import 'title'
    import 'stages'
end

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local text <const> = gfx.getLocalizedText

class('results').extends(gfx.sprite) -- Create the scene's class
function results:init(...)
    results.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(0)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        image_plate = gfx.image.new('images/ui/popup'),
        image_react_win = gfx.image.new('images/race/results_win'),
        image_react_lose = gfx.image.new('images/race/results_lose'),
        kapel = gfx.font.new('fonts/kapel'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        double_time = gfx.font.new('fonts/double_time'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        sfx_proceed = smp.new('audio/sfx/proceed'),
        image_bg = gfx.getDisplayImage(),
    }
    assets.sfx_proceed:setVolume(save.vol_sfx/5)

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        stage = args[1], -- number, 1 through 7
        mode = args[2], -- string; "story" or "tt"
        time = args[3], -- number. send in the time!
        win = args[4], -- boolean, true or false. Only affects anything if in story mode.
        timeout = args[5], -- boolean, true or false. did the player lose via time-out or beach?
        crashes = args[6], -- number. how many times did the boat crash while the race was active?
        mirror = args[7], -- A boolean indicating mirror mode.
        anim_fade = pd.timer.new(750, 34, 11, pd.easingFunctions.outSine),
        anim_plate = pd.timer.new(350, 240, 0, pd.easingFunctions.outBack),
        anim_react = pd.timer.new(450, 420, 240, pd.easingFunctions.outCubic, 200),
        stage1_speedy = 2700,
        stage2_speedy = 3390,
        stage3_speedy = 3150,
        stage4_speedy = 1650,
        stage5_speedy = 4050,
        stage6_speedy = 1500,
        stage7_speedy = 2100,
        speedy = false,
        showtimetrials = false,
        showmirrorunlock = false,
    }
    vars.resultsHandlers = {
        AButtonDown = function()
            self:proceed()
        end,

        BButtonDown = function()
            self:back()
        end
    }
    pd.inputHandlers.push(vars.resultsHandlers)

    if vars.win then
        newmusic('audio/sfx/win')
        if vars.mode == "story" then
            if vars.stage == 1 and save.stages_unlocked == 0 then vars.showtimetrials = true end
            if save.stages_unlocked < vars.stage then
                save.stages_unlocked = vars.stage
            end
            if vars.stage == 1 then
                save['slot' .. save.current_story_slot .. '_progress'] = "cutscene3"
            elseif vars.stage == 2 then
                save['slot' .. save.current_story_slot .. '_progress'] = "cutscene4"
            elseif vars.stage == 3 then
                save['slot' .. save.current_story_slot .. '_progress'] = "cutscene5"
            elseif vars.stage == 4 then
                save['slot' .. save.current_story_slot .. '_progress'] = "cutscene6"
            elseif vars.stage == 5 then
                save['slot' .. save.current_story_slot .. '_progress'] = "cutscene8"
            elseif vars.stage == 6 then
                save['slot' .. save.current_story_slot .. '_progress'] = "cutscene9"
            elseif vars.stage == 7 then
                save['slot' .. save.current_story_slot .. '_progress'] = "cutscene10"
            end
        elseif vars.mode == "tt" then
            if vars.mirror then
                if vars.time < vars['stage' .. vars.stage .. '_speedy'] and not enabled_cheats then
                    save['stage' .. vars.stage .. '_speedy_mirror'] = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not enabled_cheats then
                    save['stage' .. vars.stage .. '_flawless_mirror'] = true
                end
            else
                if vars.time < vars['stage' .. vars.stage .. '_speedy'] and not enabled_cheats then
                    if not save['stage' .. vars.stage .. '_speedy'] and save['stage' .. vars.stage .. '_flawless'] then
                        vars.showmirrorunlock = true
                    end
                    save['stage' .. vars.stage .. '_speedy'] = true
                    vars.speedy = true
                end
                if vars.crashes == 0 and not enabled_cheats then
                    if save['stage' .. vars.stage .. '_speedy'] and not save['stage' .. vars.stage .. '_flawless'] then
                        vars.showmirrorunlock = true
                    end
                    save['stage' .. vars.stage .. '_flawless'] = true
                end
            end
        end
        self:sendscores()
        savegame() -- Save the game! This is put last so "Sending score..." takes precedence over "Saving..." corner UI
    else
        self:sendscores()
        newmusic('audio/sfx/lose')
    end


    gfx.pushContext(assets.image_plate)
        local mins, secs, mils = timecalc(vars.time)
        gfx.setFont(assets.kapel_doubleup)
        if vars.win then
            if vars.mode == "story" then
                gfx.imageWithText(text('youwin'), 200, 120):drawScaled(40, 20, 2)
                makebutton(text('onwards')):drawAnchored(355, 185, 1, 0.5)
                makebutton(text('back'), 'small'):drawAnchored(395, 235, 1, 1)
                assets.kapel_doubleup:drawTextAligned(text('yourtime'), 355, 85, kTextAlignment.right)
                assets.double_time:drawTextAligned(mins .. ":" .. secs .. "." .. mils, 355, 110, kTextAlignment.right)
            elseif vars.mode == "tt" then
                makebutton(text('retry')):drawAnchored(355, 185, 1, 0.5)
                makebutton(text('newstage'), 'small'):drawAnchored(395, 235, 1, 1)
                assets.kapel_doubleup:drawTextAligned(text('yourtime'), 355, 65, kTextAlignment.right)
                assets.double_time:drawTextAligned(mins .. ":" .. secs .. "." .. mils, 355, 90, kTextAlignment.right)
                if vars.mirror and vars.time < save['stage' .. vars.stage .. '_best_mirror'] and not enabled_cheats then
                    assets.kapel_doubleup:drawTextAligned(text('newbest'), 355, 125, kTextAlignment.right)
                    save['stage' .. vars.stage .. '_best_mirror'] = vars.time
                elseif not vars.mirror and vars.time < save['stage' .. vars.stage .. '_best'] and not enabled_cheats then
                    assets.kapel_doubleup:drawTextAligned(text('newbest'), 355, 125, kTextAlignment.right)
                    save['stage' .. vars.stage .. '_best'] = vars.time
                else
                    local bestmins
                    local bestsecs
                    local bestmils
                    if vars.mirror then
                        bestmins, bestsecs, bestmils = timecalc(save['stage' .. vars.stage .. '_best_mirror'])
                    else
                        bestmins, bestsecs, bestmils = timecalc(save['stage' .. vars.stage .. '_best'])
                    end
                    assets.kapel:drawTextAligned(text('besttime'), 355, 125, kTextAlignment.right)
                    assets.times_new_rally:drawTextAligned(bestmins .. ":" .. bestsecs .. "." .. bestmils, 355, 140, kTextAlignment.right)
                end
                if vars.crashes == 0 and vars.speedy then
                    gfx.imageWithText(text('perfect'), 200, 120):drawScaled(40, 20, 2)
                elseif vars.crashes == 0 then
                    gfx.imageWithText(text('flawless'), 200, 120):drawScaled(40, 20, 2)
                elseif vars.speedy then
                    gfx.imageWithText(text('speedy'), 200, 120):drawScaled(40, 20, 2)
                else
                    gfx.imageWithText(text('finish'), 200, 120):drawScaled(40, 20, 2)
                end
                if vars.showmirrorunlock and not vars.mirror then
                    assets.kapel:drawText(text('mirrorunlockedforthisstage'), 100, 16)
                end
            end
        else
            gfx.imageWithText(text('youlost'), 200, 120):drawScaled(40, 20, 2)
            makebutton(text('retry')):drawAnchored(355, 185, 1, 0.5)
            if vars.mode == "story" then
                makebutton(text('back'), 'small'):drawAnchored(395, 235, 1, 1)
            elseif vars.mode == "tt" then
                makebutton(text('newstage'), 'small'):drawAnchored(395, 235, 1, 1)
            end
            assets.kapel_doubleup:drawTextAligned(text('yourtime'), 355, 85, kTextAlignment.right)
            assets.double_time:drawTextAligned(mins .. ":" .. secs .. "." .. mils, 355, 110, kTextAlignment.right)
        end
    gfx.popContext()

    if not vars.timeout then
        save.total_races_completed += 1
        save['stage' .. vars.stage .. '_plays'] += 1
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_bg:draw(0, 0)
    end)

    class('results_fade').extends(gfx.sprite)
    function results_fade:init()
        results_fade.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(0)
        self:setIgnoresDrawOffset(true)
        self:add()
    end
    function results_fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade.value)])
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
            self:moveTo(0, vars.anim_plate.value)
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
            self:moveTo(-15, vars.anim_react.value)
        end
    end

    -- Set the sprites
    sprites.fade = results_fade()
    sprites.plate = results_plate()
    sprites.react = results_react(vars.win)

    self:add()
end

function results:proceed()
    fademusic()
    assets.sfx_proceed:play()
    if vars.mode == "story" then
        if vars.win then
            if demo then
                scenemanager:transitionsceneoneway(notif, text('demo_complete'), text('popup_demo'), text('title_screen'), false, function() scenemanager:switchscene(title) end)
            else
                if vars.showtimetrials then
                    scenemanager:transitionsceneoneway(notif, text('time_trials_unlocked'), text('popup_time_trials_unlocked'), text('ok'), false, function() scenemanager:switchstory() end)
                else
                    scenemanager:transitionstoryoneway()
                end
            end
        else
            scenemanager:transitionsceneoneway(race, vars.stage, "story", vars.mirror)
        end
    elseif vars.mode == "tt" then
        scenemanager:transitionsceneoneway(race, vars.stage, "tt", vars.mirror)
    end
end

function results:back()
    fademusic()
    if vars.mode == "story" then
        if vars.showtimetrials then
            scenemanager:transitionsceneoneway(notif, text('time_trials_unlocked'), text('popup_time_trials_unlocked'), text('ok'), false, function() scenemanager:switchscene(title) end)
        else
            scenemanager:transitionsceneonewayback(title)
        end
    elseif vars.mode == "tt" then
        scenemanager:transitionsceneback(stages)
    end
end

function results:sendscores()
    if playtest then return end
    if demo then return end
    corner('sendscore')
    local board
    if vars.mirror then
        board = 'stage' .. vars.stage .. 'mirror'
    else
        board = 'stage' .. vars.stage
    end
    if perf then
        pd.scoreboards.addScore(board, vars.time, function(status, result)
            if status.code ~= "OK" then
                makepopup(text('whoops'), text('popup_leaderboard_failed'), text('ok'), false)
            end
        end)
    else
        pd.scoreboards.addScore(board, vars.time, function(status, result)
            if status.code ~= "OK" then
                makepopup(text('whoops'), text('popup_leaderboard_failed'), text('ok'), false)
            end
            pd.scoreboards.addScore('racetime', math.floor(save.total_racetime), function(status)
                pd.scoreboards.addScore('crashes', save.total_crashes, function(status)
                    pd.scoreboards.addScore('degreescranked', math.floor(save.total_degrees_cranked), function(status)
                    end)
                end)
            end)
        end)
    end
end