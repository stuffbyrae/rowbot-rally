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
    if save.current_story_slot == 1 then
        if save.slot1_progress == nil then
            self.newscene = opening
        elseif save.slot1_progress == "cutscene1" then
            self.newscene = cutscene
            self.sceneargs = {1}
        elseif save.slot1_progress == "tutorial" then
            self.newscene = race
            self.sceneargs = {0, "tutorial"}
        elseif save.slot1_progress == "cutscene2" then
            self.newscene = cutscene
            self.sceneargs = {2}
        elseif save.slot1_progress == "race1" then
            self.newscene = intro
            self.sceneargs = {1}
        elseif save.slot1_progress == "cutscene3" then
            self.newscene = cutscene
            self.sceneargs = {3}
        elseif save.slot1_progress == "race2" then
            self.newscene = intro
            self.sceneargs = {2}
        elseif save.slot1_progress == "cutscene4" then
            self.newscene = cutscene
            self.sceneargs = {4}
        elseif save.slot1_progress == "race3" then
            self.newscene = intro
            self.sceneargs = {3}
        elseif save.slot1_progress == "cutscene5" then
            self.newscene = cutscene
            self.sceneargs = {5}
        elseif save.slot1_progress == "race4" then
            self.newscene = intro
            self.sceneargs = {4}
        elseif save.slot1_progress == "cutscene6" then
            self.newscene = cutscene
            self.sceneargs = {6}
        elseif save.slot1_progress == "chase" then
            self.newscene = chase
        elseif save.slot1_progress == "cutscene7" then
            self.newscene = cutscene
            self.sceneargs = {7}
        elseif save.slot1_progress == "race5" then
            self.newscene = intro
            self.sceneargs = {5}
        elseif save.slot1_progress == "cutscene8" then
            self.newscene = cutscene
            self.sceneargs = {8}
        elseif save.slot1_progress == "race6" then
            self.newscene = intro
            self.sceneargs = {6}
        elseif save.slot1_progress == "cutscene9" then
            self.newscene = cutscene
            self.sceneargs = {9}
        elseif save.slot1_progress == "race7" then
            self.newscene = intro
            self.sceneargs = {10}
        elseif save.slot1_progress == "finish" then
            self.newscene = chapters
        end
    elseif save.current_story_slot == 2 then
        if save.slot2_progress == nil then
            self.newscene = opening
        elseif save.slot2_progress == "cutscene1" then
            self.newscene = cutscene
            self.sceneargs = {1}
        elseif save.slot2_progress == "tutorial" then
            self.newscene = race
            self.sceneargs = {0, "tutorial"}
        elseif save.slot2_progress == "cutscene2" then
            self.newscene = cutscene
            self.sceneargs = {2}
        elseif save.slot2_progress == "race1" then
            self.newscene = intro
            self.sceneargs = {1}
        elseif save.slot2_progress == "cutscene3" then
            self.newscene = cutscene
            self.sceneargs = {3}
        elseif save.slot2_progress == "race2" then
            self.newscene = intro
            self.sceneargs = {2}
        elseif save.slot2_progress == "cutscene4" then
            self.newscene = cutscene
            self.sceneargs = {4}
        elseif save.slot2_progress == "race3" then
            self.newscene = intro
            self.sceneargs = {3}
        elseif save.slot2_progress == "cutscene5" then
            self.newscene = cutscene
            self.sceneargs = {5}
        elseif save.slot2_progress == "race4" then
            self.newscene = intro
            self.sceneargs = {4}
        elseif save.slot2_progress == "cutscene6" then
            self.newscene = cutscene
            self.sceneargs = {6}
        elseif save.slot2_progress == "chase" then
            self.newscene = chase
        elseif save.slot2_progress == "cutscene7" then
            self.newscene = cutscene
            self.sceneargs = {7}
        elseif save.slot2_progress == "race5" then
            self.newscene = intro
            self.sceneargs = {5}
        elseif save.slot2_progress == "cutscene8" then
            self.newscene = cutscene
            self.sceneargs = {8}
        elseif save.slot2_progress == "race6" then
            self.newscene = intro
            self.sceneargs = {6}
        elseif save.slot2_progress == "cutscene9" then
            self.newscene = cutscene
            self.sceneargs = {9}
        elseif save.slot2_progress == "race7" then
            self.newscene = intro
            self.sceneargs = {10}
        elseif save.slot2_progress == "finish" then
            self.newscene = chapters
        end
    elseif save.current_story_slot == 3 then
        if save.slot3_progress == nil then
            self.newscene = opening
        elseif save.slot3_progress == "cutscene1" then
            self.newscene = cutscene
            self.sceneargs = {1}
        elseif save.slot3_progress == "tutorial" then
            self.newscene = race
            self.sceneargs = {0, "tutorial"}
        elseif save.slot3_progress == "cutscene2" then
            self.newscene = cutscene
            self.sceneargs = {2}
        elseif save.slot3_progress == "race1" then
            self.newscene = intro
            self.sceneargs = {1}
        elseif save.slot3_progress == "cutscene3" then
            self.newscene = cutscene
            self.sceneargs = {3}
        elseif save.slot3_progress == "race2" then
            self.newscene = intro
            self.sceneargs = {2}
        elseif save.slot3_progress == "cutscene4" then
            self.newscene = cutscene
            self.sceneargs = {4}
        elseif save.slot3_progress == "race3" then
            self.newscene = intro
            self.sceneargs = {3}
        elseif save.slot3_progress == "cutscene5" then
            self.newscene = cutscene
            self.sceneargs = {5}
        elseif save.slot3_progress == "race4" then
            self.newscene = intro
            self.sceneargs = {4}
        elseif save.slot3_progress == "cutscene6" then
            self.newscene = cutscene
            self.sceneargs = {6}
        elseif save.slot3_progress == "chase" then
            self.newscene = chase
        elseif save.slot3_progress == "cutscene7" then
            self.newscene = cutscene
            self.sceneargs = {7}
        elseif save.slot3_progress == "race5" then
            self.newscene = intro
            self.sceneargs = {5}
        elseif save.slot3_progress == "cutscene8" then
            self.newscene = cutscene
            self.sceneargs = {8}
        elseif save.slot3_progress == "race6" then
            self.newscene = intro
            self.sceneargs = {6}
        elseif save.slot3_progress == "cutscene9" then
            self.newscene = cutscene
            self.sceneargs = {9}
        elseif save.slot3_progress == "race7" then
            self.newscene = intro
            self.sceneargs = {10}
        elseif save.slot3_progress == "finish" then
            self.newscene = credits
        end
    end
end

function scenemanager:switchstory()
    self:findstory()
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self:loadnewscene()
end

function scenemanager:switchscene(scene, ...)
    self.newscene = scene
    self.sceneargs = {...}
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self:loadnewscene()
end

function scenemanager:transitionstory()
    if self.transitioning then return end
    show_crank = false
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self.transitioning = true
    self:findstory()
    local transitiontimer = self:transition(750, 250, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        transitiontimer = self:transition(250, -350, 10, 0)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function scenemanager:transitionscene(scene, ...)
    if self.transitioning then return end
    show_crank = false
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self.transitioning = true
    self.newscene = scene
    self.sceneargs = {...}
    local transitiontimer = self:transition(750, 250, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        transitiontimer = self:transition(250, -350, 10, 0)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function scenemanager:transitionstoryoneway()
    if self.transitioning then return end
    show_crank = false
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self.transitioning = true
    self:findstory()
    local transitiontimer = self:transitiononeway(441, -41, 0, -10)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        self.transitioning = false
        gfx.setDrawOffset(0, 0)
    end
end

function scenemanager:transitionsceneoneway(scene, ...)
    if self.transitioning then return end
    show_crank = false
    pd.inputHandlers.pop() -- Pop the scene's input handler off the stack.
    self.transitioning = true
    self.newscene = scene
    self.sceneargs = {...}
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
    gfx.sprite.performOnAllSprites(function(sprite)
        sprite:remove()
        sprite = nil
    end)
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