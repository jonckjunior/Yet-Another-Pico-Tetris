---@class Transition
---@field active boolean
---@field from_mode string|nil
---@field target_mode string|nil
---@field timer integer
---@field duration integer
---@field phase string  "idle" | "fade_out" | "fade_in"
local Transition = {}
Transition.__index = Transition

local DITHER_STEPS = {
    0x0000,
    0x8000,
    0x8080,
    0x8888,
    0xd555,
    0xaaaa,
    0xeedd,
    0xeeee,
    0xffee,
    0xffff,
}
local N_STEPS = #DITHER_STEPS

function Transition:new()
    local t       = {}
    t.active      = false
    t.target_mode = nil
    t.timer       = 0
    t.duration    = 30
    t.phase       = "idle"
    setmetatable(t, self)
    return t
end

---Kick off a transition to a new mode
---@param from_mode string
---@param target_mode string
function Transition:start(from_mode, target_mode)
    music(-1, 1000 * self.duration / 60)
    self.active      = true
    self.from_mode   = from_mode
    self.target_mode = target_mode
    self.timer       = 0
    self.phase       = "fade_out"
end

function Transition:blocks_input()
    return self.active
end

function Transition:update()
    if not self.active then return end

    self.timer += 1

    if self.phase == "fade_out" and self.timer >= self.duration then
        change_mode(self.target_mode)
        self.phase = "fade_in"
        self.timer = 0

        if self.target_mode == "playing" and music_flag then
            music(21, 1000 * 50 / 60, 4)
        end
        if self.target_mode == "menu" and music_flag then
            music(12, 1000 * 50 / 60, 4)
        end
    elseif self.phase == "fade_in" and self.timer >= self.duration then
        self.active = false
        self.phase  = "idle"
    end
end

function Transition:draw()
    if self.phase == "idle" then return end

    local progress = min(self.timer / self.duration, 1)

    local step_idx
    if self.phase == "fade_in" then
        step_idx = flr(progress * (N_STEPS - 1)) + 1
    else
        step_idx = N_STEPS - flr(progress * (N_STEPS - 1))
    end

    -- add 0x0.8 to make "off" bits transparent instead of drawing a second colour
    fillp(DITHER_STEPS[step_idx] + 0x0.8)
    rectfill(0, 0, 127, 127, 0)
    fillp()
end
