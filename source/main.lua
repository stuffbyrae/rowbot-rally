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
import 'cutscene'
import 'title'
import 'race'
scenemanager = scenemanager()

save = {}
checksave = pd.datastore.read()
if checksave == nil then
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
else
    save.t1 = checksave['t1'] -- Track 1 time
    save.t2 = checksave['t2'] -- Track 2 time
    save.t3 = checksave['t3'] -- Track 3 time
    save.t4 = checksave['t4'] -- Track 4 time
    save.t5 = checksave['t5'] -- Track 5 time
    save.t6 = checksave['t6'] -- Track 6 time
    save.t7 = checksave['t7'] -- Track 7 time
    save.t1 = checksave['m1'] -- Track 1 mirror time
    save.t2 = checksave['m2'] -- Track 2 mirror time
    save.t3 = checksave['m3'] -- Track 3 mirror time
    save.t4 = checksave['m4'] -- Track 4 mirror time
    save.t5 = checksave['m5'] -- Track 5 mirror time
    save.t6 = checksave['m6'] -- Track 6 mirror time
    save.t7 = checksave['m7'] -- Track 7 mirror time
    save.as = checksave['as'] -- Active story?
    save.ct = checksave['ct'] -- Current track
    save.mt = checksave['mt'] -- Max track
    save.cc = checksave['cc'] -- Current cutscene
    save.mc = checksave['mc'] -- Max cutscene
    save.cs = checksave['cs'] -- Credits seen?
    save.mu = checksave['mu'] -- Music
    save.fx = checksave['fx'] -- SFX
    save.ts = checksave['ts'] -- Has the time trials notif been seen?
    save.ms = checksave['ms'] -- Has the mirror mode notif been seen?
    save.ui = checksave['ui'] -- Show detailed race UI?
end

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

scenemanager:switchscene(title)

function pd.gameWillTerminate()
    playdate.datastore.write(save)
end

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    if pd.isCrankDocked() and show_crank then
        pd.ui.crankIndicator:update()
    end
    pd.drawFPS(0, 0)
end