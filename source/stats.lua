-- Gotta switch back to this later.
import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('stats').extends(gfx.sprite) -- Create the scene's class
function stats:init(...)
    stats.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addCheckmarkMenuItem(gfx.getLocalizedText('metric'), save.metric, function(new)
            save.metric = new
            self:draw_main_image()
        end)
        menu:addMenuItem(gfx.getLocalizedText('backtotitle'), function()
            if not vars.transitioning then
                self:leave()
            end
        end)
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        pedallica = gfx.font.new('fonts/pedallica'),
        image_main = gfx.image.new(400, 240, gfx.kColorWhite),
        image_ticker = gfx.image.new(481, 20, gfx.kColorBlack),
        image_wave = gfx.image.new('images/ui/wave'),
        image_wave_composite = gfx.image.new(464, 280),
        image_back = makebutton(gfx.getLocalizedText('back'), "small2")
    }

    -- Writing in the image for the "Stats" header ticker
    gfx.pushContext(assets.image_ticker)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stats'), 6, -3)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stats'), 87, -3)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stats'), 168, -3)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stats'), 249, -3)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stats'), 330, -3)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stats'), 411, -3)
        assets.kapel_doubleup:drawText(gfx.getLocalizedText('stats'), 492, -3)
    gfx.popContext()

    -- Writing in the image for the wave banner along the bottom
    gfx.pushContext(assets.image_wave_composite)
        assets.image_wave:drawTiled(0, 0, 464, 280)
    gfx.popContext()
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        transitioning = true,
        anim_ticker = gfx.animator.new(2000, 0, -81),
        anim_wave_x = gfx.animator.new(5000, 0, -58),
        anim_wave_y = gfx.animator.new(1000, -30, 185, pd.easingFunctions.outCubic), -- Send the wave down from above
        crank_distance_mm = (save.total_degrees_cranked / 360) * 125.66,
        crank_distance_in = (save.total_degrees_cranked / 360) * 4.95,
        stage_plays = { -- Each number here is the stage's total play count, with the stage's own number tacked onto the end for record-keeping.
            tonumber(save.stage1_plays .. 1),
            tonumber(save.stage2_plays .. 2),
            tonumber(save.stage3_plays .. 3),
            tonumber(save.stage4_plays .. 4),
            tonumber(save.stage5_plays .. 5),
            tonumber(save.stage6_plays .. 6),
            tonumber(save.stage7_plays .. 7),
        },
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
        vars.anim_wave_y = gfx.animator.new(5000, 185, 195, pd.easingFunctions.inOutCubic) -- Set the wave's idle animation,
        vars.anim_wave_y.repeatCount = -1 -- make it repeat forever,
        vars.anim_wave_y.reverses = true -- and make it loop!
    end)

    vars.anim_ticker.repeatCount = -1
    vars.anim_wave_x.repeatCount = -1

    table.sort(vars.stage_plays) -- Sorting the stage plays table...
    vars.mps = vars.stage_plays[7] -- Saving the most-played stage for shorthand
    vars.lps = vars.stage_plays[1] -- Saving the least-played stage for shorthand
    -- Modulo either of those numbers by 10 and you'll get JUST the stage number
    -- Divide either of those numbers by 10 and floor it, and you'll get JUST the playcount.

    -- Calculating hours, minutes, and seconds from the total game play time
    vars.total_playtime_hours = math.floor((save.total_playtime/30) / 3600)
    vars.total_playtime_minutes = math.floor((save.total_playtime/30) / 60 - (vars.total_playtime_hours * 60))
    vars.total_playtime_seconds = math.floor((save.total_playtime/30) - (vars.total_playtime_hours * 3600) - (vars.total_playtime_minutes * 60))

    -- Calculating hours, minutes, and seconds from the total race time
    vars.total_racetime_hours = math.floor((save.total_racetime/30) / 3600)
    vars.total_racetime_minutes = math.floor((save.total_racetime/30) / 60 - (vars.total_racetime_hours * 60))
    vars.total_racetime_seconds = math.floor((save.total_racetime/30) - (vars.total_racetime_hours * 3600) - (vars.total_racetime_minutes * 60))

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
    end)

    class('main').extends(gfx.sprite)
    function main:init()
        main.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(0)
        self:add()
    end
    
    class('ticker').extends(gfx.sprite)
    function ticker:init()
        ticker.super.init(self)
        self:setImage(assets.image_ticker)
        self:setCenter(0, 0)
        self:setZIndex(1)
        self:add()
    end
    function ticker:update()
        self:moveTo(vars.anim_ticker:currentValue(), 0)
    end

    class('wave').extends(gfx.sprite)
    function wave:init()
        wave.super.init(self)
        self:setImage(assets.image_wave_composite)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:moveTo(0, 185)
        self:add()
    end
    function wave:update()
        self:moveTo(vars.anim_wave_x:currentValue(), vars.anim_wave_y:currentValue())
    end

    class('back').extends(gfx.sprite)
    function back:init()
        back.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(3)
        self:setImage(assets.image_back)
        self:moveTo(295, 210)
        self:add()
    end
    function back:update()
        self:moveTo(295, (vars.anim_wave_y:currentValue()*1.1))
    end
    
    -- Set the sprites
    self.main = main()
    self.ticker = ticker()
    self.wave = wave()
    self.back = back()
    self:add()

    self:draw_main_image()
end

-- Writing in the main stats image; wrapped inside a function so this can be refreshed if necessary.
function stats:draw_main_image()
    assets.image_main = gfx.image.new(400, 240, gfx.kColorWhite)
    gfx.pushContext(assets.image_main)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_total') .. gfx.getLocalizedText('stats_playtime'), 10, 30)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_timespentracing'), 10, 45)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_total') .. gfx.getLocalizedText('stats_crashes'), 10, 70)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_racescompleted'), 10, 85)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_storiescompleted'), 10, 100)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_distancecranked'), 10, 115)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_favoritestage_' .. tostring(save.metric)), 10, 140)
        assets.pedallica:drawText(gfx.getLocalizedText('stats_leastfavoritestage_' .. tostring(save.metric)), 10, 155)
        if vars.total_playtime_hours > 0 then -- Only display hours slot if there are hours to be slotted
            assets.pedallica:drawTextAligned(vars.total_playtime_hours .. 'h ' .. vars.total_playtime_minutes .. 'm ' .. vars.total_playtime_seconds .. 's', 390, 30, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(vars.total_playtime_minutes .. 'm ' .. vars.total_playtime_seconds .. 's', 390, 30, kTextAlignment.right)
        end
        if vars.total_racetime_hours > 0 then -- Only display hours slot if there are hours to be slotted
            assets.pedallica:drawTextAligned(vars.total_racetime_hours .. 'h ' .. vars.total_racetime_minutes .. 'm ' .. vars.total_racetime_seconds .. 's', 390, 45, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(vars.total_racetime_minutes .. 'm ' .. vars.total_racetime_seconds .. 's', 390, 45, kTextAlignment.right)
        end
        assets.pedallica:drawTextAligned(save.total_crashes, 390, 70, kTextAlignment.right)
        assets.pedallica:drawTextAligned(save.total_races_completed, 390, 85, kTextAlignment.right)
        assets.pedallica:drawTextAligned(save.stories_completed, 390, 100, kTextAlignment.right)
        if save.metric then
            if vars.crank_distance_mm > 1000000 then
                assets.pedallica:drawTextAligned(string.format("%.2f", vars.crank_distance_mm / 1000000) .. gfx.getLocalizedText('km'), 390, 115, kTextAlignment.right)
            elseif vars.crank_distance_mm > 1000 then
                assets.pedallica:drawTextAligned(string.format("%.2f", vars.crank_distance_mm / 1000) .. gfx.getLocalizedText('m'), 390, 115, kTextAlignment.right)
            else
                assets.pedallica:drawTextAligned(string.format("%.2f", vars.crank_distance_mm) .. gfx.getLocalizedText('mm'), 390, 115, kTextAlignment.right)
            end
        else
            if vars.crank_distance_in > 63360 then
                assets.pedallica:drawTextAligned(string.format("%.2f", vars.crank_distance_in / 63360) .. gfx.getLocalizedText('mi'), 390, 115, kTextAlignment.right)
            elseif vars.crank_distance_in > 12 then
                assets.pedallica:drawTextAligned(string.format("%.2f", vars.crank_distance_in / 12) .. gfx.getLocalizedText('ft'), 390, 115, kTextAlignment.right)
            else
                assets.pedallica:drawTextAligned(string.format("%.2f", vars.crank_distance_in) .. gfx.getLocalizedText('in'), 390, 115, kTextAlignment.right)
            end
        end
        if vars.mps > 10 then -- If there's no plays on any stage, the highest it will go is "07" — in that event, don't bother picking a "Favorite stage" since all of them are 0 plays.
            assets.pedallica:drawTextAligned(gfx.getLocalizedText('stage_' .. vars.mps % 10 .. '_name') .. ' (' .. math.floor(vars.mps / 10) .. ' plays)', 390, 140, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned('N/A', 390, 140, kTextAlignment.right)
        end
        if vars.lps > 10 then -- Only start counting "Least favorite stage"" after every stage has had at least one play, to ensure fairness.
            assets.pedallica:drawTextAligned(gfx.getLocalizedText('stage_' .. vars.lps % 10 .. '_name') .. ' (' .. math.floor(vars.lps / 10) .. ' plays)', 390, 155, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned('N/A', 390, 155, kTextAlignment.right)
        end
    gfx.popContext()
    self.main:setImage(assets.image_main)
end

function stats:leave() -- Leave and move back to the title screen
    vars.transitioning = true -- Make sure you don't accept any more button presses at this time
    vars.anim_wave_y = gfx.animator.new(1000, self.wave.y, -40, pd.easingFunctions.inBack) -- Send the wave back up to transition smoothly
    pd.timer.performAfterDelay(1000, function() -- After that animation's done...
        scenemanager:switchscene(title) -- Switch back to the title!
    end)
end