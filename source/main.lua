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
pd.ui.crankIndicator:start()
show_crank = false

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
    save.mu = 5
    save.fx = 5
    save.ui = true
    pd.datastore.write(save)
else
    save.t1 = checksave['t1']
    save.t2 = checksave['t2']
    save.t3 = checksave['t3']
    save.t4 = checksave['t4']
    save.t5 = checksave['t5']
    save.t6 = checksave['t6']
    save.t7 = checksave['t7']
    save.t1 = checksave['m1']
    save.t2 = checksave['m2']
    save.t3 = checksave['m3']
    save.t4 = checksave['m4']
    save.t5 = checksave['m5']
    save.t6 = checksave['m6']
    save.t7 = checksave['m7']
    save.as = checksave['as']
    save.ct = checksave['ct']
    save.mt = checksave['mt']
    save.cc = checksave['cc']
    save.mc = checksave['mc']
    save.mu = checksave['mu']
    save.fx = checksave['fx']
    save.ui = checksave['ui']
end

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

scenemanager:switchscene(race)

function pd.gameWillTerminate()
    playdate.datastore.write(save)
end

function pd.keyPressed()
    save.t1 = 17970
    save.t2 = 17970
    save.t3 = 17970
    save.t4 = 17970
    save.t5 = 17970
    save.t6 = 17970
    save.t7 = 17970
    save.as = false
    save.ct = 0
    save.mt = 0
    save.cc = 0
    save.mc = 0
    save.mu = 5
    save.fx = 5
    pd.datastore.write(save)
    print("Special cheat code!! Save data cleared.")
end

function pd.update()
    gfx.sprite.update()
    if pd.isCrankDocked() and show_crank then
        pd.ui.crankIndicator:update()
    end
    pd.timer.updateTimers()
    pd.drawFPS(0, 0)
end