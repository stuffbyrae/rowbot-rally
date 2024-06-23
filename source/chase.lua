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
        crash = gfx.image.new('images/chase/crash'),
        sfx_crash = smp.new('audio/sfx/crash'),
    }
    assets.sfx_crash:setVolume(save.vol_sfx/5)

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        skippable = args[1], -- A bool. Only true if the player's entering from a game over.
        boat_turn = 5,
        boat_turn_min = 9,
        boat_turn_max = 1,
        boat_speed = 0,
        boat_speed_min = -10,
        boat_speed_max = 10,
        boat_pos_min = 70,
        boat_pos_max = 330,
        boat_can_move = false,
        rocks_can_spawn = false,
        crashes = 0,
        anim_shark_chomp = pd.timer.new(0, 0, 0)
    }
    vars.chaseHandlers = {
        -- Input handlers go here...
    }
    pd.inputHandlers.push(vars.chaseHandlers)

    vars.anim_shark_chomp.discardOnCompletion = false

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.sky:draw(0, 0)
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
        self:setZIndex(2)
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
    end
    function chase_boat:small_crash(dir)
        vars.crashes += 0.5
        assets.sfx_crash:stop()
        assets.sfx_crash:setRate(1 + (random() - 0.5))
        assets.sfx_crash:play()
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
    local change = max(pd.getCrankChange(), 1)
    if not vars.boat_can_move and change > 1 then
        vars.boat_can_move = true
    end
    if vars.boat_can_move then
        vars.boat_speed -= 1
        vars.boat_speed += change / 10
        vars.boat_speed = max(vars.boat_speed_min - 5, min(vars.boat_speed_max + 5, vars.boat_speed))
        sprites.boat:moveBy(max(vars.boat_speed_min, min(vars.boat_speed_max, vars.boat_speed)), 0)
        sprites.boat:moveTo(sprites.boat.x, 220 + (vars.crashes * 5))
        sprites.shark:moveBy((sprites.boat.x - sprites.shark.x) * 0.075, 0)
        sprites.shark:moveTo(sprites.shark.x, 400 - (vars.crashes * 5) - vars.anim_shark_chomp.value)
        sprites.boat:setImage(assets.boat[floor(-vars.boat_speed / 3.75) + 5])
        if sprites.boat.x < vars.boat_pos_min then
            sprites.boat:small_crash(false)
        end
        if sprites.boat.x > vars.boat_pos_max then
            sprites.boat:small_crash(true)
        end
    end
    gfx.setDrawOffset((-sprites.boat.x + 200) * 0.3, 0)
end

function chase:win()
    save['slot' .. save.current_story_slot .. '_progress'] = 'cutscene7'
end

function chase:lose()
    vars.anim_shark_chomp:resetnew(1000, 0, 110, pd.easingFunctions.inOutBack)
    vars.rocks_can_spawn = false
    pd.timer.performAfterDelay(1000, function()
    end)
end