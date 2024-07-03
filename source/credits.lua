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
        setpauseimage(200) -- TODO: Set this X offset
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_fade = gfx.imagetable.new('images/ui/fade/fade'),
        credits = gfx.image.new('images/ui/credits'),
        creditscover1 = gfx.image.new('images/ui/creditscover1'),
        creditscover2 = gfx.image.new('images/ui/creditscover2'),
        polaroid = gfx.imagetable.new('images/ui/polaroid'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        creditsscrolly = pd.timer.new(145989, 0, -2640),
        anim_fade = pd.timer.new(1, 1, 1),
        showcover1 = true,
        showcover2 = true,
        polaroids = {},
    }
    vars.creditsHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.creditsHandlers)

    vars.anim_fade.discardOnCompletion = false

    save.stories_completed += 1
    save['slot' .. save.current_story_slot .. '_progress'] = "finish"
    if save['slot' .. save.current_story_slot .. '_circuit'] < 4 then
        save['slot' .. save.current_story_slot .. '_circuit'] += 1
    end

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

    pd.timer.performAfterDelay(5538, function()
        vars.anim_fade:resetnew(1, 34, 34)
    end)

    pd.timer.performAfterDelay(8158, function()
        vars.showcover1 = false
    end)
    pd.timer.performAfterDelay(10867, function()
        vars.showcover2 = false
    end)
    vars.creditsscrolly.delay = 13487
    vars.creditsscrolly.timerEndedCallback = function()
        pd.timer.performAfterDelay(5000, function()
            vars.anim_fade:resetnew(2000, 34, 1)
            pd.timer.performAfterDelay(2000, function()
                if save.seen_credits then
                    scenemanager:switchscene(title)
                else
                    save.seen_credits = true
                    scenemanager:switchscene(notif, text('game_complete'), text('popup_game_complete'), text('title_screen'), false, function() scenemanager:switchscene(title) end)
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
        if vars.showcover2 then assets.creditscover2:draw(0, 0) end
        if vars.showcover1 then assets.creditscover1:draw(0, 0) end
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