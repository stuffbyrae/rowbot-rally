local pd <const> = playdate
local gfx <const> = pd.graphics

class('garage').extends(gfx.sprite)
function garage:init()
    garage.super.init(self)
    show_crank = false

    garage_assets = {
        img_bg = gfx.image.new('images/garage/bg'),
        img_button_ok = gfx.image.new('images/ui/button_ok'),
        img_button_back = gfx.image.new('images/garage/button_back'),
        img_boat_ui_1 = gfx.image.new('images/garage/boat_ui_1'),
        img_boat_ui_2 = gfx.image.new('images/garage/boat_ui_2'),
        img_boat_ui_3 = gfx.image.new('images/garage/boat_ui_3'),
        img_boat_ui_4 = gfx.image.new('images/garage/boat_ui_4'),
        img_boat_ui_5 = gfx.image.new('images/garage/boat_ui_5'),
        img_boat_ui_6 = gfx.image.new('images/garage/boat_ui_6'),
        img_boat_ui_7 = gfx.image.new('images/garage/boat_ui_7'),
        img_classic = gfx.imagetable.new('images/garage/classic/classic'),
        img_pro = gfx.imagetable.new('images/garage/pro/pro'),
        img_surf = gfx.imagetable.new('images/garage/surf/surf'),
        img_raft = gfx.imagetable.new('images/garage/raft/raft'),
        img_swan = gfx.imagetable.new('images/garage/swan/swan'),
        img_gold = gfx.imagetable.new('images/garage/gold/gold'),
        img_hover = gfx.imagetable.new('images/garage/hover/hover')
    }

    garage_vars = {
        menu_list = {'classic'},
        current_menu_item = 1,
        boat_anim = gfx.animation.loop.new(10, img_pro, true)
    }
    if save.mt == 2 then table.insert(garage_vars.menu_list, 'pro') else table.insert(garage_vars.menu_list, 'pro_locked') end
    if save.mt == 3 then table.insert(garage_vars.menu_list, 'surf') else table.insert(garage_vars.menu_list, 'surf_locked') end
    if save.mt == 4 then table.insert(garage_vars.menu_list, 'raft') else table.insert(garage_vars.menu_list, 'raft_locked') end
    if save.mt == 5 then table.insert(garage_vars.menu_list, 'swan') else table.insert(garage_vars.menu_list, 'swan_locked') end
    if save.mt == 6 then table.insert(garage_vars.menu_list, 'gold') else table.insert(garage_vars.menu_list, 'gold_locked') end
    if save.mt == 7 then table.insert(garage_vars.menu_list, 'hover') else table.insert(garage_vars.menu_list, 'hover_locked') end

    self:add()
end

function garage:update()
end