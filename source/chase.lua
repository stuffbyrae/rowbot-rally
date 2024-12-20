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
        if vars.lost then
            setpauseimage(0)
        else
            setpauseimage(max(0, min(200, floor(sprites.boat.x) - 100)), true)
        end
        if vars.skippable then
            menu:addMenuItem(text('skipchase'), function()
                self:win()
            end)
        end
        if vars.playing then
            menu:addMenuItem(text('quitfornow'), function()
                vars.playing = false
                fademusic(999)
                vars.anim_overlay:resetnew(1000, 34, 1)
                pd.timer.performAfterDelay(1000, function()
                    title_memorize = 'story_mode'
                    scenemanager:switchscene(title, title_memorize)
                end)
            end)
        end
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        sky_1 = gfx.image.new('images/chase/sky_1'),
        sky_2 = gfx.image.new('images/chase/sky_2'),
        sky_3 = gfx.image.new('images/chase/sky_3'),
        boat = gfx.imagetable.new('images/chase/boat'),
        bg = gfx.imagetable.new('images/chase/bg'),
        shark = gfx.image.new('images/chase/shark'),
        fade = gfx.imagetable.new('images/ui/fade/fade'),
        chomp = gfx.imagetable.new('images/chase/chomp'),
        crash = gfx.image.new('images/chase/crash'),
        splash = gfx.imagetable.new('images/chase/splash'),
        sfx_crash = smp.new('audio/sfx/crash'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        kapel_doubleup_outline = gfx.font.new('fonts/kapel_doubleup_outline'),
        rock = gfx.imagetable.new('images/chase/rock'),
        warn = gfx.imagetable.new('images/chase/warn'),
        sfx_blips = smp.new('audio/sfx/blips'),
        sfx_chomp = smp.new('audio/sfx/chomp'),
        sfx_cymbal = smp.new('audio/sfx/cymbal'),
        sfx_rock = smp.new('audio/sfx/rock'),
        oar = gfx.imagetable.new('images/chase/oar'),
        oar_ground = gfx.imagetable.new('images/chase/oar_ground'),
    }
    assets.sfx_crash:setVolume(save.vol_sfx/5)
    assets.sfx_blips:setVolume(save.vol_sfx/5)
    assets.sfx_chomp:setVolume(save.vol_sfx/5)
    assets.sfx_cymbal:setVolume(save.vol_sfx/5)
    assets.sfx_rock:setVolume(save.vol_sfx/5)
    gfx.setFont(assets.kapel_doubleup)
    assets.dir = gfx.imageWithText(text('chasedir'), 350, 50)
    assets.dir = assets.dir:scaledImage(2)
    gfx.setFont(assets.kapel_doubleup_outline)
    assets.overlay = assets.fade

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        skippable = args[1], -- A bool. Only true if the player's entering from a game over.
        boat_turn = 5,
        boat_turn_min = 9,
        boat_turn_max = 1,
        boat_speed = 0,
        boat_speed_min = -10,
        boat_speed_max = 10,
        boat_pos_min = 50,
        boat_pos_max = 350,
        boat_can_move = false,
        boat_can_crash = true,
        rocks_can_spawn = false,
        change = 1,
        crashes = 0,
        anim_sky = pd.timer.new(120000, -0, -50),
        anim_bg = pd.timer.new(500, 1, 6.99),
        anim_shark_chomp = pd.timer.new(0, 0, 0),
        anim_entrance = pd.timer.new(1000, 200, 0, pd.easingFunctions.outBack),
        anim_boat_y = pd.timer.new(500, 0, -3),
        anim_overlay = pd.timer.new(750, 1, 34),
        anim_warn = pd.timer.new(250, 1, 3.99),
        anim_invinc = pd.timer.new(1, 1, 1),
        anim_rock = pd.timer.new(1, 0, 0),
        anim_splash = pd.timer.new(500, 1, 4.99),
        anim_oar_1 = pd.timer.new(500, 1, 8.99),
        anim_oar_2 = pd.timer.new(500, 1, 8.99),
        playing = true,
        show_warn = false,
        show_rock = false,
        rock_x = 0,
        rocks_passed = 0,
        lost = false,
        showdir = false,
        crashed_left = false,
        crashed_right = false,
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
    vars.anim_bg.repeats = true
    vars.anim_boat_y.reverses = true
    vars.anim_boat_y.repeats = true
    vars.anim_warn.repeats = true
    vars.anim_splash.repeats = true
    vars.anim_oar_1.repeats = true
    vars.anim_oar_1.discardOnCompletion = false
    vars.anim_oar_2.discardOnCompletion = false

    vars.anim_oar_2.timerEndedCallback = function()
        vars.anim_oar_2:resetnew(500 + (vars.boat_speed * 50), 1, 8.99)
    end

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
        assets.sky_1:draw(0, 0)
        assets.sky_2:draw(0, vars.anim_sky.value)
        assets.sky_3:draw(0, vars.anim_sky.value * 1.5)
        if vars.showdir then
            assets.dir:drawAnchored(200, 10, 0.5, 0)
        end
    end)

    class('chase_bg', _, classes).extends(gfx.sprite)
    function classes.chase_bg:init()
        classes.chase_bg.super.init(self)
        self:setImage(assets.bg[1])
        self:setCenter(0.5, 1)
        self:moveTo(200, 240)
        self:setZIndex(1)
        self:add()
    end
    function classes.chase_bg:update()
        self:setImage(assets.bg[floor(vars.anim_bg.value)])
    end

    class('chase_rocks', _, classes).extends(gfx.sprite)
    function classes.chase_rocks:init()
        classes.chase_rocks.super.init(self)
        self:setSize(400, 240)
        self:setCenter(0, 0)
        self:moveTo(0, 0)
        self:setZIndex(2)
        self:add()
    end
    function classes.chase_rocks:draw()
        if vars.show_warn then
            assets.warn[floor(vars.anim_warn.value)]:drawAnchored(vars.rock_x, 90, 0.5, 1)
        end
        if vars.show_rock then
            assets.rock[(vars.rock_x % 4) + 1]:drawAnchored(vars.rock_x, vars.anim_rock.value, 0.5, 1)
        end
    end

    class('chase_oars', _, classes).extends(gfx.sprite)
    function classes.chase_oars:init()
        classes.chase_oars.super.init(self)
        self:setSize(230, 100)
        self:setCenter(0.5, 1)
        self:moveTo(200, 220)
        self:setZIndex(3)
        self:add()
    end
    function classes.chase_oars:draw()
        if floor(vars.anim_invinc.value) == 1 then
            if self.x < 100 then
                assets.oar_ground[floor(vars.anim_oar_2.value)]:draw(0, 0)
            else
                assets.oar[floor(vars.anim_oar_2.value)]:draw(0, 0)
            end
            if self.x > 300 then
                assets.oar_ground[floor(vars.anim_oar_1.value)]:draw(100, 0, "flipX")
            else
                assets.oar[floor(vars.anim_oar_1.value)]:draw(100, 0, "flipX")
            end
        end
    end

    class('chase_boat', _, classes).extends(gfx.sprite)
    function classes.chase_boat:init()
        classes.chase_boat.super.init(self)
        self:setImage(assets.boat[5])
        self:setCenter(0.5, 1)
        self:moveTo(200, 220)
        self:setZIndex(3)
        self:add()
    end
    function classes.chase_boat:crash()
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
    function classes.chase_boat:small_crash(dir)
        vars.crashes += 0.25
        if vars.boat_can_move then
            assets.sfx_crash:stop()
            assets.sfx_crash:setRate(1 + (random() - 0.5))
            assets.sfx_crash:play()
        end
        if dir then
            vars.boat_speed = -20
            sprites.boat:moveTo(vars.boat_pos_max, sprites.boat.y)
            vars.crashed_right = true
            pd.timer.performAfterDelay(250, function()
                vars.crashed_right = false
            end)
        else
            vars.boat_speed = 10
            sprites.boat:moveTo(vars.boat_pos_min, sprites.boat.y)
            vars.crashed_left = true
            pd.timer.performAfterDelay(250, function()
                vars.crashed_left = false
            end)
        end
    end

    class('chase_splash', _, classes).extends(gfx.sprite)
    function classes.chase_splash:init()
        classes.chase_splash.super.init(self)
        self:setCenter(0.5, 1)
        self:moveTo(200, 220)
        self:setZIndex(4)
        self:add()
    end

    class('chase_shark', _, classes).extends(gfx.sprite)
    function classes.chase_shark:init()
        classes.chase_shark.super.init(self)
        self:setImage(assets.shark)
        self:setCenter(0.5, 1)
        self:moveTo(200, 400)
        self:setZIndex(6)
        self:add()
    end

    class('chase_overlay', _, classes).extends(gfx.sprite)
    function classes.chase_overlay:init()
        classes.chase_overlay.super.init(self)
        self:setIgnoresDrawOffset(true)
        self:moveTo(0, 0)
        self:setCenter(0, 0)
        self:setZIndex(99)
        self:add()
    end
    function classes.chase_overlay:update()
        self:setImage(assets.overlay[floor(vars.anim_overlay.value)])
    end

    -- Set the sprites
    sprites.bg = classes.chase_bg()
    sprites.rocks = classes.chase_rocks()
    sprites.oars = classes.chase_oars()
    sprites.boat = classes.chase_boat()
    sprites.splash = classes.chase_splash()
    sprites.shark = classes.chase_shark()
    sprites.overlay = classes.chase_overlay()
    self:add()

    savegame() -- Save the game!
    newmusic('audio/music/chase', true, 1.954)
end

-- Scene update loop
function chase:update()
    if pd.isCrankDocked() and not save.button_controls then
        show_crank = true
    end
    if save.button_controls then
        vars.change = 1
        if pd.buttonIsPressed('up') then
            vars.change = 10.8
        end
        if pd.buttonIsPressed('right') then
            vars.change = 21.6
        end
    else
        vars.change = max((pd.getCrankChange() / save.sensitivity) * 1.5, 1)
        save.total_degrees_cranked += pd.getCrankChange() -- Save degrees cranked stat
    end
    if not vars.boat_can_move and vars.change > 7 and vars.playing then
        vars.boat_can_move = true
    end
    if vars.playing and vars.crashes >= 3 then
        self:lose()
    end
    if vars.playing and vars.rocks_passed >= 10 then
        self:win()
    end
    if vars.boat_can_move then
        if not vars.crashed_left then
            vars.boat_speed += vars.change / 6
        end
        if not vars.crashed_right then
            vars.boat_speed -= 1
        end
    end
    vars.boat_speed = max(vars.boat_speed_min - 5, min(vars.boat_speed_max + 5, vars.boat_speed))
    sprites.boat:moveBy(max(vars.boat_speed_min, min(vars.boat_speed_max, vars.boat_speed)), 0)
    if floor(vars.anim_invinc.value) == 1 then
        sprites.boat:setImage(assets.boat[floor(-vars.boat_speed / 3.75) + 5])
        sprites.splash:setImage(assets.splash[floor(vars.anim_splash.value)])
    else
        sprites.boat:setImage(assets.boat[11])
        sprites.splash:setImage(assets.splash[5])
    end
    if sprites.boat.x < vars.boat_pos_min then
        sprites.boat:small_crash(false)
    end
    if sprites.boat.x > vars.boat_pos_max then
        sprites.boat:small_crash(true)
    end
    sprites.boat:moveTo(sprites.boat.x, 220 + (vars.crashes * 5) + vars.anim_boat_y.value + vars.anim_entrance.value)
    sprites.oars:moveTo(sprites.boat.x, sprites.boat.y)
    sprites.splash:moveBy((((sprites.boat.x * 0.8) + 35) - sprites.splash.x) * 0.7, 0)
    sprites.splash:moveTo(sprites.splash.x, 225 + (vars.crashes * 5) + vars.anim_boat_y.value + vars.anim_entrance.value)
    sprites.shark:moveBy((sprites.boat.x - sprites.shark.x) * 0.3, 0)
    sprites.shark:moveTo(sprites.shark.x, 400 - (vars.crashes * 5) - vars.anim_shark_chomp.value + (vars.anim_entrance.value * 2))
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
                if sprites.boat.x >= vars.rock_x - 65 and sprites.boat.x <= vars.rock_x + 65 then
                    sprites.boat:crash()
                else
                    vars.rocks_passed += 1
                end
                sprites.rocks:setZIndex(5)
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
        save['slot' .. save.current_story_slot .. '_progress'] = 'cutscene7'
        vars.playing = false
        show_crank = false
        vars.boat_can_move = false
        vars.boat_speed = 0
        vars.boat_can_crash = false
        fademusic(1000)
        pd.timer.performAfterDelay(200, function()
            sprites.splash:remove()
        end)
        vars.anim_boat_y:resetnew(500, 0, -130, pd.easingFunctions.outSine)
        pd.timer.performAfterDelay(500, function()
            sprites.boat:setZIndex(-1)
            sprites.oars:setZIndex(-2)
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
        show_crank = false
    end)
    pd.timer.performAfterDelay(875, function()
        stopmusic()
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