import 'options'
import 'title'
import 'intro'
import 'tutorial'
import 'race'
import 'chase'
import 'credits'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)

function cutscene:init(...)
    local args = {...}
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 100
        pd.setMenuImage(img, xoffset)
        menu:addMenuItem(gfx.getLocalizedText("skipscene"), function()
            assets.audio:stop()
        end)
        menu:addMenuItem(gfx.getLocalizedText("backtotitle"), function()
            vars.transition = false
            assets.audio:stop()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        img_border_intro = gfx.imagetable.new('images/story/border_intro'),
        img_border = gfx.imagetable.new('images/story/border'),
        img_border_outro = gfx.imagetable.new('images/story/border_outro'),
    }
    
    vars = {
        arg_play = args[1], -- 1 through 10
        arg_move = args[2], -- "story" or "options"
        lastframe = 0,
        transition = true,
        border_exits = true,
        border_exiting = false
    }
    
    assets.video = gfx.video.new('images/story/scene' .. vars.arg_play)
    assets.audio = pd.sound.fileplayer.new('audio/story/scene' .. vars.arg_play .. '_sfx')
    assets.music = pd.sound.fileplayer.new('audio/story/scene' .. vars.arg_play .. '_music')
    vars.border_anim = gfx.animation.loop.new(70, assets.img_border_intro, false)
    pd.timer.performAfterDelay(560, function()
        if not vars.border_exiting then
            vars.border_anim = gfx.animation.loop.new(400, assets.img_border, true)
        end
    end)
    
    assets.video:renderFrame(0)
    assets.audio:setVolume((save.fx/5)+0.01)
    assets.music:setVolume(save.mu/5)
    assets.audio:play(1)
    assets.music:play(1)

    if vars.arg_move == "story" then
        save.cc = vars.arg_play
        if save.cc > save.mc then
            save.mc = save.cc
        end
        if save.sk then
            vars.border_exits = false
            assets.audio:stop()
        end
    end
    
    assets.audio:setFinishCallback(function()
        assets.music:stop()
        if vars.transition then
            if vars.border_exits then
                vars.border_exiting = true
                vars.border_anim = gfx.animation.loop.new(70, assets.img_border_outro, false)
                pd.timer.performAfterDelay(560, function()
                    cutscene:roadmap()
                end)
            else
                cutscene:roadmap()
            end
        end
    end)

    self:setImage(gfx.image.new(356, 200, gfx.kColorWhite))
    self:setCenter(0.5, 0.5)
    self:moveTo(200, 120)
    self:setZIndex(1)
    assets.video:setContext(self:getImage())
    
    class('border').extends(gfx.sprite)
    function border:init()
        border.super.init(self)
        self:moveTo(200, 120)
        self:setZIndex(2)
        self:add()
    end
    function border:update()
        self:setImage(vars.border_anim:image())
    end
    self.border = border()

    if vars.arg_play ~= 1 then
        savegame()
    end

    self:add()
end

function cutscene:roadmap()
    if vars.arg_move == "options" then
        scenemanager:transitionscene(options)
    else
        if vars.arg_play == 1 then scenemanager:switchscene(tutorial, "story") end
        if vars.arg_play == 2 then scenemanager:switchscene(intro, 1) end
        if vars.arg_play == 3 then scenemanager:switchscene(intro, 2) end
        if vars.arg_play == 4 then scenemanager:switchscene(intro, 3) end
        if vars.arg_play == 5 then scenemanager:switchscene(intro, 4) end
        if vars.arg_play == 6 then scenemanager:switchscene(chase) end
        if vars.arg_play == 7 then scenemanager:switchscene(intro, 5) end
        if vars.arg_play == 8 then scenemanager:switchscene(intro, 6) end
        if vars.arg_play == 9 then scenemanager:switchscene(intro, 7) end
        if vars.arg_play == 10 then scenemanager:switchscene(credits) end
    end
end

function cutscene:update()
        local frame = math.floor(assets.audio:getOffset() * 10)
        if frame ~= vars.lastframe then
            assets.video:renderFrame(frame)
            vars.lastframe = frame
            self:markDirty()
        end
end