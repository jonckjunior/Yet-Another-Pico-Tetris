---@class Challenge
---@field name string
---@field label string
---@field is_victory function
---@field is_defeat function
Challenge = {}

---Creates a new challenge
---@param name string
---@param label string
---@param is_victory_fn function
---@param is_defeat_fn function
---@return Challenge
function Challenge:new(name, label, is_victory_fn, is_defeat_fn)
    local c = {}
    c.name = name
    c.label = label
    c.is_victory = is_victory_fn
    c.is_defeat = is_defeat_fn

    self.__index = self
    setmetatable(c, self)
    return c
end

CHALLENGES = {
    Challenge:new("casual", "clear 15 lines", function(world)
        return world.lines_cleared >= 15
    end, nil),
    Challenge:new("marathon", "clear 150 lines", function(world)
        return world.lines_cleared >= 150
    end, nil),
    Challenge:new("quickie", "clear 15 lines in 5 minutes", function(world)
        return world.lines_cleared >= 15 and world.frame_count <= 60 * 60 * 5
    end, function(world)
        return world.frame_count > 60 * 60 * 5
    end
    ),
    Challenge:new("reverse", "use 40 pieces without clearing a line", function(world)
        return world.pieces_used == 40 and world.lines_cleared == 0
    end, function(world)
        return world.lines_cleared > 0
    end
    ),
    Challenge:new("school", "reach level 5", function(world)
        return world.level >= 5
    end, nil),
    Challenge:new("heavy g", "survive 2 minutes. blocks fall faster.", function(world)
        return world.frame_count >= 60 * 60 * 2
    end, nil),
}
