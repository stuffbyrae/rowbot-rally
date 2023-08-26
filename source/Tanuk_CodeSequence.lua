-----------------------------------------------
--- Code Sequence for cheat codes    v1.0.2 ---
--- taken from Toad on discord              ---
--- https://discord.com/channels/675983554655551509/1078126062753550476/1135205048431951912  ---
--- and modified by                         ---
---            (c) Tanuk Prod               ---
---     https://github.com/Schyzophrenic    ---
-----------------------------------------------

-- Usage example
-- self.sprCode = Tanuk_CodeSequence({"down", "left", "down", "left", "right", "a"}, function() print("Code Complete") end)

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Tanuk_CodeSequence').extends(gfx.sprite)

--- Creates a Cheat code sequence
-- @param sequence sequence of input, in order, takes the standard Playdate input up, down, left, right, a, b
-- @param callbackReward function to call when the code is successful
-- @param isAllowMultipleCalls set to false by default. If set to yes, the code may be triggered multiple times. If set to false, it will only be registered once
function Tanuk_CodeSequence:init(sequence, callbackReward, isAllowMultipleCalls)
    assert(sequence, "An input sequence must be provided")
    assert(callbackReward, "A callback function is mandatory for the sequence recognition to have any effect")
    self.sequence = sequence
    self.reward = callbackReward
    self.isAllowMultipleCalls = isAllowMultipleCalls or false
    self.sequenceIndex = 1
    self.timerInput = pd.timer.new(500, function() self.sequenceIndex = 1 end)
    self.timerInput.repeats = true
    self:add()
end

function Tanuk_CodeSequence:update()
    if pd.buttonJustPressed(self.sequence[self.sequenceIndex]) then
        self.sequenceIndex = self.sequenceIndex + 1
        self.timerInput:reset()

        if self.sequenceIndex > #self.sequence then
            self:reward()
            if not self.isAllowMultipleCalls then
                self.timerInput:remove()
                self:remove()
                self = nil
            end
        end
    end
end
