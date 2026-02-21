---@class Challenge
---@field name string
---@field label string
---@field is_victory function
---@field is_defeat function
---@field on_update function
---@field on_init function
Challenge = {}

---Creates a new challenge
---@param name string
---@param label string
---@param is_victory_fn function
---@param is_defeat_fn function
---@param on_update_fn function
---@param on_init_fn function
---@return Challenge
function Challenge:new(name, label, is_victory_fn, is_defeat_fn, on_update_fn, on_init_fn)
    local c = {}
    c.name = name
    c.label = label
    c.is_victory = is_victory_fn
    c.is_defeat = is_defeat_fn
    c.on_update = on_update_fn
    c.on_init = on_init_fn

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

function no_init()
    return function(world)
    end
end

CHALLENGES = {
    Challenge:new("casual", "clear 15 lines",
        function(world) -- victory
            return world.lines_cleared >= 15
        end,
        no_defeat(),
        no_update(),
        no_init()
    ),
    Challenge:new("marathon", "clear 150 lines",
        function(world) -- victory
            return world.lines_cleared >= 150
        end,
        no_defeat(),
        no_update(),
        no_init()
    ),
    Challenge:new("quickie", "clear 15 lines in 5 minutes",
        function(world) -- victory
            return world.lines_cleared >= 15 and world.frame_count <= 60 * 60 * 5
        end,
        function(world) -- defeat
            return world.frame_count > 60 * 60 * 5
        end,
        no_update(),
        no_init()
    ),
    Challenge:new("reverse", "use 40 pieces without clearing a line",
        function(world) -- victory
            return world.pieces_used == 40 and world.lines_cleared == 0
        end,
        function(world) -- defeat
            return world.lines_cleared > 0
        end,
        no_update(),
        no_init()
    ),
    Challenge:new("school", "reach level 5",
        function(world) -- victory
            return world.level >= 5
        end,
        no_defeat(),
        no_update(),
        no_init()
    ),
    Challenge:new("heavy g", "survive 2 minutes. blocks fall faster.",
        function(world)
            return world.frame_count >= 60 * 60 * 2
        end,
        no_defeat(),
        function(world)
            world.drop_interval_max = 5
            world.drop_interval = 5
        end,
        no_init()
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
        no_update(),
        no_init()
    ),
    Challenge:new("tight", "you only have 6 columns. clear 15 lines",
        function(world) -- victory
            return world.lines_cleared >= 15
        end,
        no_defeat(),
        function(world) -- on update
            local rows = #world.grid
            local blocked_columns = { 1, 2, 9, 10 }
            for row = 3, rows do
                for column in all(blocked_columns) do
                    if world.grid[row][column] == world.grid_spr then
                        world.grid[row][column] = flr(rnd(7)) + 1
                    end
                end
            end
        end,
        function(world) -- on_init logic (Runs ONCE)
            world.spawn_row = 3
            local rows = #world.grid
            local blocked_columns = { 1, 2, 9, 10 }
            for row = 3, rows do
                for column in all(blocked_columns) do
                    world.grid[row][column] = flr(rnd(7)) + 1
                end
            end
        end
    ),
}
