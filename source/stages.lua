-- Move to this scene later on ...
import 'title'
import 'race'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('stages').extends(gfx.sprite) -- Create the scene's class
function stages:init(...)
	stages.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	show_crank = false -- Should the crank indicator be shown?
	gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		setpauseimage(200)
		menu:removeAllMenuItems()
		if not scenemanager.transitioning then
			menu:addMenuItem(text('backtotitle'), function()
				fademusic()
				title_memorize = 'time_trials'
				scenemanager:transitionsceneonewayback(title, title_memorize)
			end)
		end
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		kapel_doubleup = gfx.font.new('fonts/kapel_doubleup'),
		kapel = gfx.font.new('fonts/kapel'),
		pedallica = gfx.font.new('fonts/pedallica'),
		times_new_rally = gfx.font.new('fonts/times_new_rally'),
		image_boat = gfx.image.new('images/stages/boat'),
		image_preview = gfx.image.new('images/stages/preview1'),
		image_timer = gfx.image.new('images/race/timer'),
		image_wave = gfx.image.new('images/ui/wave'),
		image_wave_composite = gfx.image.new(464, 280),
		image_top = gfx.image.new(480, 300),
		image_ok = makebutton(text('ok'), 'big'),
		image_back = makebutton(text('back'), 'small'),
		image_leaderboards = makebutton(text('up_leaderboards'), 'small'),
		image_mirror = makebutton(text('down_mirror'), 'small'),
		image_regular = makebutton(text('down_regular'), 'small'),
		image_medal_unobtained = gfx.image.new('images/stages/medal_unobtained'),
		image_medal_flawless = gfx.image.new('images/stages/medal_flawless'),
		image_medal_speedy = gfx.image.new('images/stages/medal_speedy'),
		image_buttons = gfx.image.new(156, 240),
		sfx_whoosh = smp.new('audio/sfx/whoosh'),
		sfx_bonk = smp.new('audio/sfx/bonk'),
		sfx_leaderboard_in = smp.new('audio/sfx/leaderboard_in'),
		sfx_proceed = smp.new('audio/sfx/proceed'),
		sfx_pop = smp.new('audio/sfx/pop'),
		sfx_menu = smp.new('audio/sfx/menu'),
		image_fade = gfx.imagetable.new('images/ui/fade_white/fade'),
		sfx_cymbal = smp.new('audio/sfx/cymbal'),
	}
	assets.sfx_whoosh:setVolume(save.vol_sfx/5)
	assets.sfx_bonk:setVolume(save.vol_sfx/5)
	assets.sfx_leaderboard_in:setVolume(save.vol_sfx/5)
	assets.sfx_proceed:setVolume(save.vol_sfx/5)
	assets.sfx_pop:setVolume(save.vol_sfx/5)
	assets.sfx_menu:setVolume(save.vol_sfx/5)
	assets.sfx_cymbal:setVolume(save.vol_sfx/5)

	-- Writing in the image for the wave banner along the bottom
	gfx.pushContext(assets.image_wave_composite)
		assets.image_wave:drawTiled(0, 0, 464, 280)
	gfx.popContext()

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		selection = args[1] or 1,
		mirror = args[2] or false,
		leaderboards_open = false,
		leaderboards_closable = false,
		anim_wave_x = pd.timer.new(5000, 0, -58),
		anim_wave_y = pd.timer.new(1, 225, 225),
		anim_boat_x = pd.timer.new(1, 45, 45),
		anim_boat_y = pd.timer.new(2500, 195, 200, pd.easingFunctions.inOutCubic),
		anim_back_y = pd.timer.new(1, 235, 235),
		anim_top_y = pd.timer.new(1, 0, 0),
		anim_fade = pd.timer.new(1, 34, 34),
		anim_preview_x = pd.timer.new(1, 400, 400),
		board = '',
		lb_selection = 0,
		lb_checking = false,
	}
	vars.stagesHandlers = {
		leftButtonDown = function()
			self:newselection(false)
		end,

		rightButtonDown = function()
			self:newselection(true)
		end,

		upButtonDown = function()
			if pd.metadata.bundleID == "wtf.rae.rowbotrally" then
				assets.sfx_leaderboard_in:play()
				self:leaderboardsin()
			end
		end,

		downButtonDown = function()
			if save['stage' .. vars.selection .. '_flawless'] and save['stage' .. vars.selection .. '_speedy'] then
				self:flipmirror()
			end
		end,

		BButtonDown = function()
			if not scenemanager.transitioning then
				fademusic()
				title_memorize = 'time_trials'
				scenemanager:transitionsceneonewayback(title, title_memorize)
			end
		end,

		AButtonDown = function()
			self:enterrace()
		end
	}
	vars.leaderboardHandlers = {
		BButtonDown = function()
			if vars.leaderboards_closable then
				self:leaderboardsout()
			end
		end
	}
	pd.inputHandlers.push(vars.stagesHandlers)

	vars.anim_wave_x.repeats = true
	vars.anim_wave_y.discardOnCompletion = false
	vars.anim_boat_x.discardOnCompletion = false
	vars.anim_boat_y.repeats = true
	vars.anim_boat_y.reverses = true
	vars.anim_boat_y.discardOnCompletion = false
	vars.anim_back_y.discardOnCompletion = false
	vars.anim_top_y.discardOnCompletion = false
	vars.anim_preview_x.discardOnCompletion = false
	vars.anim_fade.discardOnCompletion = false

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
		gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
	end)

	class('stages_wave', _, classes).extends(gfx.sprite)
	function classes.stages_wave:init()
		classes.stages_wave.super.init(self)
		self:setImage(assets.image_wave_composite)
		self:setCenter(0, 0)
		self:setZIndex(2)
		self:moveTo(0, 225)
		self:setZIndex(0)
		self:add()
	end
	function classes.stages_wave:update()
		self:moveTo(vars.anim_wave_x.value, vars.anim_wave_y.value)
	end

	class('stages_boat', _, classes).extends(gfx.sprite)
	function classes.stages_boat:init()
		classes.stages_boat.super.init(self)
		self:setImage(assets.image_boat)
		self:moveTo(45, 195)
		self:setZIndex(4)
		self:add()
	end
	function classes.stages_boat:update()
		self:moveTo(vars.anim_boat_x.value, vars.anim_boat_y.value)
	end

	class('stages_back', _, classes).extends(gfx.sprite)
	function classes.stages_back:init()
		classes.stages_back.super.init(self)
		self:setImage(assets.image_back)
		self:setCenter(0, 1)
		self:moveTo(105, 235)
		self:setZIndex(2)
		self:add()
	end
	function classes.stages_back:update()
		self:moveTo(105, vars.anim_back_y.value)
	end

	class('stages_top', _, classes).extends(gfx.sprite)
	function classes.stages_top:init()
		classes.stages_top.super.init(self)
		self:setImage(assets.image_top)
		self:setCenter(0, 0)
		self:setZIndex(3)
		self:add()
	end
	function classes.stages_top:update()
		self:moveTo(0, vars.anim_top_y.value)
	end

	class('stages_preview', _, classes).extends(gfx.sprite)
	function classes.stages_preview:init()
		classes.stages_preview.super.init(self)
		self:setZIndex(4)
		self:setCenter(1, 0)
		self:moveTo(400, 0)
		self:setImage(assets.image_preview)
		self:add()
	end
	function classes.stages_preview:update()
		self:moveTo(vars.anim_preview_x.value, 0)
	end

	class('stages_buttons', _, classes).extends(gfx.sprite)
	function classes.stages_buttons:init()
		classes.stages_buttons.super.init(self)
		self:setZIndex(5)
		self:setImage(assets.image_buttons)
		self:setCenter(1, 1)
		self:moveTo(390, 235)
		self:add()
	end
	function classes.stages_buttons:update()
		self:moveTo(vars.anim_preview_x.value - 10, 235)
	end

	class('stages_lb_accent', _, classes).extends(gfx.sprite)
	function classes.stages_lb_accent:init()
		classes.stages_lb_accent.super.init(self)
		self:setCenter(0, 1)
		self:moveTo(0, 240)
		self:setZIndex(1)
	end

	class('stages_lb_bubble', _, classes).extends(gfx.sprite)
	function classes.stages_lb_bubble:init()
		classes.stages_lb_bubble.super.init(self)
		self:setCenter(1, 0.5)
		self:moveTo(400, 120)
		self:setZIndex(7)
	end
	function classes.stages_lb_bubble:update()
		if vars.anim_lb_bubble ~= nil then
			self:setImage(vars.anim_lb_bubble:image())
			if not vars.anim_lb_bubble:isValid() then
				vars.anim_lb_bubble = gfx.animation.loop.new(250, assets.image_leaderboard_container, true)
			end
		end
	end

	class('stages_lb_text', _, classes).extends(gfx.sprite)
	function classes.stages_lb_text:init()
		classes.stages_lb_text.super.init(self)
		self:setCenter(1, 0.5)
		self:moveTo(400, 120)
		self:setZIndex(8)
	end

	class('stages_fade', _, classes).extends(gfx.sprite)
	function classes.stages_fade:init()
		classes.stages_fade.super.init(self)
		self:setCenter(0, 0)
		self:moveTo(0, 0)
		self:setZIndex(999)
		self:setIgnoresDrawOffset(true)
		self:add()
	end
	function classes.stages_fade:update()
		if vars.anim_fade ~= nil then
			self:setImage(assets.image_fade[math.floor(vars.anim_fade.value)])
		end
	end

	-- Set the sprites
	sprites.wave = classes.stages_wave()
	sprites.boat = classes.stages_boat()
	sprites.back = classes.stages_back()
	sprites.top = classes.stages_top()
	sprites.preview = classes.stages_preview()
	sprites.buttons = classes.stages_buttons()
	sprites.lb_accent = classes.stages_lb_accent()
	sprites.lb_bubble = classes.stages_lb_bubble()
	sprites.lb_text = classes.stages_lb_text()
	sprites.fade = classes.stages_fade()
	self:add()

	self:update_image_buttons()
	self:update_image_top(vars.selection, true)
	self:update_image_preview()

	newmusic('audio/music/stages', true) -- Adding new music
end

-- Select a new stage using the arrow keys. dir is a boolean — left is false, right is true
function stages:newselection(dir, num)
	vars.mirror = false
	vars.old_selection = vars.selection
	if dir then
		vars.selection = math.clamp(vars.selection + (num or 1), 1, save.stages_unlocked)
	else
		vars.selection = math.clamp(vars.selection - (num or 1), 1, save.stages_unlocked)
	end
	-- If this is true, then that means we've reached an end and nothing has changed.
	if vars.old_selection == vars.selection then
		assets.sfx_bonk:play()
		shakies()
	else
		assets.sfx_menu:play()
		self:update_image_buttons()
		self:update_image_top(vars.selection, true)
		self:update_image_preview()
	end
end

-- Enter a leaderboards screen
function stages:leaderboardsin()
	vars.leaderboards_open = true
	self:update_image_top(vars.selection, false)
	pd.inputHandlers.push(vars.leaderboardHandlers, true)
	assets.image_rowbot_accent = gfx.imagetable.new('images/stages/rowbot_accent')
	assets.image_leaderboard_container = gfx.imagetable.new('images/stages/leaderboard_container')
	assets.image_leaderboard_container_intro = gfx.imagetable.new('images/stages/leaderboard_container_intro')
	vars.anim_boat_x:resetnew(250, sprites.boat.x, -100, pd.easingFunctions.inCubic)
	vars.anim_preview_x:resetnew(250, sprites.preview.x, 600, pd.easingFunctions.inCubic)
	vars.anim_lb_bubble = gfx.animation.loop.new(100, assets.image_leaderboard_container_intro, false)
	sprites.lb_accent:setImage(assets.image_rowbot_accent[2])
	sprites.lb_accent:add()
	sprites.lb_bubble:add()
	pd.timer.performAfterDelay(1000, function()
		vars.leaderboards_closable = true
		assets.image_lb_text = gfx.image.new(190, 240)
		if playtest then
			sprites.lb_accent:setImage(assets.image_rowbot_accent[3])
			gfx.pushContext(assets.image_lb_text)
				assets.pedallica:drawTextAligned(text('leaderboards_playtest'), 100, 100, kTextAlignment.center)
			gfx.popContext()
			sprites.lb_text:setImage(assets.image_lb_text)
			sprites.lb_text:add()
			return
		end
		sprites.lb_accent:setImage(assets.image_rowbot_accent[1])
		if vars.mirror then
			vars.board = 'stage' .. tostring(vars.selection) .. 'mirror'
		else
			vars.board = 'stage' .. tostring(vars.selection)
		end
		if vars.lb_checking then
			gfx.pushContext(assets.image_lb_text)
				assets.pedallica:drawTextAligned(text('leaderboards_checking'), 100, 100, kTextAlignment.center)
			gfx.popContext()
			sprites.lb_text:setImage(assets.image_lb_text)
			sprites.lb_text:add()
			sprites.lb_accent:setImage(assets.image_rowbot_accent[3])
		else
			vars.lb_checking = true
			vars.lb_selection = vars.selection
			pd.scoreboards.getPersonalBest(vars.board, function(status, result)
				if status.code == "OK" and vars.lb_selection == vars.selection then
					if vars.leaderboards_open then
						self:update_image_top(vars.selection, false, result.rank, result.player)
					end
				end
			end)
			gfx.pushContext(assets.image_lb_text)
				assets.pedallica:drawTextAligned(text('leaderboards_grab'), 100, 100, kTextAlignment.center)
			gfx.popContext()
			sprites.lb_text:setImage(assets.image_lb_text)
			sprites.lb_text:add()
			pd.scoreboards.getScores(vars.board, function(status, result)
				vars.lb_checking = false
				if status.code == "OK" and vars.leaderboards_open and vars.lb_selection == vars.selection then
					assets.image_lb_text = gfx.image.new(190, 240)
					gfx.pushContext(assets.image_lb_text)
					for _, v in ipairs(result.scores) do
						if v.rank <= 9 then
							mins, secs, mils = timecalc(v.value)
							assets.kapel:drawTextAligned(v.player, 185, (26 * v.rank) - 22, kTextAlignment.right)
							assets.kapel:drawText(ordinal(v.rank), 12, (26 * v.rank) - 22)
							assets.pedallica:drawTextAligned(mins .. ':' .. secs .. '.' .. mils, 185, (26 * v.rank) - 12, kTextAlignment.right)
							mins = nil
							secs = nil
							mils = nil
						end
					end
					if next(result.scores) == nil then
						assets.pedallica:drawTextAligned(text('leaderboards_empty'), 100, 100, kTextAlignment.center)
					end
					gfx.popContext()
					sprites.lb_text:setImage(assets.image_lb_text)
					sprites.lb_accent:setImage(assets.image_rowbot_accent[2])
				elseif status.code == "ERROR" and vars.leaderboards_open and vars.lb_selection == vars.selection then
					assets.image_lb_text = gfx.image.new(190, 240)
					gfx.pushContext(assets.image_lb_text)
						assets.pedallica:drawTextAligned(text('leaderboards_fail'), 100, 100, kTextAlignment.center)
					gfx.popContext()
					sprites.lb_text:setImage(assets.image_lb_text)
					sprites.lb_accent:setImage(assets.image_rowbot_accent[3])
				end
			end)
		end
	end)
end

-- Exit an already-open leaderboards screen
function stages:leaderboardsout()
	assets.sfx_pop:play()
	vars.leaderboards_closable = false
	sprites.lb_text:remove()
	self:update_image_top(vars.selection, false)
	assets.image_leaderboard_container_outro = gfx.imagetable.new('images/stages/leaderboard_container_outro')
	vars.anim_lb_bubble = gfx.animation.loop.new(70, assets.image_leaderboard_container_outro, false)
	pd.timer.performAfterDelay(250, function()
		assets.sfx_whoosh:play()
		vars.anim_boat_x:resetnew(250, sprites.boat.x, 45, pd.easingFunctions.outCubic)
		vars.anim_preview_x:resetnew(250, sprites.preview.x, 400, pd.easingFunctions.outCubic)
	end)
	pd.timer.performAfterDelay(300, function()
		sprites.lb_bubble:remove()
		vars.anim_lb_bubble = nil
	end)
	pd.timer.performAfterDelay(501, function()
		if vars.leaderboards_open then
			vars.leaderboards_open = false
			sprites.lb_accent:remove()
			pd.inputHandlers.pop()
			self:update_image_top(vars.selection, true)
		end
	end)
end

-- Transition into a white screen, for the racing scene
function stages:enterrace()
	pd.inputHandlers.pop()
	assets.sfx_proceed:play()
	vars.transitioning = true
	fademusic(1000)
	vars.anim_boat_x:resetnew(750, sprites.boat.x, 450, pd.easingFunctions.inCubic)
	vars.anim_preview_x:resetnew(250, sprites.preview.x, 600, pd.easingFunctions.inCubic)
	vars.anim_back_y:resetnew(250, sprites.back.y, 275, pd.easingFunctions.inCubic)
	vars.anim_top_y:resetnew(250, sprites.top.y, -400, pd.easingFunctions.inCubic)
	vars.anim_boat_x.timerEndedCallback = function()
		vars.anim_wave_y:resetnew(250, sprites.wave.y, 245, pd.easingFunctions.inBack)
	end
	pd.timer.performAfterDelay(1200, function()
		scenemanager:switchscene(race, vars.selection, "tt", vars.mirror)
	end)
end

function stages:update_image_buttons()
	assets.image_buttons = gfx.image.new(156, 240)
	gfx.pushContext(assets.image_buttons)
		assets.image_ok:drawAnchored(99, 10, 0.5, 0)
		if save['stage' .. vars.selection .. '_flawless'] and save['stage' .. vars.selection .. '_speedy'] then
			if vars.mirror then
				if pd.metadata.bundleID == "wtf.rae.rowbotrally" then assets.image_leaderboards:drawAnchored(78, 190, 0.5, 0) end
				assets.image_regular:drawAnchored(78, 217, 0.5, 0)
			else
				if pd.metadata.bundleID == "wtf.rae.rowbotrally" then assets.image_leaderboards:drawAnchored(78, 190, 0.5, 0) end
				assets.image_mirror:drawAnchored(78, 217, 0.5, 0)
			end
		else
			if pd.metadata.bundleID == "wtf.rae.rowbotrally" then assets.image_leaderboards:drawAnchored(78, 217, 0.5, 0) end
		end
	gfx.popContext()
	sprites.buttons:setImage(assets.image_buttons)
end

function stages:update_image_preview()
	if vars.mirror then
		assets.image_preview = gfx.image.new('images/stages/preview' .. vars.selection .. '_mirror')
	else
		assets.image_preview = gfx.image.new('images/stages/preview' .. vars.selection)
	end
	sprites.preview:setImage(assets.image_preview)
end

-- Writing to the image along the top; wrapped in a function so that I can update it later.
function stages:update_image_top(stage, show_desc, ranking, name)
	-- Calculate the proper time for each save, and assign it to variables
	local mins
	local secs
	local mils
	if vars.mirror then
		mins, secs, mils = timecalc(save['stage' .. stage .. '_best_mirror'])
	else
		mins, secs, mils = timecalc(save['stage' .. stage .. '_best'])
	end
	assets.image_top = gfx.image.new(480, 300)
	gfx.pushContext(assets.image_top)
		gfx.fillRect(0, 0, 480, 50) -- Add the black rectangle

		if (vars.mirror == false and save['stage' .. stage .. '_best'] ~= 17970) or (vars.mirror and save['stage' .. stage .. '_best_mirror'] ~= 17970) then
			assets.image_timer:draw(0, 40) -- Draw the timer graphic
			assets.kapel:drawText(text('besttime'), 34, 80) -- the "Best Time" label
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Fill white...
			assets.times_new_rally:drawTextAligned(mins .. ':' .. secs .. '.' .. mils, 75, 57, kTextAlignment.center) -- and the best time.
			gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Set this back to normal just to be safe
		end

		gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Fill white...
		if vars.mirror then
			assets.kapel:drawText(text('stage') .. stage .. text('mirrormode'), 5, 7) -- The stage number
		else
			assets.kapel:drawText(text('stage') .. stage, 5, 7) -- The stage number
		end
		assets.kapel_doubleup:drawText(text('stage_' .. stage .. '_name'), 5, 16) -- The stage's name
		gfx.setImageDrawMode(gfx.kDrawModeCopy) -- Set this back to normal just to be safe
		if show_desc then
			if vars.mirror then
				if save['stage' .. stage .. '_flawless_mirror'] then
					assets.image_medal_flawless:draw(181, 45)
				else
					assets.image_medal_unobtained:draw(181, 45)
				end
				if save['stage' .. stage .. '_speedy_mirror'] then
					assets.image_medal_speedy:draw(135, 45)
				else
					assets.image_medal_unobtained:draw(135, 45)
				end
			else
				if save['stage' .. stage .. '_flawless'] then
					assets.image_medal_flawless:draw(181, 45)
				else
					assets.image_medal_unobtained:draw(181, 45)
				end
				if save['stage' .. stage .. '_speedy'] then
					assets.image_medal_speedy:draw(135, 45)
				else
					assets.image_medal_unobtained:draw(135, 45)
				end
			end
			assets.pedallica:drawText(text('stage_' .. stage .. '_desc'), 10, 95)
		end
		if ranking ~= nil then
			assets.kapel:drawText(text('yourank'), 125, 52)
			assets.kapel_doubleup:drawTextAligned(commalize(ordinal(ranking)) .. "!", 205, 60, kTextAlignment.right)
			-- If the player has a default username, then let's throw a prompt up to tell them to change that. Woohoo, indoctrination!
			if string.len(name) == 16 and tonumber(name) then
				gfx.fillRect(0, 165, 480, 40)
				gfx.setColor(gfx.kColorWhite)
				gfx.fillRect(0, 167, 480, 36)
				gfx.setColor(gfx.kColorBlack)
				assets.pedallica:drawTextAligned(text('default_username_text'), 107, 170, kTextAlignment.center)
			end
		end
	gfx.popContext()
	-- And set the image, but only if the sprite exists.
	if sprites.top ~= nil then
		sprites.top:setImage(assets.image_top)
	end
end

-- Flip mirror mode
function stages:flipmirror()
	vars.mirror = not vars.mirror
	self:update_image_top(vars.selection, true)
	self:update_image_buttons()
	self:update_image_preview()
	if not pd.getReduceFlashing() then
		vars.anim_fade:resetnew(300, 1, 34)
	end
	assets.sfx_cymbal:play()
end

function stages:update()
	if not scenemanager.transitioning then
		local ticks = pd.getCrankTicks(4)
		if not vars.transitioning and not vars.leaderboards_open then
			if ticks < 0 then
				self:newselection(false, -ticks)
			elseif ticks > 0 then
				self:newselection(true, ticks)
			end
		end
	end
end