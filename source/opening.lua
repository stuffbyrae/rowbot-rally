local pd <const> = playdate
local gfx <const> = pd.graphics

class('opening').extends(gfx.sprite)
function opening:init(...)
    opening.super.init(self)
    local args = {...}
    show_crank = false

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("skip opening", function()
            self:finish()
        end)
        menu:addMenuItem("back to title", function()
            scenemanager:switchscene(title, true)
        end)
    end

    if save.as then
        save.cc = 0
        save.ct = 0
    else
        save.as = true
    end

    assets = {
        img_opening = gfx.imagetable.new('images/story/opening'),
        img_fade = gfx.imagetable.new('images/ui/fade/fade')
    }

    vars = {
        fading = true,
        finished = false,
        progress = 1
    }

    vars.fade_anim = gfx.animator.new(500, 1, #assets.img_fade)
    pd.timer.performAfterDelay(500, function() fading = false self.fade:remove() end)

    class('images').extends(gfx.sprite)
    function images:init()
        images.super.init(self)
        self:setImage(assets.img_opening[vars.progress])
        self:setCenter(0, 0)
        self:add()
    end

    class('fade').extends(gfx.sprite)
    function fade:init()
        fade.super.init(self)
        self:setZIndex(99)
        self:setCenter(0, 0)
        self:add()
    end
    function fade:update()
        if vars.fading then
            local image = gfx.image.new(400, 240)
            gfx.pushContext(image)
                assets.img_fade[math.floor(vars.fade_anim:currentValue())]:drawTiled(0, 0, 400, 240)
            gfx.popContext()
            self:setImage(image)
        end
    end

    self.images = images()
    self.fade = fade()
    
    self:add()
end

function opening:finish()
    fading = true
    finished = true
    self.fade:add()
    vars.fade_anim = gfx.animator.new(500, #assets.img_fade, 1)
    vars.fade_anim:reset()
    pd.timer.performAfterDelay(500, function() scenemanager:switchscene(cutscene, 1, race) end)
end

function opening:update()
    if pd.buttonJustPressed('a') then
        if fading == false then
            if vars.progress < #assets.img_opening then
                vars.progress += 1
                self.images:setImage(assets.img_opening[vars.progress])
            elseif vars.finished == false then
                self:finish()
            end
        end
    end
end