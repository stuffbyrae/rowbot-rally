-----------------------------------------------
--- Code Sequence for cheat codes    v2.1.0 ---
--- taken from Toad on discord              ---
--- https://discord.com/channels/675983554655551509/1078126062753550476/1135205048431951912  ---
--- and modified by                         ---
---            (c) Tanuk Prod               ---
---     https://github.com/Schyzophrenic    ---
-----------------------------------------------

-- Usage example
-- self.sprCode = Tanuk_CodeSequence({pd.kButtonDown, pd.kButtonLeft, pd.kButtonRight, pd.kButtonLeft, pd.kButtonRight}, function() print("Code Complete") end)

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
    self.timerInput = pd.timer.new(750, function() self.sequenceIndex = 1 end)
    self.timerInput.repeats = true
    self:add()
end

function Tanuk_CodeSequence:update()
    local current, pressed, released = pd.getButtonState()

    if released == 0 then return end -- No button released

    if self.sequence[self.sequenceIndex] & released ~= 0 then
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
    else
        -- We reset the sequence
        self.sequenceIndex = 1
        self.timerInput:reset()
    end
end

---To be called to remove the timers
function Tanuk_CodeSequence:cleanup()
    if self.timerInput ~= nil then
        self.timerInput:remove()
        self.timerInput = nil
    end
end
