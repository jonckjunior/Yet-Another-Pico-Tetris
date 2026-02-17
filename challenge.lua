---@class Challenge
---@field label string
---@field is_victory function
Challenge = {}

---Creates a new challenge
---@param label string
---@param is_victory_fn function
---@return Challenge
function Challenge:new(label, is_victory_fn)
    local c = {}
    c.label = label
    c.is_victory = is_victory_fn
    self.__index = self
    setmetatable(c, self)
    return c
end

CHALLENGES = {
    clear_15_lines = Challenge:new("clear 15 lines", function(world)
        return world.lines_cleared >= 15
    end),
    do_a_tspin = Challenge:new("perform a t-spin", function(world)
        return world.is_tspin
    end),
    reach_level_5 = Challenge:new("reach level 5", function(world)
        return world.level >= 5
    end),
}
