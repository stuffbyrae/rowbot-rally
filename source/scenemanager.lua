local pd <const> = playdate
local gfx <const> = pd.graphics

class('scenemanager').extends()

img_loading = gfx.image.new('images/ui/loading')
img_loading_oneway = gfx.image.new('images/ui/loading_oneway')

function scenemanager:init()
    self.transitiontime = 1000
    self.transitiontimeblastdoors = 500
    self.offsettime = 1000
    self.transitioning = false
end

function scenemanager:switchscene(scene, ...)
    self.newscene = scene
    local args = {...}
    self.sceneargs = args
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self:loadnewscene()
end

function scenemanager:transitionscene(scene, ...)
    if self.transitioning then return end
    show_crank = false
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self.transitioning = true
    self.newscene = scene
    local args = {...}
    self.sceneargs = args
    local transitiontimer = self:transition(750, 250, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        transitiontimer = self:transition(250, -350, 10, 0)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function scenemanager:transitionsceneoneway(scene, ...)
    if self.transitioning then return end
    show_crank = false
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self.transitioning = true
    self.newscene = scene
    local args = {...}
    self.sceneargs = args
    local transitiontimer = self:transitiononeway(441, -41, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        self.transitioning = false
        gfx.setDrawOffset(0, 0)
    end
end

function scenemanager:transition(startvalue, endvalue, offsetstartvalue, offsetendvalue)
    local loading = self:loadingsprite()
    loading:moveTo(startvalue, 120)
    local transitiontimer = pd.timer.new(self.transitiontime, startvalue, endvalue, pd.easingFunctions.inOutCirc)
    local offsettimer = pd.timer.new(self.offsettime, offsetstartvalue, offsetendvalue, pd.easingFunctions.inOutCirc)
    transitiontimer.updateCallback = function(timer) loading:moveTo(timer.value, 120) end
    offsettimer.updateCallback = function(timer) gfx.setDrawOffset(timer.value, 0) end
    return transitiontimer
end

function scenemanager:transitiononeway(startvalue, endvalue, offsetstartvalue, offsetendvalue)
    local loading = self:loadingspriteoneway()
    loading:moveTo(startvalue, 120)
    local transitiontimer = pd.timer.new(self.transitiontime, startvalue, endvalue, pd.easingFunctions.inOutCirc)
    local offsettimer = pd.timer.new(self.offsettime, offsetstartvalue, offsetendvalue, pd.easingFunctions.inOutCirc)
    transitiontimer.updateCallback = function(timer) loading:moveTo(timer.value, 120) end
    offsettimer.updateCallback = function(timer) gfx.setDrawOffset(timer.value, 0) end
    return transitiontimer
end

function scenemanager:loadingsprite()
    local loading = gfx.sprite.new(img_loading)
    loading:setZIndex(26000)
    loading:moveTo(750, 120)
    loading:setIgnoresDrawOffset(true)
    loading:add()
    return loading
end

function scenemanager:loadingspriteoneway()
    local loading = gfx.sprite.new(img_loading_oneway)
    loading:setZIndex(26000)
    loading:moveTo(441, 120)
    loading:setCenter(0, 0.5)
    loading:setIgnoresDrawOffset(true)
    loading:add()
    return loading
end

function scenemanager:loadingspriteotherway()
    local loading = gfx.sprite.new(img_loading_oneway)
    loading:setImage(img_loading_oneway, gfx.kImageFlippedX)
    loading:setZIndex(26000)
    loading:moveTo(-41, 120)
    loading:setCenter(0, 0.5)
    loading:setIgnoresDrawOffset(true)
    loading:add()
    return loading
end

function scenemanager:loadnewscene()
    self:cleanupscene()
    self.newscene(table.unpack(self.sceneargs))
end

function scenemanager:cleanupscene()
    closepopup() -- Close any active popups that may be lingering.
    assets = nil -- Nil all the assets,
    vars = nil -- and nil all the variables.
    gfx.sprite.removeAll() -- Remove every sprite,
    self:removealltimers() -- Remove every timer,
    collectgarbage('collect') -- and collect the garbage.
    gfx.setDrawOffset(0, 0) -- Lastly, reset the drawing offset. just in case.
end

function scenemanager:removealltimers()
    local alltimers = pd.timer.allTimers()
    for _, timer in ipairs(alltimers) do
        timer:remove()
    end
end