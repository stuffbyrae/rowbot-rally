local pd <const> = playdate
local gfx <const> = pd.graphics

class('scenemanager').extends()

img_loading = gfx.image.new('images/ui/loading')
img_loading_oneway = gfx.image.new('images/ui/loading_oneway')
img_loading_blastdoors = gfx.image.new('images/ui/loading_blastdoors')
blastdoors_1 = pd.sound.sampleplayer.new('audio/sfx/blastdoors_1')
blastdoors_2 = pd.sound.sampleplayer.new('audio/sfx/blastdoors_2')

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
    if assets ~= nil then
        if assets.music ~= nil then
            assets.music:stop()
        end
    end
    self:loadnewscene()
end

function scenemanager:transitionscene(scene, ...)
    show_crank = false
    if self.transitioning then return end
    self.transitioning = true
    self.newscene = scene
    local args = {...}
    self.sceneargs = args
    local transitiontimer = self:transition(750, 250, 0, -10)
    if assets.music ~= nil then
        assets.music:setVolume(0, 0, (self.transitiontime-10)/1000, function() assets.music:stop() end)
    end
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        transitiontimer = self:transition(250, -350, 10, 0)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function scenemanager:transitionsceneblastdoors(scene, ...)
    show_crank = false
    if self.transitioning then return end
    self.transitioning = true
    self.newscene = scene
    local args = {...}
    self.sceneargs = args
    local transitiontimer = self:transitionblastdoors(-300, 120)
    blastdoors_1:play()
    if assets.music ~= nil then
        assets.music:setVolume(0, 0, (self.transitiontimeblastdoors-10)/1000, function() assets.music:stop() end)
    end
    transitiontimer.timerEndedCallback = function()
        shakiesy()
        pd.timer.performAfterDelay(self.transitiontimeblastdoors*1.5, function()
            self:loadnewscene()
            blastdoors_2:play()
            transitiontimer = self:transitionblastdoors(120, -300)
            transitiontimer.timerEndedCallback = function()
                self.transitioning = false
            end
        end)
    end
end

function scenemanager:transitionsceneoneway(scene, ...)
    show_crank = false
    if self.transitioning then return end
    self.transitioning = true
    self.newscene = scene
    local args = {...}
    self.sceneargs = args
    local transitiontimer = self:transitiononeway(441, -41, 0, -10)
    if assets.music ~= nil then
        assets.music:setVolume(0, 0, (self.transitiontime-10)/1000, function() assets.music:stop() end)
    end
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

function scenemanager:transitionblastdoors(startvalue, endvalue)
    local loading = self:loadingspriteblastdoors()
    loading:moveTo(200, startvalue)
    local transitiontimer = pd.timer.new(self.transitiontimeblastdoors)
    local fuck = gfx.animator.new(self.transitiontimeblastdoors-20, startvalue, endvalue, pd.easingFunctions.inSine)
    transitiontimer.updateCallback = function(timer) loading:moveTo(200, fuck:currentValue()) end
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

function scenemanager:loadingspriteblastdoors()
    local loading = gfx.sprite.new(img_loading_blastdoors)
    loading:setZIndex(26000)
    loading:moveTo(200, 400)
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
    gfx.sprite.removeAll()
    self:removealltimers()
    assets = nil
    vars = nil
    collectgarbage('collect')
    gfx.setDrawOffset(0, 0)
end

function scenemanager:removealltimers()
    local alltimers = pd.timer.allTimers()
    for _, timer in ipairs(alltimers) do
        timer:remove()
    end
end