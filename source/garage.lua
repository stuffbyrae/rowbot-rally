import 'tracks'

local pd <const> = playdate
local gfx <const> = pd.graphics

class('garage').extends(gfx.sprite)
function garage:init()
    garage.super.init(self)
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause()
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        local img = gfx.image.new(400, 240)
        xoffset = 0
        pd.setMenuImage(img, xoffset)
        menu:addMenuItem(gfx.getLocalizedText("backtotitle"), function()
            scenemanager:transitionsceneoneway(title, false)
        end)
    end

    assets = {
        img_bg = gfx.image.new('images/garage/bg'),
        img_button_ok = gfx.image.new('images/ui/button_ok'),
        img_button_back = gfx.image.new('images/garage/button_back'),
        img_arrow = gfx.image.new('images/ui/arrow'),
        img_spotlight = gfx.image.new('images/garage/spotlight'),
        img_boat_ui = gfx.image.new('images/garage/boat_ui'),
        img_boat_ui_locked = gfx.image.new('images/garage/boat_ui_locked'),
        spd = gfx.imagetable.new('images/garage/spd'),
        trn = gfx.imagetable.new('images/garage/trn'),
        img_classic = gfx.imagetable.new('images/garage/classic/classic'),
        img_pro = gfx.imagetable.new('images/garage/pro/pro'),
        img_surf = gfx.imagetable.new('images/garage/surf/surf'),
        img_raft = gfx.imagetable.new('images/garage/raft/raft'),
        img_swan = gfx.imagetable.new('images/garage/swan/swan'),
        img_gold = gfx.imagetable.new('images/garage/gold/gold'),
        img_hover = gfx.imagetable.new('images/garage/hover/hover'),
        music = pd.sound.fileplayer.new('audio/music/garage'),
        sfx_bonk = pd.sound.sampleplayer.new('audio/sfx/bonk'),
        sfx_locked = pd.sound.sampleplayer.new('audio/sfx/locked'),
        sfx_menu = pd.sound.sampleplayer.new('audio/sfx/menu'),
        sfx_proceed = pd.sound.sampleplayer.new('audio/sfx/proceed'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        pedallica = gfx.font.new('fonts/pedallica')
    }
    assets.sfx_bonk:setVolume(save.fx/5)
    assets.sfx_locked:setVolume(save.fx/5)
    assets.sfx_menu:setVolume(save.fx/5)
    assets.sfx_proceed:setVolume(save.fx/5)
    assets.music:setVolume(save.mu/5)
    assets.music:setLoopRange(3.890)
    assets.music:play(0)

    vars = {
        locked = false,
        menu_list = {},
        current_menu_item = 1,
        boat_transitioning = false,
        spotlight_fade_anim = gfx.animator.new(500, 0, 1, pd.easingFunctions.inElastic)
    }

    local boats = {'classic', 'pro', 'surf', 'raft', 'swan', 'gold', 'hover'}
    for index = 1, #boats do
        if save.mt >= index then
            key = boats[index]
        else
            key = boats[index] .. '_locked'
        end
        table.insert(vars.menu_list, key)
        key = nil
    end
    assets.img_boat = assets.img_classic
    vars.boat_anim = gfx.animation.loop.new(40, assets.img_boat, true)

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        local img = gfx.image.new(400, 240)
        gfx.pushContext(img)
            assets.img_bg:drawTiled(0, 0, 400, 240)
        gfx.popContext()
        self:setImage(img)
        self:setCenter(0, 0)
        self:setZIndex(-5)
        self:add()
    end

    class('spotlight').extends(gfx.sprite)
    function spotlight:init()
        spotlight.super.init(self)
        self:setZIndex(-4)
        self:setCenter(0, 0)
        self:moveTo(25, 0)
        self:add()
    end
    function spotlight:update()
        self:setImage(assets.img_spotlight:fadedImage(vars.spotlight_fade_anim:currentValue(), gfx.image.kDitherTypeBayer8x8))
    end

    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setCenter(0, 0)
        self:moveTo(42, 40)
        self:setZIndex(1)
        self:add()
    end
    function boat:update()
        if vars.boat_transitioning then
            self:setImage(assets.img_boat[math.floor(vars.anim_boat_transition_turn:currentValue())])
            self:moveTo(vars.anim_boat_transition_move:currentValue(), 40)
            if vars.locked then
                if pd.getReduceFlashing() then
                    local img = gfx.image.new(130, 130)
                    gfx.pushContext(img)
                        gfx.setColor(gfx.kColorWhite)
                        gfx.fillRect(0, 0, 130, 130)
                        img:setMaskImage(assets.img_boat[math.floor(vars.anim_boat_transition_turn:currentValue())])
                    gfx.popContext()
                    self:setImage(img:fadedImage(0.25, gfx.image.kDitherTypeDiagonalLine))
                else
                    self:setImage(assets.img_boat[math.floor(vars.anim_boat_transition_turn:currentValue())]:vcrPauseFilterImage():fadedImage(0.5, gfx.image.kDitherTypeDiagonalLine))
                end
            end
            return
        end
        if vars.locked then
            if pd.getReduceFlashing() then
                local img = gfx.image.new(130, 130)
                gfx.pushContext(img)
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillRect(0, 0, 130, 130)
                    img:setMaskImage(vars.boat_anim:image())
                gfx.popContext()
                self:setImage(img:fadedImage(0.25, gfx.image.kDitherTypeDiagonalLine))
            else
                self:setImage(vars.boat_anim:image():vcrPauseFilterImage():fadedImage(0.5, gfx.image.kDitherTypeDiagonalLine))
            end
        else
            self:setImage(vars.boat_anim:image())
        end
    end

    class('ui').extends(gfx.sprite)
    function ui:init()
        ui.super.init(self)
        self:moveTo(200, 203)
        self:setZIndex(4)
        self:refresh()
        self:add()
    end
    function ui:refresh()
        local image = gfx.image.new(373, 250)
        gfx.pushContext(image)
            if vars.locked then
                assets.img_button_ok:drawFaded(10, 100, 0.5, gfx.image.kDitherTypeDiagonalLine)
            else
                assets.img_button_ok:draw(10, 100)
            end
            assets.img_button_back:draw(274, 127)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            if vars.current_menu_item == 1 then
                assets.img_arrow:draw(166, 0, gfx.kImageFlippedX)
            elseif vars.current_menu_item == 7 then
                assets.img_arrow:draw(0, 0)
            else
                assets.img_arrow:draw(0, 0)
                assets.img_arrow:draw(166, 0, gfx.kImageFlippedX)
            end
        gfx.popContext()
        self:setImage(image)
    end
    
    class('boat_ui').extends(gfx.sprite)
    function boat_ui:init()
        boat_ui.super.init(self)
        self:moveTo(200, 80)
        self:setZIndex(5)
        self:add()
    end
    function boat_ui:refresh(boatname)
        if vars.locked then
            self:setImage(assets.img_boat_ui_locked)
            return
        else
            assets.img_boat_ui_full = gfx.image.new(400, 130)
            gfx.pushContext(assets.img_boat_ui_full)
            if string.find(boatname, '^classic') then
                assets.kapel_doubleup:drawTextAligned('Wooden Classic', 107, 3, kTextAlignment.center)
            elseif string.find(boatname, '^pro') then
                assets.kapel_doubleup:drawTextAligned('Pro Rower', 107, 3, kTextAlignment.center)
            elseif string.find(boatname, '^surf') then
                assets.kapel_doubleup:drawTextAligned('Surfboat', 107, 3, kTextAlignment.center)
                elseif string.find(boatname, '^raft') then
                    assets.kapel_doubleup:drawTextAligned('Log Rafter', 107, 3, kTextAlignment.center)
                elseif string.find(boatname, '^swan') then
                    assets.kapel_doubleup:drawTextAligned('Swan Paddler', 107, 3, kTextAlignment.center)
                elseif string.find(boatname, '^gold') then
                    assets.kapel_doubleup:drawTextAligned('Gold Digger', 107, 3, kTextAlignment.center)
                elseif string.find(boatname, '^hover') then
                    assets.kapel_doubleup:drawTextAligned('Hovercraft-X', 107, 3, kTextAlignment.center)
                end
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                if string.find(boatname, '^classic') then
                    assets.kapel_doubleup:drawTextAligned('Wooden Classic', 107, 0, kTextAlignment.center)
                elseif string.find(boatname, '^pro') then
                    assets.kapel_doubleup:drawTextAligned('Pro Rower', 107, 0, kTextAlignment.center)
                elseif string.find(boatname, '^surf') then
                    assets.kapel_doubleup:drawTextAligned('Surfboat', 107, 0, kTextAlignment.center)
                elseif string.find(boatname, '^raft') then
                    assets.kapel_doubleup:drawTextAligned('Log Rafter', 107, 0, kTextAlignment.center)
                elseif string.find(boatname, '^swan') then
                    assets.kapel_doubleup:drawTextAligned('Swan Paddler', 107, 0, kTextAlignment.center)
                elseif string.find(boatname, '^gold') then
                    assets.kapel_doubleup:drawTextAligned('Gold Digger', 107, 0, kTextAlignment.center)
                elseif string.find(boatname, '^hover') then
                    assets.kapel_doubleup:drawTextAligned('Hovercraft-X', 107, 0, kTextAlignment.center)
                end
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
                assets.img_boat_ui:draw(213, 0)
                if string.find(boatname, '^classic') then
                    assets.pedallica:drawText('A classic in the line\nof boats - perfect for\na good mid-lake\nfishing trip.', 223, 25)
                    assets.spd:drawImage(2, 223, 97)
                    assets.trn:drawImage(2, 223, 110)
                elseif string.find(boatname, '^pro') then
                    assets.pedallica:drawText('A decked-out boat\nwith tighter turns,\nwell-suited for pro\nboat racing.', 223, 25)
                    assets.spd:drawImage(2, 223, 97)
                    assets.trn:drawImage(3, 223, 110)
                elseif string.find(boatname, '^surf') then
                    assets.pedallica:drawText('Hang ten in this\nwave-surfing vessel\nthat\'s definitely not\njust a surfboard.', 223, 25)
                    assets.spd:drawImage(3, 223, 97)
                    assets.trn:drawImage(2, 223, 110)
                elseif string.find(boatname, '^raft') then
                    assets.pedallica:drawText('Keeps you alive, and\ndoes it well - good\nfor maneuvering\ntight corners.', 223, 25)
                    assets.spd:drawImage(1, 223, 97)
                    assets.trn:drawImage(4, 223, 110)
                elseif string.find(boatname, '^swan') then
                    assets.pedallica:drawText('A double-pedal boat\nthat\'s almost as\nmajestic as a real\nswan. ...Almost.', 223, 25)
                    assets.spd:drawImage(3, 223, 97)
                    assets.trn:drawImage(3, 223, 110)
                elseif string.find(boatname, '^gold') then
                    assets.pedallica:drawText('An old minecart,\nturned rowing\nhotrod. Slow, but\npulls wonderful turns.', 223, 25)
                    assets.spd:drawImage(2, 223, 97)
                    assets.trn:drawImage(4, 223, 110)
                elseif string.find(boatname, '^hover') then
                    assets.pedallica:drawText('Why row on top of\nthe water, when you \ncould just drift\nabove it instead?', 223, 25)
                    assets.spd:drawImage(4, 223, 97)
                    assets.trn:drawImage(1, 223, 110)
                end
            gfx.popContext()
            self:setImage(assets.img_boat_ui_full)
        end
    end
    
    self.bg = bg()
    self.spotlight = spotlight()
    self.boat = boat()
    self.ui = ui()
    self.boat_ui = boat_ui()
    
    self.ui:refresh()
    self.boat_ui:refresh('classic')

    self:add()
end

function garage:changeboat(boatname, dir)
    vars.boat_transitioning = true
    if dir then
        vars.anim_boat_transition_turn = gfx.animator.new(300, vars.boat_anim.frame, 12, pd.easingFunctions.outSine)
        vars.anim_boat_transition_move = gfx.animator.new(300, 42, 542, pd.easingFunctions.inBack, 100)
    else
        vars.anim_boat_transition_turn = gfx.animator.new(300, vars.boat_anim.frame, 26, pd.easingFunctions.outSine)
        vars.anim_boat_transition_move = gfx.animator.new(300, 42, -142, pd.easingFunctions.inBack, 100)
    end
    pd.timer.performAfterDelay(400, function()
        if string.find(boatname, 'locked') then
            if vars.locked == false then
                vars.locked = true
                vars.spotlight_fade_anim = gfx.animator.new(100, 1, 0, pd.easingFunctions.outSine)
            end
        else
            if vars.locked then
                vars.locked = false
                vars.spotlight_fade_anim = gfx.animator.new(500, 0, 1, pd.easingFunctions.inElastic)
            end
        end
        if dir then
            vars.anim_boat_transition_turn = gfx.animator.new(200, 26, 30)
            vars.anim_boat_transition_move = gfx.animator.new(200, -142, 42, pd.easingFunctions.outSine)
        else
            vars.anim_boat_transition_turn = gfx.animator.new(200, 12, 30)
            vars.anim_boat_transition_move = gfx.animator.new(200, 542, 42, pd.easingFunctions.outSine)
        end
        pd.timer.performAfterDelay(200, function()
            vars.boat_transitioning = false
            vars.boat_anim = gfx.animation.loop.new(40, assets.img_boat, true)
        end)
        if string.find(boatname, '^classic') then
            assets.img_boat = assets.img_classic
        elseif string.find(boatname, '^pro') then
            assets.img_boat = assets.img_pro
        elseif string.find(boatname, '^surf') then
            assets.img_boat = assets.img_surf
        elseif string.find(boatname, '^raft') then
            assets.img_boat = assets.img_raft
        elseif string.find(boatname, '^swan') then
            assets.img_boat = assets.img_swan
        elseif string.find(boatname, '^gold') then
            assets.img_boat = assets.img_gold
        elseif string.find(boatname, '^hover') then
            assets.img_boat = assets.img_hover
        end
        self.ui:refresh()
        self.boat_ui:refresh(boatname)
    end)
end

function garage:update()
    if pd.buttonJustPressed('a') then
        if vars.boat_transitioning == false then
            if vars.locked then
                assets.sfx_locked:play()
                shakiesx()
                return
            else
                assets.sfx_proceed:play()
                local boat = vars.current_menu_item
                scenemanager:transitionscene(tracks, boat)
            end
        end
    end
    if pd.buttonJustPressed('b') then
        scenemanager:transitionsceneoneway(title, false)
    end
    if pd.buttonJustPressed('left') then
        if vars.boat_transitioning == false then
            if vars.current_menu_item == 1 then
                assets.sfx_bonk:play()
                shakiesx()
                return
            else
                assets.sfx_menu:play()
                vars.current_menu_item = math.clamp(vars.current_menu_item - 1, 1, #vars.menu_list)
                vars.current_name = vars.menu_list[vars.current_menu_item]
                self:changeboat(vars.current_name, true)
            end
        end
    end
    if pd.buttonJustPressed('right') then
        if vars.boat_transitioning == false then
            if vars.current_menu_item == 7 then
                assets.sfx_bonk:play()
                shakiesx()
                return
            else
                assets.sfx_menu:play()
                vars.current_menu_item = math.clamp(vars.current_menu_item + 1, 1, #vars.menu_list)
                vars.current_name = vars.menu_list[vars.current_menu_item]
                self:changeboat(vars.current_name, false)
            end
        end
    end
end