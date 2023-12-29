import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'CoreLibs/ui'
import 'CoreLibs/sprites'
import 'CoreLibs/math'
import 'CoreLibs/animation'
import 'CoreLibs/object'
import 'stagecpucoords'
import 'pdParticles'
import 'Tanuk_CodeSequence'

local pd <const> = playdate
local gfx <const> = pd.graphics

pd.display.setRefreshRate(30)
show_crank = false -- do you show the crankindicator in this scene?
catalog = true -- leaderboard compatibility
first_pause = true -- so that when you pause the first time, it always reads "Paused!" first.
saving = false -- todo: change this
if string.find(pd.metadata.bundleID, "demo") then demo = true else demo = false end -- DEMO check.

import 'scenemanager'
import 'title'
scenemanager = scenemanager()

gfx.setBackgroundColor(gfx.kColorBlack)

-- Save check
function savecheck()
    save = pd.datastore.read()
    if save == nil then save = {} end

    if save.stage1_best == nil then save.stage1_best = 17970 end
    if save.stage2_best == nil then save.stage2_best = 17970 end
    if save.stage3_best == nil then save.stage3_best = 17970 end
    if save.stage4_best == nil then save.stage4_best = 17970 end
    if save.stage5_best == nil then save.stage5_best = 17970 end
    if save.stage6_best == nil then save.stage6_best = 17970 end
    if save.stage7_best == nil then save.stage7_best = 17970 end
    if save.slot1_active == nil then save.slot1_active = false end
    if save.slot1_current_stage == nil then save.slot1_current_stage = 0 end
    if save.slot1_current_cutscene == nil then save.slot1_current_cutscene = 0 end
    if save.slot1_crashes == nil then save.slot1_crashes = 0 end
    if save.slot1_time_racing == nil then save.slot1_time_racing = 0 end
    if save.slot2_active == nil then save.slot2_active = false end
    if save.slot2_current_stage == nil then save.slot2_current_stage = 0 end
    if save.slot2_current_cutscene == nil then save.slot2_current_cutscene = 0 end
    if save.slot2_crashes == nil then save.slot2_crashes = 0 end
    if save.slot2_time_racing == nil then save.slot2_time_racing = 0 end
    if save.slot3_active == nil then save.slot3_active = false end
    if save.slot3_current_stage == nil then save.slot3_current_stage = 0 end
    if save.slot3_current_cutscene == nil then save.slot3_current_cutscene = 0 end
    if save.slot3_crashes == nil then save.slot3_crashes = 0 end
    if save.slot3_time_racing == nil then save.slot3_time_racing = 0 end
    if save.unlocked_stages == nil then save.unlocked_stages = 0 end
    if save.unlocked_cutscenes == nil then save.unlocked_cutscenes = 0 end
    if save.credits_unlocked == nil then save.credits_unlocked = false end
    if save.tutorial_unlocked == nil then save.tutorial_unlocked = false end
    if save.vol_music == nil then save.vol_music = 5 end
    if save.vol_sfx == nil then save.vol_sfx = 5 end
    if save.time_trials_unlocked == nil then save.time_trials_unlocked = false end
    if save.pro_ui == nil then save.pro_ui = false end
    if save.power_flip == nil then save.power_flip = false end
    if save.dpad == nil then save.dpad = false end
    if save.sensitivity == nil then save.sensitivity = 3 end
    if save.autoskip == nil then save.autoskip = false end
    if save.first_launch == nil then save.first_launch = true end
    if save.stories_completed == nil then save.stories_completed = 0 end
    if save.total_crashes == nil then save.total_crashes = 0 end
    if save.time_racing == nil then save.time_racing = 0 end
end

-- ... now we run that!
savecheck()

-- math clamp function
function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

function savegame()
    if not demo then
        pd.datastore.write(save)
        saving = true
        savingtable = gfx.imagetable.new('images/ui/saving')
        savinginc = 1
        savingsprite = gfx.sprite.new(savingtable[1])
        savingsprite:moveTo(0, 5)
        savingsprite:setZIndex(32767)
        savingsprite:setCenter(0, 0)
        savingsprite:setIgnoresDrawOffset(true)
        savingsprite:add()
    end
end

-- global screen-shaky functions
shakies_anim = nil
function shakiesx()
    if not pd.getReduceFlashing() then
        shakies_anim_dir = true
        shakies_anim = gfx.animator.new(500, 10, 0, pd.easingFunctions.outElastic)
    end
end
function shakiesy()
    if not pd.getReduceFlashing() then
        shakies_anim_dir = false
        shakies_anim = gfx.animator.new(500, 10, 0, pd.easingFunctions.outElastic)
    end
end

if save.first_launch then
    scenemanager:switchscene(opening, 0, "title")
else
    scenemanager:switchscene(title, false)
end

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
    if saving then
        savinginc += 0.6
        savingsprite:setImage(savingtable[math.floor(savinginc)])
        savingsprite:add()
        if savinginc >= 29 then
            saving = false
            savingsprite:remove()
            savinginc = nil
            savingimage = nil
        end
    end
    gfx.sprite.update()
    pd.timer.updateTimers()
    if pd.isCrankDocked() and show_crank then
        pd.ui.crankIndicator:update()
    end
    if shakies_anim ~= nil then
        if shakies_anim_dir then
            pd.display.setOffset(shakies_anim:currentValue(), 0)
        else
            pd.display.setOffset(0, shakies_anim:currentValue())
        end
    end
end