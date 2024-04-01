-- Move to this scene later on ...
import 'title'
import 'race'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer

class('stages').extends(gfx.sprite) -- Create the scene's class
function stages:init(...)
    stages.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(200) -- TODO: Set this X offset
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        kapel = gfx.font.new('fonts/kapel'),
        pedallica = gfx.font.new('fonts/pedallica'),
        times_new_rally = gfx.font.new('fonts/times_new_rally'),
        image_boat = gfx.image.new('images/stages/boat'),
        image_preview = gfx.image.new('images/stages/preview1'),
        image_timer = gfx.image.new('images/race/timer'),
        image_wave = gfx.image.new('images/ui/wave'),
        image_wave_composite = gfx.image.new(464, 280),
        image_top = gfx.image.new(480, 300),
        image_ok = makebutton(gfx.getLocalizedText('ok'), 'big'),
        image_back = makebutton(gfx.getLocalizedText('back'), 'small'),
        image_leaderboards = makebutton(gfx.getLocalizedText('up_leaderboards'), 'small2'),
        image_medal_unobtained = gfx.image.new('images/stages/medal_unobtained'),
        image_medal_flawless = gfx.image.new('images/stages/medal_flawless'),
        image_medal_speedy = gfx.image.new('images/stages/medal_speedy'),
        image_buttons = gfx.image.new(156, 68),
        sfx_whoosh = smp.new('audio/sfx/whoosh'),
        sfx_bonk = smp.new('audio/sfx/bonk'),
        sfx_leaderboard_in = smp.new('audio/sfx/leaderboard_in'),
        sfx_proceed = smp.new('audio/sfx/proceed'),
        sfx_pop = smp.new('audio/sfx/pop'),
        sfx_menu = smp.new('audio/sfx/menu'),
    }
    assets.sfx_whoosh:setVolume(save.vol_sfx/5)
    assets.sfx_bonk:setVolume(save.vol_sfx/5)
    assets.sfx_leaderboard_in:setVolume(save.vol_sfx/5)
    assets.sfx_proceed:setVolume(save.vol_sfx/5)
    assets.sfx_pop:setVolume(save.vol_sfx/5)
    assets.sfx_menu:setVolume(save.vol_sfx/5)

    -- Writing in the image for the wave banner along the bottom
    gfx.pushContext(assets.image_wave_composite)
        assets.image_wave:drawTiled(0, 0, 464, 280)
    gfx.popContext()

    gfx.pushContext(assets.image_buttons)
        assets.image_ok:drawAnchored(83, 0, 0.5, 0)
        assets.image_leaderboards:drawAnchored(78, 45, 0.5, 0)
    gfx.popContext()

    -- Writing to the image along the top; wrapped in a function so that I can update it later.
    function update_image_top(stage, show_desc, ranking, name)
        -- Todo: figure out if there's a better way to accomplish this bullshit
        -- Calculate the proper time for each save, and assign it to variables
        mins, secs, mils = timecalc(save['stage' .. stage .. '_best'])
        assets.image_top = gfx.image.new(480, 300)
        gfx.pushContext(assets.image_top)
            gfx.fillRect(0, 0, 480, 50) -- Add the black rectangle
            assets.image_timer:draw(0, 40) -- Draw the timer graphic
            assets.kapel:drawText(gfx.getLocalizedText('besttime'), 34, 80) -- the "Best Time" label
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Fill white...
            assets.kapel:drawText(gfx.getLocalizedText('stage') .. stage, 5, 7) -- The stage number
            assets.kapel_doubleup:drawText(gfx.getLocalizedText('stage_' .. stage .. '_name'), 5, 16) -- The stage's name
            assets.times_new_rally:drawTextAligned(mins .. ':' .. secs .. '.' .. mils, 75, 57, kTextAlignment.center) -- and the best time.
            gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Set this back to normal just to be safe
            if show_desc then
                assets.pedallica:drawText(gfx.getLocalizedText('stage_' .. stage .. '_desc'), 10, 95)
                if save['stage' .. stage .. '_flawless'] then
                    assets.image_medal_flawless:draw(135, 45)
                else
                    assets.image_medal_unobtained:draw(135, 45)
                end
                if save['stage' .. stage .. '_speedy'] then
                    assets.image_medal_speedy:draw(180, 45)
                else
                    assets.image_medal_unobtained:draw(180, 45)
                end
            end
            if ranking ~= nil then
                assets.kapel:drawText(gfx.getLocalizedText('yourank'), 125, 52)
                assets.kapel_doubleup:drawTextAligned(ordinal(ranking) .. "!", 205, 60, kTextAlignment.right)
                -- If the player has a default username, then let's throw a prompt up to tell them to change that. Woohoo, indoctrination!
                if string.len(name) == 16 and tonumber(name) then
                    gfx.fillRect(0, 165, 480, 40)
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillRect(0, 167, 480, 36)
                    gfx.setColor(gfx.kColorBlack)
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('default_username_text'), 107, 170, kTextAlignment.center)
                end
            end
        gfx.popContext()
        -- Nil those save variables, just in case
        mins = nil
        secs = nil
        mils = nil
        -- And set the image, but only if the sprite exists.
        if self.top ~= nil then
            self.top:setImage(assets.image_top)
        end
    end

    -- Now call it at stage 1 to start.
    update_image_top(1, true)
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        selection = 1,
        leaderboards_open = false,
        leaderboards_closable = false,
        anim_wave_x = pd.timer.new(5000, 0, -58),
        anim_boat_y = pd.timer.new(2500, 195, 200, pd.easingFunctions.inOutCubic),
    }
    vars.stagesHandlers = {
        leftButtonDown = function()
            self:newselection(false)
        end,

        rightButtonDown = function()
            self:newselection(true)
        end,

        upButtonDown = function()
            assets.sfx_leaderboard_in:play()
            self:leaderboardsin()
        end,

        BButtonDown = function()
            fademusic()
            scenemanager:transitionsceneonewayback(title)
        end,

        AButtonDown = function()
            self:enterrace()
        end
    }
    vars.leaderboardHandlers = {
        BButtonDown = function()
            if vars.leaderboards_closable then
                self:leaderboardsout()
            end
        end
    }
    pd.inputHandlers.push(vars.stagesHandlers)

    vars.anim_wave_x.repeats = true
    vars.anim_boat_y.repeats = true
    vars.anim_boat_y.reverses = true

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
    end)

    class('stages_wave').extends(gfx.sprite)
    function stages_wave:init()
        stages_wave.super.init(self)
        self:setImage(assets.image_wave_composite)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:moveTo(0, 225)
        self:setZIndex(0)
        self:add()
    end
    function stages_wave:update()
        if vars.anim_wave_y ~= nil then
            self:moveTo(vars.anim_wave_x.value, vars.anim_wave_y.value)
        else
            self:moveTo(vars.anim_wave_x.value, 225)
        end
    end

    class('stages_boat').extends(gfx.sprite)
    function stages_boat:init()
        stages_boat.super.init(self)
        self:setImage(assets.image_boat)
        self:moveTo(45, 195)
        self:setZIndex(1)
        self:add()
    end
    function stages_boat:update()
        if vars.anim_boat_x ~= nil then
            self:moveTo(vars.anim_boat_x.value, vars.anim_boat_y.value)
        elseif vars.anim_boat_y ~= nil then
            self:moveTo(45, vars.anim_boat_y.value)
        end
    end

    class('stages_back').extends(gfx.sprite)
    function stages_back:init()
        stages_back.super.init(self)
        self:setImage(assets.image_back)
        self:setCenter(0, 1)
        self:moveTo(105, 235)
        self:setZIndex(2)
        self:add()
    end
    function stages_back:update()
        if vars.anim_back_y ~= nil then
            self:moveTo(105, vars.anim_back_y.value)
        end
    end

    class('stages_top').extends(gfx.sprite)
    function stages_top:init()
        stages_top.super.init(self)
        self:setImage(assets.image_top)
        self:setCenter(0, 0)
        self:setZIndex(3)
        self:add()
    end
    function stages_top:update()
        if vars.anim_top_y ~= nil then
            self:moveTo(0, vars.anim_top_y.value)
        end
    end

    class('stages_preview').extends(gfx.sprite)
    function stages_preview:init()
        stages_preview.super.init(self)
        self:setZIndex(4)
        self:setCenter(1, 0)
        self:moveTo(400, 0)
        self:setImage(assets.image_preview)
        self:add()
    end
    function stages_preview:update()
        if vars.anim_preview_x ~= nil then
            self:moveTo(vars.anim_preview_x.value, 0)
        end
    end

    class('stages_buttons').extends(gfx.sprite)
    function stages_buttons:init()
        stages_buttons.super.init(self)
        self:setZIndex(5)
        self:setImage(assets.image_buttons)
        self:setCenter(1, 1)
        self:moveTo(390, 235)
        self:add()
    end
    function stages_buttons:update()
        if vars.anim_preview_x ~= nil then
            self:moveTo(vars.anim_preview_x.value - 10, 235)
        end
    end

    class('stages_lb_accent').extends(gfx.sprite)
    function stages_lb_accent:init()
        stages_lb_accent.super.init(self)
        self:setCenter(0, 1)
        self:moveTo(0, 240)
        self:setZIndex(1)
    end

    class('stages_lb_bubble').extends(gfx.sprite)
    function stages_lb_bubble:init()
        stages_lb_bubble.super.init(self)
        self:setCenter(1, 0.5)
        self:moveTo(400, 120)
        self:setZIndex(7)
    end
    function stages_lb_bubble:update()
        if vars.anim_lb_bubble ~= nil then
            self:setImage(vars.anim_lb_bubble:image())
            if not vars.anim_lb_bubble:isValid() then
                vars.anim_lb_bubble = gfx.animation.loop.new(250, assets.image_leaderboard_container, true)
            end
        end
    end

    class('stages_lb_text').extends(gfx.sprite)
    function stages_lb_text:init()
        stages_lb_text.super.init(self)
        self:setCenter(1, 0.5)
        self:moveTo(400, 120)
        self:setZIndex(8)
    end

    -- Set the sprites
    self.wave = stages_wave()
    self.boat = stages_boat()
    self.back = stages_back()
    self.top = stages_top()
    self.preview = stages_preview()
    self.buttons = stages_buttons()
    self.lb_accent = stages_lb_accent()
    self.lb_bubble = stages_lb_bubble()
    self.lb_text = stages_lb_text()
    self:add()

    newmusic('audio/music/stages', true) -- Adding new music
end

-- Select a new stage using the arrow keys. dir is a boolean — left is false, right is true
function stages:newselection(dir)
    vars.old_selection = vars.selection
    if dir then
        vars.selection = math.clamp(vars.selection + 1, 1, save.stages_unlocked)
    else
        vars.selection = math.clamp(vars.selection - 1, 1, save.stages_unlocked)
    end
    -- If this is true, then that means we've reached an end and nothing has changed.
    if vars.old_selection == vars.selection then
        assets.sfx_bonk:play()
        shakies()
    else
        assets.sfx_menu:play()
        update_image_top(vars.selection, true)
        assets.image_preview = gfx.image.new('images/stages/preview' .. vars.selection)
        self.preview:setImage(assets.image_preview)
    end
end

-- Enter a leaderboards screen
function stages:leaderboardsin()
    vars.leaderboards_open = true
    update_image_top(vars.selection, false)
    pd.inputHandlers.push(vars.leaderboardHandlers, true)
    assets.image_rowbot_accent = gfx.imagetable.new('images/stages/rowbot_accent')
    assets.image_leaderboard_container = gfx.imagetable.new('images/stages/leaderboard_container')
    assets.image_leaderboard_container_intro = gfx.imagetable.new('images/stages/leaderboard_container_intro')
    vars.anim_boat_y = pd.timer.new(250, self.boat.y, 300, pd.easingFunctions.inCubic)
    vars.anim_preview_x = pd.timer.new(250, self.preview.x, 600, pd.easingFunctions.inCubic)
    vars.anim_lb_bubble = gfx.animation.loop.new(100, assets.image_leaderboard_container_intro, false)
    self.lb_accent:setImage(assets.image_rowbot_accent[2])
    self.lb_accent:add()
    self.lb_bubble:add()
    pd.timer.performAfterDelay(1000, function()
        vars.leaderboards_closable = true
        self.lb_accent:setImage(assets.image_rowbot_accent[1])
        pd.scoreboards.getPersonalBest('stage' .. tostring(vars.selection), function(status, result)
            if status.code == "OK" then
                if vars.leaderboards_open then
                    update_image_top(vars.selection, false, result.rank, result.player)
                end
            end
        end)
        assets.image_lb_text = gfx.image.new(190, 240)
        gfx.pushContext(assets.image_lb_text)
            assets.pedallica:drawTextAligned(gfx.getLocalizedText('leaderboards_grab'), 100, 100, kTextAlignment.center)
        gfx.popContext()
        self.lb_text:setImage(assets.image_lb_text)
        self.lb_text:add()
        pd.scoreboards.getScores('stage' .. tostring(vars.selection), function(status, result)
            if status.code == "OK" and vars.leaderboards_open then
                assets.image_lb_text = gfx.image.new(190, 240)
                gfx.pushContext(assets.image_lb_text)
                for _, v in ipairs(result.scores) do
                    mins, secs, mils = timecalc(v.value)
                    assets.kapel:drawText(v.player, 12, (26 * v.rank) - 22)
                    assets.kapel:drawTextAligned(ordinal(v.rank), 185, (26 * v.rank) - 22, kTextAlignment.right)
                    assets.pedallica:drawTextAligned(mins .. ':' .. secs .. '.' .. mils, 185, (26 * v.rank) - 12, kTextAlignment.right)
                    mins = nil
                    secs = nil
                    mils = nil
                end
                if next(result.scores) == nil then
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('leaderboards_empty'), 100, 100, kTextAlignment.center)
                end
                gfx.popContext()
                self.lb_text:setImage(assets.image_lb_text)
                self.lb_accent:setImage(assets.image_rowbot_accent[2])
            elseif status.code == "ERROR" and vars.leaderboards_open then
                assets.image_lb_text = gfx.image.new(190, 240)
                gfx.pushContext(assets.image_lb_text)
                    assets.pedallica:drawTextAligned(gfx.getLocalizedText('leaderboards_fail'), 100, 100, kTextAlignment.center)
                gfx.popContext()
                self.lb_text:setImage(assets.image_lb_text)
                self.lb_accent:setImage(assets.image_rowbot_accent[3])
            end
        end)
    end)
end

-- Exit an already-open leaderboards screen
function stages:leaderboardsout()
    assets.sfx_pop:play()
    vars.leaderboards_closable = false
    self.lb_text:remove()
    update_image_top(vars.selection, false)
    assets.image_leaderboard_container_outro = gfx.imagetable.new('images/stages/leaderboard_container_outro')
    vars.anim_lb_bubble = gfx.animation.loop.new(70, assets.image_leaderboard_container_outro, false)
    pd.timer.performAfterDelay(250, function()
        assets.sfx_whoosh:play()
        vars.anim_boat_y = pd.timer.new(250, self.boat.y, 200, pd.easingFunctions.outCubic)
        vars.anim_preview_x = pd.timer.new(250, self.preview.x, 400, pd.easingFunctions.outCubic)
    end)
    pd.timer.performAfterDelay(300, function()
        self.lb_bubble:remove()
        vars.anim_lb_bubble = nil
    end)
    pd.timer.performAfterDelay(501, function()
        if vars.leaderboards_open then
            vars.leaderboards_open = false
            self.lb_accent:remove()
            pd.inputHandlers.pop()
            update_image_top(vars.selection, true)
            vars.anim_boat_y = pd.timer.new(2500, 195, 200, pd.easingFunctions.inOutCubic)
            vars.anim_boat_y.repeats = true
            vars.anim_boat_y.reverses = true
        end
    end)
end

-- Transition into a white screen, for the racing scene
function stages:enterrace()
    pd.inputHandlers.pop()
    assets.sfx_proceed:play()
    fademusic(1000)
    vars.anim_boat_x = pd.timer.new(750, self.boat.x, 450, pd.easingFunctions.inCubic)
    vars.anim_preview_x = pd.timer.new(250, self.preview.x, 600, pd.easingFunctions.inCubic)
    vars.anim_back_y = pd.timer.new(250, self.back.y, 275, pd.easingFunctions.inCubic)
    vars.anim_top_y = pd.timer.new(250, self.top.y, -400, pd.easingFunctions.inCubic)
    vars.anim_boat_x.timerEndedCallback = function()
        vars.anim_wave_y = pd.timer.new(250, self.wave.y, 245, pd.easingFunctions.inBack)
    end
    pd.timer.performAfterDelay(1200, function()
        scenemanager:switchscene(race, vars.selection, "tt")
    end)
end