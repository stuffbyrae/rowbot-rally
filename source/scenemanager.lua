local pd <const> = playdate
local gfx <const> = pd.graphics

class('scenemanager').extends()

function scenemanager:init()
    self.transitiontime = 1000
end

function scenemanager:switchscene(scene, ...)
    self.newscene = scene
    self.sceneargs = ...
    self:loadnewscene()
end

function scenemanager:transitionscene(scene, ...)
    self.newscene = scene
    self.sceneargs = ...
    local transitiontimer = self:transition(750, 200)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        transitiontimer = self:transition(200, -450)
    end
end

function scenemanager:transition(startvalue, endvalue)
    local loading = self:loadingsprite()
    loading:moveTo(startvalue, 120)
    local transitiontimer = pd.timer.new(self.transitiontime, startvalue, endvalue, pd.easingFunctions.inOutCirc)
    transitiontimer.updateCallback = function(timer)
        loading:moveTo(timer.value, 120)
    end
    return transitiontimer
end

function scenemanager:loadingsprite()
    local img_loading = gfx.image.new('images/ui/loading')
    local loading = gfx.sprite.new(img_loading)
    loading:setZIndex(26000)
    loading:moveTo(750, 120)
    loading:setIgnoresDrawOffset(true)
    loading:add()
    return loading
end

function scenemanager:loadnewscene()
    self:cleanupscene()
    self:newscene(self.sceneargs)
end

function scenemanager:cleanupscene()
    gfx.sprite.removeAll()
    self:removealltimers()
    gfx.setDrawOffset(0, 0)
end

function scenemanager:removealltimers()
    local alltimers = pd.timer.allTimers()
    for _, timer in ipairs(alltimers) do
        timer:remove()
    end
end