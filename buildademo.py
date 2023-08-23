import os
import shutil
import glob

os.chdir('../PlaydateSDK/Disk/Games')
if os.path.exists('RowBot Rally DEMO.pdx') is True:
    shutil.rmtree('RowBot Rally DEMO.pdx')
shutil.copytree('RowBot Rally.pdx', 'RowBot Rally DEMO.pdx')
os.chdir('RowBot Rally DEMO.pdx')

retain_dirs = [
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/music",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/story",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/fonts",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/intro",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options/gear_large",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options/gear_small",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/boats",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/results",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/story",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/title",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/fade",
]
retain_files = [
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/main.pdz",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/pdxinfo",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/en.pds",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/fonts/double_time.pft",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/fonts/kapel_doubleup.pft",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/fonts/kapel.pft",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/fonts/pedallica.pft",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/fonts/times_new_rally.pft",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/music/options.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/music/title.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/story/scene1_music.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/story/scene1_sfx.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/story/scene2_music.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/story/scene2_sfx.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/bonk.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/intro.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/locked.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/menu.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/ping.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/proceed.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/start.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/ui.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/audio/sfx/whoosh.pda",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/intro/a.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/intro/preview1.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/intro/prompt_icons.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/intro/prompt.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options/bg.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options/music_slider.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options/sfx_slider.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options/gear_large/gear_large.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/options/gear_small/gear_small.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/boats/boat1.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/track1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/trackc1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/trackt.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/trackct.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/water.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/water_1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/water_2.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/tracks/water_bg.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/meter_mask.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/meter.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/net.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/react_confused.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/react_crash.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/react_happy.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/react_idle.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/react_shocked.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/timer_1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/timer_2.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/timer_3.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/race/wake.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/results/plate.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/results/react_lose.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/results/react_win.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/story/border_intro.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/story/border_outro.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/story/border.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/story/opening.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/story/scene1.pdv",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/story/scene2.pdv",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/wrapping-pattern.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-pressed.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-demo.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/2.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/3.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/4.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/5.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/6.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/7.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/8.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/9.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/10.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/card-highlighted-demo/animation.txt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/2.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/3.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/4.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/5.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/6.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/7.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/8.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/9.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/10.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/11.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/12.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/13.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/14.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/15.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/16.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/17.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/18.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/19.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/icon-highlighted/animation.txt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/2.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/3.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/4.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/5.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/6.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/7.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/8.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/9.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/10.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/11.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/12.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/13.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/14.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/15.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/16.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/17.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/18.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/19.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/20.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/21.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/22.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/23.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/24.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/25.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/26.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/27.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/28.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/29.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/30.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/31.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/system/launchImages/32.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/title/bg_demo.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/title/checker.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/title/sel_new_demo.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/title/sel_options.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/title/wave.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/fade/fade.pdt",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/arrow.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/button_start.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/byebye.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/demo_warn.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/fullgame_warn.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/tutui.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/tutuia.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/loading_oneway.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/loading.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/logo_demo.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused1.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused2.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused3.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused4.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused5.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused6.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused7.pdi",
    "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/images/ui/paused8.pdi",
]

with open(os.getcwd() + '/pdxinfo', 'r') as f:
    fd = f.read()
fd = fd.replace('RowBot Rally', 'RowBot Rally DEMO')
fd = fd.replace('wtf.rae.rowbotrally', 'wtf.rae.rowbotrallydemo')
with open(os.getcwd() + '/pdxinfo', 'w') as f:
    f.write(fd)

for filename in glob.iglob(os.getcwd() + '/**', recursive=True):
    if filename != "/Users/rae/Developer/PlaydateSDK/Disk/Games/RowBot Rally DEMO.pdx/":
        if os.path.isdir(filename):
            if filename not in retain_dirs:
                shutil.rmtree(filename)
        elif filename not in retain_files:
            os.remove(filename)

os.rename(os.getcwd() + '/images/system/card-demo.pdi', os.getcwd() + '/images/system/card.pdi')
os.rename(os.getcwd() + '/images/system/card-highlighted-demo', os.getcwd() + '/images/system/card-highlighted')