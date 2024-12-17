import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local text <const> = gfx.getLocalizedText

class('options').extends(gfx.sprite) -- Create the scene's class
function options:init(...)
    options.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    show_crank = false -- Should the crank indicator be shown?
    gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        setpauseimage(50)
		if not vars.transitioning then
			menu:addMenuItem(text('setdefaults'), function()
				save.vol_music = 5
				save.vol_sfx = 5
				if pd.isSimulator == 1 then
					save.button_controls = true
				else
					save.button_controls = false
				end
				save.sensitivity = 3
				save.pro_ui = false
				perf = false
				newmusic('audio/music/title', true, 1.1)
				self:sfx_change()
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
        image_gears = gfx.imagetable.new('images/ui/options_gears')
    }
    self:sfx_change()

    -- Writing in the image for the wave banner along the bottom
    gfx.pushContext(assets.image_wave_composite)
        assets.image_wave:drawTiled(0, 0, 464, 280)
    gfx.popContext()

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        slide = args[1], -- bool
        transitioning = true,
        anim_wave_x = pd.timer.new(5000, 0, -58),
        anim_wave_y = pd.timer.new(1000, -30, 185, pd.easingFunctions.outCubic), -- Send the wave down from above
        item_list = {'music', 'sfx', 'button_controls', 'sensitivity', 'ui', 'minimap', 'perf'},
        selection = 1,
        offset = 1,
    }
    vars.optionsHandlers = {
        AButtonDown = function()
            if vars.selection == 1 then -- Music
                if save.vol_music > 0 then
                    save.vol_music = 0
                    assets.sfx_clickoff:play()
                    stopmusic()
                else
                    save.vol_music = 5
                    assets.sfx_clickon:play()
                    newmusic('audio/music/title', true, 1.1)
                end
            elseif vars.selection == 2 then -- SFX
                if save.vol_sfx > 0 then
                    save.vol_sfx = 0
                    assets.sfx_clickoff:play() -- Lol
                else
                    save.vol_sfx = 5
                    assets.sfx_clickon:play()
                end
                self:sfx_change()
            elseif vars.selection == 3 then -- Button controls
                if save.button_controls then
                    save.button_controls = false
                    assets.sfx_clickoff:play()
                else
                    save.button_controls = true
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 4 then -- Sensitivity
                if save.button_controls then
                    shakies()
                    assets.sfx_bonk:play()
                else
                    if save.sensitivity > 2 then
                        save.sensitivity = 2
                        assets.sfx_clickon:play()
                    else
                        save.sensitivity = 3
                        assets.sfx_clickoff:play()
                    end
                end
            elseif vars.selection == 5 then -- Pro UI
                if save.pro_ui then
                    save.pro_ui = false
                    assets.sfx_clickoff:play()
                else
                    save.pro_ui = true
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 6 then
                if save.minimap then
                    save.minimap = false
                    assets.sfx_clickoff:play()
                else
                    save.minimap = true
                    assets.sfx_clickon:play()
                end
            elseif vars.selection == 7 then
                if perf then
                    perf = false
                    save.perf = false
                    assets.sfx_clickoff:play()
                else
                    perf = true
                    save.perf = true
                    assets.sfx_clickon:play()
                end
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
        vars.anim_wave_y.repeatCount = -1 -- make it repeat forever,
        vars.anim_wave_y.reverses = true -- and make it loop!
        pd.inputHandlers.push(vars.optionsHandlers) -- Wait to push the input handlers, so you can't fuck with shit before you have a chance to read it.
    end)

    vars.textwidth = assets.kapel_doubleup:getTextWidth(text('options')) + 10
    -- Writing in the image for the "Options" header ticker
    gfx.pushContext(assets.image_ticker)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.kapel_doubleup:drawText(text('options'), vars.textwidth * 1, -3)
        assets.kapel_doubleup:drawText(text('options'), vars.textwidth * 2, -3)
        assets.kapel_doubleup:drawText(text('options'), vars.textwidth * 3, -3)
        assets.kapel_doubleup:drawText(text('options'), vars.textwidth * 4, -3)
        assets.kapel_doubleup:drawText(text('options'), vars.textwidth * 5, -3)
    gfx.popContext()

    vars.anim_ticker = pd.timer.new(2000, -vars.textwidth, (-vars.textwidth * 2) + 1)
    vars.anim_ticker.repeats = true
    vars.anim_wave_x.repeats = true
    vars.anim_wave_y.discardOnCompletion = false
    vars.anim_gears = gfx.animation.loop.new(20, assets.image_gears, true)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
        assets.image_popup_small:draw(192, 26)
        if vars.selection >= 3 then vars.offset = 2 else vars.offset = 1 end
        gfx.fillRect(0, 5 + 15 * vars.selection + 10 * vars.offset, 5, 15)

        assets.pedallica:drawText(text('music_name'), 10, 30)
        assets.pedallica:drawText(text('sfx_name'), 10, 45)

        assets.pedallica:drawText(text('button_controls_name'), 10, 70)
        assets.pedallica:drawText(text('sensitivity_name'), 10, 85)
        assets.pedallica:drawText(text('ui_name'), 10, 100)
        assets.pedallica:drawText(text('minimap_name'), 10, 115)
        assets.pedallica:drawText(text('perf_name'), 10, 130)

        if save.vol_music > 0 then
            assets.pedallica:drawTextAligned(text('on'), 180, 30, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 30, kTextAlignment.right)
        end
        if save.vol_sfx > 0 then
            assets.pedallica:drawTextAligned(text('on'), 180, 45, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 45, kTextAlignment.right)
        end

        if save.button_controls then
            assets.pedallica:drawTextAligned(text('on'), 180, 70, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 70, kTextAlignment.right)
        end
        if save.sensitivity < 3 then
            assets.pedallica:drawTextAligned(text('on'), 180, 85, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 85, kTextAlignment.right)
        end
        if save.pro_ui then
            assets.pedallica:drawTextAligned(text('on'), 180, 100, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 100, kTextAlignment.right)
        end
        if save.minimap then
            assets.pedallica:drawTextAligned(text('on'), 180, 115, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 115, kTextAlignment.right)
        end
        if perf then
            assets.pedallica:drawTextAligned(text('on'), 180, 130, kTextAlignment.right)
        else
            assets.pedallica:drawTextAligned(text('off'), 180, 130, kTextAlignment.right)
        end

        if save.button_controls then
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
            gfx.fillRect(10, 85, 180, 15)
            gfx.setColor(gfx.kColorBlack)
        end

        assets.pedallica:drawText(text(vars.item_list[vars.selection] .. '_desc'), 213, 48)
    end)

    class('options_ticker', _, classes).extends(gfx.sprite)
    function classes.options_ticker:init()
        classes.options_ticker.super.init(self)
        self:setImage(assets.image_ticker)
        self:setCenter(0, 0)
        self:setZIndex(1)
        self:add()
    end
    function classes.options_ticker:update()
        self:moveTo(vars.anim_ticker.value, 0)
    end

    class('options_gear', _, classes).extends(gfx.sprite)
    function classes.options_gear:init()
        classes.options_gear.super.init(self)
        self:setZIndex(2)
        self:setCenter(0, 0)
        self:moveTo(25, 20)
        self:add()
    end
    function classes.options_gear:update()
        self:setImage(vars.anim_gears:image())
        self:moveTo(25, vars.anim_wave_y.value - 40)
    end

    class('options_wave', _, classes).extends(gfx.sprite)
    function classes.options_wave:init()
        classes.options_wave.super.init(self)
        self:setSize(464, 280)
        self:setCenter(0, 0)
        self:setZIndex(3)
        self:moveTo(0, 185)
        self:add()
    end
    function classes.options_wave:update()
        self:moveTo(0, vars.anim_wave_y.value)
        self:markDirty()
    end
    function classes.options_wave:draw()
        assets.image_wave_composite:draw(vars.anim_wave_x.value, 0)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        assets.pedallica:drawText('v' .. pd.metadata.version .. ' - Build ' .. pd.metadata.buildNumber, 10, 20)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end

    class('options_back', _, classes).extends(gfx.sprite)
    function classes.options_back:init()
        classes.options_back.super.init(self)
        self:setCenter(0, 0)
        self:setZIndex(4)
        self:setImage(assets.image_back)
        self:moveTo(295, 210)
        self:add()
    end
    function classes.options_back:update()
        self:moveTo(295, (vars.anim_wave_y.value*1.1))
    end

    -- Set the sprites
    sprites.ticker = classes.options_ticker()
    sprites.wave = classes.options_wave()
    sprites.back = classes.options_back()
    sprites.gear = classes.options_gear()
    self:add()
end

-- This needs to be its own function, because this is the only scene where these SFX can change volumes dynamically (depending on option change.)
function options:sfx_change()
    assets.sfx_bonk:setVolume(save.vol_sfx/5)
    assets.sfx_menu:setVolume(save.vol_sfx/5)
    assets.sfx_clickon:setVolume(save.vol_sfx/5)
    assets.sfx_clickoff:setVolume(save.vol_sfx/5)
end

-- Select a new stage using the arrow keys. dir is a boolean — left is false, right is true
function options:newselection(dir, num)
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

function options:leave() -- Leave and move back to the title screen
    savegame()
    pd.inputHandlers.pop() -- Pop the handlers, so you can't change anything as you're leaving.
    vars.transitioning = true -- Make sure you don't accept any more button presses at this time
    vars.anim_wave_y:resetnew(1000, sprites.wave.y, -40, pd.easingFunctions.inBack) -- Send the wave back up to transition smoothly
    pd.timer.performAfterDelay(1200, function()
        if not vars.slide then
            title_memorize = 'options'
        end
        scenemanager:switchscene(title, title_memorize) -- Switch back to the title!
    end)
end

function options:update()
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