---@class Challenge
---@field name string
---@field label string
---@field is_victory function
Challenge = {}

---Creates a new challenge
---@param name string
---@param label string
---@param is_victory_fn function
---@return Challenge
function Challenge:new(name, label, is_victory_fn)
    local c = {}
    c.name = name
    c.label = label
    c.is_victory = is_victory_fn
    self.__index = self
    setmetatable(c, self)
    return c
end

CHALLENGES = {
    Challenge:new("casual", "clear 15 lines", function(world)
        return world.lines_cleared >= 15
    end),
    Challenge:new("marathon", "clear 150 lines", function(world)
        return world.lines_cleared >= 150
    end),
    Challenge:new("school", "reach level 5", function(world)
        return world.level >= 5
    end),
}
