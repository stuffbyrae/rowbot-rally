local pd <const> = playdate
local gfx <const> = pd.graphics

class('results').extends(gfx.sprite)
function results:init(...)
    results.super.init(self)
    local args = {...}
    show_crank = false
    
    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if vars.arg_mode == "story" then
            if vars.arg_win then
                menu:addMenuItem("onward!", function()
                    scenemanager:transitionsceneoneway(garage)
                end)
            else
                menu:addMenuItem("retry?", function()
                    scenemanager:transitionsceneoneway(intro, vars.arg_track)
                end)
            end
        else
            menu:addMenuItem("change boat", function()
                scenemanager:transitionsceneblastdoors(garage)
            end)
            menu:addMenuItem("change track", function()
                scenemanager:transitionscene(tracks, vars.arg_boat)
            end)
        end
        menu:addMenuItem("back to title", function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end
    
    assets = {
        
    }
    
    vars = {
        arg_track = args[1], -- 1 through 7
        arg_mode = args[2], -- "story" or "tt"
        arg_win = args[3], -- true or false. only matters when arg_mode is "story"
        arg_boat = args[4], -- 1 through 7
        arg_time = args[5], -- time in the race
        arg_bg = args[6] -- last frame shown in the race
    }

    self:add()
end

function results:update()
end