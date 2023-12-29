local pd <const> = playdate
local gfx <const> = pd.graphics

class('lbtest').extends(gfx.sprite)
function lbtest:init(...)
    lbtest.super.init(self)
    local args = {...}
    show_crank = false
    gfx.sprite.setAlwaysRedraw(false)

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        gfx.image.new(400, 240, gfx.kColorWhite):draw(0, 0)
        gfx.drawText('Press B to get scoreboards (printed to console)', 10, 10)
        gfx.drawText('Press A to submit a test score', 10, 30)
    end)
    
    assets = {
        
    }

    vars = {

    }    
    self:add()
end

function getScoreboards()
    pd.scoreboards.getScoreboards(function (status, result)
        printTable(status)
        printTable(result)
    end)
end

function getScores(stage)
    pd.scoreboards.getScores(stage, function (status, result)
        printTable(status)
        printTable(result)
    end)
end

function lbtest:update()
    if pd.buttonJustPressed('b') then
        getScoreboards()
        getScores('stage1')
        getScores('stage2')
        getScores('stage3')
        getScores('stage4')
        getScores('stage5')
        getScores('stage6')
        getScores('stage7')
    end
    if pd.buttonJustPressed('a') then
        pd.scoreboards.addScore('stage1', 17969, getScores('stage1'))
    end
end