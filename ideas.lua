fade_map = {
    [0] = 0,  -- Black -> Black
    [1] = 0,  -- Dark Blue -> Black
    [2] = 1,  -- Dark Purple -> Dark Blue
    [3] = 1,  -- Dark Green -> Dark Blue
    [4] = 2,  -- Brown -> Dark Purple
    [5] = 1,  -- Dark Grey -> Dark Blue
    [6] = 0,  -- Light Grey -> Indigo
    [7] = 1,  -- White -> Light Grey
    [8] = 2,  -- Red -> Dark Purple
    [9] = 4,  -- Orange -> Brown
    [10] = 9, -- Yellow -> Orange
    [11] = 3, -- Green -> Dark Green
    [12] = 1, -- Blue -> Dark Blue
    [13] = 1, -- Indigo -> Dark Blue
    [14] = 2, -- Pink -> Dark Purple
    [15] = 4, -- Peach -> Brown
    [129] = 0
}

function fade_step(percent)
    -- percent: 0 to 1
    local steps = flr(percent * 4)
    for i = 0, 15 do
        local col = i
        for s = 1, steps do
            col = fade_map[col]
        end
        pal(i, col, 1) -- Set display palette
    end
    pal(6, 0, 1)       -- Set display palette
end

---Draw cursor at given position
---@param x integer
---@param y integer
function Menu:draw_cursor(x, y)
    local height = 6
    local width = { 2, 3, 4, 5, 4, 3, 2 }
    for dy = 0, height do
        for dx = 0, width[dy + 1] - 1 do
            local c = (dx == 0 or dx == width[dy + 1] - 1) and 0 or 7
            pset(x + dx, y + dy, c)
        end
    end
end
