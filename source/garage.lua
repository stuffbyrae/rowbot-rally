local pd <const> = playdate
local gfx <const> = pd.graphics

class('garage').extends(gfx.sprite)
function garage:init(...)
    garage.super.init(self)
    local args = {...}
    show_crank = false

    assets = {
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

    vars = {
        menu_list = {'classic'},
        current_menu_item = 1,
    }
    if save.mt >= 2 then table.insert(vars.menu_list, 'pro') else table.insert(vars.menu_list, 'pro_locked') end
    if save.mt >= 3 then table.insert(vars.menu_list, 'surf') else table.insert(vars.menu_list, 'surf_locked') end
    if save.mt >= 4 then table.insert(vars.menu_list, 'raft') else table.insert(vars.menu_list, 'raft_locked') end
    if save.mt >= 5 then table.insert(vars.menu_list, 'swan') else table.insert(vars.menu_list, 'swan_locked') end
    if save.mt >= 6 then table.insert(vars.menu_list, 'gold') else table.insert(vars.menu_list, 'gold_locked') end
    if save.mt >= 7 then table.insert(vars.menu_list, 'hover') else table.insert(vars.menu_list, 'hover_locked') end
    vars.boat_anim = gfx.animation.loop.new(10, assets.img_classic, true)

    class('bg').extends(gfx.sprite)
    function bg:init()
        bg.super.init(self)
        self:setImage(assets.img_bg)
        self:setCenter(0, 0)
        self:setZIndex(-5)
        self:add()
    end

    class('boat').extends(gfx.sprite)
    function boat:init()
        boat.super.init(self)
        self:setCenter(0, 0)
        self:moveTo(42, 50)
        self:setZIndex(1)
        self:add()
    end
    function boat:update()
        self:setImage(vars.boat_anim:image())
    end

    class('ui').extends(gfx.sprite)
    function ui:init()
        ui.super.init(self)
        self:moveTo(200, 190)
        self:setZIndex(4)
        self:add()
    end
    function ui:update()
        local image = gfx.image.new(373, 74)
        gfx.pushContext(image)
            assets.img_button_ok:draw(10, 33)
            assets.img_button_back:draw(274, 51)
        gfx.popContext()
        self:setImage(image)
    end

    class('boat_ui').extends(gfx.sprite)
    function boat_ui:init()
        boat_ui.super.init(self)
        self:moveTo(200, 80)
        self:setImage(assets.img_boat_ui_1)
        self:setZIndex(5)
        self:add()
    end
    function boat_ui:update()
    end

    self.bg = bg()
    self.boat = boat()
    self.ui = ui()
    self.boat_ui = boat_ui()

    self:add()
end

function garage:changeboat(boatname) -- this the bit what not work
    local boat_image = 'assets.img_' .. tostring(boatname)
    vars.boat_anim:setImageTable()
    print(_G[boat_image])
end

function garage:update()
    if pd.buttonJustPressed('b') then
        scenemanager:transitionscene(title, false)
    end
    if pd.buttonJustPressed('left') then
        vars.current_menu_item = math.clamp(vars.current_menu_item - 1, 1, #vars.menu_list)
        vars.current_name = vars.menu_list[vars.current_menu_item]
        self:changeboat(vars.current_name)
    end
    if pd.buttonJustPressed('right') then
        vars.current_menu_item = math.clamp(vars.current_menu_item + 1, 1, #vars.menu_list)
        vars.current_name = vars.menu_list[vars.current_menu_item]
        self:changeboat(vars.current_name)
    end
    if pd.buttonJustPressed('a') then
        if vars.current_name == 'continue' then
            
        end
    end
end