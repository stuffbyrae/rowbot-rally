import 'options'
import 'title'
import 'tutorial'
import 'race'
import 'chase'
import 'credits'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)

function cutscene:init(...)
    local args = {...}
    local play = args[1]
    local move = args[2]
    show_crank = false

    if move == "story" then
        save.cc = play
    end

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("skip scene", function()
            assets.audio:stop()
        end)
        menu:addMenuItem("back to title", function()
            vars.transition = false
            assets.audio:stop()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end

    assets = {
        img_border_intro = gfx.imagetable.new('images/story/border_intro'),
        img_border = gfx.imagetable.new('images/story/border'),
        img_border_outro = gfx.imagetable.new('images/story/border_outro'),
        video = gfx.video.new('images/story/scene1'),
        audio = pd.sound.fileplayer.new('audio/story/scene1_sfx'),
    }

    vars = {
        lastframe = 0,
        transition = true
    }
    vars.border_anim = gfx.animation.loop.new(70, assets.img_border_intro, false)
    pd.timer.performAfterDelay(560, function()
        vars.border_anim = gfx.animation.loop.new(400, assets.img_border, true)
    end)
    
    assets.video:renderFrame(0)
    assets.audio:play(1)

    assets.audio:setFinishCallback(function()
        if vars.transition then
            vars.border_anim = gfx.animation.loop.new(70, assets.img_border_outro, false)
            pd.timer.performAfterDelay(560, function()
                if move == "options" then
                    scenemanager:transitionsceneotherway(options)
                else
                    if play == 1 then scenemanager:switchscene(race) end
                    if play == 2 then scenemanager:switchscene(intro, 1) end
                    if play == 3 then scenemanager:switchscene(intro, 2) end
                    if play == 4 then scenemanager:switchscene(intro, 3) end
                    if play == 5 then scenemanager:switchscene(intro, 4) end
                    if play == 6 then scenemanager:switchscene(chase) end
                    if play == 7 then scenemanager:switchscene(intro, 5) end
                    if play == 8 then scenemanager:switchscene(intro, 6) end
                    if play == 9 then scenemanager:switchscene(intro, 7) end
                    if play == 10 then scenemanager:switchscene(credits) end
                end
            end)
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

    self:add()
end

function cutscene:update()
        local frame = math.floor(assets.audio:getOffset() * 10)
        if frame ~= vars.lastframe then
            assets.video:renderFrame(frame)
            vars.lastframe = frame
            self:markDirty()
        end
end