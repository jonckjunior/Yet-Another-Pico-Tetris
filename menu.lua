function update_menu()
    if btnp(5) then
        change_mode("playing")
    end
end

dark_map = {
    [7] = 6,
    [6] = 5,
    [5] = 1,
    [1] = 5,
    [12] = 13,
    [13] = 1
}

function darken_pixel(x, y)
    local c = pget(x, y)
    local mapped = dark_map[c]
    if mapped then
        pset(x, y, mapped)
    else
        pset(x, y, 1)
    end
end

function bevel_box(x, y, w, h, bg, dark)
    -- background
    rect(x, y, x + w - 1, y + h - 1, 7)
    rect(x - 1, y - 1, x + w, y + h, 0)
    for dx = 0, w - 1 do
        for dy = 0, h - 1 do
            darken_pixel(x + dx, y + dy)
        end
    end
end

function draw_diagonal_lines()
    local scroll = (time() * 20) % 16
    for i = -128, 128, 8 do
        local x1 = i + scroll
        local x2 = i + 128 + scroll
        line(x1, 128, x2, 0, 1)
    end
end

function draw_menu()
    draw_diagonal_lines()
    local logo_width = 62
    local logo_height = 38

    local x = (127 - logo_width) / 2
    local y = (127 - logo_height) / 2 - 20
    local t = time()
    local offset = sin(t * 0.5) * 2 -- speed * amplitude

    circfill(x + logo_width / 2, y + offset + logo_height / 2, 30 + 1, 0)
    circfill(x + logo_width / 2, y + offset + logo_height / 2, 30, 1)

    for i = 1, 15 do
        pal(i, drk[i])
    end
    spr(16, x + 2, y + offset + 2, logo_width, logo_height)
    pal()
    spr(16, x, y + offset, logo_width, logo_height)
    local t = sin(time() * 4)
    local col = (t > 0) and 7 or 6
    -- print("\f7\^o0ffgame over", 50, 50)
    -- print("\f7\^o0ffpress x to start", 30, 76, col)

    bevel_box(40, 80, 50, 30, 13, 1)
    print("\^o1ffstart", 50, 90, col)
end
