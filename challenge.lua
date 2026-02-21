---@class Challenge
---@field name string
---@field label string
---@field is_victory function
---@field is_defeat function
---@field on_update function
Challenge = {}

---Creates a new challenge
---@param name string
---@param label string
---@param is_victory_fn function
---@param is_defeat_fn function
---@param on_update_fn function
---@return Challenge
function Challenge:new(name, label, is_victory_fn, is_defeat_fn, on_update_fn)
    local c = {}
    c.name = name
    c.label = label
    c.is_victory = is_victory_fn
    c.is_defeat = is_defeat_fn
    c.on_update = on_update_fn

    self.__index = self
    setmetatable(c, self)
    return c
end

function no_defeat()
    return function(world)
        return false
    end
end

function no_update()
    return function(world)
    end
end

CHALLENGES = {
    Challenge:new("casual", "clear 15 lines",
        function(world) -- victory
            return world.lines_cleared >= 15
        end,
        no_defeat(),
        no_update()
    ),
    Challenge:new("marathon", "clear 150 lines",
        function(world) -- victory
            return world.lines_cleared >= 150
        end,
        no_defeat(),
        no_update()
    ),
    Challenge:new("quickie", "clear 15 lines in 5 minutes",
        function(world) -- victory
            return world.lines_cleared >= 15 and world.frame_count <= 60 * 60 * 5
        end,
        function(world) -- defeat
            return world.frame_count > 60 * 60 * 5
        end,
        no_update()
    ),
    Challenge:new("reverse", "use 40 pieces without clearing a line",
        function(world) -- victory
            return world.pieces_used == 40 and world.lines_cleared == 0
        end,
        function(world) -- defeat
            return world.lines_cleared > 0
        end,
        no_update()
    ),
    Challenge:new("school", "reach level 5",
        function(world) -- victory
            return world.level >= 5
        end,
        no_defeat(),
        no_update()
    ),
    Challenge:new("heavy g", "survive 2 minutes. blocks fall faster.",
        function(world)
            return world.frame_count >= 60 * 60 * 2
        end,
        no_defeat(),
        function(world)
            world.drop_interval_max = 5
            world.drop_interval = 5
        end
    ),
    Challenge:new("perfect", "get a perfect clear (no pieces after clearing lines)",
        function(world) -- victory
            local row = #world.grid
            for column = 1, #world.grid[1] do
                if world.grid[row][column] ~= world.grid_spr then
                    return false
                end
            end
            return world.lines_cleared > 0
        end,
        no_defeat(),
        no_update()
    ),
}
