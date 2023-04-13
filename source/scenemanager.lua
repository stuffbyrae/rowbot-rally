local pd <const> = playdate
local gfx <const> = pd.graphics

class('scenemanager').extends()

function scenemanager:init()
end

function scenemanager:switchscene(scene, ...)
    self.newscene = scene
    self.sceneargs = ...
    self:loadnewscene()
end

function scenemanager:loadnewscene()
    gfx.sprite.removeAll()
    self:removealltimers()
    self.newscene(self.sceneargs)
end

function scenemanager:removealltimers()
    local alltimers = pd.timer.allTimers()
    for _, timer in ipairs(alltimers) do
        timer:remove()
    end
end