local pd <const> = playdate
local gfx <const> = pd.graphics

class('cutscene').extends(gfx.sprite)
function cutscene:init(...)
    cutscene.super.init(self)
    local args = {...}
    local play = args[1]
    local move = args[2]
    show_crank = false

    local test_vid = gfx.video.new('images/story/scene1')
    local test_sfx = pd.sound.fileplayer.new('audio/story/scene1_sfx')

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("skip scene", function()
            
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:switchscene(title, true)
        end)
    end

    self:add()
end

function cutscene:update()
end