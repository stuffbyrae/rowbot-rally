import 'title'
import 'tutorial'
import 'intro'
import 'chase'
import 'credits'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry

class('cutscene').extends(gfx.sprite) -- Create the scene's class
function cutscene:init(...)
    cutscene.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        img_border_intro = gfx.imagetable.new('images/story/border_intro'), -- Border scene entry animation
        img_border = gfx.imagetable.new('images/story/border'), -- Border idle animation
        img_border_outro = gfx.imagetable.new('images/story/border_outro'), -- Border scene-exit animation
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        play = args[1], -- What scene do we play?
    }
    assert(vars.play, 'hey find me a video you dummy') -- dummy.
    vars.anim_border = gfx.animation.loop.new(70, assets.img_border_intro, false) -- Set up the border intro animation

    assets.video = gfx.video.new('images/story/scene' .. vars.play) -- Get me the video,
    assets.sfx = fle.new('audio/story/scene' .. vars.play .. '_sfx') -- the sounds,
    assets.music = fle.new('audio/story/scene' .. vars.play .. '_music') -- and the music.

    assets.video:renderFrame(0)
    assets.sfx:setVolume(save.vol_sfx/5)
    assets.music:setVolume(save.vol_music/5)
    assets.sfx:play()
    assets.music:play()

    assets.sfx:setFinishCallback(function()
        assets.music:stop()
        vars.anim_border = gfx.animation.loop.new(70, assets.img_border_outro, false)
        pd.timer.performAfterDelay(550, function()
            if vars.play == 1 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'tutorial'
            elseif vars.play == 2 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'race1'
            elseif vars.play == 3 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'race2'
            elseif vars.play == 4 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'race3'
            elseif vars.play == 5 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'race4'
            elseif vars.play == 6 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'chase'
            elseif vars.play == 7 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'race5'
            elseif vars.play == 8 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'race6'
            elseif vars.play == 9 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'race7'
            elseif vars.play == 10 then
                save['slot' .. save.current_story_slot .. '_progress'] = 'finish'
            end
            scenemanager:switchstory()
        end)
    end)

    self:setImage(gfx.image.new(356, 200, gfx.kColorWhite))
    self:setCenter(0.5, 0.5)
    self:moveTo(200, 120)
    self:setZIndex(1)
    assets.video:setContext(self:getImage())

    class('cutscene_border').extends(gfx.sprite)
    function cutscene_border:init()
        cutscene_border.super.init(self)
        self:moveTo(200, 120)
        self:setZIndex(2)
        self:add()
    end
    function cutscene_border:update()
        self:setImage(vars.anim_border:image())
    end

    -- Set the sprites
    self.border = cutscene_border()
    self:add()
end

-- Scene update loop
function cutscene:update()
    if not vars.anim_border:isValid() then
        vars.anim_border = gfx.animation.loop.new(400, assets.img_border, true)
    end
    local frame = math.floor(assets.sfx:getOffset() * 10)
    if frame ~= vars.lastframe then
        assets.video:renderFrame(frame)
        vars.lastframe = frame
        self:markDirty()
    end
end