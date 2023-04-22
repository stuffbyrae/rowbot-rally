local pd <const> = playdate
local gfx <const> = pd.graphics

class('scenemanager').extends()

function scenemanager:switchscene(scene, ...)
    self.newscene = scene
    self.sceneargs = ...
    self:loadnewscene()
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