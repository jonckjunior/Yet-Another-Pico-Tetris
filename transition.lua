---@class Transition
---@field active boolean
---@field from_mode string|nil
---@field target_mode string|nil
---@field timer integer
---@field duration integer
---@field phase string  "idle" | "fade_out" | "fade_in"
local Transition = {}
Transition.__index = Transition

-- Ordered dither steps: each value is a 16-bit fillp pattern.
-- The .1 suffix (0x0.8 added) makes the "off" bits transparent,
-- so only the black pixels are drawn and the scene shows through the rest.
-- Steps go from empty → fully covered (for fade_out),
-- and are read in reverse for fade_in.
local DITHER_STEPS = {
    0x0000, -- 0/16 pixels  (transparent)
    0x8000, -- 1/16
    0x8080, -- 2/16
    0x8888, -- 4/16
    0xd555, -- 6/16 (dispersed)
    0xaaaa, -- 8/16 (checkerboard)
    0xeedd, -- 10/16
    0xeeee, -- 12/16
    0xffee, -- 14/16
    0xffff, -- 16/16 (solid black)
}
local N_STEPS = #DITHER_STEPS

function Transition:new()
    local t       = {}
    t.active      = false
    t.target_mode = nil
    t.timer       = 0
    t.duration    = 60
    t.phase       = "idle"
    setmetatable(t, self)
    return t
end

---Kick off a transition to a new mode
---@param from_mode string
---@param target_mode string
function Transition:start(from_mode, target_mode)
    --- let's fade out music too
    music(-1, 1000)
    self.active      = true
    self.from_mode   = from_mode
    self.target_mode = target_mode
    self.timer       = 0
    self.phase       = "fade_out"
end

---Returns true while input should be suppressed
function Transition:blocks_input()
    return self.active
end

function Transition:update()
    if not self.active then return end

    self.timer += 1

    if self.phase == "fade_out" and self.timer >= self.duration then
        -- screen is fully black — swap mode and begin fade in
        change_mode(self.target_mode)
        self.phase = "fade_in"
        self.timer = 0

        if self.target_mode == "playing" then
            -- music(21, 1000, 4)
        end
    elseif self.phase == "fade_in" and self.timer >= self.duration then
        -- fade complete
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
