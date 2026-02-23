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

function Transition:draw()
    if self.phase == "idle" then return end

    local progress = self.timer / self.duration
    local r -- current diamond "radius" in pixels

    if self.phase == "wipe_out" then
        r = flr(progress * DIAMOND_SIZE)
    else
        r = flr((1 - progress) * DIAMOND_SIZE)
    end

    if r <= 0 then return end

    -- When r >= DIAMOND_SIZE the diamonds fully tile the screen.
    -- Just fill solid black and skip the geometry.
    if r >= DIAMOND_SIZE then
        rectfill(0, 0, 127, 127, 0)
        return
    end

    -- Draw one filled diamond (rotated square) per grid cell.
    -- A filled diamond centred at (cx, cy) with radius r is a set of
    -- horizontal scanlines: for each dy in [-r, r], draw a horizontal
    -- segment of half-width (r - |dy|).
    local half = DIAMOND_SIZE / 2
    -- grid anchors run from -half to 128+half to cover screen edges
    for cy = -half, 127 + half, DIAMOND_SIZE do
        for cx = -half, 127 + half, DIAMOND_SIZE do
            for dy = -r, r do
                local y = cy + dy
                if y >= 0 and y <= 127 then
                    local hw = r - abs(dy) -- half-width at this scanline
                    local x1 = max(cx - hw, 0)
                    local x2 = min(cx + hw, 127)
                    if x1 <= x2 then
                        line(x1, y, x2, y, 0)
                    end
                end
            end
        end
    end
end
