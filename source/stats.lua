-- Gotta switch back to this later.
import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local text <const> = gfx.getLocalizedText
local floor <const> = math.floor
local format <const> = string.format

class('stats').extends(gfx.sprite) -- Create the scene's class
function stats:init(...)
    stats.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(130)
        menu:addCheckmarkMenuItem(text('metric'), save.metric, function(new)
            save.metric = new
            gfx.sprite.redrawBackground()
        end)
        if vars.show_leaderboards then
            menu:addMenuItem(text('localstats'), function()
                vars.show_leaderboards = false
                gfx.sprite.redrawBackground()
            end)
        elseif not playtest then
            menu:addMenuItem(text('onlinestats'), function()
                self:refreshonlinestats()
            end)
        end
        menu:addMenuItem(text('backtotitle'), function()
            if not vars.transitioning then
                self:leave()
            end
        end)

    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        kapel = gfx.font.new('fonts/kapel'),
        pedallica = gfx.font.new('fonts/pedallica'),
        image_ticker = gfx.image.new(800, 20, gfx.kColorBlack),
        image_wave = gfx.image.new('images/ui/wave'),
        image_wave_composite = gfx.image.new(464, 280),
        image_back = makebutton(text('back'), "small2")
    }

    -- Writing in the image for the wave banner along the bottom
    gfx.pushContext(assets.image_wave_composite)
        assets.image_wave:drawTiled(0, 0, 464, 280)
    gfx.popContext()

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        transitioning = true,
        anim_wave_x = pd.timer.new(5000, 0, -58),
        anim_wave_y = pd.timer.new(1000, -30, 185, pd.easingFunctions.outCubic), -- Send the wave down from above
        stage_plays = { -- Each number here is the stage's total play count, with the stage's own number tacked onto the end for record-keeping.
            tonumber(save.stage1_plays .. 1),
            tonumber(save.stage2_plays .. 2),
            tonumber(save.stage3_plays .. 3),
            tonumber(save.stage4_plays .. 4),
            tonumber(save.stage5_plays .. 5),
            tonumber(save.stage6_plays .. 6),
            tonumber(save.stage7_plays .. 7),
        },
        show_leaderboards = false,
        lb_racetime_result = {},
        rank_racetime_result = {},
        lb_crashes_result = {},
        rank_crashes_result = {},
        lb_degreescranked_result = {},
        rank_degreescranked_result = {},
    }
    vars.statsHandlers = {
        BButtonDown = function()
            if not vars.transitioning then
                self:leave()
            end
        end
    }
    pd.inputHandlers.push(vars.statsHandlers)

    pd.timer.performAfterDelay(1000, function() -- After the wave's done animating inward...
        vars.transitioning = false -- Start accepting button presses to go back.
        vars.anim_wave_y:resetnew(5000, 185, 195, pd.easingFunctions.inOutCubic) -- Set the wave's idle animation,
        vars.anim_wave_y.repeats = true -- make it repeat forever,
        vars.anim_wave_y.reverses = true -- and make it loop!
    end)


    vars.textwidth = assets.kapel_doubleup:getTextWidth(text('stats')) + 10
    -- Writing in the image for the "Options" header ticker
    gfx.pushContext(assets.image_ticker)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.kapel_doubleup:drawText(text('stats'), vars.textwidth * 1, -3)
        assets.kapel_doubleup:drawText(text('stats'), vars.textwidth * 2, -3)
        assets.kapel_doubleup:drawText(text('stats'), vars.textwidth * 3, -3)
        assets.kapel_doubleup:drawText(text('stats'), vars.textwidth * 4, -3)
        assets.kapel_doubleup:drawText(text('stats'), vars.textwidth * 5, -3)
        assets.kapel_doubleup:drawText(text('stats'), vars.textwidth * 6, -3)
        assets.kapel_doubleup:drawText(text('stats'), vars.textwidth * 7, -3)
    gfx.popContext()

    vars.anim_ticker = pd.timer.new(2000, -vars.textwidth, (-vars.textwidth * 2) + 1)
    vars.anim_wave_y.discardOnCompletion = false
    vars.anim_ticker.repeats = true
    vars.anim_wave_x.repeats = true

    table.sort(vars.stage_plays) -- Sorting the stage plays table...
    vars.mps = vars.stage_plays[7] -- Saving the most-played stage for shorthand
    vars.lps = vars.stage_plays[1] -- Saving the least-played stage for shorthand
    -- Modulo either of those numbers by 10 and you'll get JUST the stage number
    -- Divide either of those numbers by 10 and floor it, and you'll get JUST the playcount.

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
        if vars.show_leaderboards then
            assets.pedallica:drawText(text('stats_timespentracing'), 10, 30)
            if vars.lb_racetime_result == "fail" then
                assets.pedallica:drawText(text('leaderboards_fail_short'), 10, 45)
            elseif vars.lb_racetime_result.scores == nil then
                assets.pedallica:drawText(text('leaderboards_grab_short'), 10, 45)
            else
                for _, v in ipairs(vars.lb_racetime_result.scores) do
                    if v.rank > 5 then
                        return
                    else
                        assets.kapel:drawText(v.rank .. '. ' .. v.player, 10, 45 + (25 * (v.rank - 1)))
                        if v.value > 108000 then
                            assets.pedallica:drawText(self:gethms(v.value, true), 10, 55 + (25 * (v.rank - 1)))
                        else
                            assets.pedallica:drawText(self:gethms(v.value, false), 10, 55 + (25 * (v.rank - 1)))
                        end
                    end
                end
                if vars.lb_racetime_result.scores[1] == nil then
                    assets.pedallica:drawText(text('leaderboards_empty_short'), 10, 45)
                end
            end

            assets.pedallica:drawTextAligned(text('stats_total') .. text('stats_crashes'), 200, 30, kTextAlignment.center)
            if vars.lb_crashes_result == "fail" then
                assets.pedallica:drawTextAligned(text('leaderboards_fail_short'), 200, 45, kTextAlignment.center)
            elseif vars.lb_crashes_result.scores == nil then
                assets.pedallica:drawTextAligned(text('leaderboards_grab_short'), 200, 45, kTextAlignment.center)
            else
                for _, v in ipairs(vars.lb_crashes_result.scores) do
                    if v.rank > 5 then
                        return
                    else
                        assets.kapel:drawTextAligned(v.rank .. '. ' .. v.player, 200, 45 + (25 * (v.rank - 1)), kTextAlignment.center)
                        assets.pedallica:drawTextAligned(commalize(v.value), 200, 55 + (25 * (v.rank - 1)), kTextAlignment.center)
                    end
                end
                if vars.lb_crashes_result.scores[1] == nil then
                    assets.pedallica:drawTextAligned(text('leaderboards_empty_short'), 200, 45, kTextAlignment.center)
                end
            end

            assets.pedallica:drawTextAligned(text('stats_distancecranked'), 390, 30, kTextAlignment.right)
            if vars.lb_degreescranked_result == "fail" then
                assets.pedallica:drawTextAligned(text('leaderboards_fail_short'), 390, 45, kTextAlignment.right)
            elseif vars.lb_degreescranked_result.scores == nil then
                assets.pedallica:drawTextAligned(text('leaderboards_grab_short'), 390, 45, kTextAlignment.right)
            else
                for _, v in ipairs(vars.lb_degreescranked_result.scores) do
                    if v.rank > 5 then
                        return
                    else
                        assets.kapel:drawTextAligned(v.rank .. '. ' .. v.player, 390, 45 + (25 * (v.rank - 1)), kTextAlignment.right)
                        assets.pedallica:drawTextAligned(self:getdistancecranked(v.value), 390, 55 + (25 * (v.rank - 1)), kTextAlignment.right)
                    end
                end
                if vars.lb_degreescranked_result.scores[1] == nil then
                    assets.pedallica:drawTextAligned(text('leaderboards_empty_short'), 390, 45, kTextAlignment.right)
                end
            end
        else
            assets.pedallica:drawText(text('stats_total') .. text('stats_playtime'), 10, 30)
            assets.pedallica:drawText(text('stats_timespentracing'), 10, 45)
            assets.pedallica:drawText(text('stats_total') .. text('stats_crashes'), 10, 70)
            assets.pedallica:drawText(text('stats_racescompleted'), 10, 85)
            assets.pedallica:drawText(text('stats_storiescompleted'), 10, 100)
            assets.pedallica:drawText(text('stats_distancecranked'), 10, 115)
            assets.pedallica:drawText(text('stats_favoritestage_' .. tostring(save.metric)), 10, 140)
            assets.pedallica:drawText(text('stats_leastfavoritestage_' .. tostring(save.metric)), 10, 155)
            if save.total_playtime > 108000 then -- Only display hours slot if there are hours to be slotted
                assets.pedallica:drawTextAligned(self:gethms(save.total_playtime, true), 390, 30, kTextAlignment.right)
            else
                assets.pedallica:drawTextAligned(self:gethms(save.total_playtime, false), 390, 30, kTextAlignment.right)
            end
            if save.total_playtime > 108000 then -- Only display hours slot if there are hours to be slotted
                assets.pedallica:drawTextAligned(self:gethms(save.total_racetime, true), 390, 45, kTextAlignment.right)
            else
                assets.pedallica:drawTextAligned(self:gethms(save.total_racetime, false), 390, 45, kTextAlignment.right)
            end
            assets.pedallica:drawTextAligned(commalize(save.total_crashes), 390, 70, kTextAlignment.right)
            assets.pedallica:drawTextAligned(commalize(save.total_races_completed), 390, 85, kTextAlignment.right)
            assets.pedallica:drawTextAligned(commalize(save.stories_completed), 390, 100, kTextAlignment.right)
            assets.pedallica:drawTextAligned(self:getdistancecranked(save.total_degrees_cranked), 390, 115, kTextAlignment.right)
            if vars.mps > 10 then -- If there's no plays on any stage, the highest it will go is "07" — in that event, don't bother picking a "Favorite stage" since all of them are 0 plays.
                if floor(vars.mps / 10) == 1 then
                    assets.pedallica:drawTextAligned(text('stage_' .. vars.mps % 10 .. '_name') .. ' (' .. floor(vars.mps / 10) .. ' play)', 390, 140, kTextAlignment.right)
                else
                    assets.pedallica:drawTextAligned(text('stage_' .. vars.mps % 10 .. '_name') .. ' (' .. commalize(floor(vars.mps / 10)) .. ' plays)', 390, 140, kTextAlignment.right)
                end
            else
                assets.pedallica:drawTextAligned('N/A', 390, 140, kTextAlignment.right)
            end
            if vars.lps > 10 then -- Only start counting "Least favorite stage"" after every stage has had at least one play, to ensure fairness.
                if floor(vars.lps / 10) == 1 then
                    assets.pedallica:drawTextAligned(text('stage_' .. vars.lps % 10 .. '_name') .. ' (' .. floor(vars.lps / 10) .. ' play)', 390, 155, kTextAlignment.right)
                else
                    assets.pedallica:drawTextAligned(text('stage_' .. vars.lps % 10 .. '_name') .. ' (' .. commalize(floor(vars.lps / 10)) .. ' plays)', 390, 155, kTextAlignment.right)
                end
            else
                assets.pedallica:drawTextAligned('N/A', 390, 155, kTextAlignment.right)
            end
        end
    end)

    class('stats_ticker').extends(gfx.sprite)
    function stats_ticker:init()
        stats_ticker.super.init(self)
        self:setImage(assets.image_ticker)
        self:setCenter(0, 0)
        self:setZIndex(1)
        self:add()
    end
    function stats_ticker:update()
        self:moveTo(vars.anim_ticker.value, 0)
    end

    class('stats_wave').extends(gfx.sprite)
    function stats_wave:init()
        stats_wave.super.init(self)
        self:setImage(assets.image_wave_composite)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:moveTo(0, 185)
        self:add()
    end
    function stats_wave:update()
        self:moveTo(vars.anim_wave_x.value, vars.anim_wave_y.value)
    end

    class('stats_back').extends(gfx.sprite)
    function stats_back:init()
        stats_back.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(3)
        self:setImage(assets.image_back)
        self:moveTo(295, 210)
        self:add()
    end
    function stats_back:update()
        self:moveTo(295, (vars.anim_wave_y.value*1.1))
    end

    -- Set the sprites
    sprites.ticker = stats_ticker()
    sprites.wave = stats_wave()
    sprites.back = stats_back()
    self:add()
end

function stats:gethms(num, hoursenabled)
    local hours = floor((num/30) / 3600)
    local minutes = floor((num/30) / 60 - (hours * 60))
    local seconds = floor((num/30) - (hours * 3600) - (minutes * 60))
    if hoursenabled then
        return hours .. 'h ' .. minutes .. 'm ' .. seconds .. 's'
    else
        return minutes .. 'm ' .. seconds .. 's'
    end
end

function stats:getdistancecranked(num)
    local crank_distance
    local crank_distance_string
    if save.metric then
        crank_distance = (num / 360) * 125.66
        if crank_distance > 1000000 then
            crank_distance_string = commalize(format("%.2f", crank_distance / 1000000)) .. text('km')
        elseif crank_distance > 1000 then
            crank_distance_string = commalize(format("%.2f", crank_distance / 1000)) .. text('m')
        else
            crank_distance_string = commalize(format("%.2f", crank_distance)) .. text('mm')
        end
    else
        crank_distance = (num / 360) * 4.95
        if crank_distance > 63360 then
            crank_distance_string = commalize(format("%.2f", crank_distance / 63360)) .. text('mi')
        elseif crank_distance > 12 then
            crank_distance_string = commalize(format("%.2f", crank_distance / 12)) .. text('ft')
        else
            crank_distance_string = commalize(format("%.2f", crank_distance)) .. text('in')
        end
    end
    return crank_distance_string
end

function stats:leave() -- Leave and move back to the title screen
    vars.transitioning = true -- Make sure you don't accept any more button presses at this time
    vars.anim_wave_y:resetnew(1000, sprites.wave.y, -40, pd.easingFunctions.inBack) -- Send the wave back up to transition smoothly
    pd.timer.performAfterDelay(1200, function() -- After that animation's done...
        title_memorize = 'stats'
        scenemanager:switchscene(title, title_memorize) -- Switch back to the title!
    end)
end

function stats:refreshonlinestats()
    if not vars.show_leaderboards then
        vars.show_leaderboards = true
        vars.lb_degreescranked_result = {}
        vars.lb_racetime_result = {}
        vars.lb_crashes_result = {}
        gfx.sprite.redrawBackground()
        self:sendonlinestatsscores()
    end
end

function stats:sendonlinestatsscores()
    if playtest then return end
    corner('sendscore')
    pd.scoreboards.addScore('racetime', floor(save.total_racetime), function(status)
        if status.code ~= "OK" then
            makepopup(text('whoops'), text('popup_leaderboard_failed'), text('ok'), false)
            vars.lb_racetime_result = "fail"
            vars.lb_crashes_result = "fail"
            vars.lb_degreescranked_result = "fail"
            gfx.sprite.redrawBackground()
        end
        pd.scoreboards.addScore('crashes', save.total_crashes, function(status)
            if status.code ~= "OK" then
                vars.lb_racetime_result = "fail"
                vars.lb_crashes_result = "fail"
                vars.lb_degreescranked_result = "fail"
                gfx.sprite.redrawBackground()
            end
            pd.scoreboards.addScore('degreescranked', floor(save.total_degrees_cranked), function(status)
                if status.code == "OK" then
                    stats:getonlinestatsscores()
                else
                    vars.lb_racetime_result = "fail"
                    vars.lb_crashes_result = "fail"
                    vars.lb_degreescranked_result = "fail"
                    gfx.sprite.redrawBackground()
                end
            end)
        end)
    end)
end

function stats:getonlinestatsscores()
    pd.scoreboards.getScores('racetime', function(status, result)
        if status.code == "OK" then
            vars.lb_racetime_result = result
            pd.scoreboards.getScores('crashes', function(status, result)
                if status.code == "OK" then
                    vars.lb_crashes_result = result
                    pd.scoreboards.getScores('degreescranked', function(status, result)
                        if status.code == "OK" then
                            vars.lb_degreescranked_result = result
                        else
                            vars.lb_degreescranked_result = "fail"
                        end
                        gfx.sprite.redrawBackground()
                    end)
                else
                    vars.lb_crashes_result = "fail"
                    vars.lb_degreescranked_result = "fail"
                end
                gfx.sprite.redrawBackground()
            end)
        else
            vars.lb_racetime_result = "fail"
            vars.lb_crashes_result = "fail"
            vars.lb_degreescranked_result = "fail"
        end
        gfx.sprite.redrawBackground()
    end)
end