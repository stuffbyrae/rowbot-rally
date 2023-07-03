import 'cutscene'
import 'title'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('notif').extends(gfx.sprite)
function notif:init(...)
    notif.super.init(self)
    local args = {...}
    local warn = args[1] -- "mirror", "tt", or "reset"
    local move = args[2] -- "story" or "title"
    show_crank = false
    
    assets = {
        img_mirror_warn = gfx.image.new('images/ui/mirror_warn'),
        img_tt_warn = gfx.image.new('images/ui/tt_warn'),
        img_reset_confirmed = gfx.image.new('images/ui/reset_confirmed')
    }

    vars = {
        ui_anim_in = gfx.animator.new(250, 250, 120, pd.easingFunctions.outBack),
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
    
    if warn == "mirror" then
        self.ui:setImage(assets.img_mirror_warn)
        save.ms = true
    elseif warn == "tt" then
        self.ui:setImage(assets.img_tt_warn)
        save.ts = true
    elseif warn == "reset" then
        self.ui:setImage(assets.img_reset_confirmed)
        save.t1 = 17970
        save.t2 = 17970
        save.t3 = 17970
        save.t4 = 17970
        save.t5 = 17970
        save.t6 = 17970
        save.t7 = 17970
        save.m1 = 17970
        save.m2 = 17970
        save.m3 = 17970
        save.m4 = 17970
        save.m5 = 17970
        save.m6 = 17970
        save.m7 = 17970
        save.as = false
        save.ct = 0
        save.mt = 0
        save.cc = 0
        save.mc = 0
        save.cs = false
        save.mu = 5
        save.fx = 5
        save.ts = false
        save.ms = false
        save.ui = true
        pd.datastore.write(save)
    end

    self:add()
end

function notif:update()
    if pd.buttonJustPressed('a') then
        vars.ui_anim_out = gfx.animator.new(101, 120, 500, pd.easingFunctions.inSine)
        pd.timer.performAfterDelay(100, function()
            self.ui:remove()
            if move == "story" then
                scenemanager:switchscene(cutscene, save.cc+1, "story")
            else
                scenemanager:switchscene(title, false)
            end
        end)
    end
end