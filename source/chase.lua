import 'title'
import 'cutscene'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local floor <const> = math.floor
local min <const> = math.min
local max <const> = math.max
local random <const> = math.random
local text <const> = gfx.getLocalizedText

class('chase').extends(gfx.sprite) -- Create the scene's class
function chase:init(...)
    chase.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(max(0, min(200, floor(sprites.boat.x) - 100)), true) -- TODO: Set this X offset
        if vars.skippable then
            menu:addMenuItem(text('skipchase'), function()
                self:win()
            end)
        end
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        sky = gfx.image.new('images/chase/sky'),
        boat = gfx.imagetable.new('images/chase/boat'),
        bg = gfx.imagetable.new('images/chase/bg'),
        shark = gfx.image.new('images/chase/shark'),
        fade = gfx.imagetable.new('images/ui/fade/fade'),
        chomp = gfx.imagetable.new('images/chase/chomp'),
        crash = gfx.image.new('images/chase/crash'),
        sfx_crash = smp.new('audio/sfx/crash'),
        kapel_doubleup_outline = gfx.font.new('fonts/kapel_doubleup_outline'),
        rock = gfx.imagetable.new('images/chase/rock'),
        warn = gfx.imagetable.new('images/chase/warn'),
        sfx_blips = smp.new('audio/sfx/blips'),
        sfx_chomp = smp.new('audio/sfx/chomp'),
        sfx_cymbal = smp.new('audio/sfx/cymbal'),
        sfx_rock = smp.new('audio/sfx/rock'),
    }
    assets.sfx_crash:setVolume(save.vol_sfx/5)
    assets.sfx_blips:setVolume(save.vol_sfx/5)
    assets.sfx_chomp:setVolume(save.vol_sfx/5)
    assets.sfx_cymbal:setVolume(save.vol_sfx/5)
    assets.sfx_rock:setVolume(save.vol_sfx/5)
    gfx.setFont(assets.kapel_doubleup_outline)
    assets.dir = gfx.imageWithText(text('chasedir'), 350, 50)
    assets.overlay = assets.fade

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        skippable = args[1], -- A bool. Only true if the player's entering from a game over.
        boat_turn = 5,
        boat_turn_min = 9,
        boat_turn_max = 1,
        boat_speed = 0,
        boat_speed_min = -10,
        boat_speed_max = 10,
        boat_pos_min = 30,
        boat_pos_max = 370,
        boat_can_move = false,
        boat_can_crash = true,
        rocks_can_spawn = false,
        crashes = 0,
        anim_shark_chomp = pd.timer.new(0, 0, 0),
        anim_boat_y = pd.timer.new(500, 0, -3),
        anim_overlay = pd.timer.new(750, 1, 34),
        anim_warn = pd.timer.new(250, 1, 3.99),
        anim_invinc = pd.timer.new(1, 1, 1),
        anim_rock = pd.timer.new(1, 0, 0),
        playing = true,
        show_warn = false,
        show_rock = false,
        rock_x = 0,
        rocks_passed = 0,
        lost = false,
        showdir = false,
    }
    vars.chaseHandlers = {
        -- Input handlers go here...
        AButtonDown = function()
            if vars.lost then
                scenemanager:transitionsceneoneway(chase, true)
            end
            self:spawnrock()
        end,

        BButtonDown = function()
            if vars.lost then
                scenemanager:transitionsceneonewayback(title)
            end
        end
    }
    pd.inputHandlers.push(vars.chaseHandlers)

    vars.anim_shark_chomp.discardOnCompletion = false
    vars.anim_overlay.discardOnCompletion = false
    vars.anim_rock.discardOnCompletion = false
    vars.anim_invinc.discardOnCompletion = false
    vars.anim_boat_y.reverses = true
    vars.anim_boat_y.repeats = true
    vars.anim_warn.repeats = true

    pd.timer.performAfterDelay(2000, function()
        vars.showdir = true
    end)

    pd.timer.performAfterDelay(4000, function()
        vars.showdir = false
    end)

    pd.timer.performAfterDelay(4750, function()
        self:spawnrock()
    end)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.sky:draw(0, 0)
        if vars.showdir then
            assets.dir:drawAnchored(200, 40, 0.5, 0.5)
        end
    end)

    class('chase_bg').extends(gfx.sprite)
    function chase_bg:init()
        chase_bg.super.init(self)
        self:setImage(assets.bg[1])
        self:setCenter(0.5, 1)
        self:moveTo(200, 240)
        self:setZIndex(1)
        self:add()
    end

    class('chase_rocks').extends(gfx.sprite)
    function chase_rocks:init()
        chase_rocks.super.init(self)
        self:setSize(400, 240)
        self:setCenter(0, 0)
        self:moveTo(0, 0)
        self:setZIndex(2)
        self:add()
    end
    function chase_rocks:draw()
        if vars.show_warn then
            assets.warn[floor(vars.anim_warn.value)]:drawAnchored(vars.rock_x, 90, 0.5, 1)
        end
        if vars.show_rock then
            assets.rock[(vars.rock_x % 4) + 1]:drawAnchored(vars.rock_x, vars.anim_rock.value, 0.5, 1)
        end
    end

    class('chase_boat').extends(gfx.sprite)
    function chase_boat:init()
        chase_boat.super.init(self)
        self:setImage(assets.boat[5])
        self:setCenter(0.5, 1)
        self:moveTo(200, 220)
        self:setZIndex(3)
        self:add()
    end
    function chase_boat:crash()
        if vars.boat_can_crash then
            vars.crashes += 0.75
            assets.sfx_crash:stop()
            assets.sfx_crash:setRate(1 + (random() - 0.5))
            assets.sfx_crash:play()
            if pd.getReduceFlashing() then
                vars.anim_invinc:resetnew(500, 2.99, 1)
            else
                vars.anim_invinc:resetnew(200, 2.99, 1)
            end
            vars.anim_invinc.repeats = true
            shakies()
            vars.boat_can_crash = false
            pd.timer.performAfterDelay(2000, function()
                vars.boat_can_crash = true
                vars.anim_invinc:resetnew(1, 1, 1)
            end)
        end
    end
    function chase_boat:small_crash(dir)
        vars.crashes += 0.25
        if vars.boat_can_move then
            assets.sfx_crash:stop()
            assets.sfx_crash:setRate(1 + (random() - 0.5))
            assets.sfx_crash:play()
        end
        if dir then
            vars.boat_speed = -10
            sprites.boat:moveTo(vars.boat_pos_max, sprites.boat.y)
        else
            vars.boat_speed = 10
            sprites.boat:moveTo(vars.boat_pos_min, sprites.boat.y)
        end
    end

    class('chase_shark').extends(gfx.sprite)
    function chase_shark:init()
        chase_shark.super.init(self)
        self:setImage(assets.shark)
        self:setCenter(0.5, 1)
        self:moveTo(200, 400)
        self:setZIndex(5)
        self:add()
    end

    class('chase_overlay').extends(gfx.sprite)
    function chase_overlay:init()
        chase_overlay.super.init(self)
        self:setIgnoresDrawOffset(true)
        self:moveTo(0, 0)
        self:setCenter(0, 0)
        self:setZIndex(99)
        self:add()
    end
    function chase_overlay:update()
        self:setImage(assets.overlay[floor(vars.anim_overlay.value)])
    end

    -- Set the sprites
    sprites.bg = chase_bg()
    sprites.rocks = chase_rocks()
    sprites.boat = chase_boat()
    sprites.shark = chase_shark()
    sprites.overlay = chase_overlay()
    self:add()

    savegame() -- Save the game!
    newmusic('audio/music/chase', true, 1.954)
end

-- Scene update loop
function chase:update()
    if pd.isCrankDocked() then
        show_crank = true
    end
    local change = max(pd.getCrankChange(), 1)
    if not vars.boat_can_move and change > 1 and vars.playing then
        vars.boat_can_move = true
    end
    if vars.playing and vars.crashes >= 3 then
        self:lose()
    end
    if vars.playing and vars.rocks_passed >= 10 then
        self:win()
    end
    if vars.boat_can_move then
        vars.boat_speed -= 1
        vars.boat_speed += change / 10
    end
    vars.boat_speed = max(vars.boat_speed_min - 5, min(vars.boat_speed_max + 5, vars.boat_speed))
    sprites.boat:moveBy(max(vars.boat_speed_min, min(vars.boat_speed_max, vars.boat_speed)), 0)
    if floor(vars.anim_invinc.value) == 1 then
        sprites.boat:setImage(assets.boat[floor(-vars.boat_speed / 3.75) + 5])
    else
        sprites.boat:setImage(assets.boat[10])
    end
    if sprites.boat.x < vars.boat_pos_min then
        sprites.boat:small_crash(false)
    end
    if sprites.boat.x > vars.boat_pos_max then
        sprites.boat:small_crash(true)
    end
    sprites.boat:moveTo(sprites.boat.x, 220 + (vars.crashes * 5) + vars.anim_boat_y.value)
    sprites.shark:moveBy((sprites.boat.x - sprites.shark.x) * 0.3, 0)
    sprites.shark:moveTo(sprites.shark.x, 400 - (vars.crashes * 5) - vars.anim_shark_chomp.value)
    gfx.setDrawOffset((-sprites.boat.x + 200) * 0.3, 0)
end

function chase:spawnrock()
    if not vars.rock_spawned and vars.playing then
        vars.rock_spawned = true
        sprites.rocks:setZIndex(2)
        if not vars.boat_can_move then
            vars.rock_x = 200
        else
            vars.rock_x = math.random(100, 300)
        end
        vars.show_warn = true
        assets.sfx_blips:play()
        pd.timer.performAfterDelay(2000, function()
            vars.show_warn = false
            assets.sfx_blips:stop()
            sprites.rocks:setZIndex(-1)
            pd.timer.performAfterDelay(500, function()
                sprites.rocks:setZIndex(2)
            end)
            vars.show_rock = true
            assets.sfx_rock:play()
            vars.anim_rock:resetnew(500, 200, 120, pd.easingFunctions.outSine)
            pd.timer.performAfterDelay(500, function()
                vars.anim_rock:resetnew(1250, 120, 450, pd.easingFunctions.inSine)
            end)
            pd.timer.performAfterDelay(1150, function()
                if sprites.boat.x >= vars.rock_x - 55 and sprites.boat.x <= vars.rock_x + 55 then
                    sprites.boat:crash()
                else
                    vars.rocks_passed += 1
                end
                sprites.rocks:setZIndex(4)
            end)
        end)
        pd.timer.performAfterDelay(4750, function()
            vars.rock_spawned = false
            pd.timer.performAfterDelay(1500 * random(), function()
                self:spawnrock()
            end)
        end)
    end
end

function chase:win()
    if vars.playing then
        fademusic(1000)
        save['slot' .. save.current_story_slot .. '_progress'] = 'cutscene7'
        vars.playing = false
        vars.boat_can_move = false
        vars.boat_speed = 0
        vars.boat_can_crash = false
        vars.anim_boat_y:resetnew(500, 0, -130, pd.easingFunctions.outSine)
        pd.timer.performAfterDelay(500, function()
            sprites.boat:setZIndex(-1)
            vars.anim_boat_y:resetnew(750, -130, 400, pd.easingFunctions.inSine)
        end)
        pd.timer.performAfterDelay(1250, function()
            vars.anim_overlay:resetnew(1000, 34, 1)
        end)
        pd.timer.performAfterDelay(2250, function()
            scenemanager:switchstory()
        end)
    end
end

function chase:lose()
    vars.anim_shark_chomp:resetnew(1000, 0, 110, pd.easingFunctions.inOutBack)
    assets.sfx_rock:play()
    vars.playing = false
    vars.rocks_can_spawn = false
    vars.boat_can_crash = false
    pd.timer.performAfterDelay(850, function()
        assets.overlay = assets.chomp
        vars.anim_overlay:resetnew(25, 1, 2)
        vars.boat_can_move = false
    end)
    pd.timer.performAfterDelay(875, function()
        fademusic(1)
        assets.sfx_chomp:play()
        assets.sfx_cymbal:play()
        shakies_y()
    end)
    pd.timer.performAfterDelay(2000, function()
        gfx.pushContext(assets.chomp[2])
            gfx.imageWithText(text('chomped'), 400, 30):drawScaled(25, 10, 2)
            assets.kapel_doubleup_outline:drawText(text('retry'), 25, 175)
            assets.kapel_doubleup_outline:drawText(text('back'), 25, 195)
        gfx.popContext()
    end)
    vars.lost = true
end