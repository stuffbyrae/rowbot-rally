-- Importing things
import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'CoreLibs/ui'
import 'CoreLibs/sprites'
import 'CoreLibs/math'
import 'CoreLibs/animation'
import 'CoreLibs/object'
import 'title' -- Title screen, so we can transition to it on start-up
import 'stats'
import 'scenemanager'
scenemanager = scenemanager()

-- Setting up basic SDK params
local pd <const> = playdate
local gfx <const> = pd.graphics

pd.display.setRefreshRate(30)
gfx.setBackgroundColor(gfx.kColorBlack)

show_crank = false -- do you show the crankindicator in this scene?
first_pause = true -- so that when you pause the first time, it always reads "Paused!" first.
if string.find(pd.metadata.bundleID, "demo") then demo = true else demo = false end -- DEMO check.

-- Save check
function savecheck()
    save = pd.datastore.read()
    if save == nil then save = {} end
    -- Local best time-trial records for all courses
    save.stage1_best = save.stage1_best or 17970
    save.stage2_best = save.stage2_best or 17970
    save.stage3_best = save.stage3_best or 17970
    save.stage4_best = save.stage4_best or 17970
    save.stage5_best = save.stage5_best or 17970
    save.stage6_best = save.stage6_best or 17970
    save.stage7_best = save.stage7_best or 17970
    -- How many times each stage has been played
    save.stage1_plays = save.stage1_plays or 0
    save.stage2_plays = save.stage2_plays or 0
    save.stage3_plays = save.stage3_plays or 0
    save.stage4_plays = save.stage4_plays or 0
    save.stage5_plays = save.stage5_plays or 0
    save.stage6_plays = save.stage6_plays or 0
    save.stage7_plays = save.stage7_plays or 0
    -- Story slot 1
    save.slot1_active = save.slot1_active or false
    save.slot1_stage = save.slot1_stage or 0
    save.slot1_cutscene = save.slot1_cutscene or 0
    save.slot1_crashes = save.slot1_crashes or 0
    save.slot1_racetime = save.slot1_racetime or 0
    -- Story slot 2
    save.slot2_active = save.slot2_active or false
    save.slot2_stage = save.slot2_stage or 0
    save.slot2_cutscene = save.slot2_cutscene or 0
    save.slot2_crashes = save.slot2_crashes or 0
    save.slot2_racetime = save.slot2_racetime or 0
    -- Story slot 3
    save.slot3_active = save.slot3_active or false
    save.slot3_stage = save.slot3_stage or 0
    save.slot3_cutscene = save.slot3_cutscene or 0
    save.slot3_crashes = save.slot3_crashes or 0
    save.slot3_racetime = save.slot3_racetime or 0
    -- Global unlocks
    save.stages_unlocked = save.stages_unlocked or 0
    save.cutscenes_unlocked = save.cutscenes_unlocked or 0
    save.credits_unlocked = save.credits_unlocked or false
    save.tutorial_unlocked = save.tutorial_unlocked or false
    save.time_trials_unlocked = save.time_trials_unlocked or false
    -- Preferences, adjustable in Options menu
    save.vol_music = save.vol_music or 5
    save.vol_sfx = save.vol_sfx or 0
    save.pro_ui = save.pro_ui or false
    save.power_flip = save.power_flip or false
    save.dpad_controls = save.dpad_controls or false
    save.sensitivty = save.sensitivity or 3
    save.autoskip = save.autoskip or false
    -- Global stats
    save.first_launch = save.first_launch or true
    save.stories_completed = save.stories_completed or 0
    save.total_crashes = save.total_crashes or 0
    save.total_racetime = save.total_racetime or 0
    save.total_races_completed = save.races_completed or 0
    save.total_playtime = save.total_playtime or 0
    save.total_degrees_cranked = save.total_degrees_cranked or 0
    save.metric = save.metric or true
end

-- ... now we run that!
savecheck()

-- Math clamp function
function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

scenemanager:switchscene(stats)

function pd.gameWillTerminate()
    if not demo then
        pd.datastore.write(save)
    end
    -- local img = gfx.getDisplayImage()
    -- local byebye = gfx.image.new('images/ui/byebye')
    -- local fade = gfx.imagetable.new('images/ui/fade/fade')
    -- local imgslide = gfx.animator.new(350, 1, 400, pd.easingFunctions.outSine)
    -- local fadeout = gfx.animator.new(150, #fade, 1, pd.easingFunctions.outSine, 1000)
    -- gfx.setDrawOffset(0, 0)
    -- while not fadeout:ended() do
    --     byebye:draw(0, 0)
    --     img:draw(imgslide:currentValue(), 0)
    --     fade:drawImage(math.floor(fadeout:currentValue()), 0, 0)
    --     pd.display.flush()
    -- end
end

function pd.update()
    save.total_playtime += 1
    gfx.sprite.update()
    pd.timer.updateTimers()
    if pd.isCrankDocked() and show_crank then
        pd.ui.crankIndicator:update()
    end
end