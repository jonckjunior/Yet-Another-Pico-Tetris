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
            return world.lines_cleared >= 1
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
    Challenge:new("quickie", "clear 15 lines in 3 minutes",
        function(world) -- victory
            return world.lines_cleared >= 15 and world.frame_count <= 60 * 60 * 3
        end,
        function(world) -- defeat
            return world.frame_count > 60 * 60 * 3
        end,
        function(world) -- on_update - countdown timer
            world.time_remaining -= 1
        end,
        function(world)                        -- on_init
            world.time_remaining = 60 * 60 * 3 -- Start with 3 minutes
            world.time_mode = "countdown"      -- Flag for UI to display countdown
        end
    ),
    Challenge:new("reverse", "use 40 pieces without, clearing a line",
        function(world) -- victory
            return world.pieces_used == 40 and world.lines_cleared == 0
        end,
        function(world) -- defeat
            return world.lines_cleared > 0
        end,
        no_update(),
        no_init()
    ),
    Challenge:new("expert", "reach level 20",
        function(world) -- victory
            return world.level >= 20
        end,
        no_defeat(),
        no_update(),
        no_init()
    ),
    Challenge:new("heavy g", "survive 2 minutes,blocks fall faster",
        function(world)
            return world.frame_count >= 60 * 60 * 2
        end,
        no_defeat(),
        no_update(),
        function(world)
            world.drop_interval_max = 5
            world.drop_interval = 5
        end
    ),
    Challenge:new("perfect", "get a perfect clear,no pieces after clearing lines",
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
    Challenge:new("tight", "you only have 6 columns",
        nil,
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
    Challenge:new("garbage", "clear the bottom row, lines are filled with garbage",
        function(world) -- victory
            return world.cleared_bottom_row
        end,
        no_defeat(),
        no_update(),
        function(world) -- on_init logic
            -- Fill bottom 10 rows with garbage, leaving one random hole per row
            local rows = #world.grid
            local columns = #world.grid[1]

            local prev_hole = -1
            for row = rows - 9, rows do                   -- Last 10 rows (13-22)
                local hole_column = flr(rnd(columns)) + 1 -- Random column 1-10
                while hole_column == prev_hole do
                    hole_column = flr(rnd(columns)) + 1
                end
                for column = 1, columns do
                    if column ~= hole_column then
                        world.grid[row][column] = flr(rnd(7)) + 1 -- Random piece color
                    end
                end
                prev_hole = hole_column
            end
        end
    ),
    Challenge:new("rush", "clear lines to gain time,survive as long as possible",
        nil,
        function(world) -- defeat - run out of time
            return world.time_remaining <= 0
        end,
        function(world) -- on_update - countdown timer
            world.time_remaining -= 1
        end,
        function(world)                    -- on_init
            world.time_remaining = 60 * 15 -- Start with 15 seconds
            world.time_mode = "countdown"  -- Flag for UI to display countdown
        end
    ),
}

for i, c in ipairs(CHALLENGES) do c.index = i end
