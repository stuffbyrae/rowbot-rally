import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local text <const> = gfx.getLocalizedText
local random <const> = math.random

class('credits').extends(gfx.sprite) -- Create the scene's class
function credits:init(...)
    credits.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local pauseimage = gfx.image.new(400, 240)
        pd.setMenuImage(pauseimage, 100)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        credits = gfx.image.new('images/ui/credits'),
        polaroid = gfx.imagetable.new('images/ui/polaroid'),
        pedallica = gfx.font.new('fonts/pedallica'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        creditsscrolly = pd.timer.new(76719, 0, -2640),
        anim_fade = pd.timer.new(1, 1, 1),
        showcover1 = true,
        showcover2 = true,
        polaroids = {},
    }

    vars.anim_fade.discardOnCompletion = false

    save.stories_completed += 1
    save['slot' .. save.current_story_slot .. '_progress'] = "finish"

    local randomnum
    local dont
    local i = 0
    while #vars.polaroids < 6 do
        i += 1
        dont = false
        randomnum = random(1, 12)
        if i > 1 then
            for n = 1, i do
                if vars.polaroids[n] == randomnum then
                    dont = true
                end
            end
        end
        if not dont then
            table.insert(vars.polaroids, randomnum)
        end
    end
    randomnum = nil
    dont = nil
    i = nil

    pd.timer.performAfterDelay(4794, function()
        vars.anim_fade:resetnew(1, 34, 34)
    end)

    pd.timer.performAfterDelay(7179, function()
        vars.showcover1 = false
    end)
    pd.timer.performAfterDelay(9544, function()
        vars.showcover2 = false
    end)
    vars.creditsscrolly.delay = 11906
    vars.creditsscrolly.timerEndedCallback = function()
        pd.timer.performAfterDelay(5000, function()
            vars.anim_fade:resetnew(2000, 34, 1)
            pd.timer.performAfterDelay(2000, function()
                title_memorize = 'story_mode'
                if save.seen_credits then
                    scenemanager:switchscene(title, title_memorize)
                else
                    save.seen_credits = true
                    scenemanager:switchscene(notif, text('game_complete'), text('popup_game_complete'), text('title_screen'), false, function() scenemanager:switchscene(title, title_memorize) end)
                end
            end)
        end)
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.polaroid[vars.polaroids[1]]:draw(29, 412 + vars.creditsscrolly.value)
        assets.polaroid[vars.polaroids[2]]:draw(213, 652 + vars.creditsscrolly.value)
        assets.polaroid[vars.polaroids[3]]:draw(29, 892 + vars.creditsscrolly.value)
        assets.polaroid[vars.polaroids[4]]:draw(213, 1132 + vars.creditsscrolly.value)
        assets.polaroid[vars.polaroids[5]]:draw(29, 1372 + vars.creditsscrolly.value)
        assets.polaroid[vars.polaroids[6]]:draw(213, 1612 + vars.creditsscrolly.value)
        assets.credits:draw(0, vars.creditsscrolly.value)
        -- Draw text
        if not vars.showcover1 then
            assets.pedallica:drawTextAligned(text('madebyrae'), 200, 182 + vars.creditsscrolly.value, kTextAlignment.center)
            if not vars.showcover2 then
                assets.pedallica:drawTextAligned(text('andsomanyotherpeople'), 200, 195 + vars.creditsscrolly.value, kTextAlignment.center)
            end
        end
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.kapel_doubleup:drawText(text('programming'), 207, 400 + vars.creditsscrolly.value)
        assets.pedallica:drawText(text('programming_desc'), 207, 425 + vars.creditsscrolly.value)
        assets.kapel_doubleup:drawText(text('sounds'), 14, 655 + vars.creditsscrolly.value)
        assets.pedallica:drawText(text('sounds_desc'), 14, 685 + vars.creditsscrolly.value)
        assets.kapel_doubleup:drawText(text('art'), 220, 915 + vars.creditsscrolly.value)
        assets.pedallica:drawText(text('art_desc'), 220, 940 + vars.creditsscrolly.value)
        assets.kapel_doubleup:drawText(text('bugsmashers'), 14, 1140 + vars.creditsscrolly.value)
        assets.pedallica:drawText(text('bugsmashers_desc'), 14, 1165 + vars.creditsscrolly.value)
        assets.kapel_doubleup:drawText(text('playtesters'), 220, 1403 + vars.creditsscrolly.value)
        assets.pedallica:drawText(text('playtesters_desc'), 220, 1428 + vars.creditsscrolly.value)
        assets.kapel_doubleup:drawText(text('radstuff'), 14, 1601 + vars.creditsscrolly.value)
        assets.pedallica:drawText(text('radstuff_desc'), 14, 1626 + vars.creditsscrolly.value)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        assets.kapel_doubleup:drawTextAligned(text('thankyouto'), 200, 1931 + vars.creditsscrolly.value, kTextAlignment.center)
        assets.pedallica:drawTextAligned(text('thankyouto_desc'), 200, 1964 + vars.creditsscrolly.value, kTextAlignment.center)
        assets.pedallica:drawTextAligned(text('copyright'), 200, 2507 + vars.creditsscrolly.value, kTextAlignment.center)
        assets.kapel_doubleup:drawTextAligned(text('thankyouforplaying'), 200, 2656 + vars.creditsscrolly.value, kTextAlignment.center)
    end)

    class('credits_fade').extends(gfx.sprite)
    function credits_fade:init()
        credits_fade.super.init(self)
        self:setImage(assets.image_fade[34])
        self:setCenter(0, 0)
        self:setIgnoresDrawOffset(true)
        self:setZIndex(9)
        self:add()
    end
    function credits_fade:update()
        if vars.anim_fade ~= nil then
            self:setImage(assets.image_fade[math.floor(vars.anim_fade.value)])
        end
    end

    sprites.fade = credits_fade()
    self:add()

    savegame(true) -- Save the game!
    newmusic('audio/music/credits') -- Adding new music
end