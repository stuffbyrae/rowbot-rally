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

function scenemanager:findstory()
    if save["slot" .. save.current_story_slot .. '_progress'] == nil then
        if save.first_launch then -- If this variable is true, then nobody's started a story yet and the Opening scene will play on launch until they do.
            self.newscene = cutscene
            self.sceneargs = {1}
            save.first_launch = false
        else
            self.newscene = opening
        end
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene1" then
        self.newscene = cutscene
        self.sceneargs = {1}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "tutorial" then
        self.newscene = tutorial
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene2" then
        self.newscene = cutscene
        self.sceneargs = {2}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "race1" then
        self.newscene = intro
        self.sceneargs = {1}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene3" then
        self.newscene = cutscene
        self.sceneargs = {3}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "race2" then
        self.newscene = intro
        self.sceneargs = {2}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene4" then
        self.newscene = cutscene
        self.sceneargs = {4}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "race3" then
        self.newscene = intro
        self.sceneargs = {3}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene5" then
        self.newscene = cutscene
        self.sceneargs = {5}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "race4" then
        self.newscene = intro
        self.sceneargs = {4}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene6" then
        self.newscene = cutscene
        self.sceneargs = {6}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "chase" then
        self.newscene = chase
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene7" then
        self.newscene = cutscene
        self.sceneargs = {7}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "race5" then
        self.newscene = intro
        self.sceneargs = {5}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene8" then
        self.newscene = cutscene
        self.sceneargs = {8}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "race6" then
        self.newscene = intro
        self.sceneargs = {6}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene9" then
        self.newscene = cutscene
        self.sceneargs = {9}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "race7" then
        self.newscene = intro
        self.sceneargs = {7}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "cutscene10" then
        self.newscene = cutscene
        self.sceneargs = {10}
    elseif save["slot" .. save.current_story_slot .. '_progress'] == "finish" then
        self.newscene = credits
    end
end

function scenemanager:switchstory()
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    savegame()
    self:loadnewstory()
end

function scenemanager:switchscene(scene, ...)
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.sceneargs = {...}
    self:loadnewscene(scene)
end

function scenemanager:transitionstory()
    if self.transitioning then return end
    show_crank = false
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.transitioning = true
    savegame()
    local transitiontimer = self:transition(750, 250, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewstory()
        transitiontimer = self:transition(250, -350, 10, 0)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function scenemanager:transitionscene(scene, ...)
    if self.transitioning then return end
    show_crank = false
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.transitioning = true
    self.sceneargs = {...}
    local transitiontimer = self:transition(750, 250, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene(scene)
        transitiontimer = self:transition(250, -350, 10, 0)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function scenemanager:transitionsceneback(scene, ...)
    if self.transitioning then return end
    show_crank = false
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.transitioning = true
    self.sceneargs = {...}
    local transitiontimer = self:transition(-350, 250, 0, 10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene(scene)
        transitiontimer = self:transition(250, 750, -10, 0)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function scenemanager:transitionstoryoneway()
    if self.transitioning then return end
    show_crank = false
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.transitioning = true
    savegame()
    local transitiontimer = self:transitiononeway(441, -41, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewstory()
        self.transitioning = false
        gfx.setDrawOffset(0, 0)
    end
end

function scenemanager:transitionsceneoneway(scene, ...)
    if self.transitioning then return end
    show_crank = false
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.transitioning = true
    self.sceneargs = {...}
    local transitiontimer = self:transitiononeway(441, -41, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene(scene)
        self.transitioning = false
        gfx.setDrawOffset(0, 0)
    end
end

function scenemanager:transitionsceneonewayback(scene, ...)
    if self.transitioning then return end
    show_crank = false
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.transitioning = true
    self.sceneargs = {...}
    local transitiontimer = self:transitiononewayback(-482, 0, 0, 10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene(scene)
        self.transitioning = false
        gfx.setDrawOffset(0, 0)
    end
end

function scenemanager:transition(startvalue, endvalue, offsetstartvalue, offsetendvalue)
    local loading = self:loadingsprite()
    loading:moveTo(startvalue, 120)
    local transitiontimer = pd.timer.new(self.transitiontime, startvalue, endvalue, pd.easingFunctions.inOutCubic)
    local offsettimer = pd.timer.new(self.offsettime, offsetstartvalue, offsetendvalue, pd.easingFunctions.inOutQuint)
    transitiontimer.updateCallback = function(timer) loading:moveTo(timer.value, 120) end
    offsettimer.updateCallback = function(timer) gfx.setDrawOffset(timer.value, 0) end
    return transitiontimer
end

function scenemanager:transitiononeway(startvalue, endvalue, offsetstartvalue, offsetendvalue)
    local loading = self:loadingspriteoneway()
    loading:moveTo(startvalue, 120)
    local transitiontimer = pd.timer.new(self.transitiontime, startvalue, endvalue, pd.easingFunctions.inOutCubic)
    local offsettimer = pd.timer.new(self.offsettime, offsetstartvalue, offsetendvalue, pd.easingFunctions.inOutQuint)
    transitiontimer.updateCallback = function(timer) loading:moveTo(timer.value, 120) end
    offsettimer.updateCallback = function(timer) gfx.setDrawOffset(timer.value, 0) end
    return transitiontimer
end

function scenemanager:transitiononewayback(startvalue, endvalue, offsetstartvalue, offsetendvalue)
    local loading = self:loadingspriteotherway()
    loading:moveTo(startvalue, 120)
    local transitiontimer = pd.timer.new(self.transitiontime, startvalue, endvalue, pd.easingFunctions.inOutCubic)
    local offsettimer = pd.timer.new(self.offsettime, offsetstartvalue, offsetendvalue, pd.easingFunctions.inOutQuint)
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

function scenemanager:loadnewscene(scene)
    self:cleanupscene()
    self.newscene = scene
    self.newscene(table.unpack(self.sceneargs))
end

function scenemanager:loadnewstory()
    self:cleanupscene()
    self:findstory()
    self.newscene(table.unpack(self.sceneargs))
end

function scenemanager:cleanupscene()
    closepopup() -- Close any active popups that may be lingering.
    if assets ~= nil then
        for i = 1, #assets do
            assets[i] = nil
        end
        assets = nil -- Nil all the assets,
    end
    if vars ~= nil then
        for i = 1, #vars do
            vars[i] = nil
        end
    end
    vars = nil -- and nil all the variables.
    if self.newscene ~= nil then
        self.newscene = nil
    end
    gfx.sprite.performOnAllSprites(function(sprite)
        sprite:remove()
    end)
    self:removealltimers() -- Remove every timer,
    collectgarbage('collect') -- and collect the garbage.
    gfx.setDrawOffset(0, 0) -- Lastly, reset the drawing offset. just in case.
    pd.display.setMosaic(0, 0) -- Reset the mosaic, in case Retro Mode is on
end

function scenemanager:removealltimers()
    local alltimers = pd.timer.allTimers()
    for _, timer in ipairs(alltimers) do
        if timer.duration ~= 501 then
            timer:remove()
            timer = nil
        end
    end
end