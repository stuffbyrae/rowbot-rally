import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local text <const> = gfx.getLocalizedText

class('cheats').extends(gfx.sprite) -- Create the scene's class
function cheats:init(...)
    cheats.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(50)
		if not vars.transitioning then
			menu:addMenuItem(text('disableall'), function()
				enabled_cheats = false
				enabled_cheats_big = false
				enabled_cheats_small = false
				enabled_cheats_tiny = false
				enabled_cheats_retro = false
				enabled_cheats_scream = false
				gfx.sprite.redrawBackground()
			end)
			menu:addMenuItem(text('backtotitle'), function()
				if not vars.transitioning then
					self:leave()
				end
			end)
		end
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        kapel = gfx.font.new('fonts/kapel'),
        pedallica = gfx.font.new('fonts/pedallica'),
        kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
        image_ticker = gfx.image.new(800, 20, gfx.kColorBlack),
        image_wave = gfx.image.new('images/ui/wave'),
        image_wave_composite = gfx.image.new(464, 280),
        image_back = makebutton(text('back'), "small2"),
        image_popup_small = gfx.image.new('images/ui/popup_small'),
        sfx_bonk = smp.new('audio/sfx/bonk'),
        sfx_menu = smp.new('audio/sfx/menu'),
        sfx_clickon = smp.new('audio/sfx/clickon'),
        sfx_clickoff = smp.new('audio/sfx/clickoff'),
    }
    assets.sfx_bonk:setVolume(save.vol_sfx/5)
    assets.sfx_menu:setVolume(save.vol_sfx/5)
    assets.sfx_clickon:setVolume(save.vol_sfx/5)
    assets.sfx_clickoff:setVolume(save.vol_sfx/5)

    -- Writing in the image for the wave banner along the bottom
    gfx.pushContext(assets.image_wave_composite)
        assets.image_wave:drawTiled(0, 0, 464, 280)
    gfx.popContext()

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        transitioning = true,
        anim_wave_x = pd.timer.new(5000, 0, -58),
        anim_wave_y = pd.timer.new(1000, -30, 185, pd.easingFunctions.outCubic), -- Send the wave down from above
        item_list = {'big', 'small', 'tiny', 'retro', 'scream', 'trippy'},
        selection = 1,
        offset = 1,
    }
    vars.cheatsHandlers = {
        AButtonDown = function()
            if vars.selection == 1 and save.unlocked_cheats_big then -- Big
                if enabled_cheats_big then
                    enabled_cheats_big = false
                    assets.sfx_clickoff:play()
                else
                    enabled_cheats_big = true
                    enabled_cheats_small = false
                    enabled_cheats_tiny = false
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 2 and save.unlocked_cheats_small then -- Small
                if enabled_cheats_small then
                    enabled_cheats_small = false
                    assets.sfx_clickoff:play()
                else
                    enabled_cheats_small = true
                    enabled_cheats_big = false
                    enabled_cheats_tiny = false
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 3 and save.unlocked_cheats_tiny then -- Tiny
                if enabled_cheats_tiny then
                    enabled_cheats_tiny = false
                    assets.sfx_clickoff:play()
                else
                    enabled_cheats_tiny = true
                    enabled_cheats_big = false
                    enabled_cheats_small = false
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 4 and save.unlocked_cheats_retro then -- Retro
                if enabled_cheats_retro then
                    enabled_cheats_retro = false
                    assets.sfx_clickoff:play()
                else
                    enabled_cheats_retro = true
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 5 and save.unlocked_cheats_scream then -- Scream
                if enabled_cheats_scream then
                    enabled_cheats_scream = false
                    assets.sfx_clickoff:play()
                else
                    enabled_cheats_scream = true
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 6 and save.unlocked_cheats_trippy then
                if enabled_cheats_trippy then
                    enabled_cheats_trippy = false
                    assets.sfx_clickoff:play()
                else
                    enabled_cheats_trippy = true
                    assets.sfx_clickon:play()
                end
            else
                assets.sfx_bonk:play()
                shakies()
            end
            gfx.sprite.redrawBackground()
        end,

        upButtonDown = function()
            self:newselection(false)
        end,

        downButtonDown = function()
            self:newselection(true)
        end,

        BButtonDown = function()
            if not vars.transitioning then
                self:leave()
            end
        end
    }

    pd.timer.performAfterDelay(1000, function() -- After the wave's done animating inward...
        vars.transitioning = false -- Start accepting button presses to go back.
        vars.anim_wave_y:resetnew(5000, 185, 195, pd.easingFunctions.inOutCubic) -- Set the wave's idle animation,
        vars.anim_wave_y.repeats = true -- make it repeat forever,
        vars.anim_wave_y.reverses = true -- and make it loop!
        pd.inputHandlers.push(vars.cheatsHandlers) -- Wait to push the input handlers, so you can't fuck with shit before you have a chance to read it.
    end)

    vars.textwidth = assets.kapel_doubleup:getTextWidth(text('cheats')) + 10
    -- Writing in the image for the "Options" header ticker
    gfx.pushContext(assets.image_ticker)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.kapel_doubleup:drawText(text('cheats'), vars.textwidth * 1, -3)
        assets.kapel_doubleup:drawText(text('cheats'), vars.textwidth * 2, -3)
        assets.kapel_doubleup:drawText(text('cheats'), vars.textwidth * 3, -3)
        assets.kapel_doubleup:drawText(text('cheats'), vars.textwidth * 4, -3)
        assets.kapel_doubleup:drawText(text('cheats'), vars.textwidth * 5, -3)
        assets.kapel_doubleup:drawText(text('cheats'), vars.textwidth * 6, -3)
        assets.kapel_doubleup:drawText(text('cheats'), vars.textwidth * 7, -3)
    gfx.popContext()

    vars.anim_ticker = pd.timer.new(2000, -vars.textwidth, (-vars.textwidth * 2) + 1)
    vars.anim_ticker.repeats = true
    vars.anim_wave_x.repeats = true
    vars.anim_wave_y.discardOnCompletion = false

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
        assets.image_popup_small:draw(192, 26)
        if vars.selection >= 4 then vars.offset = 2 else vars.offset = 1 end
        gfx.fillRect(0, 5 + 15 * vars.selection + 10 * vars.offset, 5, 15)
        enabled_cheats = false

        if enabled_cheats_big then
            enabled_cheats = true
            assets.pedallica:drawTextAligned(text('on'), 180, 30, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 30, kTextAlignment.right)
        end
        if enabled_cheats_small then
            enabled_cheats = true
            assets.pedallica:drawTextAligned(text('on'), 180, 45, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 45, kTextAlignment.right)
        end

        if enabled_cheats_tiny then
            enabled_cheats = true
            assets.pedallica:drawTextAligned(text('on'), 180, 60, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 60, kTextAlignment.right)
        end
        if enabled_cheats_retro then
            enabled_cheats = true
            assets.pedallica:drawTextAligned(text('on'), 180, 85, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 85, kTextAlignment.right)
        end
        if enabled_cheats_scream then
            enabled_cheats = true
            assets.pedallica:drawTextAligned(text('on'), 180, 100, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 100, kTextAlignment.right)
        end
        if enabled_cheats_trippy then
            enabled_cheats = true
            assets.pedallica:drawTextAligned(text('on'), 180, 115, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 115, kTextAlignment.right)
        end

        if save.unlocked_cheats_big then
            assets.pedallica:drawText(text('big_name'), 10, 30)
        else
            assets.pedallica:drawText(text('???'), 10, 30)
            if save.button_controls then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
                gfx.fillRect(10, 30, 180, 15)
                gfx.setColor(gfx.kColorBlack)
            end
        end
        if save.unlocked_cheats_small then
            assets.pedallica:drawText(text('small_name'), 10, 45)
        else
            assets.pedallica:drawText(text('???'), 10, 45)
            if save.button_controls then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
                gfx.fillRect(10, 45, 180, 15)
                gfx.setColor(gfx.kColorBlack)
            end
        end
        if save.unlocked_cheats_tiny then
            assets.pedallica:drawText(text('tiny_name'), 10, 60)
        else
            assets.pedallica:drawText(text('???'), 10, 60)
            if save.button_controls then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
                gfx.fillRect(10, 60, 180, 15)
                gfx.setColor(gfx.kColorBlack)
            end
        end

        if save.unlocked_cheats_retro then
            assets.pedallica:drawText(text('retro_name'), 10, 85)
        else
            assets.pedallica:drawText(text('???'), 10, 85)
            if save.button_controls then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
                gfx.fillRect(10, 85, 180, 15)
                gfx.setColor(gfx.kColorBlack)
            end
        end
        if save.unlocked_cheats_scream then
            assets.pedallica:drawText(text('scream_name'), 10, 100)
        else
            assets.pedallica:drawText(text('???'), 10, 100)
            if save.button_controls then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
                gfx.fillRect(10, 100, 180, 15)
                gfx.setColor(gfx.kColorBlack)
            end
        end
        if save.unlocked_cheats_trippy then
            assets.pedallica:drawText(text('trippy_name'), 10, 115)
        else
            assets.pedallica:drawText(text('???'), 10, 115)
            if save.button_controls then
                gfx.setColor(gfx.kColorWhite)
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
                gfx.fillRect(10, 115, 180, 15)
                gfx.setColor(gfx.kColorBlack)
            end
        end

        if save['unlocked_cheats_' .. vars.item_list[vars.selection]] then
            assets.pedallica:drawText(text(vars.item_list[vars.selection] .. '_desc'), 213, 48)
        end
    end)

    class('cheats_ticker', _, classes).extends(gfx.sprite)
    function classes.cheats_ticker:init()
        classes.cheats_ticker.super.init(self)
        self:setImage(assets.image_ticker)
        self:setCenter(0, 0)
        self:setZIndex(1)
        self:add()
    end
    function classes.cheats_ticker:update()
        self:moveTo(vars.anim_ticker.value, 0)
    end

    class('cheats_wave', _, classes).extends(gfx.sprite)
    function classes.cheats_wave:init()
        classes.cheats_wave.super.init(self)
        self:setSize(464, 280)
        self:setCenter(0, 0)
        self:setZIndex(2)
        self:moveTo(0, 185)
        self:add()
    end
    function classes.cheats_wave:update()
        self:moveTo(0, vars.anim_wave_y.value)
    end
    function classes.cheats_wave:draw()
        assets.image_wave_composite:draw(vars.anim_wave_x.value, 0)
        if enabled_cheats then
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            assets.pedallica:drawText(text('cheats_warning'), 10, 15)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
    end

    class('cheats_back', _, classes).extends(gfx.sprite)
    function classes.cheats_back:init()
        classes.cheats_back.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(3)
        self:setImage(assets.image_back)
        self:moveTo(295, 210)
        self:add()
    end
    function classes.cheats_back:update()
        self:moveTo(295, (vars.anim_wave_y.value*1.1))
    end

    -- Set the sprites
    sprites.ticker = classes.cheats_ticker()
    sprites.wave = classes.cheats_wave()
    sprites.back = classes.cheats_back()
    self:add()
end

-- Select a new stage using the arrow keys. dir is a boolean — left is false, right is true
function cheats:newselection(dir, num)
    vars.old_selection = vars.selection
    if dir then
        vars.selection = math.clamp(vars.selection + (num or 1), 1, #vars.item_list)
    else
        vars.selection = math.clamp(vars.selection - (num or 1), 1, #vars.item_list)
    end
    -- If this is true, then that means we've reached an end and nothing has changed.
    if vars.old_selection == vars.selection then
        assets.sfx_bonk:play()
        shakies_y()
    else
        assets.sfx_menu:play()
        gfx.sprite.redrawBackground()
    end
end

function cheats:leave() -- Leave and move back to the title screen
    savegame()
    pd.inputHandlers.pop() -- Pop the handlers, so you can't change anything as you're leaving.
    vars.transitioning = true -- Make sure you don't accept any more button presses at this time
    vars.anim_wave_y:resetnew(1000, sprites.wave.y, -40, pd.easingFunctions.inBack) -- Send the wave back up to transition smoothly
    pd.timer.performAfterDelay(1200, function() -- After that animation's done...
        title_memorize = 'cheats'
        scenemanager:switchscene(title, title_memorize) -- Switch back to the title!
    end)
end

function cheats:update()
	if not scenemanager.transitioning then
		local ticks = pd.getCrankTicks(7)
		if not vars.transitioning then
			if ticks < 0 then
				self:newselection(false, -ticks)
			elseif ticks > 0 then
				self:newselection(true, ticks)
			end
		end
	end
end