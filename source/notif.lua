import 'cutscene'
import 'title'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('notif').extends(gfx.sprite)
function notif:init(...)
    notif.super.init(self)
    local args = {...}
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)


    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 0
        pd.setMenuImage(img, xoffset)
    end
    
    assets = {
        img_mirror_warn = gfx.image.new('images/ui/mirror_warn'),
        img_tt_warn = gfx.image.new('images/ui/tt_warn'),
        img_demo_warn = gfx.image.new('images/ui/demo_warn'),
        img_fullgame_warn = gfx.image.new('images/ui/fullgame_warn'),
        sfx_ui = pd.sound.sampleplayer.new('audio/sfx/ui'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        sfx_whoosh = pd.sound.sampleplayer.new('audio/sfx/whoosh'),
    }
    assets.sfx_ui:setVolume(save.vol_sfx/5)
    assets.sfx_proceed:setVolume(save.vol_sfx/5)
    assets.sfx_whoosh:setVolume(save.vol_sfx/5)
    
    vars = {
        arg_slot = args[1],
        arg_warn = args[2], -- "mirror", "tt", "demo", or "fullgame"
        arg_move = args[3], -- "story" or "title"
        ui_anim_in = gfx.animator.new(250, 250, 120, pd.easingFunctions.outBack),
        ui_open = true
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        gfx.image.new(400, 240, gfx.kColorBlack):draw(0, 0)
    end)

    class('ui').extends(gfx.sprite)
    function ui:init()
        ui.super.init(self)
        self:moveTo(200, 400)
        self:setZIndex(99)
        self:add()
    end
    function ui:update()
        if vars.ui_anim_in:ended() == false then
            self:moveTo(200, vars.ui_anim_in:currentValue())
        end
        if vars.ui_anim_out and vars.ui_anim_out:ended() == false then
            self:moveTo(200, vars.ui_anim_out:currentValue())
        end
    end
    
        self.ui = ui()
    
    if vars.arg_warn == "tt" then
        self.ui:setImage(assets.img_tt_warn)
        save.time_trials_unlocked = true
    elseif vars.arg_warn == "demo" then
        self.ui:setImage(assets.img_demo_warn)
    elseif vars.arg_warn == "fullgame" then
        self.ui:setImage(assets.img_fullgame_warn)
    end

    assets.sfx_ui:play()
    savegame()
    self:add()
end

function notif:update()
    if pd.buttonJustPressed('a') and vars.ui_open then
        vars.ui_open = false
        assets.sfx_whoosh:play()
        vars.ui_anim_out = gfx.animator.new(101, 120, 500, pd.easingFunctions.inSine)
        pd.timer.performAfterDelay(100, function()
            self.ui:remove()
            if vars.arg_move == "story" then
                if save.autoskip then
                    scenemanager:switchscene(intro, 1, 2)
                else
                    scenemanager:switchscene(cutscene, 1, 3, "story")
                end
            else
                scenemanager:switchscene(title, false)
            end
        end)
    end
end