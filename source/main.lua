import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'CoreLibs/ui'
import 'CoreLibs/sprites'
import 'CoreLibs/math'
import 'CoreLibs/animation'
import 'pdParticles'

local pd <const> = playdate
local gfx <const> = pd.graphics

pd.display.setRefreshRate(30)
show_crank = false

import 'scenemanager'
import 'title'
scenemanager = scenemanager()

gfx.setBackgroundColor(gfx.kColorBlack)

function unlockeverything()
    save = {t1 = 17970, t2 = 17970, t3 = 17970, t4 = 17970, t5 = 17970, t6 = 17970, t7 = 17970, m1 = 17970, m2 = 17970, m3 = 17970, m4 = 17970, m5 = 17970, m6 = 17970, m7 = 17970, as = false, sc = 0, ct = 0, mt = 7, cc = 0, mc = 10, cs = true, ss = true, mu = 5, fx = 5, ts = true, ms = true, ui = true}
end

function unlocksomethings()
    save = {t1 = 17970, t2 = 17970, t3 = 17970, t4 = 17970, t5 = 17970, t6 = 17970, t7 = 17970, m1 = 17970, m2 = 17970, m3 = 17970, m4 = 17970, m5 = 17970, m6 = 17970, m7 = 17970, as = false, sc = 0, ct = 0, mt = 4, cc = 0, mc = 5, cs = false, ss = true, mu = 5, fx = 5, ts = true, ms = false, ui = true}
end

function clearALLthesaves()
    save = {t1 = 17970, t2 = 17970, t3 = 17970, t4 = 17970, t5 = 17970, t6 = 17970, t7 = 17970, m1 = 17970, m2 = 17970, m3 = 17970, m4 = 17970, m5 = 17970, m6 = 17970, m7 = 17970, as = false, sc = 0, ct = 0, mt = 0, cc = 0, mc = 0, cs = false, ss = false, mu = 5, fx = 5, ts = false, ms = false, ui = true}
end

save = pd.datastore.read()
if save == nil then
save = {
    t1 = 17970, -- Track 1 time
    t2 = 17970, -- Track 2 time
    t3 = 17970, -- Track 3 time
    t4 = 17970, -- Track 4 time
    t5 = 17970, -- Track 5 time
    t6 = 17970, -- Track 6 time
    t7 = 17970, -- Track 7 time
    t1 = 17970, -- Track 1 mirror time - this is for the post-launch update. if you're seeing this, shh!
    t2 = 17970, -- Track 2 mirror time - this is for the post-launch update. if you're seeing this, shh!
    t3 = 17970, -- Track 3 mirror time - this is for the post-launch update. if you're seeing this, shh!
    t4 = 17970, -- Track 4 mirror time - this is for the post-launch update. if you're seeing this, shh!
    t5 = 17970, -- Track 5 mirror time - this is for the post-launch update. if you're seeing this, shh!
    t6 = 17970, -- Track 6 mirror time - this is for the post-launch update. if you're seeing this, shh!
    t7 = 17970, -- Track 7 mirror time - this is for the post-launch update. if you're seeing this, shh!
    sc = 0, -- Shark Chase+ score - this is for the post-launch update. if you're seeing this, shh!
    as = false, -- Active story?
    ct = 0, -- Current story track
    mt = 0, -- Highest-seen story track
    cc = 0, -- Current story cutscene
    mc = 0, -- Highest-seen story cutscene
    cs = false, -- Credits seen?
    ss = false, -- Tutorial seen?
    mu = 5, -- Music
    fx = 5, -- SFX
    ts = false, -- Has the time trials notif been seen?
    ms = false, -- Has the mirror mode notif been seen? - this is for the post-launch update. if you're seeing this, shh!
    ui = true -- Show detailed race UI?
}
end

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

shakies_anim = nil

function shakiesx()
    if pd.getReduceFlashing() then
        return
    else
        shakies_anim_dir = true
        shakies_anim = gfx.animator.new(500, 10, 0, pd.easingFunctions.outElastic)
    end
end

function shakiesy()
    if pd.getReduceFlashing() then
        return
    else
        shakies_anim_dir = false
        shakies_anim = gfx.animator.new(500, 10, 0, pd.easingFunctions.outElastic)
    end
end

scenemanager:switchscene(race, 1, "story", 1, false)

function pd.gameWillTerminate()
    pd.datastore.write(save)
    local img = gfx.getDisplayImage()
    local byebye = gfx.image.new('images/ui/byebye')
    local fade = gfx.imagetable.new('images/ui/fade/fade')
    local imgslide = gfx.animator.new(350, 1, 400, pd.easingFunctions.outSine)
    local fadeout = gfx.animator.new(150, #fade, 1, pd.easingFunctions.outSine, 1000)
    gfx.setDrawOffset(0, 0)
    while not fadeout:ended() do
        byebye:draw(0, 0)
        img:draw(imgslide:currentValue(), 0)
        fade:drawImage(math.floor(fadeout:currentValue()), 0, 0)
        pd.display.flush()
    end
end

function pd.keyPressed(key)
    if key == "q" then
        unlockeverything()
        print('cheat code!! everything unlocked')
    elseif key == "w" then
        clearALLthesaves()
        print('cheat code!! everything cleared')
    end
end

function pd.update()
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