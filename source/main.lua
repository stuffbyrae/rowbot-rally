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
launch = true

import 'scenemanager'
import 'title'
scenemanager = scenemanager()

gfx.setBackgroundColor(gfx.kColorBlack)

save = {
    t1 = 17970,
    t2 = 17970,
    t3 = 17970,
    t4 = 17970,
    t5 = 17970,
    t6 = 17970,
    t7 = 17970,
    m1 = 17970,
    m2 = 17970,
    m3 = 17970,
    m4 = 17970,
    m5 = 17970,
    m6 = 17970,
    m7 = 17970,
    as = false,
    sc = 0,
    ct = 0,
    mt = 0,
    cc = 0,
    mc = 0,
    cs = false,
    ss = false,
    mu = 5,
    fx = 5,
    ts = false,
    ms = false,
    ui = true,
}

function clearALLthesaves()
    pd.datastore.write(save)
end

checksave = pd.datastore.read()
if checksave == nil then
    clearALLthesaves()
else
    save.t1 = checksave['t1'] -- Track 1 time
    save.t2 = checksave['t2'] -- Track 2 time
    save.t3 = checksave['t3'] -- Track 3 time
    save.t4 = checksave['t4'] -- Track 4 time
    save.t5 = checksave['t5'] -- Track 5 time
    save.t6 = checksave['t6'] -- Track 6 time
    save.t7 = checksave['t7'] -- Track 7 time
    save.t1 = checksave['m1'] -- Track 1 mirror time - this is for the post-launch update. if you're seeing this, shh!
    save.t2 = checksave['m2'] -- Track 2 mirror time - this is for the post-launch update. if you're seeing this, shh!
    save.t3 = checksave['m3'] -- Track 3 mirror time - this is for the post-launch update. if you're seeing this, shh!
    save.t4 = checksave['m4'] -- Track 4 mirror time - this is for the post-launch update. if you're seeing this, shh!
    save.t5 = checksave['m5'] -- Track 5 mirror time - this is for the post-launch update. if you're seeing this, shh!
    save.t6 = checksave['m6'] -- Track 6 mirror time - this is for the post-launch update. if you're seeing this, shh!
    save.t7 = checksave['m7'] -- Track 7 mirror time - this is for the post-launch update. if you're seeing this, shh!
    save.sc = checksave['sc'] -- Shark Chase+ score - this is for the post-launch update. if you're seeing this, shh!
    save.as = checksave['as'] -- Active story?
    save.ct = checksave['ct'] -- Current story track
    save.mt = checksave['mt'] -- Highest-seen story track
    save.cc = checksave['cc'] -- Current story cutscene
    save.mc = checksave['mc'] -- Highest-seen story cutscene
    save.cs = checksave['cs'] -- Credits seen?
    save.ss = checksave['ss'] -- Tutorial seen?
    save.mu = checksave['mu'] -- Music
    save.fx = checksave['fx'] -- SFX
    save.ts = checksave['ts'] -- Has the time trials notif been seen?
    save.ms = checksave['ms'] -- Has the mirror mode notif been seen? - this is for the post-launch update. if you're seeing this, shh!
    save.ui = checksave['ui'] -- Show detailed race UI?
end

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

shakies_anim = nil

function shakiesx()
    if playdate.getReduceFlashing() then
        return
    else
        shakies_anim_dir = true
        shakies_anim = gfx.animator.new(500, 10, 0, pd.easingFunctions.outElastic)
    end
end

function shakiesy()
    if playdate.getReduceFlashing() then
        return
    else
        shakies_anim_dir = false
        shakies_anim = gfx.animator.new(500, 10, 0, pd.easingFunctions.outElastic)
    end
end

scenemanager:switchscene(garage)

function pd.gameWillTerminate()
    pd.datastore.write(save)
--     local img = gfx.getDisplayImage()
--     local byebye = gfx.image.new('images/ui/byebye')
--     local fade = gfx.imagetable.new('images/ui/fade/fade')
--     local imgslide = gfx.animator.new(350, 1, 400, pd.easingFunctions.outSine)
--     local fadeout = gfx.animator.new(150, #fade, 1, pd.easingFunctions.outSine, 1500)
--     gfx.setDrawOffset(0, 0)
--     while not fadeout:ended() do
--         byebye:draw(0, 0)
--         img:draw(imgslide:currentValue(), 0)
--         fade:drawImage(math.floor(fadeout:currentValue()), 0, 0)
--         pd.display.flush()
--     end
end

function pd.keyPressed()
    save = {
        t1 = 17970,
        t2 = 17970,
        t3 = 17970,
        t4 = 17970,
        t5 = 17970,
        t6 = 17970,
        t7 = 17970,
        m1 = 17970,
        m2 = 17970,
        m3 = 17970,
        m4 = 17970,
        m5 = 17970,
        m6 = 17970,
        m7 = 17970,
        as = false,
        sc = 0,
        ct = 7,
        mt = 7,
        cc = 10,
        mc = 10,
        cs = true,
        ss = true,
        mu = 5,
        fx = 5,
        ts = true,
        ms = true,
        ui = true
    }
    pd.datastore.write(save)
    print('cheat code!! everything unlocked')
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