import os
import shutil
import glob

demo = False

os.chdir('../')
if os.path.exists('source') is True:
    shutil.rmtree('source')
shutil.copytree('RowBot Rally/source', 'source')
os.chdir('source')

retain = [
    "/Users/rae/Developer/source/audio/music/intro.wav",
    "/Users/rae/Developer/source/audio/music/opening.wav",
    "/Users/rae/Developer/source/audio/music/stage1.wav",
    "/Users/rae/Developer/source/audio/music/title.wav",
    "/Users/rae/Developer/source/audio/sfx/bonk.wav",
    "/Users/rae/Developer/source/audio/sfx/clickoff.wav",
    "/Users/rae/Developer/source/audio/sfx/clickon.wav",
    "/Users/rae/Developer/source/audio/sfx/countdown.wav",
    "/Users/rae/Developer/source/audio/sfx/crash.wav",
    "/Users/rae/Developer/source/audio/sfx/final.wav",
    "/Users/rae/Developer/source/audio/sfx/finish.wav",
    "/Users/rae/Developer/source/audio/sfx/launch.wav",
    "/Users/rae/Developer/source/audio/sfx/locked.wav",
    "/Users/rae/Developer/source/audio/sfx/lose.wav",
    "/Users/rae/Developer/source/audio/sfx/menu.wav",
    "/Users/rae/Developer/source/audio/sfx/ping.wav",
    "/Users/rae/Developer/source/audio/sfx/proceed.wav",
    "/Users/rae/Developer/source/audio/sfx/ref.wav",
    "/Users/rae/Developer/source/audio/sfx/row.wav",
    "/Users/rae/Developer/source/audio/sfx/rowboton.wav",
    "/Users/rae/Developer/source/audio/sfx/sea.wav",
    "/Users/rae/Developer/source/audio/sfx/start.wav",
    "/Users/rae/Developer/source/audio/sfx/ui.wav",
    "/Users/rae/Developer/source/audio/sfx/whoosh.wav",
    "/Users/rae/Developer/source/audio/sfx/win.wav",
    "/Users/rae/Developer/source/audio/story/scene1_music.wav",
    "/Users/rae/Developer/source/audio/story/scene2_music.wav",
    "/Users/rae/Developer/source/audio/story/scene1_sfx.wav",
    "/Users/rae/Developer/source/audio/story/scene2_sfx.wav",
    "/Users/rae/Developer/source/fonts/double_time.fnt",
    "/Users/rae/Developer/source/fonts/kapel_doubleup_outline.fnt",
    "/Users/rae/Developer/source/fonts/kapel_doubleup.fnt",
    "/Users/rae/Developer/source/fonts/kapel.fnt",
    "/Users/rae/Developer/source/fonts/pedallica.fnt",
    "/Users/rae/Developer/source/fonts/times_new_rally.fnt",
    "/Users/rae/Developer/source/stages/1/bush.gif",
    "/Users/rae/Developer/source/stages/1/bushtop.gif",
    "/Users/rae/Developer/source/stages/1/caustics.gif",
    "/Users/rae/Developer/source/stages/1/stage-table-1000-1000.png",
    "/Users/rae/Developer/source/stages/1/stage.lua",
    "/Users/rae/Developer/source/stages/1/stagec.png",
    "/Users/rae/Developer/source/stages/1/tree.gif",
    "/Users/rae/Developer/source/stages/1/treetop.gif",
    "/Users/rae/Developer/source/stages/1/trunk.gif",
    "/Users/rae/Developer/source/stages/1/water_bg.png",
    "/Users/rae/Developer/source/stages/1/water.gif",
    "/Users/rae/Developer/source/stages/tutorial/bush.gif",
    "/Users/rae/Developer/source/stages/tutorial/bushtop.gif",
    "/Users/rae/Developer/source/stages/tutorial/caustics.gif",
    "/Users/rae/Developer/source/stages/tutorial/stage-table-704-1881.png",
    "/Users/rae/Developer/source/stages/tutorial/stagec.png",
    "/Users/rae/Developer/source/stages/tutorial/tree.gif",
    "/Users/rae/Developer/source/stages/tutorial/treetop.gif",
    "/Users/rae/Developer/source/stages/tutorial/trunk.gif",
    "/Users/rae/Developer/source/stages/tutorial/umbrella.png",
    "/Users/rae/Developer/source/stages/tutorial/water_bg.png",
    "/Users/rae/Developer/source/stages/tutorial/water.gif",
    "/Users/rae/Developer/source/images/race/crash.png",
    "/Users/rae/Developer/source/images/race/countdown.gif",
    "/Users/rae/Developer/source/images/race/net.png",
    "/Users/rae/Developer/source/images/race/pole_cap.png",
    "/Users/rae/Developer/source/images/race/results_lose.png",
    "/Users/rae/Developer/source/images/race/results_win.png",
    "/Users/rae/Developer/source/images/race/timer_1.png",
    "/Users/rae/Developer/source/images/race/timer_2.png",
    "/Users/rae/Developer/source/images/race/timer_3.png",
    "/Users/rae/Developer/source/images/race/audience/audience_basic.png",
    "/Users/rae/Developer/source/images/race/audience/audience_fisher.png",
    "/Users/rae/Developer/source/images/race/audience/audience_nebula-table-42-42.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-1.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-2.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-3.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-4.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-5.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-6.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-7.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-8.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-9.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-10.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-11.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-12.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-13.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-14.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-15.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-16.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-17.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-18.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-19.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-20.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-21.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-22.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-23.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-24.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-25.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-26.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-27.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-28.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-29.png",
    "/Users/rae/Developer/source/images/race/meter/meter_p-table-30.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-1.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-2.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-3.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-4.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-5.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-6.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-7.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-8.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-9.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-10.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-11.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-12.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-13.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-14.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-15.png",
    "/Users/rae/Developer/source/images/race/meter/meter_r-table-16.png",
    "/Users/rae/Developer/source/images/stages/gimmick_container.png",
    "/Users/rae/Developer/source/images/stages/gimmick_icons-table-65-48.png",
    "/Users/rae/Developer/source/images/stages/preview1.png",
    "/Users/rae/Developer/source/images/story/scene1.pdv",
    "/Users/rae/Developer/source/images/story/scene2.pdv",
    "/Users/rae/Developer/source/images/story/opening-table-1.png",
    "/Users/rae/Developer/source/images/story/opening-table-2.png",
    "/Users/rae/Developer/source/images/story/opening-table-3.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-1.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-2.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-3.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-4.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-5.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-6.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-7.png",
    "/Users/rae/Developer/source/images/story/border_intro-table-8.png",
    "/Users/rae/Developer/source/images/story/border-table-1.png",
    "/Users/rae/Developer/source/images/story/border-table-2.png",
    "/Users/rae/Developer/source/images/story/border-table-3.png",
    "/Users/rae/Developer/source/images/story/border-table-4.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-1.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-2.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-3.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-4.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-5.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-6.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-7.png",
    "/Users/rae/Developer/source/images/story/border_outro-table-8.png",
    "/Users/rae/Developer/source/images/system/card.png",
    "/Users/rae/Developer/source/images/system/card-pressed.png",
    "/Users/rae/Developer/source/images/system/icon.png",
    "/Users/rae/Developer/source/images/system/icon-pressed.png",
    "/Users/rae/Developer/source/images/system/launchImage.png",
    "/Users/rae/Developer/source/images/system/wrapping-pattern.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/1.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/2.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/3.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/4.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/5.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/6.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/7.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/8.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/9.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/10.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/11.png",
    "/Users/rae/Developer/source/images/system/card-highlighted/animation.txt",
    "/Users/rae/Developer/source/images/system/icon-highlighted/1.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/2.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/3.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/4.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/5.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/6.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/7.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/8.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/9.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/10.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/11.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/12.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/13.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/14.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/15.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/16.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/17.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/18.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/19.png",
    "/Users/rae/Developer/source/images/system/icon-highlighted/animation.txt",
    "/Users/rae/Developer/source/images/system/launchImages/1.png",
    "/Users/rae/Developer/source/images/system/launchImages/2.png",
    "/Users/rae/Developer/source/images/system/launchImages/3.png",
    "/Users/rae/Developer/source/images/system/launchImages/4.png",
    "/Users/rae/Developer/source/images/system/launchImages/5.png",
    "/Users/rae/Developer/source/images/system/launchImages/6.png",
    "/Users/rae/Developer/source/images/system/launchImages/7.png",
    "/Users/rae/Developer/source/images/system/launchImages/8.png",
    "/Users/rae/Developer/source/images/system/launchImages/9.png",
    "/Users/rae/Developer/source/images/system/launchImages/10.png",
    "/Users/rae/Developer/source/images/system/launchImages/11.png",
    "/Users/rae/Developer/source/images/system/launchImages/12.png",
    "/Users/rae/Developer/source/images/system/launchImages/13.png",
    "/Users/rae/Developer/source/images/system/launchImages/14.png",
    "/Users/rae/Developer/source/images/system/launchImages/15.png",
    "/Users/rae/Developer/source/images/system/launchImages/16.png",
    "/Users/rae/Developer/source/images/system/launchImages/17.png",
    "/Users/rae/Developer/source/images/system/launchImages/18.png",
    "/Users/rae/Developer/source/images/system/launchImages/19.png",
    "/Users/rae/Developer/source/images/system/launchImages/20.png",
    "/Users/rae/Developer/source/images/system/launchImages/21.png",
    "/Users/rae/Developer/source/images/system/launchImages/22.png",
    "/Users/rae/Developer/source/images/system/launchImages/23.png",
    "/Users/rae/Developer/source/images/system/launchImages/24.png",
    "/Users/rae/Developer/source/images/system/launchImages/25.png",
    "/Users/rae/Developer/source/images/system/launchImages/26.png",
    "/Users/rae/Developer/source/images/system/launchImages/27.png",
    "/Users/rae/Developer/source/images/system/launchImages/28.png",
    "/Users/rae/Developer/source/images/ui/a.png",
    "/Users/rae/Developer/source/images/ui/button_big.png",
    "/Users/rae/Developer/source/images/ui/button_small.png",
    "/Users/rae/Developer/source/images/ui/button_small2.png",
    "/Users/rae/Developer/source/images/ui/byebye.png",
    "/Users/rae/Developer/source/images/ui/loading_oneway.png",
    "/Users/rae/Developer/source/images/ui/loading.png",
    "/Users/rae/Developer/source/images/ui/popup_banner.png",
    "/Users/rae/Developer/source/images/ui/popup_small.png",
    "/Users/rae/Developer/source/images/ui/popup.png",
    "/Users/rae/Developer/source/images/ui/title_bg.png",
    "/Users/rae/Developer/source/images/ui/title_checker.png",
    "/Users/rae/Developer/source/images/ui/tutorial_up.png",
    "/Users/rae/Developer/source/images/ui/wave.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-1.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-2.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-3.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-4.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-5.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-6.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-7.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-8.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-9.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-10.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-11.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-12.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-13.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-14.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-15.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-16.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-17.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-18.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-19.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-20.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-21.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-22.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-23.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-24.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-25.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-26.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-27.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-28.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-29.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-30.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-31.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-32.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-33.png",
    "/Users/rae/Developer/source/images/ui/fade/fade-table-34.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-1.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-2.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-3.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-4.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-5.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-6.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-7.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-8.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-9.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-10.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-11.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-12.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-13.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-14.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-15.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-16.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-17.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-18.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-19.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-20.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-21.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-22.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-23.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-24.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-25.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-26.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-27.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-28.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-29.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-30.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-31.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-32.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-33.png",
    "/Users/rae/Developer/source/images/ui/fade_white/fade-table-34.png",
    "/Users/rae/Developer/source/boat.lua",
    "/Users/rae/Developer/source/en.strings",
    "/Users/rae/Developer/source/intro.lua",
    "/Users/rae/Developer/source/main.lua",
    "/Users/rae/Developer/source/notif.lua",
    "/Users/rae/Developer/source/opening.lua",
    "/Users/rae/Developer/source/options.lua",
    "/Users/rae/Developer/source/pdParticles.lua",
    "/Users/rae/Developer/source/pdxinfo",
    "/Users/rae/Developer/source/race.lua",
    "/Users/rae/Developer/source/results.lua",
    "/Users/rae/Developer/source/scenemanager.lua",
    "/Users/rae/Developer/source/title.lua",
    "/Users/rae/Developer/source/tutorial.lua",
    "/Users/rae/Developer/source/cutscene.lua",
    # i fucking hate this shit
    "/Users/rae/Developer/source/chase.lua",
    "/Users/rae/Developer/source/credits.lua",
    "/Users/rae/Developer/source/cheats.lua",
    "/Users/rae/Developer/source/chill.lua",
    "/Users/rae/Developer/source/stages.lua",
    "/Users/rae/Developer/source/stats.lua",
    "/Users/rae/Developer/source/Tanuk_CodeSequence.lua",
]

with open(os.getcwd() + '/pdxinfo', 'r') as f:
    fd = f.read()
    fd = fd.replace('RowBot Rally', 'RowBot Rally DEMO')
    fd = fd.replace('wtf.rae.rowbotrally', 'wtf.rae.rowbotrallydemo')
with open(os.getcwd() + '/pdxinfo', 'w') as f:
    f.write(fd)

for filename in glob.iglob(os.getcwd() + '/**', recursive=True):
    if filename != "/Users/rae/Developer/source/" and not os.path.isdir(filename):
        if filename not in retain:
            print('attempting to delete  ' + filename)
            os.remove(filename)

os.chdir('../')
os.system('pdc source PlaydateSDK/Disk/Games/DEMO.pdx')